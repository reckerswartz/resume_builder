module Llm
  module Providers
    class NvidiaBuildClient < BaseClient
      def fetch_models
        response = get_json(path: "/v1/models", headers: authorization_headers)
        Array(response["data"]).map(&:deep_stringify_keys)
      end

      def generate_text(model:, prompt:)
        raise StandardError, "#{provider.name} needs a valid API key reference or token." if provider.api_key.blank?

        response = post_json(
          path: "/v1/chat/completions",
          body: {
            model: model.identifier,
            messages: [
              {
                role: "system",
                content: "You are a precise resume analysis assistant. Return valid JSON only."
              },
              {
                role: "user",
                content: prompt
              }
            ],
            temperature: model.temperature,
            max_tokens: model.max_output_tokens
          },
          headers: authorization_headers
        )

        {
          content: response.dig("choices", 0, "message", "content").to_s,
          token_usage: response.fetch("usage", {}).slice("prompt_tokens", "completion_tokens", "total_tokens"),
          metadata: response.except("choices")
        }
      end

      private
        def authorization_headers
          raise StandardError, "#{provider.name} needs a valid API key reference or token." if provider.api_key.blank?

          {
            "Authorization" => "Bearer #{provider.api_key}"
          }
        end
    end
  end
end
