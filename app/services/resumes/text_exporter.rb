module Resumes
  class TextExporter
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new
    CONTACT_FIELDS = %w[full_name email phone location website linkedin].freeze

    def initialize(resume:)
      @resume = resume
    end

    def call
      lines = []
      lines << resume.title.to_s.squish
      lines << resume.headline.to_s.squish if resume.headline.present?

      contact_line = contact_line_for
      lines << contact_line if contact_line.present?

      if resume.summary.present?
        lines << ""
        lines << "SUMMARY"
        lines << resume.summary.to_s.strip
      end

      ordered_sections.each do |section|
        entry_blocks = section.ordered_entries.filter_map do |entry|
          formatted_entry_lines(section, entry)
        end
        next if entry_blocks.empty?

        lines << ""
        lines << section.title.to_s

        entry_blocks.each do |entry_lines|
          lines << ""
          lines.concat(entry_lines)
        end
      end

      [ lines.join("\n").gsub(/\n{3,}/, "\n\n").strip, "" ].join("\n")
    end

    private
      attr_reader :resume

      def contact_line_for
        CONTACT_FIELDS.filter_map do |field|
          resume.contact_field(field).to_s.squish.presence
        end.join(" | ")
      end

      def ordered_sections
        resume.sections.includes(:entries).order(position: :asc, created_at: :asc)
      end

      def formatted_entry_lines(section, entry)
        lines = case section.section_type
        when "experience"
          experience_lines(entry)
        when "education"
          education_lines(entry)
        when "skills"
          skill_lines(entry)
        when "projects"
          project_lines(entry)
        else
          generic_lines(entry)
        end

        normalized_lines = lines.map { |line| line.to_s.squish }.reject(&:blank?)
        normalized_lines.presence
      end

      def experience_lines(entry)
        content = entry.content

        [
          join_parts(content["title"], content["organization"]),
          join_meta(date_range_for(content), content["location"], remote_label(content)),
          content["summary"],
          *highlight_lines(content)
        ]
      end

      def education_lines(entry)
        content = entry.content

        [
          join_parts(content["degree"], content["institution"]),
          join_meta(date_range_for(content), content["location"]),
          content["details"]
        ]
      end

      def skill_lines(entry)
        [ join_parts(entry.content["name"], entry.content["level"]) ]
      end

      def project_lines(entry)
        content = entry.content

        [
          join_parts(content["name"], content["role"]),
          content["url"],
          content["summary"],
          *highlight_lines(content)
        ]
      end

      def generic_lines(entry)
        entry.content.values.flatten.map { |value| value.to_s.squish }.reject(&:blank?)
      end

      def highlight_lines(content)
        Array(content["highlights"]).filter_map do |highlight|
          normalized_highlight = highlight.to_s.squish
          "- #{normalized_highlight}" if normalized_highlight.present?
        end
      end

      def date_range_for(content)
        start_date = content["start_date"].to_s.squish.presence
        end_date_value = content["end_date"].to_s.squish
        current_role = BOOLEAN_TYPE.cast(content["current_role"]) || %w[Current Present].include?(end_date_value)
        end_date = current_role ? "Present" : end_date_value.presence

        join_parts(start_date, end_date)
      end

      def remote_label(content)
        BOOLEAN_TYPE.cast(content["remote"]) ? "Remote" : nil
      end

      def join_parts(*parts)
        parts.map { |part| part.to_s.squish.presence }.compact.join(" - ").presence
      end

      def join_meta(*parts)
        parts.map { |part| part.to_s.squish.presence }.compact.join(" | ").presence
      end
  end
end
