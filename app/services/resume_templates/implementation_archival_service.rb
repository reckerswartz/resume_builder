module ResumeTemplates
  class ImplementationArchivalService
    Result = Data.define(:template, :template_implementation, :error_message, :archived) do
      def success?
        error_message.blank? && template_implementation.present?
      end

      def archived?
        archived
      end
    end

    def initialize(template:, template_implementation:, user:)
      @template = template
      @template_implementation = template_implementation
      @user = user
    end

    def call
      return failure(error_message: implementation_mismatch_message) unless implementation_belongs_to_template?
      return success(template_implementation: template_implementation, archived: false) if template_implementation.archived?
      return failure(error_message: current_implementation_message) if current_implementation?
      return failure(error_message: ineligible_implementation_message) unless template_implementation.render_ready?

      archived_implementation = nil
      did_archive = false
      archived_from_status = template_implementation.status
      archived_at = Time.current.iso8601

      ActiveRecord::Base.transaction do
        template_implementation.with_lock do
          if template_implementation.archived?
            archived_implementation = template_implementation
            next
          end

          template_implementation.update!(
            status: "archived",
            metadata: archival_metadata(archived_from_status: archived_from_status, archived_at: archived_at)
          )
          archived_implementation = template_implementation
          did_archive = true
        end
      end

      success(template_implementation: archived_implementation, archived: did_archive)
    rescue ActiveRecord::RecordInvalid => error
      failure(error_message: error.record.errors.full_messages.to_sentence)
    end

    private
      attr_reader :template, :template_implementation, :user

      def implementation_belongs_to_template?
        template_implementation.template_id == template.id
      end

      def current_implementation?
        template.current_implementation&.id == template_implementation.id
      end

      def archival_metadata(archived_from_status:, archived_at:)
        template_implementation.metadata.merge(
          "archive_mode" => "admin_history_cleanup",
          "archived_from_status" => archived_from_status,
          "archived_by_user_id" => user&.id,
          "archived_by_user_email" => user&.email_address,
          "archived_at" => archived_at
        ).compact
      end

      def implementation_mismatch_message
        "Selected implementation does not belong to this template."
      end

      def current_implementation_message
        "The current implementation cannot be archived from this flow."
      end

      def ineligible_implementation_message
        "Only superseded render-ready implementations can be archived from this flow."
      end

      def success(template_implementation:, archived:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          error_message: nil,
          archived: archived
        )
      end

      def failure(error_message:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          error_message: error_message,
          archived: false
        )
      end
  end
end
