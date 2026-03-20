module Admin::TemplatesHelper
  include ResumesHelper

  def template_status_badge_tone(template)
    template.active? ? :success : :neutral
  end

  def template_status_label(template)
    template.active? ? "Active" : "Inactive"
  end

  def template_layout_metadata(template)
    @template_layout_metadata ||= {}
    @template_layout_metadata[template.object_id] ||= begin
      layout_config = template.normalized_layout_config
      family = layout_config.fetch("family")
      family_label = ResumeTemplates::Catalog.family_label(family)
      sidebar_section_labels = Array(layout_config["sidebar_section_types"]).map do |section_type|
        ResumeBuilder::SectionRegistry.title_for(section_type)
      end

      {
        family:,
        family_label:,
        accent_color: layout_config.fetch("accent_color"),
        column_count: layout_config.fetch("column_count"),
        column_count_label: ResumeTemplates::Catalog.column_count_label(layout_config.fetch("column_count")),
        density: layout_config.fetch("density"),
        density_label: layout_config.fetch("density").titleize,
        font_scale: layout_config.fetch("font_scale"),
        font_scale_label: layout_config.fetch("font_scale").titleize,
        theme_tone: layout_config.fetch("theme_tone"),
        theme_tone_label: ResumeTemplates::Catalog.theme_tone_label(layout_config.fetch("theme_tone")),
        supports_headshot: layout_config.fetch("supports_headshot"),
        header_style: layout_config.fetch("header_style"),
        header_style_label: layout_config.fetch("header_style").titleize,
        entry_style: layout_config.fetch("entry_style"),
        entry_style_label: layout_config.fetch("entry_style").titleize,
        skill_style: layout_config.fetch("skill_style"),
        skill_style_label: layout_config.fetch("skill_style").titleize,
        section_heading_style: layout_config.fetch("section_heading_style"),
        section_heading_style_label: layout_config.fetch("section_heading_style").titleize,
        shell_style: layout_config.fetch("shell_style"),
        shell_style_label: layout_config.fetch("shell_style").titleize,
        sidebar_position: layout_config["sidebar_position"],
        sidebar_section_labels:,
        summary: template_card_summary(
          family_label:,
          header_style: layout_config.fetch("header_style"),
          section_heading_style: layout_config.fetch("section_heading_style"),
          entry_style: layout_config.fetch("entry_style"),
          sidebar_position: layout_config["sidebar_position"],
          sidebar_section_labels:
        ),
        short_label: family_label.first(2).upcase
      }
    end
  end

  def template_layout_focus_summary(template)
    metadata = template_layout_metadata(template)
    return "Balanced single-column section flow" if metadata.fetch(:sidebar_section_labels).blank?

    "#{metadata.fetch(:sidebar_position).to_s.titleize} sidebar for #{metadata.fetch(:sidebar_section_labels).to_sentence}"
  end

  def template_headshot_metadata_label(template)
    template_layout_metadata(template).fetch(:supports_headshot) ? "Enabled" : "Disabled"
  end

  def template_headshot_metadata_description(template)
    if template_layout_metadata(template).fetch(:supports_headshot)
      "Internal-only planning flag is on. Public gallery, picker, and renderer flows still do not advertise headshot support until a truthful layout ships."
    else
      "Internal-only planning flag is off. Public gallery, picker, and renderer flows continue to omit headshot promises for this template."
    end
  end

  def template_headshot_metadata_tone(template)
    template_layout_metadata(template).fetch(:supports_headshot) ? :info : :neutral
  end

  def template_visibility_label(template)
    template.active? ? "User-visible" : "Admin-only"
  end

  def template_visibility_description(template)
    if template.active?
      "Signed-in users can choose this template in the template gallery and resume creation flow."
    else
      "Inactive templates stay available for admin review and existing resumes, but non-admin users will not see them in the gallery."
    end
  end

  def template_visibility_tone(template)
    template.active? ? :success : :neutral
  end
end
