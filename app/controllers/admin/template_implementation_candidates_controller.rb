class Admin::TemplateImplementationCandidatesController < Admin::BaseController
  before_action :set_template

  def create
    authorize @template, :update?

    result = ResumeTemplates::ImplementationCandidateCreationService.new(
      template: @template,
      user: current_user,
      source_artifact_id: params[:source_artifact_id]
    ).call

    if result.success?
      redirect_to(
        admin_template_path(@template, anchor: "implementation-validation"),
        notice: implementation_candidate_notice(result)
      )
    else
      redirect_to(
        admin_template_path(@template, anchor: "artifact-review"),
        alert: result.error_message
      )
    end
  end

  private
    def set_template
      @template = policy_scope(Template).find(params[:template_id])
    end

    def implementation_candidate_notice(result)
      key = result.created? ? "admin.template_implementation_candidates_controller.candidate_created" : "admin.template_implementation_candidates_controller.candidate_reused"

      I18n.t(
        key,
        artifact_name: result.source_artifact.name,
        candidate_name: result.template_implementation.name
      )
    end
end
