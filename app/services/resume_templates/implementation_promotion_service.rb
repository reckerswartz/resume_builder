module ResumeTemplates
  class ImplementationPromotionService
    Result = Data.define(:template, :template_implementation, :promotion_artifact, :validation_run, :error_message, :promoted) do
      def success?
        error_message.blank? && template_implementation.present?
      end

      def promoted?
        promoted
      end
    end

    def initialize(template:, template_implementation:, user:)
      @template = template
      @template_implementation = template_implementation
      @user = user
    end

    def call
      return failure(error_message: implementation_mismatch_message) unless implementation_belongs_to_template?
      return success(template_implementation: template_implementation, promotion_artifact: nil, validation_run: latest_successful_validation_run, promoted: false) if template_implementation.render_ready?
      return failure(error_message: ineligible_status_message) unless template_implementation.draft?

      successful_validation_run = latest_successful_validation_run
      return failure(error_message: missing_successful_validation_message) unless successful_validation_run.present?

      created_promotion_artifact = nil
      promoted_candidate = nil
      did_promote = false

      ActiveRecord::Base.transaction do
        template_implementation.with_lock do
          if template_implementation.validated?
            promoted_candidate = template_implementation
            next
          end

          template_implementation.update!(
            status: "validated",
            validated_at: successful_validation_run.validated_at || Time.current,
            metadata: promotion_metadata(successful_validation_run)
          )
          created_promotion_artifact = create_promotion_artifact!(validation_run: successful_validation_run)
          promoted_candidate = template_implementation
          did_promote = true
        end
      end

      success(
        template_implementation: promoted_candidate,
        promotion_artifact: created_promotion_artifact,
        validation_run: successful_validation_run,
        promoted: did_promote
      )
    rescue ActiveRecord::RecordInvalid => error
      failure(error_message: error.record.errors.full_messages.to_sentence)
    end

    private
      attr_reader :template, :template_implementation, :user

      def implementation_belongs_to_template?
        template_implementation.template_id == template.id
      end

      def latest_successful_validation_run
        @latest_successful_validation_run ||= template_implementation.template_validation_runs.successful.recent.first
      end

      def promotion_metadata(validation_run)
        template_implementation.metadata.merge(
          "promotion_mode" => "admin_validation_promotion",
          "promoted_by_user_id" => user&.id,
          "promoted_by_user_email" => user&.email_address,
          "promotion_validation_run_identifier" => validation_run.identifier,
          "promotion_validation_type" => validation_run.validation_type,
          "promotion_status" => "validated",
          "promoted_at" => Time.current.iso8601
        ).compact
      end

      def create_promotion_artifact!(validation_run:)
        template.template_artifacts.create!(
          artifact_type: "version_snapshot",
          lineage_kind: "derived",
          parent_artifact: template_implementation.source_artifact,
          name: template_implementation.name,
          description: "Validated implementation snapshot.",
          content: JSON.pretty_generate(template_implementation.effective_render_profile),
          version_label: template_implementation.identifier,
          metadata: promotion_artifact_metadata(validation_run)
        )
      end

      def promotion_artifact_metadata(validation_run)
        {
          "artifact_role" => "validated_implementation_snapshot",
          "template_implementation_id" => template_implementation.id,
          "template_implementation_identifier" => template_implementation.identifier,
          "source_artifact_identifier" => template_implementation.source_artifact&.identifier,
          "promotion_validation_run_identifier" => validation_run.identifier,
          "validation_type" => validation_run.validation_type,
          "status" => template_implementation.status,
          "promoted_by_user_id" => user&.id,
          "promoted_by_user_email" => user&.email_address,
          "created_at" => Time.current.iso8601
        }.compact
      end

      def implementation_mismatch_message
        "Selected implementation does not belong to this template."
      end

      def ineligible_status_message
        "Only draft implementations can be promoted from this flow."
      end

      def missing_successful_validation_message
        "Record a passed validation run before promoting this draft implementation."
      end

      def success(template_implementation:, promotion_artifact:, validation_run:, promoted:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          promotion_artifact: promotion_artifact,
          validation_run: validation_run,
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
          error_message: error_message,
          promoted: false
        )
      end
  end
end
