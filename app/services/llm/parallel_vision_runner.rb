require "base64"

module Llm
  class ParallelVisionRunner
    Execution = Data.define(:success, :llm_model, :response_text, :images, :token_usage, :latency_ms, :metadata, :error_message, :interaction) do
      def success?
        success
      end
    end

    def initialize(user:, resume:, feature_name:, role:, prompt:, llm_models:, source_assets:, metadata: {})
      @feature_name = feature_name
      @llm_models = Array(llm_models)
      @metadata = metadata
      @prompt = prompt
      @resume = resume
      @role = role.to_s
      @source_assets = Array(source_assets)
      @user = user
    end

    def call
      return [] if llm_models.blank?

      llm_models.map do |llm_model|
        Thread.new(llm_model) { |model| execute_model(model) }
      end.map(&:value).map do |attributes|
        build_execution(attributes)
      end
    end

    private
      attr_reader :feature_name, :llm_models, :metadata, :prompt, :resume, :role, :source_assets, :user

      def execute_model(llm_model)
        started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        response = if role == "vision_verification"
          ClientFactory.build(llm_model.llm_provider).verify_image_candidate(
            model: llm_model,
            prompt: prompt,
            images: prepared_images
          )
        else
          ClientFactory.build(llm_model.llm_provider).generate_image_variations(
            model: llm_model,
            prompt: prompt,
            images: prepared_images
          )
        end

        {
          success: true,
          llm_model: llm_model,
          response_text: response.fetch(:content, ""),
          images: Array(response[:images]).map { |image| image.deep_stringify_keys },
          token_usage: response.fetch(:token_usage, {}),
          latency_ms: elapsed_time_ms(started_at),
          metadata: response.fetch(:metadata, {}),
          error_message: nil
        }
      rescue StandardError => error
        {
          success: false,
          llm_model: llm_model,
          response_text: nil,
          images: [],
          token_usage: {},
          latency_ms: elapsed_time_ms(started_at),
          metadata: { "exception_class" => error.class.name },
          error_message: error.message
        }
      end

      def build_execution(attributes)
        llm_model = attributes.fetch(:llm_model)
        interaction = build_interaction(llm_model, attributes)

        Execution.new(
          success: attributes.fetch(:success),
          llm_model: llm_model,
          response_text: attributes[:response_text],
          images: attributes.fetch(:images, []),
          token_usage: attributes.fetch(:token_usage, {}),
          latency_ms: attributes[:latency_ms],
          metadata: attributes.fetch(:metadata, {}),
          error_message: attributes[:error_message],
          interaction: interaction
        )
      end

      def build_interaction(llm_model, attributes)
        return unless resume.present?

        resume.llm_interactions.create!(
          user: user,
          llm_provider: llm_model.llm_provider,
          llm_model: llm_model,
          feature_name: feature_name,
          role: role,
          status: attributes.fetch(:success) ? :succeeded : :failed,
          prompt: prompt,
          response: attributes[:response_text],
          token_usage: attributes.fetch(:token_usage, {}),
          latency_ms: attributes[:latency_ms],
          metadata: interaction_metadata(llm_model, attributes),
          error_message: attributes[:error_message]
        )
      end

      def interaction_metadata(llm_model, attributes)
        metadata.merge(attributes.fetch(:metadata, {})).merge(
          "llm_provider_slug" => llm_model.llm_provider.slug,
          "llm_model_identifier" => llm_model.identifier,
          "source_asset_ids" => source_assets.map(&:id),
          "generated_image_count" => attributes.fetch(:images, []).size
        )
      end

      def prepared_images
        @prepared_images ||= source_assets.map do |source_asset|
          {
            "data" => Base64.strict_encode64(source_asset.file.download),
            "content_type" => source_asset.content_type,
            "filename" => source_asset.display_name,
            "photo_asset_id" => source_asset.id
          }
        end
      end

      def elapsed_time_ms(started_at)
        ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round
      end
  end
end
