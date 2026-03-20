module ResumeBuilder
  class StepRegistry
    STEP_DEFINITIONS = [
      {
        key: "source",
        section_types: [],
        tracked: false
      },
      {
        key: "heading",
        section_types: [],
        tracked: true
      },
      {
        key: "personal_details",
        section_types: [],
        tracked: false
      },
      {
        key: "experience",
        section_types: ResumeBuilder::SectionRegistry.section_types_for_step("experience"),
        tracked: true
      },
      {
        key: "education",
        section_types: ResumeBuilder::SectionRegistry.section_types_for_step("education"),
        tracked: true
      },
      {
        key: "skills",
        section_types: ResumeBuilder::SectionRegistry.section_types_for_step("skills"),
        tracked: true
      },
      {
        key: "summary",
        section_types: [],
        tracked: true
      },
      {
        key: "finalize",
        section_types: ResumeBuilder::SectionRegistry.secondary_types,
        tracked: false
      }
    ].freeze

    class << self
      def all
        STEP_DEFINITIONS.map { |step| localized_step_definition(step) }
      end

      def keys
        STEP_DEFINITIONS.map { |step| step.fetch(:key) }
      end

      def fetch(step_key)
        step = STEP_DEFINITIONS.find { |definition| definition.fetch(:key) == step_key.to_s } || STEP_DEFINITIONS.find { |definition| definition.fetch(:key) == "heading" }
        localized_step_definition(step)
      end

      def tracked_steps
        STEP_DEFINITIONS.select { |step| step.fetch(:tracked) }.map { |step| localized_step_definition(step) }
      end

      def section_types_for(step_key)
        fetch(step_key).fetch(:section_types)
      end

      private
        def localized_step_definition(step)
          key = step.fetch(:key)

          step.merge(
            label: I18n.t("resume_builder.step_registry.steps.#{key}.label"),
            title: I18n.t("resume_builder.step_registry.steps.#{key}.title"),
            description: I18n.t("resume_builder.step_registry.steps.#{key}.description")
          )
        end
    end
  end
end
