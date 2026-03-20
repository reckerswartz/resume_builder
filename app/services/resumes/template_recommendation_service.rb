module Resumes
  class TemplateRecommendationService
    def initialize(resume:, template_cards:)
      @resume = resume
      @template_cards = Array(template_cards)
    end

    def call
      return [] if resume.experience_level.blank?

      recommendations = []

      early_career_template = ats_friendly_template
      if early_career_template.present? && early_career_resume?
        recommendations << build_recommendation(
          early_career_template,
          reason: I18n.t("resumes.template_recommendation_service.reasons.early_career")
        )
      end

      if resume.student_status == "student"
        student_template = education_forward_template(excluding_template_ids: recommendations.map { |recommendation| recommendation.fetch(:template_id) })

        if student_template.present?
          recommendations << build_recommendation(
            student_template,
            reason: I18n.t("resumes.template_recommendation_service.reasons.student")
          )
        end
      end

      recommendations
    end

    private
      attr_reader :resume, :template_cards

      def early_career_resume?
        %w[no_experience less_than_3_years].include?(resume.experience_level)
      end

      def ats_friendly_template
        template_cards.find do |template_card|
          template_card.fetch(:family) == "ats-minimal" ||
            (
              template_card.fetch(:density) == "compact" &&
              template_card.fetch(:shell_style) == "flat" &&
              template_card.fetch(:entry_style) == "list"
            )
        end
      end

      def education_forward_template(excluding_template_ids:)
        template_cards.reject { |template_card| excluding_template_ids.include?(template_card.fetch(:template).id) }
          .find do |template_card|
            template_card.fetch(:family) == "sidebar-accent" ||
              template_card.fetch(:sidebar_section_labels).include?("Education")
          end
      end

      def build_recommendation(template_card, reason:)
        {
          template_id: template_card.fetch(:template).id,
          badge_label: I18n.t("resumes.template_recommendation_service.badge_label"),
          reason: reason
        }
      end
  end
end
