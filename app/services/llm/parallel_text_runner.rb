module Llm
  class ParallelTextRunner
    Execution = Data.define(:success, :llm_model, :response_text, :token_usage, :latency_ms, :metadata, :error_message, :interaction) do
      def success?
        success
      end
    end

    def initialize(user:, resume:, feature_name:, role:, prompt:, llm_models:, metadata: {})
      @feature_name = feature_name
      @llm_models = Array(llm_models)
      @metadata = metadata
      @prompt = prompt
      @resume = resume
      @role = role.to_s
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
      attr_reader :feature_name, :llm_models, :metadata, :prompt, :resume, :role, :user

      def execute_model(llm_model)
        started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        response = ClientFactory.build(llm_model.llm_provider).generate_text(model: llm_model, prompt: prompt)

        {
          success: true,
          llm_model: llm_model,
          response_text: response.fetch(:content, ""),
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
          token_usage: {},
          latency_ms: elapsed_time_ms(started_at),
          metadata: { "exception_class" => error.class.name },
          error_message: error.message
        }
      end

      def build_execution(attributes)
        llm_model = attributes.fetch(:llm_model)
        interaction = resume.llm_interactions.create!(
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
          metadata: interaction_metadata(llm_model, attributes.fetch(:metadata, {})),
          error_message: attributes[:error_message]
        )

        Execution.new(
          success: attributes.fetch(:success),
          llm_model: llm_model,
          response_text: attributes[:response_text],
          token_usage: attributes.fetch(:token_usage, {}),
          latency_ms: attributes[:latency_ms],
          metadata: attributes.fetch(:metadata, {}),
          error_message: attributes[:error_message],
          interaction: interaction
        )
      end

      def interaction_metadata(llm_model, metadata)
        self.metadata.merge(metadata).merge(
          "llm_provider_slug" => llm_model.llm_provider.slug,
          "llm_model_identifier" => llm_model.identifier
        )
      end

      def elapsed_time_ms(started_at)
        ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round
      end
  end
end
