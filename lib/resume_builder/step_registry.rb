module ResumeBuilder
  class StepRegistry
    STEP_DEFINITIONS = [
      {
        key: "source",
        label: "Source",
        title: "Choose how to start",
        description: "Start from scratch, paste an existing resume, or upload a source file before moving into the guided builder.",
        section_types: [],
        tracked: false
      },
      {
        key: "heading",
        label: "Heading",
        title: "Heading details",
        description: "Keep this step focused on the name, headline, and contact details employers actually need first.",
        section_types: [],
        tracked: true
      },
      {
        key: "personal_details",
        label: "Personal details",
        title: "Personal details",
        description: "Add profile links, credentials, and optional personal information only when it is relevant for the role or application.",
        section_types: [],
        tracked: false
      },
      {
        key: "experience",
        label: "Experience",
        title: "Work history",
        description: "Start with the most relevant roles and keep each entry easy to scan.",
        section_types: ResumeBuilder::SectionRegistry.section_types_for_step("experience"),
        tracked: true
      },
      {
        key: "education",
        label: "Education",
        title: "Education",
        description: "Add degrees, training, and dates only when they strengthen this resume.",
        section_types: ResumeBuilder::SectionRegistry.section_types_for_step("education"),
        tracked: true
      },
      {
        key: "skills",
        label: "Skills",
        title: "Skills",
        description: "Group the strongest skills so the preview stays easy to scan.",
        section_types: ResumeBuilder::SectionRegistry.section_types_for_step("skills"),
        tracked: true
      },
      {
        key: "summary",
        label: "Summary",
        title: "Professional summary",
        description: "Write the short narrative that links your experience and skills.",
        section_types: [],
        tracked: true
      },
      {
        key: "finalize",
        label: "Finalize",
        title: "Finalize and export",
        description: "Choose the final layout, review export actions, and manage any extra sections that sit outside the core guided flow.",
        section_types: ResumeBuilder::SectionRegistry.secondary_types,
        tracked: false
      }
    ].freeze

    class << self
      def all
        STEP_DEFINITIONS
      end

      def keys
        STEP_DEFINITIONS.map { |step| step.fetch(:key) }
      end

      def fetch(step_key)
        STEP_DEFINITIONS.find { |step| step.fetch(:key) == step_key.to_s } || STEP_DEFINITIONS.find { |step| step.fetch(:key) == "heading" }
      end

      def tracked_steps
        STEP_DEFINITIONS.select { |step| step.fetch(:tracked) }
      end

      def section_types_for(step_key)
        fetch(step_key).fetch(:section_types)
      end
    end
  end
end
