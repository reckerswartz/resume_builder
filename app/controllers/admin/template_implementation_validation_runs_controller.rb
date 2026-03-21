class Admin::TemplateImplementationValidationRunsController < Admin::BaseController
  before_action :set_template
  before_action :set_template_implementation

  def create
    authorize @template, :update?

    result = ResumeTemplates::ImplementationValidationRunCreationService.new(
      template: @template,
      template_implementation: @template_implementation,
      user: current_user,
      validation_type: validation_run_params[:validation_type],
      status: validation_run_params[:status],
      notes: validation_run_params[:notes]
    ).call

    if result.success?
      redirect_to(
        admin_template_path(@template, anchor: "implementation-validation"),
        notice: validation_run_notice(result)
      )
    else
      redirect_to(
        admin_template_path(@template, anchor: "implementation-validation"),
        alert: result.error_message
      )
    end
  end

  private
    def set_template
      @template = policy_scope(Template).find(params[:template_id])
    end

    def set_template_implementation
      @template_implementation = @template.template_implementations.find(params[:implementation_id])
    end

    def validation_run_params
      params.fetch(:validation_run, {}).permit(:validation_type, :status, :notes)
    end

    def validation_run_notice(result)
      I18n.t(
        "admin.template_implementation_validation_runs_controller.validation_recorded",
        implementation_name: result.template_implementation.name,
        validation_type: result.template_validation_run.validation_type.to_s.tr("_", " ").titleize,
        status: result.template_validation_run.status.to_s.tr("_", " ").titleize
      )
    end
end
