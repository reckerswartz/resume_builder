require "ostruct"

module Llm
  class ResumeSuggestionService
    def initialize(user:, entry:)
      @entry = entry
      @user = user
    end

    def call
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      interaction = entry.section.resume.llm_interactions.create!(
        user: user,
        feature_name: "resume_suggestions",
        status: feature_enabled? ? :succeeded : :skipped,
        prompt: prompt_text,
        response: feature_enabled? ? suggestion_text : "LLM suggestions are disabled.",
        token_usage: feature_enabled? ? { "input_tokens" => prompt_text.split.size, "output_tokens" => suggestion_text.split.size } : {},
        latency_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round,
        metadata: { "entry_id" => entry.id },
        error_message: feature_enabled? ? nil : "Feature disabled"
      )

      OpenStruct.new(success?: feature_enabled?, interaction: interaction, content: improved_content)
    end

    private
      attr_reader :entry, :user

      def feature_enabled?
        PlatformSetting.current.feature_enabled?("resume_suggestions") && PlatformSetting.current.feature_enabled?("llm_access")
      end

      def prompt_text
        "Improve this resume bullet for clarity, measurable impact, and readability: #{entry.content.to_json}"
      end

      def suggestion_text
        highlights = Array(entry.content["highlights"])
        return entry.content["summary"].to_s if highlights.empty?

        highlights.map do |highlight|
          next highlight if highlight.match?(/\d/)

          "Delivered #{highlight.sub(/\A[a-z]/) { |match| match.upcase }}"
        end.join("\n")
      end

      def improved_content
        return entry.content unless feature_enabled?

        updated = entry.content.deep_dup
        updated["highlights"] = suggestion_text.split("\n")
        updated
      end
  end
end
