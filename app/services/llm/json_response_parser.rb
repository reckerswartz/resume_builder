require "json"

module Llm
  class JsonResponseParser
    def array_from(response_text, key:)
      payload = object_from(response_text)
      values = payload[key.to_s] || payload[key.to_sym]
      return normalize_values(values) if values.present?

      fallback_values(response_text)
    end

    def object_from(response_text)
      payload = parse_object(response_text)
      payload.is_a?(Hash) ? payload.deep_stringify_keys : {}
    rescue JSON::ParserError
      {}
    end

    private
      def parse_object(response_text)
        JSON.parse(response_text.to_s)
      rescue JSON::ParserError
        extracted_json = response_text.to_s[/\{.*\}/m]
        raise if extracted_json.blank?

        JSON.parse(extracted_json)
      end

      def normalize_values(values)
        Array(values).filter_map do |value|
          normalized = value.to_s.squish
          normalized if normalized.present?
        end
      end

      def fallback_values(response_text)
        response_text.to_s.lines.filter_map do |line|
          normalized = line.to_s.strip.sub(/\A[-*•]\s*/, "")
          normalized if normalized.present?
        end
      end
  end
end
