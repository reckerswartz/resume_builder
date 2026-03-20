module Llm
  module Providers
    class OllamaClient < BaseClient
      def fetch_models
        response = get_json(path: "/api/tags")
        Array(response["models"]).map(&:deep_stringify_keys)
      end

      def generate_text(model:, prompt:)
        response = post_json(
          path: "/api/generate",
          body: {
            model: model.identifier,
            prompt: prompt,
            stream: false,
            format: "json",
            options: ollama_options(model)
          }
        )

        {
          content: response["response"].to_s,
          token_usage: {
            "input_tokens" => response["prompt_eval_count"],
            "output_tokens" => response["eval_count"]
          }.compact_blank,
          metadata: response.except("response")
        }
      end

      private
        def ollama_options(model)
          {}.tap do |options|
            options["temperature"] = model.temperature if model.temperature.present?
            options["num_predict"] = model.max_output_tokens if model.max_output_tokens.present?
          end
        end
    end
  end
end
