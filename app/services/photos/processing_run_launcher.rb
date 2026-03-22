module Photos
  class ProcessingRunLauncher
    WORKFLOW_CONFIG = {
      "background_remove" => {
        llm_role: "vision_generation",
        job_class: "PhotoBackgroundRemovalJob",
        requires_resume: false
      },
      "generate_for_template" => {
        llm_role: "vision_generation",
        job_class: "ResumeTemplateImageGenerationJob",
        requires_resume: true
      },
      "verify_candidate" => {
        llm_role: "vision_verification",
        job_class: "PhotoVerificationJob",
        requires_resume: true
      }
    }.freeze

    Result = Data.define(:run, :success, :error_message) do
      def success?
        success
      end
    end

    def initialize(photo_profile:, photo_asset:, user:, workflow_type:, resume: nil)
      @photo_profile = photo_profile
      @photo_asset = photo_asset
      @user = user
      @workflow_type = workflow_type.to_s
      @resume = resume
    end

    def call
      config = WORKFLOW_CONFIG.fetch(workflow_type) { return missing_workflow_result }

      if config[:requires_resume] && resume.blank?
        return Result.new(run: nil, success: false, error_message: I18n.t("resumes.photo_library.controller.resume_required"))
      end

      run = photo_profile.photo_processing_runs.create!(
        workflow_type: workflow_type,
        status: :queued,
        resume: resume,
        template: resume&.template,
        input_asset_ids: [ photo_asset.id ],
        selected_model_ids: LlmModelAssignment.ready_models_for(config[:llm_role]).map(&:id)
      )

      config[:job_class].constantize.perform_later(run.id, photo_asset.id, *job_trailing_args)

      Result.new(run: run, success: true, error_message: nil)
    end

    private
      attr_reader :photo_profile, :photo_asset, :user, :workflow_type, :resume

      def job_trailing_args
        case workflow_type
        when "background_remove"
          [ user.id, resume&.id ]
        else
          [ resume&.id, user.id ]
        end
      end

      def missing_workflow_result
        Result.new(run: nil, success: false, error_message: "Unknown workflow type: #{workflow_type}")
      end
  end
end
