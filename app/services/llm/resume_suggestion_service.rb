module Llm
  class ResumeSuggestionService
    Result = Data.define(:success, :content, :interactions, :error_message) do
      def success?
        success
      end
    end

    FEATURE_NAME = "resume_suggestions".freeze
    TEXT_GENERATION_ROLE = "text_generation".freeze
    TEXT_VERIFICATION_ROLE = "text_verification".freeze

    def initialize(user:, entry:)
      @entry = entry
      @json_response_parser = JsonResponseParser.new
      @user = user
    end

    def call
      return skipped_result("LLM suggestions are disabled.") unless feature_enabled?

      generation_models = assigned_models_for(TEXT_GENERATION_ROLE)
      return skipped_result("No text analysis model is enabled.") if generation_models.blank?

      generation_prompt = generation_prompt_text
      generation_executions = ParallelTextRunner.new(
        user: user,
        resume: resume,
        feature_name: FEATURE_NAME,
        role: TEXT_GENERATION_ROLE,
        prompt: generation_prompt,
        llm_models: generation_models,
        metadata: interaction_metadata
      ).call

      primary_execution = generation_executions.find(&:success?)
      return failure_result(generation_executions, "Text analysis is unavailable right now.") unless primary_execution

      generated_highlights = json_response_parser.array_from(primary_execution.response_text, key: :highlights)
      return failure_result(generation_executions, "The text analysis model did not return any highlights.") if generated_highlights.blank?

      verification_executions = verification_models.any? ? run_verification_models(generated_highlights) : []
      verifier_highlights = verification_executions.filter_map do |execution|
        next unless execution.success?

        json_response_parser.array_from(execution.response_text, key: :missing_highlights)
      end.flatten

      highlights = merged_highlights(generated_highlights, verifier_highlights)
      Result.new(
        success: true,
        content: improved_content(highlights),
        interactions: generation_executions.map(&:interaction) + verification_executions.map(&:interaction),
        error_message: nil
      )
    end

    private
      attr_reader :entry, :json_response_parser, :user

      def feature_enabled?
        PlatformSetting.current.feature_enabled?(FEATURE_NAME) && PlatformSetting.current.feature_enabled?("llm_access")
      end

      def generation_prompt_text
        <<~PROMPT.squish
          Improve the resume entry for clarity, measurable impact, and readability.
          Return valid JSON only in this shape: {"highlights":["..."]}.
          Resume entry JSON: #{entry.content.to_json}
        PROMPT
      end

      def verification_prompt_text(generated_highlights)
        <<~PROMPT.squish
          Review the generated highlights for the original resume entry.
          Return valid JSON only in this shape: {"missing_highlights":["..."]}.
          Original resume entry JSON: #{entry.content.to_json}
          Generated highlights JSON: #{generated_highlights.to_json}
        PROMPT
      end

      def assigned_models_for(role)
        LlmModelAssignment.ready_models_for(role)
      end

      def verification_models
        @verification_models ||= assigned_models_for(TEXT_VERIFICATION_ROLE)
      end

      def run_verification_models(generated_highlights)
        ParallelTextRunner.new(
          user: user,
          resume: resume,
          feature_name: FEATURE_NAME,
          role: TEXT_VERIFICATION_ROLE,
          prompt: verification_prompt_text(generated_highlights),
          llm_models: verification_models,
          metadata: interaction_metadata
        ).call
      end

      def merged_highlights(generated_highlights, verifier_highlights)
        (generated_highlights + verifier_highlights).filter_map do |highlight|
          normalized = highlight.to_s.squish
          normalized if normalized.present?
        end.uniq
      end

      def improved_content(highlights)
        updated = entry.content.deep_dup
        updated["highlights"] = highlights
        updated
      end

      def resume
        entry.section.resume
      end

      def skipped_result(message)
        interaction = resume.llm_interactions.create!(
          user: user,
          feature_name: FEATURE_NAME,
          role: TEXT_GENERATION_ROLE,
          status: :skipped,
          prompt: generation_prompt_text,
          response: message,
          token_usage: {},
          latency_ms: 0,
          metadata: interaction_metadata,
          error_message: message
        )

        Result.new(success: false, content: entry.content, interactions: [ interaction ], error_message: message)
      end

      def failure_result(executions, message)
        Result.new(
          success: false,
          content: entry.content,
          interactions: executions.map(&:interaction),
          error_message: executions.filter_map(&:error_message).first || message
        )
      end

      def interaction_metadata
        { "entry_id" => entry.id }
      end
  end
end
