module Resumes
  class SkillsStepState
    def initialize(resume:)
      @resume = resume
    end

    def suggestions
      state = catalog_state

      {
        title: title_for(state.query),
        description: description_for(state.query),
        badge_label: badge_label,
        results_label: I18n.t("resumes.skills_step_state.results_label", count: state.results.size),
        add_button_label: I18n.t("resumes.skills_step_state.add_button_label"),
        results: state.results.map { |result| presented_result(result) }
      }
    end

    private
      attr_reader :resume

      def catalog_state
        @catalog_state ||= Resumes::SkillSuggestionCatalog.new(
          resume: resume,
          query: resume.headline.to_s
        ).call
      end

      def title_for(query)
        if query.present?
          I18n.t("resumes.skills_step_state.title_with_query", query: query)
        else
          I18n.t("resumes.skills_step_state.title_without_query")
        end
      end

      def description_for(query)
        if early_career?
          I18n.t("resumes.skills_step_state.description_early_career")
        elsif query.present?
          I18n.t("resumes.skills_step_state.description_with_query", query: query)
        else
          I18n.t("resumes.skills_step_state.description_without_query")
        end
      end

      def badge_label
        I18n.t("resumes.skills_step_state.badges.#{early_career? ? :early_career : :role_aware}")
      end

      def early_career?
        %w[no_experience less_than_3_years].include?(resume.experience_level.to_s)
      end

      def presented_result(result)
        {
          role_title: result.fetch(:role_title),
          expert_recommended: result.fetch(:expert_recommended),
          expert_badge_label: I18n.t("resumes.skills_step_state.expert_badge_label"),
          audience_badge_label: I18n.t("resumes.skills_step_state.audience_badges.#{result.fetch(:audience_key)}"),
          skills: result.fetch(:skills),
          skills_text: result.fetch(:skills).join("\n")
        }
      end
  end
end
