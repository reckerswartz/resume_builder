module ResumesHelper
  ENTRY_FIELD_CONFIG = {
    "experience" => [
      { key: "title", label: "Role" },
      { key: "organization", label: "Organization" },
      { key: "location", label: "Location" },
      { key: "start_date", label: "Start date" },
      { key: "end_date", label: "End date" },
      { key: "summary", label: "Summary", as: :textarea },
      { key: "highlights_text", label: "Highlights", as: :textarea }
    ],
    "education" => [
      { key: "institution", label: "Institution" },
      { key: "degree", label: "Degree" },
      { key: "location", label: "Location" },
      { key: "start_date", label: "Start date" },
      { key: "end_date", label: "End date" },
      { key: "details", label: "Details", as: :textarea }
    ],
    "skills" => [
      { key: "name", label: "Skill" },
      { key: "level", label: "Level" }
    ],
    "projects" => [
      { key: "name", label: "Project" },
      { key: "role", label: "Role" },
      { key: "url", label: "URL" },
      { key: "summary", label: "Summary", as: :textarea },
      { key: "highlights_text", label: "Highlights", as: :textarea }
    ]
  }.freeze

  def template_options_for_builder
    Template.order(:name).map { |template| [template.name, template.id] }
  end

  def section_type_options_for_builder
    Section.section_types.keys.map { |section_type| [section_type.titleize, section_type] }
  end

  def entry_fields_for(section)
    ENTRY_FIELD_CONFIG.fetch(section.section_type, [])
  end

  def entry_field_value(entry, key)
    return Array(entry.content["highlights"]).join("\n") if key == "highlights_text"

    entry.content.fetch(key, "")
  end

  def entry_field_text_area?(field)
    field[:as] == :textarea
  end
end
