module ResumeBuilder
  class EditorState
    def initialize(resume:, flow:, view_context:)
      @resume = resume
      @flow = flow
      @view_context = view_context
    end

    def steps
      @steps ||= flow.steps
    end

    def current_step
      @current_step ||= steps.find { |step| step[:current] } || steps.first
    end

    def current_step_title
      current_step.fetch(:title)
    end

    def current_step_description
      current_step.fetch(:description)
    end

    def current_step_avatar_text
      current_step.fetch(:label).first(2).upcase
    end

    def previous_step_path
      @previous_step_path ||= flow.previous_step_path
    end

    def next_step_path
      @next_step_path ||= flow.next_step_path
    end

    def next_step
      @next_step ||= steps.find { |step| step[:path] == next_step_path }
    end

    def completion_percentage
      @completion_percentage ||= flow.completion_percentage
    end

    def completed_steps_count
      @completed_steps_count ||= flow.completed_steps_count
    end

    def total_steps
      @total_steps ||= flow.total_steps
    end

    def hero_badges
      @hero_badges ||= [
        { label: primary_identity, tone: :hero },
        { label: I18n.t("resume_builder.editor_state.hero_badges.template", template: resume.template.name), tone: :hero },
        { label: I18n.t("resume_builder.editor_state.hero_badges.steps_complete", completed: completed_steps_count, total: total_steps), tone: :hero_success }
      ]
    end

    def progress_card_attributes
      {
        eyebrow: I18n.t("resume_builder.editor_state.progress_card.eyebrow"),
        title: I18n.t("resume_builder.editor_state.progress_card.title", percent: completion_percentage),
        description: I18n.t("resume_builder.editor_state.progress_card.description"),
        tone: :default,
        padding: :sm
      }
    end

    def progress_meter_style
      "width: #{completion_percentage}%"
    end

    def progress_meter_label
      "#{completion_percentage}%"
    end

    def next_step_card_attributes
      {
        eyebrow: I18n.t("resume_builder.editor_state.next_step_card.eyebrow"),
        title: next_step&.fetch(:label, nil) || I18n.t("resume_builder.editor_state.next_step_card.finalize_title"),
        description: next_step.present? ? I18n.t("resume_builder.editor_state.next_step_card.with_next_description") : I18n.t("resume_builder.editor_state.next_step_card.finalize_description"),
        tone: :subtle,
        padding: :sm
      }
    end

    def step_sections
      @step_sections ||= flow.sections_for_step(current_step.fetch(:key))
    end

    def add_section_types
      @add_section_types ||= flow.add_section_types(current_step.fetch(:key))
    end

    def step_partial
      @step_partial ||= case current_step.fetch(:key)
      when "source"
        "editor_source_step"
      when "heading"
        "editor_heading_step"
      when "personal_details"
        "editor_personal_details_step"
      when "summary"
        "editor_summary_step"
      when "finalize"
        "editor_finalize_step"
      else
        "editor_section_step"
      end
    end

    def primary_identity
      @primary_identity ||= view_context.resume_primary_identity(resume)
    end

    def go_back_path
      previous_step_path.presence || view_context.resumes_path
    end

    def go_back_link_options
      previous_step_path.present? ? {} : { data: { turbo_frame: "_top" } }
    end

    def builder_tab_items
      @builder_tab_items ||= steps.each_with_index.map do |step, index|
        {
          label: step[:label],
          path: step[:path],
          badge: index + 1,
          status: step[:current] ? I18n.t("resume_builder.editor_state.tab_status.current") : step[:completed] ? I18n.t("resume_builder.editor_state.tab_status.done") : I18n.t("resume_builder.editor_state.tab_status.open"),
          current: step[:current],
          completed: step[:completed]
        }
      end
    end

    def navigation_actions
      @navigation_actions ||= [
        {
          label: I18n.t("resume_builder.editor_state.navigation.back_to_workspace"),
          path: view_context.resumes_path,
          style: :secondary,
          options: { data: { turbo_frame: "_top" } }
        },
        {
          label: I18n.t("resume_builder.editor_state.navigation.preview"),
          path: view_context.resume_path(resume, step: current_step_key),
          style: :secondary,
          options: { data: { turbo_frame: "_top" } }
        },
        {
          label: I18n.t("resume_builder.editor_state.navigation.go_back"),
          path: go_back_path,
          style: :secondary,
          options: go_back_link_options
        },
        next_navigation_action
      ].compact
    end

    private
      attr_reader :flow, :resume, :view_context

      def current_step_key
        current_step.fetch(:key)
      end

      def next_navigation_action
        return unless next_step_path.present? && next_step.present?

        {
          label: I18n.t("resume_builder.editor_state.navigation.next", step: next_step.fetch(:label)),
          path: next_step_path,
          style: :primary,
          options: {}
        }
      end
  end
end
