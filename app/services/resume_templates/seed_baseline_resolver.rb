module ResumeTemplates
  class SeedBaselineResolver
    def initialize(template:, implementation: nil)
      @template = template
      @implementation = implementation
    end

    def call
      {
        available: seeded_implementation.present?,
        ready: seeded_implementation.present? && seed_artifact.present?,
        missing_artifact: seeded_implementation.present? && seed_artifact.blank?,
        implementation_id: seeded_implementation&.id,
        implementation_identifier: seeded_implementation&.identifier,
        implementation_name: seeded_implementation&.name,
        source_artifact_identifier: seeded_implementation&.source_artifact&.identifier,
        seeded_at: seeded_implementation&.seeded_at,
        artifact_id: seed_artifact&.id,
        artifact_identifier: seed_artifact&.identifier,
        artifact_version_label: seed_artifact&.version_label,
        artifact_created_at: seed_artifact&.created_at
      }
    end

    private
      attr_reader :implementation, :template

      def selected_implementation
        @selected_implementation ||= implementation || template.current_implementation
      end

      def seeded_implementation
        @seeded_implementation ||= selected_implementation if selected_implementation&.seeded?
      end

      def seed_artifact
        return unless seeded_implementation.present?

        @seed_artifact ||= template.template_artifacts.active.where(artifact_type: "seed_snapshot").order(created_at: :desc).detect do |artifact|
          artifact.metadata["template_implementation_identifier"] == seeded_implementation.identifier
        end
      end
  end
end
