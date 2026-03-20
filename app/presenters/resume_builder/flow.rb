module ResumeBuilder
  class Flow
    def initialize(resume:, requested_step:, view_context:)
      @resume = resume
      @requested_step = requested_step
      @view_context = view_context
    end

    def current_step_key
      StepCatalog.current_step_key(requested_step)
    end

    def current_step
      StepCatalog.fetch(current_step_key)
    end

    def steps
      StepCatalog.steps.map do |step|
        step.merge(
          current: step[:key] == current_step_key,
          completed: step_completed?(step[:key]),
          path: view_context.edit_resume_path(resume, step: step[:key])
        )
      end
    end

    def previous_step_path
      current_index = steps.index { |step| step[:key] == current_step_key }
      return if current_index.blank? || current_index.zero?

      view_context.edit_resume_path(resume, step: steps[current_index - 1][:key])
    end

    def next_step_path
      current_index = steps.index { |step| step[:key] == current_step_key }
      return if current_index.blank?

      next_step = steps[current_index + 1]
      view_context.edit_resume_path(resume, step: next_step[:key]) if next_step.present?
    end

    def total_steps
      tracked_steps.size
    end

    def completed_steps_count
      tracked_steps.count { |step| step_completed?(step[:key]) }
    end

    def completion_percentage
      return 0 if tracked_steps.empty?

      ((completed_steps_count.to_f / tracked_steps.size) * 100).round
    end

    def sections_for_step(step_key = current_step_key)
      section_types = StepCatalog.section_types_for(step_key)
      return [] if section_types.blank?

      resume.ordered_sections.select { |section| section_types.include?(section.section_type) }
    end

    def add_section_types(step_key = current_step_key)
      StepCatalog.add_section_types_for(step_key)
    end

    def step_params(step = current_step_key)
      { step: step }
    end

    def step_completed?(step_key)
      step = StepCatalog.fetch(step_key)

      case step.fetch(:key)
      when "source"
        resume.source_step_completed?
      when "heading"
        resume.contact_field("full_name").present? && resume.contact_field("email").present? && resume.title.present?
      when "personal_details"
        resume.personal_details_step_completed?
      when "summary"
        resume.summary.present?
      when "finalize"
        completion_percentage == 100
      else
        step.fetch(:section_types).any? && section_complete?(step.fetch(:key))
      end
    end

    private
      attr_reader :requested_step, :resume, :view_context

      def tracked_steps
        StepCatalog.tracked_steps
      end

      def section_complete?(section_type)
        resume.ordered_sections.select { |section| section.section_type == section_type.to_s }.any? do |section|
          section.ordered_entries.any? do |entry|
            entry.content.values.any? do |value|
              Array(value).any?(&:present?)
            end
          end
        end
      end
  end
end
