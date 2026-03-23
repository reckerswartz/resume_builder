module Admin
  module Templates
    class ArtifactReviewState
      include ActionView::Helpers::TextHelper

      def initialize(template:)
        @template = template
      end

      def artifact_review_counts
        @artifact_review_counts ||= {
          source_artifacts: source_artifacts.size,
          documentation_artifacts: documentation_artifacts.size,
          validation_artifacts: validation_artifacts.size,
          derived_artifacts: derived_artifacts.size,
          candidate_implementations: candidate_implementations.size,
          validation_runs: recent_validation_runs.size
        }
      end

      def artifact_review_tone
        latest_validation_status = recent_validation_runs.first&.dig(:status).to_s
        return :warning if source_artifacts.blank?
        return :neutral if current_implementation.blank? && candidate_implementations.blank?
        return :danger if latest_validation_status == "failed"
        return :success if seed_baseline[:ready]
        return :warning if seed_baseline[:missing_artifact]
        return :info if current_implementation.blank? && candidate_implementations.any?
        return :neutral if latest_validation_status.blank? || latest_validation_status == "pending" || latest_validation_status == "needs_review"

        :success
      end

      def artifact_review_title
        if source_artifacts.blank?
          I18n.t("admin.templates.show.artifact_review.summary.states.source_capture_needed")
        elsif current_implementation.blank? && candidate_implementations.blank?
          I18n.t("admin.templates.show.artifact_review.summary.states.implementation_follow_up")
        elsif current_implementation.blank? && candidate_implementations.any?
          I18n.t("admin.templates.show.artifact_review.summary.states.draft_candidate_in_progress", count: candidate_implementations.size)
        elsif seed_baseline[:missing_artifact]
          I18n.t("admin.templates.show.artifact_review.summary.states.seed_baseline_follow_up")
        elsif seed_baseline[:ready]
          I18n.t("admin.templates.show.artifact_review.summary.states.seed_baseline_ready")
        elsif artifact_review_tone == :success
          I18n.t("admin.templates.show.artifact_review.summary.states.review_ready")
        else
          I18n.t("admin.templates.show.artifact_review.summary.states.validation_follow_up")
        end
      end

      def artifact_review_detail
        [
          I18n.t("admin.templates.show.artifact_review.badges.sources", count: artifact_review_counts.fetch(:source_artifacts)),
          artifact_review_implementation_badge_label,
          I18n.t("admin.templates.show.artifact_review.badges.validation_runs", count: artifact_review_counts.fetch(:validation_runs))
        ].join(" · ")
      end

      def seed_baseline_status_label
        return I18n.t("admin.templates.show.artifact_review.seed_baseline.states.ready") if seed_baseline[:ready]
        return I18n.t("admin.templates.show.artifact_review.seed_baseline.states.missing") if seed_baseline[:missing_artifact]

        I18n.t("admin.templates.show.artifact_review.seed_baseline.states.unavailable")
      end

      def seed_baseline_detail
        return I18n.t("admin.templates.show.artifact_review.seed_baseline.descriptions.ready") if seed_baseline[:ready]
        return I18n.t("admin.templates.show.artifact_review.seed_baseline.descriptions.missing") if seed_baseline[:missing_artifact]

        I18n.t("admin.templates.show.artifact_review.seed_baseline.descriptions.unavailable")
      end

      def seed_baseline_tone
        return :success if seed_baseline[:ready]
        return :warning if seed_baseline[:missing_artifact]

        :neutral
      end

      def artifact_review_implementation_badge_label
        return I18n.t("admin.templates.show.artifact_review.badges.draft_candidates", count: candidate_implementations.size) if current_implementation.blank? && candidate_implementations.any?
        return I18n.t("admin.templates.show.artifact_review.badges.implementation_pending") if current_implementation.blank?

        I18n.t(
          "admin.templates.show.artifact_review.badges.implementation_ready",
          status: template_lifecycle_status_label(current_implementation.fetch(:status, nil))
        )
      end

      def artifact_review_implementation_badge_tone
        return :info if current_implementation.blank? && candidate_implementations.any?
        return :neutral if current_implementation.blank?

        template_implementation_status_tone(current_implementation.fetch(:status, nil))
      end

      def artifact_review_groups
        group_keys = %i[source_artifacts documentation_artifacts validation_artifacts]
        group_keys << :derived_artifacts if derived_artifacts.any?

        group_keys.map do |key|
          artifacts = send(key)

          {
            key: key,
            title: I18n.t("admin.templates.show.artifact_review.groups.#{key}.title"),
            description: I18n.t("admin.templates.show.artifact_review.groups.#{key}.description"),
            empty_title: I18n.t("admin.templates.show.artifact_review.groups.#{key}.empty_title"),
            empty_description: I18n.t("admin.templates.show.artifact_review.groups.#{key}.empty_description"),
            artifacts: artifacts,
            count_label: pluralize(artifacts.count, "artifact"),
            tone: key == :source_artifacts && artifacts.any? ? :success : :neutral
          }
        end
      end

      def current_implementation
        @current_implementation ||= package.fetch(:implementation, {})
      end

      def seed_baseline
        @seed_baseline ||= package.fetch(:seed_baseline, {})
      end

      def candidate_implementations
        @candidate_implementations ||= Array(package.fetch(:candidate_implementations, []))
      end

      def historical_implementations
        @historical_implementations ||= Array(package.fetch(:historical_implementations, []))
      end

      def recent_validation_runs
        @recent_validation_runs ||= Array(package.fetch(:validation_runs, []))
      end

      private
        attr_reader :template

        def package
          @package ||= ResumeTemplates::ArtifactPackage.new(template: template).call
        end

        def source_artifacts
          @source_artifacts ||= Array(package.fetch(:source_artifacts, []))
        end

        def documentation_artifacts
          @documentation_artifacts ||= Array(package.fetch(:documentation_artifacts, []))
        end

        def validation_artifacts
          @validation_artifacts ||= Array(package.fetch(:validation_artifacts, []))
        end

        def derived_artifacts
          @derived_artifacts ||= Array(package.fetch(:derived_artifacts, []))
        end

        def template_implementation_status_tone(status)
          case status.to_s
          when "stable", "seeded"
            :success
          when "validated"
            :info
          else
            :neutral
          end
        end

        def template_lifecycle_status_label(status)
          status.to_s.tr("_", " ").titleize
        end
      end
    end
  end
