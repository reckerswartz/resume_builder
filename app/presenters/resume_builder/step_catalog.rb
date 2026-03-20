 module ResumeBuilder
  class StepCatalog
    class << self
      def all
        StepRegistry.all.deep_dup
      end

      def steps
        all
      end

      def fetch(step_key)
        StepRegistry.fetch(step_key).deep_dup
      end

      def current_step_key(requested_step)
        fetch(requested_step).fetch(:key)
      end

      def tracked_steps
        StepRegistry.tracked_steps.deep_dup
      end

      def section_types_for(step_key)
        StepRegistry.section_types_for(step_key).dup
      end

      def core_section_types
        tracked_steps.flat_map { |step| step.fetch(:section_types) }.uniq
      end

      def secondary_section_types
        SectionRegistry.secondary_types.dup
      end

      def add_section_types_for(step_key)
        section_types_for(step_key)
      end

      def entry_fields_for(section_type)
        SectionRegistry.fields_for(section_type)
      end
    end
  end
 end
