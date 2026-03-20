module Resumes
  class EntryContentNormalizer
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

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

      normalize_experience_dates(normalized) if section_type == "experience"
      normalized["level"] = normalized["level"].presence || "Advanced" if section_type == "skills"
      normalized
    end

    private
      attr_reader :params, :section_type

      def normalize_experience_dates(normalized)
        start_month = normalized.delete("start_month")
        start_year = normalized.delete("start_year")
        end_month = normalized.delete("end_month")
        end_year = normalized.delete("end_year")
        current_role = BOOLEAN_TYPE.cast(normalized["current_role"])
        remote = BOOLEAN_TYPE.cast(normalized["remote"])

        normalized["remote"] = remote
        normalized["current_role"] = current_role
        normalized["start_date"] = [start_month, start_year].compact_blank.join(" ")
        normalized["end_date"] = current_role ? "Current" : [end_month, end_year].compact_blank.join(" ")
      end
  end
end
