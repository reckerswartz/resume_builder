module ResumeBuilder
  class SectionRegistry
    SECTION_DEFINITIONS = {
      "experience" => {
        title: "Experience",
        builder_step: "experience",
        core: true,
        fields: [
          { key: "title", label: "Job title *" },
          { key: "organization", label: "Employer" },
          { key: "location", label: "Location" },
          { key: "remote", label: "Remote", as: :checkbox },
          { key: "start_month", label: "Start month" },
          { key: "start_year", label: "Start year" },
          { key: "end_month", label: "End month" },
          { key: "end_year", label: "End year" },
          { key: "current_role", label: "I currently work here", as: :checkbox },
          { key: "summary", label: "Summary", as: :textarea },
          { key: "highlights_text", label: "Highlights", as: :textarea }
        ],
        starter_entries: [
          {
            "title" => "Senior Product Designer",
            "organization" => "Acme Inc.",
            "location" => "Remote",
            "start_date" => "2022",
            "end_date" => "Present",
            "summary" => "Led cross-functional resume product improvements.",
            "highlights" => [
              "Improved conversion through iterative UX changes",
              "Partnered with engineering on scalable editor workflows"
            ]
          }
        ]
      },
      "education" => {
        title: "Education",
        builder_step: "education",
        core: true,
        fields: [
          { key: "institution", label: "Institution" },
          { key: "degree", label: "Degree" },
          { key: "location", label: "Location" },
          { key: "start_date", label: "Start date" },
          { key: "end_date", label: "End date" },
          { key: "details", label: "Details", as: :textarea }
        ],
        starter_entries: [
          {
            "institution" => "State University",
            "degree" => "B.S. Computer Science",
            "location" => "Boston, MA",
            "start_date" => "2016",
            "end_date" => "2020",
            "details" => "Graduated with honors."
          }
        ]
      },
      "skills" => {
        title: "Skills",
        builder_step: "skills",
        core: true,
        fields: [
          { key: "name", label: "Skill" },
          { key: "level", label: "Level" }
        ],
        starter_entries: [
          { "name" => "Ruby on Rails", "level" => "Expert" },
          { "name" => "Hotwire", "level" => "Advanced" },
          { "name" => "PostgreSQL", "level" => "Advanced" }
        ]
      },
      "projects" => {
        title: "Projects",
        builder_step: "finalize",
        core: false,
        fields: [
          { key: "name", label: "Project" },
          { key: "role", label: "Role" },
          { key: "url", label: "URL" },
          { key: "summary", label: "Summary", as: :textarea },
          { key: "highlights_text", label: "Highlights", as: :textarea }
        ],
        starter_entries: [
          {
            "name" => "Resume Builder",
            "role" => "Lead Engineer",
            "url" => "https://example.com",
            "summary" => "Built a live-editing resume platform.",
            "highlights" => [
              "Implemented Turbo-driven split-screen editing",
              "Shared rendering between preview and export"
            ]
          }
        ]
      }
    }.freeze

    class << self
      def all
        SECTION_DEFINITIONS
      end

      def types
        SECTION_DEFINITIONS.keys
      end

      def enum_values
        types.index_with(&:itself)
      end

      def fetch(section_type)
        SECTION_DEFINITIONS.fetch(section_type.to_s)
      end

      def title_for(section_type)
        SECTION_DEFINITIONS.dig(section_type.to_s, :title) || section_type.to_s.titleize
      end

      def fields_for(section_type)
        fetch(section_type).fetch(:fields).deep_dup
      end

      def section_types_for_step(step_key)
        SECTION_DEFINITIONS.filter_map do |section_type, definition|
          section_type if definition.fetch(:builder_step) == step_key.to_s
        end
      end

      def secondary_types
        SECTION_DEFINITIONS.filter_map do |section_type, definition|
          section_type unless definition.fetch(:core)
        end
      end

      def starter_sections
        SECTION_DEFINITIONS.filter_map do |section_type, definition|
          {
            section_type: section_type,
            title: definition.fetch(:title),
            entries: definition.fetch(:starter_entries).deep_dup
          }
        end
      end
    end
  end
end
