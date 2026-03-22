class TemplatesController < ApplicationController
  COLUMN_COUNT_FILTER_VALUES = ResumeTemplates::Catalog.column_count_options.map(&:last).freeze
  DENSITY_FILTER_VALUES = ResumeTemplates::Catalog.density_options.map(&:last).freeze
  SHELL_STYLE_FILTER_VALUES = ResumeTemplates::Catalog.shell_style_options.map(&:last).freeze
  THEME_TONE_FILTER_VALUES = ResumeTemplates::Catalog.theme_tone_options.map(&:last).freeze

  allow_unauthenticated_access only: %i[index show]
  before_action :resume_session, only: %i[index show]
  before_action :set_template, only: :show

  def index
    authorize Template
    @query = params[:query].to_s.strip
    @family_filter = params[:family].to_s.presence_in(ResumeTemplates::Catalog.families)
    @density_filter = params[:density].to_s.presence_in(DENSITY_FILTER_VALUES)
    @column_count_filter = params[:column_count].to_s.presence_in(COLUMN_COUNT_FILTER_VALUES)
    @theme_tone_filter = params[:theme_tone].to_s.presence_in(THEME_TONE_FILTER_VALUES)
    @shell_style_filter = params[:shell_style].to_s.presence_in(SHELL_STYLE_FILTER_VALUES)
    @sort = params[:sort].to_s.presence
    @recommendation_resume = Resume.new(intake_details: requested_resume_intake_details, settings: requested_resume_settings)

    @filter_templates = user_visible_templates.matching_query(@query)
    @templates = @filter_templates
      .with_family_filter(@family_filter)
      .with_density_filter(@density_filter)
      .with_column_count_filter(@column_count_filter)
      .with_theme_tone_filter(@theme_tone_filter)
      .with_shell_style_filter(@shell_style_filter)
  end

  def show
    authorize @template
    @recommendation_resume = Resume.new(intake_details: requested_resume_intake_details, settings: requested_resume_settings)
    @preview_resume = ResumeTemplates::PreviewResumeBuilder.new(
      template: @template,
      accent_color: requested_resume_accent_color
    ).call
  end

  private
    def set_template
      @template = user_visible_templates.find_by(id: params[:id])
      return if @template.present?

      redirect_to templates_path, alert: I18n.t("templates.controller.template_unavailable")
    end

    def requested_resume_intake_details
      raw_details = params.fetch(:resume, {}).fetch(:intake_details, {})
      raw_details = raw_details.to_unsafe_h if raw_details.respond_to?(:to_unsafe_h)

      raw_details
        .to_h
        .deep_stringify_keys
        .slice("experience_level", "student_status")
    end

    def requested_resume_settings
      raw_settings = params.fetch(:resume, {}).fetch(:settings, {})
      raw_settings = raw_settings.to_unsafe_h if raw_settings.respond_to?(:to_unsafe_h)

      raw_settings
        .to_h
        .deep_stringify_keys
        .slice("accent_color")
    end

    def requested_resume_accent_color
      requested_resume_settings["accent_color"]
    end

    def user_visible_templates
      @user_visible_templates ||= Template.user_visible.order(:name)
    end
end
