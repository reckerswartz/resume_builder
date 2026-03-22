module Resumes
  class SkillsStepState
    def initialize(resume:)
      @resume = resume
    end

    def section_guidance
      {
        title: section_guidance_title,
        description: section_guidance_description,
        badge: section_guidance_badge,
        helper_text: section_guidance_helper_text,
        suggestions: catalog_state.results.map { |suggestion| presented_suggestion(suggestion) }
      }
    end

    private

    attr_reader :resume

    def catalog_state
      @catalog_state ||= Resumes::SkillsSuggestionCatalog.new(
        resume: resume,
        query: resume.headline.to_s
      ).call
    end

    def early_career?
      %w[no_experience less_than_3_years].include?(resume.experience_level.to_s)
    end

    def experience_tier
      early_career? ? :early_career : :experienced
    end

    def section_guidance_title
      I18n.t("resumes.skills_step_state.section_guidance.#{experience_tier}.title")
    end

    def section_guidance_description
      I18n.t("resumes.skills_step_state.section_guidance.#{experience_tier}.description")
    end

    def section_guidance_badge
      I18n.t("resumes.skills_step_state.section_guidance.#{experience_tier}.badge")
    end

    def section_guidance_helper_text
      I18n.t("resumes.skills_step_state.section_guidance.#{experience_tier}.helper_text")
    end

    def presented_suggestion(suggestion)
      {
        category_label: suggestion.category_label,
        audience_key: suggestion.audience_key,
        audience_badge_label: I18n.t("resumes.skills_step_state.audience_badges.#{suggestion.audience_key}"),
        skills: suggestion.skills,
        strength_order: suggestion.strength_order
      }
    end
  end
end
