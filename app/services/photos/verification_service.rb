module Photos
  class VerificationService
    FEATURE_NAME = "photo_candidate_verification".freeze
    PROMPT = "Review the attached resume portrait candidate. Confirm whether it is realistic, professional, identity-consistent, tightly cropped for a resume header, and free from distracting artifacts. Return concise JSON-ready feedback.".freeze

    Result = Data.define(:success, :execution, :error_message) do
      def success?
        success
      end
    end

    def initialize(source_asset:, resume:, user:)
      @source_asset = source_asset
      @resume = resume
      @user = user
    end

    def call
      return failure(I18n.t("resumes.photo_library.verification_service.no_models")) if verification_models.blank?

      execution = Llm::ParallelVisionRunner.new(
        user: user,
        resume: resume,
        feature_name: FEATURE_NAME,
        role: "vision_verification",
        prompt: PROMPT,
        llm_models: verification_models,
        source_assets: [ source_asset ],
        metadata: {
          "resume_id" => resume.id,
          "source_asset_id" => source_asset.id,
          "workflow_type" => "verify_candidate"
        }
      ).call.find(&:success?)

      return failure(I18n.t("resumes.photo_library.verification_service.no_feedback")) if execution.blank?

      Result.new(success: true, execution: execution, error_message: nil)
    end

    private
      attr_reader :resume, :source_asset, :user

      def verification_models
        @verification_models ||= LlmModelAssignment.ready_models_for("vision_verification")
      end

      def failure(message)
        Result.new(success: false, execution: nil, error_message: message)
      end
  end
end
