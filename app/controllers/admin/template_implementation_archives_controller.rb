class Admin::TemplateImplementationArchivesController < Admin::BaseController
  before_action :set_template
  before_action :set_template_implementation

  def create
    authorize @template, :update?

    result = ResumeTemplates::ImplementationArchivalService.new(
      template: @template,
      template_implementation: @template_implementation,
      user: current_user
    ).call

    if result.success?
      redirect_to(
        admin_template_path(@template, anchor: "implementation-validation"),
        notice: archive_notice(result)
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

    def archive_notice(result)
      key = if result.archived?
        "admin.template_implementation_archives_controller.implementation_archived"
      else
        "admin.template_implementation_archives_controller.implementation_already_archived"
      end

      I18n.t(key, implementation_name: result.template_implementation.name)
    end
end
