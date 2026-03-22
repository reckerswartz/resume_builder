require "base64"

module ResumeTemplates
  class BaseComponent < ApplicationComponent
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

    attr_reader :resume, :template

    def initialize(resume:)
      @resume = resume
      @template = resume.template
    end

    def layout_config
      @layout_config ||= template.render_layout_config
    end

    def family
      layout_config.fetch("family")
    end

    def accent_color
      @accent_color ||= resume.accent_color
    end

    def accent_color_with_alpha(alpha)
      "#{accent_color}#{alpha}"
    end

    def card_shell?
      layout_config.fetch("shell_style") == "card"
    end

    def split_header?
      layout_config.fetch("header_style") == "split"
    end

    def marker_section_heading?
      layout_config.fetch("section_heading_style") == "marker"
    end

    def chip_skill_style?
      layout_config.fetch("skill_style") == "chips"
    end

    def card_entry_style?
      layout_config.fetch("entry_style") == "cards"
    end

    def font_family_class
      @font_family_class ||= ResumeTemplates::Catalog.font_family_class(resume.font_family)
    end

    def shell_classes
      [
        "mx-auto w-full max-w-3xl bg-white text-slate-900",
        font_family_class,
        density_scale.fetch(:container_padding),
        ("rounded-[2rem] shadow-sm" if card_shell?)
      ].compact.join(" ")
    end

    def header_padding_class
      density_scale.fetch(:header_padding_bottom)
    end

    def section_stack_classes
      return density_scale.fetch(:section_stack) unless explicit_section_spacing?

      [ section_spacing_scale.fetch(:stack_margin_top), section_spacing_scale.fetch(:stack_space) ].join(" ")
    end

    def section_stack_spacing_class(fallback: nil)
      return fallback unless explicit_section_spacing?

      section_spacing_scale.fetch(:stack_space)
    end

    def section_margin_top_class(fallback: nil)
      return fallback unless explicit_section_spacing?

      section_spacing_scale.fetch(:stack_margin_top)
    end

    def compact_section_stack_classes(fallback: nil)
      return fallback unless explicit_section_spacing?

      section_spacing_scale.fetch(:compact_stack_space)
    end

    def section_content_margin_top_class(fallback: nil)
      return fallback unless explicit_section_spacing?

      section_spacing_scale.fetch(:content_margin_top)
    end

    def section_heading_spacing_class
      density_scale.fetch(:section_heading_spacing)
    end

    def entry_stack_classes
      density_scale.fetch(:entry_stack)
    end

    def entry_body_spacing_class(fallback: nil)
      return fallback || density_scale.fetch(:entry_body_spacing) unless explicit_paragraph_spacing?

      paragraph_spacing_scale.fetch(:entry_body_spacing)
    end

    def summary_margin_top_class(fallback: nil)
      return fallback || density_scale.fetch(:summary_margin_top) unless explicit_paragraph_spacing?

      paragraph_spacing_scale.fetch(:summary_margin_top)
    end

    def body_leading_class(default: "leading-6")
      explicit_line_spacing? ? line_spacing_scale.fetch(:body) : default
    end

    def relaxed_body_leading_class(default: "leading-7")
      explicit_line_spacing? ? line_spacing_scale.fetch(:relaxed_body) : default
    end

    def meta_leading_class(default: "leading-6")
      explicit_line_spacing? ? line_spacing_scale.fetch(:meta) : default
    end

    def name_text_class
      typography_scale.fetch(:name)
    end

    def headline_text_class
      typography_scale.fetch(:headline)
    end

    def section_title_text_class
      typography_scale.fetch(:section_title)
    end

    def entry_title_text_class
      typography_scale.fetch(:entry_title)
    end

    def body_text_class
      typography_scale.fetch(:body)
    end

    def meta_text_class
      typography_scale.fetch(:meta)
    end

    def chip_text_class
      typography_scale.fetch(:chip)
    end

    def contact_items
      [
        [ "Email", contact_value("email") ],
        [ "Phone", contact_value("phone") ],
        [ "Location", contact_value("location") ],
        [ "Website", contact_value("website") ],
        [ "LinkedIn", contact_value("linkedin") ],
        [ "Driving licence", contact_value("driving_licence") ]
      ].reject { |_label, value| value.blank? }
    end

    def full_name
      contact_value("full_name").presence || resume.user.display_name
    end

    def supports_headshot?
      layout_config.fetch("supports_headshot")
    end

    def headshot_attached?
      supports_headshot? && resolved_headshot_attachment&.attached?
    end

    def headshot_data_url
      return unless headshot_attached?

      @headshot_data_url ||= begin
        encoded_image = Base64.strict_encode64(resolved_headshot_attachment.download)
        "data:#{resolved_headshot_attachment.blob.content_type};base64,#{encoded_image}"
      end
    end

    def headshot_alt_text
      "#{full_name} headshot"
    end

    def photo_slot_config(slot_name)
      layout_config.fetch("photo_slots", {}).fetch(slot_name.to_s, {})
    end

    def hidden_sections
      @hidden_sections ||= resume.hidden_section_types
    end

    def section_visible?(section)
      !hidden_sections.include?(section.section_type.to_s)
    end

    def visible_sections
      resume.ordered_sections.select { |section| section_visible?(section) && !empty_section?(section) }
    end

    def empty_section?(section)
      section.entries.empty?
    end

    def section_entries(section)
      section.ordered_entries
    end

    def entry_title(entry)
      value_for(entry, "title").presence || value_for(entry, "degree").presence || value_for(entry, "name")
    end

    def entry_subtitle(entry)
      [ value_for(entry, "organization"), value_for(entry, "institution"), value_for(entry, "role"), value_for(entry, "level") ].reject(&:blank?).join(" · ")
    end

    def entry_location(entry)
      value_for(entry, "location")
    end

    def entry_body_paragraphs(entry)
      [ value_for(entry, "summary"), value_for(entry, "details") ].reject(&:blank?)
    end

    def entry_highlights(entry)
      list_values_for(entry, "highlights")
    end

    def entry_url(entry)
      value_for(entry, "url")
    end

    def skill_label(entry)
      level = value_for(entry, "level")
      [ value_for(entry, "name"), ("(#{level})" if level.present?) ].compact.join(" ")
    end

    def inline_skill_summary(section)
      section_entries(section).map { |entry| skill_label(entry) }.join(" | ")
    end

    def date_range_for(entry)
      start_date = value_for(entry, "start_date")
      end_date = BOOLEAN_TYPE.cast(value_for(entry, "current_role")) ? "Current" : value_for(entry, "end_date")
      [ start_date, end_date ].reject(&:blank?).join(" - ")
    end

    def value_for(entry, key)
      entry.content.fetch(key, "")
    end

    def list_values_for(entry, key)
      Array(entry.content[key])
    end

    private
      def typography_scale
        @typography_scale ||= ResumeTemplates::Catalog.typography_scale(resume.font_scale)
      end

      def density_scale
        @density_scale ||= ResumeTemplates::Catalog.density_scale(resume.density)
      end

      def section_spacing_scale
        @section_spacing_scale ||= ResumeTemplates::Catalog.section_spacing_scale(resume.section_spacing)
      end

      def paragraph_spacing_scale
        @paragraph_spacing_scale ||= ResumeTemplates::Catalog.paragraph_spacing_scale(resume.paragraph_spacing)
      end

      def line_spacing_scale
        @line_spacing_scale ||= ResumeTemplates::Catalog.line_spacing_scale(resume.line_spacing)
      end

      def explicit_section_spacing?
        raw_setting_present?("section_spacing")
      end

      def explicit_paragraph_spacing?
        raw_setting_present?("paragraph_spacing")
      end

      def explicit_line_spacing?
        raw_setting_present?("line_spacing")
      end

      def raw_setting_present?(key)
        resume_settings[key].present?
      end

      def resume_settings
        @resume_settings ||= (resume.settings || {}).deep_stringify_keys
      end

      def contact_value(key)
        resume.contact_field(key)
      end

      def resolved_headshot_attachment
        return @resolved_headshot_attachment if defined?(@resolved_headshot_attachment)

        @resolved_headshot_attachment = if resume.selected_headshot_photo_asset&.file&.attached?
          resume.selected_headshot_photo_asset.file
        elsif resume.headshot.attached?
          resume.headshot
        end
      end
  end
end
