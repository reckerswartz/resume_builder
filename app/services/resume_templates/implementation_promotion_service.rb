module ResumeTemplates
  class ImplementationPromotionService
    LIFECYCLE_PROMOTIONS = {
      "draft" => "validated",
      "validated" => "stable",
      "stable" => "seeded"
    }.freeze

    LIFECYCLE_ORDER = %w[draft validated stable seeded archived].freeze

    Result = Data.define(:template, :template_implementation, :promotion_artifact, :validation_run, :target_status, :error_message, :promoted) do
      def success?
        error_message.blank? && template_implementation.present?
      end

      def promoted?
        promoted
      end
    end

    def initialize(template:, template_implementation:, user:, target_status: nil)
      @template = template
      @template_implementation = template_implementation
      @user = user
      @target_status = target_status
    end

    def call
      return failure(error_message: implementation_mismatch_message) unless implementation_belongs_to_template?
      return failure(error_message: archived_implementation_message) if template_implementation.archived?
      return success(template_implementation: template_implementation, promotion_artifact: nil, validation_run: supporting_validation_run, target_status: template_implementation.status, promoted: false) if resolved_target_status.blank?
      return success(template_implementation: template_implementation, promotion_artifact: nil, validation_run: supporting_validation_run, target_status: resolved_target_status, promoted: false) if template_implementation.status == resolved_target_status
      return failure(error_message: already_beyond_target_message) if already_beyond_target?
      return failure(error_message: ineligible_status_message) unless eligible_for_target_status?

      successful_validation_run = supporting_validation_run
      return failure(error_message: missing_successful_validation_message) if validation_required? && successful_validation_run.blank?

      created_promotion_artifact = nil
      promoted_candidate = nil
      did_promote = false
      source_status = template_implementation.status

      ActiveRecord::Base.transaction do
        template_implementation.with_lock do
          if template_implementation.status == resolved_target_status
            promoted_candidate = template_implementation
            next
          end

          template_implementation.update!(
            status: resolved_target_status,
            validated_at: updated_validated_at(successful_validation_run),
            seeded_at: updated_seeded_at,
            metadata: promotion_metadata(source_status: source_status, validation_run: successful_validation_run)
          )
          created_promotion_artifact = create_promotion_artifact!(source_status: source_status, validation_run: successful_validation_run)
          promoted_candidate = template_implementation
          did_promote = true
        end
      end

      success(
        template_implementation: promoted_candidate,
        promotion_artifact: created_promotion_artifact,
        validation_run: successful_validation_run,
        target_status: resolved_target_status,
        promoted: did_promote
      )
    rescue ActiveRecord::RecordInvalid => error
      failure(error_message: error.record.errors.full_messages.to_sentence)
    end

    private
      attr_reader :target_status, :template, :template_implementation, :user

      def implementation_belongs_to_template?
        template_implementation.template_id == template.id
      end

      def requested_target_status
        target_status.to_s.presence
      end

      def resolved_target_status
        @resolved_target_status ||= requested_target_status || LIFECYCLE_PROMOTIONS[template_implementation.status]
      end

      def supporting_validation_run
        return latest_successful_validation_run if validation_required?

        nil
      end

      def latest_successful_validation_run
        @latest_successful_validation_run ||= template_implementation.template_validation_runs.successful.recent.first
      end

      def validation_required?
        resolved_target_status == "validated"
      end

      def eligible_for_target_status?
        LIFECYCLE_PROMOTIONS[template_implementation.status] == resolved_target_status
      end

      def already_beyond_target?
        lifecycle_index(template_implementation.status) > lifecycle_index(resolved_target_status)
      end

      def lifecycle_index(status)
        LIFECYCLE_ORDER.index(status.to_s) || -1
      end

      def updated_validated_at(validation_run)
        case resolved_target_status
        when "validated"
          validation_run&.validated_at || Time.current
        else
          template_implementation.validated_at.presence || validation_run&.validated_at || Time.current
        end
      end

      def updated_seeded_at
        return template_implementation.seeded_at unless resolved_target_status == "seeded"

        template_implementation.seeded_at.presence || Time.current
      end

      def promotion_metadata(source_status:, validation_run:)
        template_implementation.metadata.merge(
          "promotion_mode" => "admin_lifecycle_promotion",
          "promotion_source_status" => source_status,
          "promotion_target_status" => resolved_target_status,
          "promoted_by_user_id" => user&.id,
          "promoted_by_user_email" => user&.email_address,
          "promotion_validation_run_identifier" => validation_run&.identifier,
          "promotion_validation_type" => validation_run&.validation_type,
          "promotion_status" => resolved_target_status,
          "promoted_at" => Time.current.iso8601
        ).compact
      end

      def create_promotion_artifact!(source_status:, validation_run:)
        template.template_artifacts.create!(
          artifact_type: promotion_artifact_type,
          lineage_kind: "derived",
          parent_artifact: template_implementation.source_artifact,
          name: template_implementation.name,
          description: promotion_artifact_description,
          content: JSON.pretty_generate(template_implementation.effective_render_profile),
          version_label: "#{template_implementation.identifier}-#{resolved_target_status}",
          metadata: promotion_artifact_metadata(source_status: source_status, validation_run: validation_run)
        )
      end

      def promotion_artifact_type
        resolved_target_status == "seeded" ? "seed_snapshot" : "version_snapshot"
      end

      def promotion_artifact_description
        case resolved_target_status
        when "stable"
          "Stable implementation snapshot."
        when "seeded"
          "Seeded implementation snapshot."
        else
          "Validated implementation snapshot."
        end
      end

      def promotion_artifact_role
        case resolved_target_status
        when "stable"
          "stable_implementation_snapshot"
        when "seeded"
          "seeded_implementation_snapshot"
        else
          "validated_implementation_snapshot"
        end
      end

      def promotion_artifact_metadata(source_status:, validation_run:)
        {
          "artifact_role" => promotion_artifact_role,
          "template_implementation_id" => template_implementation.id,
          "template_implementation_identifier" => template_implementation.identifier,
          "source_artifact_identifier" => template_implementation.source_artifact&.identifier,
          "promotion_source_status" => source_status,
          "promotion_target_status" => resolved_target_status,
          "promotion_validation_run_identifier" => validation_run&.identifier,
          "validation_type" => validation_run&.validation_type,
          "status" => template_implementation.status,
          "promoted_by_user_id" => user&.id,
          "promoted_by_user_email" => user&.email_address,
          "created_at" => Time.current.iso8601
        }.compact
      end

      def implementation_mismatch_message
        "Selected implementation does not belong to this template."
      end

      def archived_implementation_message
        "Archived implementations cannot be promoted from this flow."
      end

      def ineligible_status_message
        case resolved_target_status
        when "validated"
          "Only draft implementations can be promoted to validated from this flow."
        when "stable"
          "Only validated implementations can be promoted to stable from this flow."
        when "seeded"
          "Only stable implementations can be promoted to seeded from this flow."
        else
          "This implementation cannot be promoted from its current lifecycle state."
        end
      end

      def already_beyond_target_message
        "This implementation is already beyond the requested #{resolved_target_status.to_s.tr("_", " ")} stage."
      end

      def missing_successful_validation_message
        "Record a passed validation run before promoting this draft implementation."
      end

      def success(template_implementation:, promotion_artifact:, validation_run:, target_status:, promoted:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          promotion_artifact: promotion_artifact,
          validation_run: validation_run,
          target_status: target_status,
          error_message: nil,
          promoted: promoted
        )
      end

      def failure(error_message:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          promotion_artifact: nil,
          validation_run: nil,
          target_status: resolved_target_status,
          error_message: error_message,
          promoted: false
        )
      end
  end
end
