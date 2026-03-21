module Resumes
  class EntryFieldState
    def initialize(entry:, section:)
      @entry = entry
      @section = section
    end

    attr_reader :entry, :section

    def field_value(key)
      case key
      when "highlights_text"
        Array(entry.content["highlights"]).join("\n")
      when "start_month"
        date_part(entry.content["start_date"], :month)
      when "start_year"
        date_part(entry.content["start_date"], :year)
      when "end_month"
        current_role? ? "" : date_part(entry.content["end_date"], :month)
      when "end_year"
        current_role? ? "" : date_part(entry.content["end_date"], :year)
      when "remote"
        ActiveModel::Type::Boolean.new.cast(entry.content["remote"])
      when "current_role"
        current_role?
      else
        entry.content.fetch(key, "")
      end
    end

    def field_checked?(key)
      ActiveModel::Type::Boolean.new.cast(field_value(key))
    end

    def editor_title
      fallback = I18n.t("resumes.entry_form.titles.entry_fallback", section: ResumeBuilder::SectionRegistry.title_for(section.section_type))

      case section.section_type
      when "experience"
        entry.content["title"].presence || entry.content["organization"].presence || fallback
      when "education"
        entry.content["degree"].presence || entry.content["institution"].presence || fallback
      when "skills"
        entry.content["name"].presence || fallback
      when "projects"
        entry.content["name"].presence || entry.content["role"].presence || fallback
      else
        first_present_value || fallback
      end
    end

    def editor_metadata
      case section.section_type
      when "experience"
        [ entry.content["organization"], date_range_label ].compact_blank.join(" · ").presence
      when "education"
        [ entry.content["institution"], date_range_label ].compact_blank.join(" · ").presence
      when "skills"
        entry.content["level"].presence
      when "projects"
        [ entry.content["role"], entry.content["url"] ].compact_blank.join(" · ").presence
      end
    end

    def editor_supporting_text
      case section.section_type
      when "experience", "projects"
        entry.content["summary"].presence || Array(entry.content["highlights"]).first.presence
      when "education"
        entry.content["details"].presence
      end
    end

    private
      def current_role?
        ActiveModel::Type::Boolean.new.cast(entry.content["current_role"]) || %w[Current Present].include?(entry.content["end_date"])
      end

      def date_range_label
        start_date = entry.content["start_date"].presence
        end_date = current_role? ? "Present" : entry.content["end_date"].presence

        return if start_date.blank? && end_date.blank?

        [ start_date, end_date ].compact.join(" - ")
      end

      def date_part(value, part)
        normalized_value = value.to_s.squish
        return "" if normalized_value.blank?

        components = normalized_value.split(" ", 2)
        return components.first if part == :year && components.one?
        return components.first if part == :month && components.many?
        return components.last.to_s if part == :year && components.many?

        ""
      end

      def first_present_value
        entry.content.values.flatten.map { |value| value.to_s.squish }.find(&:present?)
      end
  end
end
