module Resumes
  class EntryContentNormalizer
    def initialize(section_type:, params:)
      @section_type = section_type.to_s
      @params = params.to_h
    end

    def call
      normalized = params.deep_stringify_keys.compact_blank
      highlights_text = normalized.delete("highlights_text")

      if highlights_text.present?
        normalized["highlights"] = highlights_text.split(/\r?\n/).map(&:strip).reject(&:blank?)
      end

      normalized["level"] = normalized["level"].presence || "Advanced" if section_type == "skills"
      normalized
    end

    private
      attr_reader :params, :section_type
  end
end
