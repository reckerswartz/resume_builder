module ResumeTemplates
  class ArtifactPackage
    def initialize(template:, implementation: nil)
      @template = template
      @implementation = implementation
    end

    def call
      {
        template: template_payload,
        implementation: implementation_payload,
        candidate_implementations: candidate_implementations_payload,
        source_artifacts: source_artifacts_payload,
        derived_artifacts: derived_artifacts_payload,
        documentation_artifacts: documentation_artifacts_payload,
        validation_artifacts: validation_artifacts_payload,
        validation_runs: validation_runs_payload
      }
    end

    private
      attr_reader :template, :implementation

      def selected_implementation
        @selected_implementation ||= implementation || template.current_implementation
      end

      def template_payload
        {
          id: template.id,
          slug: template.slug,
          name: template.name,
          active: template.active?,
          render_layout_config: template.render_layout_config,
          current_implementation_identifier: selected_implementation&.identifier
        }
      end

      def implementation_payload
        return {} unless selected_implementation

        implementation_payload_for(selected_implementation)
      end

      def candidate_implementations_payload
        template.template_implementations.where(status: "draft").most_recent_first.limit(5).map do |draft_candidate|
          implementation_payload_for(draft_candidate)
        end
      end

      def source_artifacts_payload
        template.template_artifacts.active.where(lineage_kind: "source").order(:created_at).map do |artifact|
          artifact_payload(artifact)
        end
      end

      def derived_artifacts_payload
        template.template_artifacts.active.where(lineage_kind: "derived").order(:created_at).map do |artifact|
          artifact_payload(artifact)
        end
      end

      def validation_artifacts_payload
        template.template_artifacts.active.where(lineage_kind: "validation").order(:created_at).map do |artifact|
          artifact_payload(artifact)
        end
      end

      def documentation_artifacts_payload
        template.template_artifacts.active.where(lineage_kind: "documentation").order(:created_at).map do |artifact|
          artifact_payload(artifact)
        end
      end

      def validation_runs_payload
        template.template_validation_runs.includes(:template_implementation, :reference_artifact).recent.limit(10).map do |run|
          validation_run_payload_for(run)
        end
      end

      def artifact_payload(artifact)
        {
          id: artifact.id,
          identifier: artifact.identifier,
          artifact_type: artifact.artifact_type,
          lineage_kind: artifact.lineage_kind,
          name: artifact.name,
          description: artifact.description,
          version_label: artifact.version_label,
          source_url: artifact.reference_source_url,
          source_signature: artifact.source_signature,
          immutable_source: artifact.immutable_source,
          parent_identifier: artifact.parent_artifact&.identifier,
          metadata: artifact.metadata,
          has_attachment: artifact.primary_attachment.present?,
          attachment: artifact.primary_attachment_metadata
        }
      end

      def implementation_payload_for(template_implementation)
        validation_runs = template_implementation.template_validation_runs.recent.to_a
        latest_validation_run = validation_runs.first

        {
          id: template_implementation.id,
          identifier: template_implementation.identifier,
          name: template_implementation.name,
          status: template_implementation.status,
          renderer_family: template_implementation.renderer_family,
          render_profile: template_implementation.effective_render_profile,
          source_artifact_identifier: template_implementation.source_artifact&.identifier,
          notes: template_implementation.notes,
          metadata: template_implementation.metadata,
          created_at: template_implementation.created_at,
          validated_at: template_implementation.validated_at,
          seeded_at: template_implementation.seeded_at,
          validation_runs_count: validation_runs.size,
          promotion_ready: template_implementation.draft? && validation_runs.any?(&:successful?),
          latest_validation_run: latest_validation_run.present? ? validation_run_payload_for(latest_validation_run) : nil
        }
      end

      def validation_run_payload_for(run)
        {
          id: run.id,
          identifier: run.identifier,
          validation_type: run.validation_type,
          status: run.status,
          validator_name: run.validator_name,
          notes: run.notes,
          metrics: run.metrics,
          metadata: run.metadata,
          validated_at: run.validated_at,
          template_implementation_id: run.template_implementation_id,
          template_implementation_identifier: run.template_implementation&.identifier,
          template_implementation_name: run.template_implementation&.name,
          template_implementation_status: run.template_implementation&.status,
          reference_artifact_identifier: run.reference_artifact&.identifier
        }
      end
  end
end
