module Resumes
  class StartFlowState
    EXPERIENCE_STEP = "experience"
    STUDENT_STEP = "student"
    SETUP_STEP = "setup"
    EXPERIENCE_OPTION_VALUES = %w[no_experience less_than_3_years three_to_five_years five_to_ten_years ten_plus_years].freeze
    STUDENT_OPTION_VALUES = %w[student not_student].freeze

    def initialize(resume:, step: nil)
      @resume = resume
      @step = step.to_s
    end

    def current_step
      return STUDENT_STEP if step == STUDENT_STEP && selected_experience_level == "less_than_3_years"
      return SETUP_STEP if step == SETUP_STEP && selected_experience_level.present?

      EXPERIENCE_STEP
    end

    def experience_step?
      current_step == EXPERIENCE_STEP
    end

    def student_step?
      current_step == STUDENT_STEP
    end

    def setup_step?
      current_step == SETUP_STEP
    end

    def experience_options
      EXPERIENCE_OPTION_VALUES.map do |value|
        { label: I18n.t("resumes.start_flow_state.experience_options.#{value}"), value: value }
      end
    end

    def student_options
      STUDENT_OPTION_VALUES.map do |value|
        { label: I18n.t("resumes.start_flow_state.student_options.#{value}"), value: value }
      end
    end

    def selected_experience_level
      @selected_experience_level ||= resume.experience_level.to_s.presence_in(Resume::EXPERIENCE_LEVELS).to_s
    end

    def selected_experience_option
      experience_options.find { |option| option.fetch(:value) == selected_experience_level }
    end

    def selected_student_status
      resume.student_status.to_s.presence_in(Resume::STUDENT_STATUSES).to_s
    end

    def next_step_for_experience(experience_level)
      experience_level.to_s == "less_than_3_years" ? STUDENT_STEP : SETUP_STEP
    end

    def selected_template_id
      resume.template_id
    end

    private
      attr_reader :resume, :step
  end
end
