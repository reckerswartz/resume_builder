module Resumes
  class SummaryStepState
    attr_reader :resume

    def initialize(resume:, query:, view_context:)
      @resume = resume
      @query = query.to_s
      @view_context = view_context
    end

    def query
      @query.presence || suggested_query
    end

    def search_placeholder
      "Search by job title for pre-written examples"
    end

    def related_roles
      labels = [
        *catalog.related_roles(query:, experience_level: resume.experience_level, limit: 4),
        *catalog.featured_roles(experience_level: resume.experience_level, limit: 4)
      ].uniq.reject { |label| normalize(label) == normalize(query) }.first(4)

      labels.map do |label|
        {
          title: label,
          query: label
        }
      end
    end

    def results
      @results ||= catalog.search(query:, experience_level: resume.experience_level).map do |entry|
        {
          id: entry.id,
          role_title: entry.role_label,
          related_roles_text: entry.related_roles.to_sentence,
          expert_recommended: entry.expert_recommended,
          expert_badge_label: "Expert Recommended",
          experience_badge_label: experience_badge_label(entry.experience_levels),
          summary: entry.summary
        }
      end
    end

    def results_label
      count = results.size
      count == 1 ? "1 summary example" : "#{count} summary examples"
    end

    def empty_state_title
      "No summary examples match yet"
    end

    def empty_state_description
      "Try a nearby title like Product Designer or Backend Engineer, or write your own summary in the editor."
    end

    def guidance_message
      if query.present?
        "Start from the examples closest to #{query.titleize}, then tailor the language to your own experience and results."
      else
        "Choose a close-fit example, insert it into the summary field, and personalize the wording before you move to finalize."
      end
    end

    private
      def catalog
        @catalog ||= Resumes::SummarySuggestionCatalog.new
      end

      def suggested_query
        [ resume.headline, primary_experience_title ].find { |value| value.to_s.squish.present? }.to_s
      end

      def primary_experience_title
        resume.sections
          .detect { |section| section.section_type == "experience" }
          &.entries
          &.first
          &.content
          &.fetch("title", "")
          .to_s
      end

      def experience_badge_label(experience_levels)
        levels = Array(experience_levels)

        if levels.any? { |level| %w[no_experience less_than_3_years].include?(level) } && levels.none? { |level| %w[five_to_ten_years ten_plus_years].include?(level) }
          "Early career"
        elsif levels.any? { |level| %w[five_to_ten_years ten_plus_years].include?(level) }
          "Mid to senior"
        else
          "Growth stage"
        end
      end

      def normalize(value)
        value.to_s.squish.downcase
      end
  end
end
