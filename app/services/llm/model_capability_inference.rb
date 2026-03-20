module Llm
  class ModelCapabilityInference
    ENV_VAR_NAME_PATTERN = /\A[A-Z_][A-Z0-9_]*\z/.freeze
    EMBEDDING_KEYWORDS = %w[embed embedding nv-embed bge e5].freeze
    RERANKER_KEYWORDS = %w[rerank reranker].freeze
    REWARD_KEYWORDS = %w[reward judge].freeze
    TEXT_KEYWORDS = %w[chat instruct instruction completion generate code coder assistant qa question answer summarize summary].freeze
    VISION_KEYWORDS = %w[vision visual multimodal multi-modal vlm llava image video qwen-vl qwen2-vl qwen2.5-vl pixtral ovis].freeze
    VISION_MODALITIES = %w[image images vision video].freeze

    def self.display_name(identifier, fallback: nil)
      candidate = fallback.to_s.strip
      return candidate if candidate.present?

      source = identifier.to_s.split("/").last.presence || identifier.to_s
      source = source.split(":").first

      source.tr("_-", " ").squeeze(" ").split.map do |token|
        token.match?(ENV_VAR_NAME_PATTERN) ? token : token.capitalize
      end.join(" ")
    end

    def initialize(identifier:, raw_attributes: {})
      @identifier = identifier.to_s
      @raw_attributes = (raw_attributes || {}).deep_stringify_keys
    end

    def call
      {
        "model_type" => model_type,
        "supports_text" => supports_text?,
        "supports_vision" => supports_vision?,
        "input_modalities" => input_modalities,
        "output_modalities" => output_modalities
      }
    end

    private
      attr_reader :identifier, :raw_attributes

      def model_type
        return "embedding" if embedding_model?
        return "reranker" if reranker_model?
        return "reward" if reward_model?
        return "multimodal" if supports_text? && supports_vision?
        return "vision" if supports_vision?
        return "text" if supports_text?

        "unknown"
      end

      def supports_text?
        return false if embedding_model? || reranker_model? || reward_model?
        return true if text_modalities?
        return true if keyword_match?(TEXT_KEYWORDS)
        return true if supports_vision?

        searchable_text.present?
      end

      def supports_vision?
        return false if embedding_model? || reranker_model? || reward_model?

        return true if vision_modalities?

        keyword_match?(VISION_KEYWORDS)
      end

      def embedding_model?
        keyword_match?(EMBEDDING_KEYWORDS)
      end

      def reranker_model?
        keyword_match?(RERANKER_KEYWORDS)
      end

      def reward_model?
        keyword_match?(REWARD_KEYWORDS)
      end

      def text_modalities?
        (input_modalities + output_modalities).include?("text")
      end

      def vision_modalities?
        (input_modalities + output_modalities).any? { |value| VISION_MODALITIES.include?(value) }
      end

      def input_modalities
        @input_modalities ||= modality_values(
          raw_attributes["input_modalities"],
          raw_attributes.dig("modalities", "input"),
          raw_attributes.dig("capabilities", "input_modalities")
        )
      end

      def output_modalities
        @output_modalities ||= modality_values(
          raw_attributes["output_modalities"],
          raw_attributes.dig("modalities", "output"),
          raw_attributes.dig("capabilities", "output_modalities")
        )
      end

      def modality_values(*values)
        values.flatten.compact.flat_map do |value|
          Array(value).flat_map { |item| item.to_s.downcase.split(/[\s,\/]+/) }
        end.filter_map(&:presence).uniq
      end

      def keyword_match?(keywords)
        keywords.any? { |keyword| searchable_text.include?(keyword) }
      end

      def searchable_text
        @searchable_text ||= begin
          values = []
          append_value(values, identifier)
          append_value(values, raw_attributes["id"])
          append_value(values, raw_attributes["name"])
          append_value(values, raw_attributes["model"])
          append_value(values, raw_attributes["type"])
          append_value(values, raw_attributes["model_type"])
          append_value(values, raw_attributes["category"])
          append_value(values, raw_attributes["task"])
          append_value(values, raw_attributes["description"])
          append_value(values, raw_attributes["owned_by"])
          append_value(values, raw_attributes.dig("details", "family"))
          append_value(values, raw_attributes.dig("details", "families"))
          append_value(values, raw_attributes["input_modalities"])
          append_value(values, raw_attributes["output_modalities"])
          append_value(values, raw_attributes["capabilities"])
          values.join(" ").downcase
        end
      end

      def append_value(collection, value)
        case value
        when Array
          value.each { |item| append_value(collection, item) }
        when Hash
          value.each_value { |item| append_value(collection, item) }
        else
          normalized = value.to_s.strip
          collection << normalized if normalized.present?
        end
      end
  end
end
