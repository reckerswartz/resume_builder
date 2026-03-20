module ResumeTemplates
  class BaseComponent < ApplicationComponent
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

    attr_reader :resume, :template

    def initialize(resume:)
      @resume = resume
      @template = resume.template
    end

    def layout_config
      @layout_config ||= ResumeTemplates::Catalog.normalize_layout_config(template.layout_config, fallback_family: template.slug)
    end

    def family
      layout_config.fetch("family")
    end

    def accent_color
      @accent_color ||= ResumeTemplates::Catalog.normalized_accent_color(
        (resume.settings || {})["accent_color"],
        fallback: layout_config.fetch("accent_color")
      )
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

    def shell_classes
      [
        "mx-auto w-full max-w-3xl bg-white text-slate-900",
        density_scale.fetch(:container_padding),
        ("rounded-[2rem] shadow-sm" if card_shell?)
      ].compact.join(" ")
    end

    def header_padding_class
      density_scale.fetch(:header_padding_bottom)
    end

    def section_stack_classes
      density_scale.fetch(:section_stack)
    end

    def section_heading_spacing_class
      density_scale.fetch(:section_heading_spacing)
    end

    def entry_stack_classes
      density_scale.fetch(:entry_stack)
    end

    def entry_body_spacing_class
      density_scale.fetch(:entry_body_spacing)
    end

    def summary_margin_top_class
      density_scale.fetch(:summary_margin_top)
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
        ["Email", contact_value("email")],
        ["Phone", contact_value("phone")],
        ["Location", contact_value("location")],
        ["Website", contact_value("website")],
        ["LinkedIn", contact_value("linkedin")],
        ["Driving licence", contact_value("driving_licence")]
      ].reject { |_label, value| value.blank? }
    end

    def full_name
      contact_value("full_name").presence || resume.user.display_name
    end

    def section_entries(section)
      section.ordered_entries
    end

    def entry_title(entry)
      value_for(entry, "title").presence || value_for(entry, "degree").presence || value_for(entry, "name")
    end

    def entry_subtitle(entry)
      [ value_for(entry, "organization"), value_for(entry, "institution"), value_for(entry, "role") ].reject(&:blank?).join(" · ")
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
      section_entries(section).map { |entry| skill_label(entry) }.join(" • ")
    end

    def date_range_for(entry)
      start_date = value_for(entry, "start_date")
      end_date = BOOLEAN_TYPE.cast(value_for(entry, "current_role")) ? "Current" : value_for(entry, "end_date")
      [start_date, end_date].reject(&:blank?).join(" - ")
    end

    def value_for(entry, key)
      entry.content.fetch(key, "")
    end

    def list_values_for(entry, key)
      Array(entry.content[key])
    end

    private
      def typography_scale
        @typography_scale ||= ResumeTemplates::Catalog.typography_scale(layout_config.fetch("font_scale"))
      end

      def density_scale
        @density_scale ||= ResumeTemplates::Catalog.density_scale(layout_config.fetch("density"))
      end

      def contact_value(key)
        resume.contact_field(key)
      end
  end
end
