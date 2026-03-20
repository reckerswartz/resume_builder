module Resumes
  class StartFlowState
    EXPERIENCE_STEP = "experience"
    STUDENT_STEP = "student"
    SETUP_STEP = "setup"
    EXPERIENCE_OPTIONS = [
      { label: "No Experience", value: "no_experience" },
      { label: "Less than 3 years", value: "less_than_3_years" },
      { label: "3-5 Years", value: "three_to_five_years" },
      { label: "5-10 Years", value: "five_to_ten_years" },
      { label: "10+ Years", value: "ten_plus_years" }
    ].freeze
    STUDENT_OPTIONS = [
      { label: "Yes", value: "student" },
      { label: "No", value: "not_student" }
    ].freeze

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
      EXPERIENCE_OPTIONS
    end

    def student_options
      STUDENT_OPTIONS
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
