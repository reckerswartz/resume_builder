module ResumeBuilder
  class SectionRegistry
    SECTION_DEFINITIONS = {
      "experience" => {
        builder_step: "experience",
        core: true,
        fields: [
          { key: "title" },
          { key: "organization" },
          { key: "location" },
          { key: "remote", as: :checkbox },
          { key: "start_month" },
          { key: "start_year" },
          { key: "end_month" },
          { key: "end_year" },
          { key: "current_role", as: :checkbox },
          { key: "summary", as: :textarea },
          { key: "highlights_text", as: :textarea }
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
        builder_step: "education",
        core: true,
        fields: [
          { key: "institution" },
          { key: "degree" },
          { key: "location" },
          { key: "start_date" },
          { key: "end_date" },
          { key: "details", as: :textarea }
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
        builder_step: "skills",
        core: true,
        fields: [
          { key: "name" },
          { key: "level" }
        ],
        starter_entries: [
          { "name" => "Ruby on Rails", "level" => "Expert" },
          { "name" => "Hotwire", "level" => "Advanced" },
          { "name" => "PostgreSQL", "level" => "Advanced" }
        ]
      },
      "projects" => {
        builder_step: "finalize",
        core: false,
        fields: [
          { key: "name" },
          { key: "role" },
          { key: "url" },
          { key: "summary", as: :textarea },
          { key: "highlights_text", as: :textarea }
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
      },
      "certifications" => {
        builder_step: "finalize",
        core: false,
        fields: [
          { key: "name" },
          { key: "organization" },
          { key: "start_date" },
          { key: "details", as: :textarea }
        ],
        starter_entries: [
          {
            "name" => "AWS Solutions Architect",
            "organization" => "Amazon Web Services",
            "start_date" => "2023",
            "details" => "Cloud architecture design and deployment."
          }
        ]
      },
      "languages" => {
        builder_step: "finalize",
        core: false,
        fields: [
          { key: "name" },
          { key: "level" }
        ],
        starter_entries: [
          { "name" => "English", "level" => "Native" },
          { "name" => "Spanish", "level" => "Conversational" }
        ]
      }
    }.freeze

    class << self
      def all
        SECTION_DEFINITIONS.each_with_object({}) do |(section_type, definition), localized_definitions|
          localized_definitions[section_type] = localized_definition(section_type, definition)
        end
      end

      def types
        SECTION_DEFINITIONS.keys
      end

      def enum_values
        types.index_with(&:itself)
      end

      def fetch(section_type)
        key = section_type.to_s
        localized_definition(key, SECTION_DEFINITIONS.fetch(key))
      end

      def title_for(section_type)
        fetch(section_type).fetch(:title)
      end

      def singular_title_for(section_type)
        fetch(section_type).fetch(:singular_title)
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
          localized_section = localized_definition(section_type, definition)

          {
            section_type: section_type,
            title: localized_section.fetch(:title),
            entries: localized_section.fetch(:starter_entries).deep_dup
          }
        end
      end

      private
        def localized_definition(section_type, definition)
          definition.merge(
            title: localized_title(section_type),
            singular_title: localized_singular_title(section_type),
            fields: definition.fetch(:fields).map do |field|
              field.merge(label: I18n.t("resume_builder.section_registry.sections.#{section_type}.fields.#{field.fetch(:key)}"))
            end,
            starter_entries: localized_starter_entries(section_type, definition)
          )
        end

        def localized_title(section_type)
          I18n.t("resume_builder.section_registry.sections.#{section_type}.title")
        end

        def localized_singular_title(section_type)
          I18n.t(
            "resume_builder.section_registry.sections.#{section_type}.singular_title",
            default: localized_title(section_type).to_s.singularize
          )
        end

        def localized_starter_entries(section_type, definition)
          entries = if I18n.exists?(starter_entries_key(section_type))
            I18n.t(starter_entries_key(section_type))
          else
            definition.fetch(:starter_entries)
          end

          Array(entries).map do |entry|
            entry.is_a?(Hash) ? entry.deep_stringify_keys : entry
          end
        end

        def starter_entries_key(section_type)
          "resume_builder.section_registry.sections.#{section_type}.starter_entries"
        end
    end
  end
end
