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
      I18n.t("resumes.summary_step_state.search_placeholder")
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
          expert_badge_label: I18n.t("resumes.summary_step_state.expert_badge_label"),
          experience_badge_label: experience_badge_label(entry.experience_levels),
          summary: entry.summary
        }
      end
    end

    def results_label
      I18n.t("resumes.summary_step_state.results_label", count: results.size)
    end

    def empty_state_title
      I18n.t("resumes.summary_step_state.empty_state_title")
    end

    def empty_state_description
      I18n.t("resumes.summary_step_state.empty_state_description")
    end

    def guidance_message
      if query.present?
        I18n.t("resumes.summary_step_state.guidance.with_query", query: query.titleize)
      else
        I18n.t("resumes.summary_step_state.guidance.without_query")
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
          I18n.t("resumes.summary_step_state.experience_badges.early_career")
        elsif levels.any? { |level| %w[five_to_ten_years ten_plus_years].include?(level) }
          I18n.t("resumes.summary_step_state.experience_badges.mid_to_senior")
        else
          I18n.t("resumes.summary_step_state.experience_badges.growth_stage")
        end
      end

      def normalize(value)
        value.to_s.squish.downcase
      end
  end
end
