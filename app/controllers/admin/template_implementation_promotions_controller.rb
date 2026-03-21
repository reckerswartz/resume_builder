class Admin::TemplateImplementationPromotionsController < Admin::BaseController
  before_action :set_template
  before_action :set_template_implementation

  def create
    authorize @template, :update?

    result = ResumeTemplates::ImplementationPromotionService.new(
      template: @template,
      template_implementation: @template_implementation,
      user: current_user
    ).call

    if result.success?
      redirect_to(
        admin_template_path(@template, anchor: "implementation-validation"),
        notice: promotion_notice(result)
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

    def promotion_notice(result)
      key = result.promoted? ? "admin.template_implementation_promotions_controller.implementation_promoted" : "admin.template_implementation_promotions_controller.implementation_already_promoted"

      I18n.t(
        key,
        implementation_name: result.template_implementation.name
      )
    end
end
