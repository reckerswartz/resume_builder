module Photos
  class GenerationOrchestrator
    FEATURE_NAME = "resume_image_generation".freeze

    Result = Data.define(:success, :executions, :assets, :error_message, :prompt_text) do
      def success?
        success
      end
    end

    def initialize(photo_profile:, source_asset:, resume:, template:, user:)
      @photo_profile = photo_profile
      @source_asset = source_asset
      @resume = resume
      @template = template
      @user = user
    end

    def call
      return failure(I18n.t("resumes.photo_library.generation_orchestrator.no_models")) if generation_models.blank?

      executions = Llm::ParallelVisionRunner.new(
        user: user,
        resume: resume,
        feature_name: FEATURE_NAME,
        role: "vision_generation",
        prompt: prompt_text,
        llm_models: generation_models,
        source_assets: [ source_asset ],
        metadata: {
          "photo_profile_id" => photo_profile.id,
          "template_id" => template.id,
          "source_asset_id" => source_asset.id
        }
      ).call

      generated_assets = persist_assets(executions)
      return failure(compiled_error_message(executions), executions:, prompt_text:) if generated_assets.blank?

      Result.new(
        success: true,
        executions: executions,
        assets: generated_assets,
        error_message: nil,
        prompt_text: prompt_text
      )
    end

    private
      attr_reader :photo_profile, :resume, :source_asset, :template, :user

      def generation_models
        @generation_models ||= LlmModelAssignment.ready_models_for("vision_generation")
      end

      def prompt_text
        @prompt_text ||= Photos::TemplatePromptBuilder.new(
          resume: resume,
          template: template,
          source_asset: source_asset
        ).call
      end

      def persist_assets(executions)
        executions.filter_map do |execution|
          next unless execution.success?

          execution.images.filter_map do |image_payload|
            image_data = image_payload["data"].presence || image_payload["base64"].presence
            next if image_data.blank?

            extension = image_extension(image_payload["content_type"])
            filename = image_payload["filename"].presence || generated_filename(execution.llm_model, extension)
            metadata = image_payload.except("data", "base64").merge(
              "source_asset_id" => source_asset.id,
              "llm_model_id" => execution.llm_model.id,
              "llm_provider_id" => execution.llm_model.llm_provider_id,
              "processing_step" => "generated",
              "generated_at" => Time.current.iso8601
            )

            Photos::TempfileManager.with_decoded_base64(image_data, basename: "generated-photo-#{source_asset.id}", extension: extension) do |tempfile|
              Photos::AssetBuilder.new(
                photo_profile: photo_profile,
                source_asset: source_asset,
                asset_kind: :generated,
                file_io: tempfile,
                filename: filename,
                content_type: image_payload["content_type"].presence || "image/png",
                metadata: metadata,
                status: :ready
              ).call
            end
          end
        end.flatten.compact
      end

      def compiled_error_message(executions)
        executions.filter_map(&:error_message).presence&.to_sentence || I18n.t("resumes.photo_library.generation_orchestrator.no_generated_image")
      end

      def failure(message, executions: [], prompt_text: nil)
        Result.new(
          success: false,
          executions: executions,
          assets: [],
          error_message: message,
          prompt_text: prompt_text
        )
      end

      def image_extension(content_type)
        case content_type.to_s
        when "image/jpeg"
          ".jpg"
        when "image/webp"
          ".webp"
        else
          ".png"
        end
      end

      def generated_filename(llm_model, extension)
        "#{File.basename(source_asset.display_name, ".*")}-#{llm_model.identifier.parameterize}#{extension}"
      end
  end
end
