module ResumeTemplates
  class ImplementationValidationRunCreationService
    Result = Data.define(:template, :template_implementation, :template_validation_run, :validation_artifact, :error_message) do
      def success?
        error_message.blank? && template_validation_run.present?
      end
    end

    def initialize(template:, template_implementation:, user:, validation_type: nil, status: nil, notes: nil, validator_name: nil, metrics: nil)
      @template = template
      @template_implementation = template_implementation
      @user = user
      @validation_type = validation_type
      @status = status
      @notes = notes
      @validator_name = validator_name
      @metrics = metrics
    end

    def call
      return failure(error_message: implementation_mismatch_message) unless implementation_belongs_to_template?
      return failure(error_message: ineligible_implementation_message) if template_implementation.archived?

      created_validation_run = nil
      created_validation_artifact = nil

      ActiveRecord::Base.transaction do
        created_validation_run = template.template_validation_runs.create!(
          template_implementation: template_implementation,
          reference_artifact: reference_artifact,
          validation_type: resolved_validation_type,
          status: resolved_status,
          validator_name: resolved_validator_name,
          notes: resolved_notes,
          metrics: resolved_metrics,
          metadata: validation_metadata,
          validated_at: resolved_validated_at
        )
        created_validation_artifact = create_validation_artifact!(validation_run: created_validation_run)
      end

      success(
        template_validation_run: created_validation_run,
        validation_artifact: created_validation_artifact
      )
    rescue ActiveRecord::RecordInvalid => error
      failure(error_message: error.record.errors.full_messages.to_sentence)
    end

    private
      attr_reader :metrics, :notes, :status, :template, :template_implementation, :user, :validation_type, :validator_name

      def implementation_belongs_to_template?
        template_implementation.template_id == template.id
      end

      def reference_artifact
        template_implementation.source_artifact
      end

      def resolved_validation_type
        validation_type.presence || "manual_review"
      end

      def resolved_status
        status.presence || "pending"
      end

      def resolved_validator_name
        validator_name.presence || user&.email_address
      end

      def resolved_notes
        notes.to_s
      end

      def resolved_metrics
        (metrics || {}).deep_stringify_keys
      end

      def resolved_validated_at
        return if resolved_status == "pending"

        Time.current
      end

      def validation_metadata
        {
          "creation_mode" => "admin_validation_record",
          "created_by_user_id" => user&.id,
          "created_by_user_email" => user&.email_address,
          "template_implementation_identifier" => template_implementation.identifier,
          "source_artifact_identifier" => reference_artifact&.identifier,
          "created_at" => Time.current.iso8601
        }.compact
      end

      def create_validation_artifact!(validation_run:)
        template.template_artifacts.create!(
          artifact_type: "validation_report",
          lineage_kind: "validation",
          parent_artifact: reference_artifact,
          name: validation_artifact_name(validation_run),
          description: validation_artifact_description(validation_run),
          content: JSON.pretty_generate(validation_artifact_payload(validation_run)),
          version_label: validation_run.identifier,
          metadata: validation_artifact_metadata(validation_run)
        )
      end

      def validation_artifact_name(validation_run)
        "#{template_implementation.name} #{validation_run.validation_type.to_s.tr('_', ' ').titleize}"
      end

      def validation_artifact_description(validation_run)
        "#{template_implementation.name} #{validation_run.validation_type.to_s.tr('_', ' ')} recorded as #{validation_run.status.to_s.tr('_', ' ')}."
      end

      def validation_artifact_payload(validation_run)
        {
          validation_run_identifier: validation_run.identifier,
          validation_type: validation_run.validation_type,
          status: validation_run.status,
          validator_name: validation_run.validator_name,
          notes: validation_run.notes.presence,
          metrics: validation_run.metrics,
          metadata: validation_run.metadata
        }.compact
      end

      def validation_artifact_metadata(validation_run)
        {
          "artifact_role" => "implementation_validation_result",
          "template_validation_run_id" => validation_run.id,
          "template_validation_run_identifier" => validation_run.identifier,
          "template_implementation_id" => template_implementation.id,
          "template_implementation_identifier" => template_implementation.identifier,
          "source_artifact_identifier" => reference_artifact&.identifier,
          "validation_type" => validation_run.validation_type,
          "status" => validation_run.status,
          "validator_name" => validation_run.validator_name,
          "created_by_user_id" => user&.id,
          "created_by_user_email" => user&.email_address,
          "created_at" => Time.current.iso8601
        }.compact
      end

      def implementation_mismatch_message
        "Selected implementation does not belong to this template."
      end

      def ineligible_implementation_message
        "Archived implementations cannot record new validation runs."
      end

      def success(template_validation_run:, validation_artifact:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          template_validation_run: template_validation_run,
          validation_artifact: validation_artifact,
          error_message: nil
        )
      end

      def failure(error_message:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          template_validation_run: nil,
          validation_artifact: nil,
          error_message: error_message
        )
      end
  end
end
