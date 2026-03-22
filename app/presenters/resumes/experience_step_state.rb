module Resumes
  class ExperienceStepState
    def initialize(resume:)
      @resume = resume
    end

    def suggestions_for(entry)
      query = query_for(entry)
      state = catalog_state_for(entry)

      {
        title: title_for(query),
        description: description_for(query),
        badge_label: badge_label,
        results_label: I18n.t("resumes.experience_step_state.results_label", count: state.results.size),
        insert_button_label: I18n.t("resumes.experience_step_state.insert_button_label"),
        results: state.results.map { |result| presented_result(result) }
      }
    end

    private
      attr_reader :resume

      def catalog_state_for(entry)
        @catalog_states ||= {}
        state_key = [ entry_content(entry)["title"].to_s, resume.headline.to_s, resume.experience_level.to_s, resume.student_status.to_s ]

        @catalog_states[state_key] ||= Resumes::ExperienceSuggestionCatalog.new(
          resume: resume,
          query: query_for(entry)
        ).call
      end

      def query_for(entry)
        [ entry_content(entry)["title"], resume.headline ].find { |value| value.to_s.squish.present? }.to_s
      end

      def entry_content(entry)
        entry.content.is_a?(Hash) ? entry.content : {}
      end

      def title_for(query)
        if query.present?
          I18n.t("resumes.experience_step_state.title_with_query", query: query)
        else
          I18n.t("resumes.experience_step_state.title_without_query")
        end
      end

      def description_for(query)
        if early_career?
          I18n.t("resumes.experience_step_state.description_early_career")
        elsif query.present?
          I18n.t("resumes.experience_step_state.description_with_query", query: query)
        else
          I18n.t("resumes.experience_step_state.description_without_query")
        end
      end

      def badge_label
        I18n.t("resumes.experience_step_state.badges.#{early_career? ? :early_career : :role_aware}")
      end

      def early_career?
        %w[no_experience less_than_3_years].include?(resume.experience_level.to_s)
      end

      def presented_result(result)
        {
          role_title: result.fetch(:role_title),
          expert_recommended: result.fetch(:expert_recommended),
          expert_badge_label: I18n.t("resumes.experience_step_state.expert_badge_label"),
          audience_badge_label: I18n.t("resumes.experience_step_state.audience_badges.#{result.fetch(:audience_key)}"),
          highlights: result.fetch(:highlights),
          highlights_text: result.fetch(:highlights).join("\n")
        }
      end
  end
end
