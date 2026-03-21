module Photos
  class BackgroundRemovalService
    FEATURE_NAME = "photo_background_removal".freeze
    PROMPT = "Remove the background from the attached portrait, keep the same person and framing, preserve facial detail, and return a clean transparent or studio-neutral output suitable for a professional resume headshot.".freeze

    Result = Data.define(:success, :execution, :asset, :error_message) do
      def success?
        success
      end
    end

    def initialize(photo_profile:, source_asset:, user:, resume: nil)
      @photo_profile = photo_profile
      @source_asset = source_asset
      @resume = resume
      @user = user
    end

    def call
      return failure(I18n.t("resumes.photo_library.background_removal_service.no_models")) if generation_models.blank?

      execution = Llm::ParallelVisionRunner.new(
        user: user,
        resume: resume,
        feature_name: FEATURE_NAME,
        role: "vision_generation",
        prompt: PROMPT,
        llm_models: generation_models,
        source_assets: [ source_asset ],
        metadata: {
          "photo_profile_id" => photo_profile.id,
          "source_asset_id" => source_asset.id,
          "workflow_type" => "background_remove"
        }
      ).call.find(&:success?)

      return failure(I18n.t("resumes.photo_library.background_removal_service.no_reusable_image")) if execution.blank? || execution.images.blank?

      image_payload = execution.images.first
      image_data = image_payload["data"].presence || image_payload["base64"].presence
      return failure(I18n.t("resumes.photo_library.background_removal_service.no_image_data")) if image_data.blank?

      asset = persist_asset(execution:, image_payload:, image_data:)
      Result.new(success: true, execution: execution, asset: asset, error_message: nil)
    end

    private
      attr_reader :photo_profile, :resume, :source_asset, :user

      def generation_models
        @generation_models ||= LlmModelAssignment.ready_models_for("vision_generation")
      end

      def persist_asset(execution:, image_payload:, image_data:)
        content_type = image_payload["content_type"].presence || "image/png"
        extension = content_type == "image/jpeg" ? ".jpg" : ".png"

        Photos::TempfileManager.with_decoded_base64(image_data, basename: "background-removed-#{source_asset.id}", extension: extension) do |tempfile|
          Photos::AssetBuilder.new(
            photo_profile: photo_profile,
            source_asset: source_asset,
            asset_kind: :cutout,
            file_io: tempfile,
            filename: "#{File.basename(source_asset.display_name, ".*")}-cutout#{extension}",
            content_type: content_type,
            metadata: image_payload.except("data", "base64").merge(
              "source_asset_id" => source_asset.id,
              "llm_model_id" => execution.llm_model.id,
              "llm_provider_id" => execution.llm_model.llm_provider_id,
              "processing_step" => "background_remove",
              "background_removed_at" => Time.current.iso8601
            ),
            status: :ready
          ).call
        end
      end

      def failure(message)
        Result.new(success: false, execution: nil, asset: nil, error_message: message)
      end
  end
end
