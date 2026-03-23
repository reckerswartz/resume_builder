module Resumes
  class SourceStepState
    attr_reader :resume

    def initialize(resume:, autofill_enabled:, view_context:)
      @resume = resume
      @autofill_enabled = autofill_enabled
      @view_context = view_context
    end

    def autofill_enabled?
      @autofill_enabled
    end

    def document_autofill_supported?
      ::Resumes::SourceTextResolver.supported_upload?(resume.source_document)
    end

    def upload_review_state
      return unless resume.source_document.attached?

      attachment = resume.source_document
      supported = document_autofill_supported?
      content_type = attachment.blob.content_type.presence || I18n.t("resumes.helper.source_upload_review.unknown_type")

      if supported && autofill_enabled?
        upload_review_hash(:ready_for_ai_import, attachment, content_type, tone: :success)
      elsif supported
        upload_review_hash(:supported_upload_attached, attachment, content_type, tone: :neutral, panel_tone: :default)
      else
        upload_review_hash(:reference_file_only, attachment, content_type, tone: :neutral, panel_tone: :default)
      end
    end

    def autofill_status_label
      return I18n.t("resumes.helper.source_autofill.labels.unavailable") unless autofill_enabled?

      case resume.source_mode
      when "paste"
        paste_text_present? ? I18n.t("resumes.helper.source_autofill.labels.paste_ready") : I18n.t("resumes.helper.source_autofill.labels.paste_required")
      when "upload"
        return I18n.t("resumes.helper.source_autofill.labels.attach_file") unless resume.source_document.attached?

        document_autofill_supported? ? I18n.t("resumes.helper.source_autofill.labels.upload_ready") : I18n.t("resumes.helper.source_autofill.labels.reference_file_only")
      else
        I18n.t("resumes.helper.source_autofill.labels.choose_import_path")
      end
    end

    def autofill_status_message
      return I18n.t("resumes.helper.source_autofill.messages.unavailable") unless autofill_enabled?

      case resume.source_mode
      when "paste"
        paste_text_present? ? I18n.t("resumes.helper.source_autofill.messages.paste_ready") : I18n.t("resumes.helper.source_autofill.messages.paste_required")
      when "upload"
        return I18n.t("resumes.helper.source_autofill.messages.attach_document") unless resume.source_document.attached?

        if document_autofill_supported?
          I18n.t("resumes.helper.source_autofill.messages.upload_ready")
        else
          I18n.t("resumes.helper.source_autofill.messages.upload_reference_only", formats: ::Resumes::SourceTextResolver.supported_upload_formats_label)
        end
      else
        I18n.t("resumes.helper.source_autofill.messages.scratch_mode")
      end
    end

    def autofill_action_ready?
      return false unless autofill_enabled?

      case resume.source_mode
      when "paste"
        paste_text_present?
      when "upload"
        resume.source_document.attached? && document_autofill_supported?
      else
        false
      end
    end

    def cloud_import_provider_states
      ::Resumes::CloudImportProviderCatalog.all.map do |provider|
        configured = provider.fetch(:configured)
        provider_label = provider.fetch(:label)

        {
          key: provider.fetch(:key),
          label: provider_label,
          description: provider.fetch(:description),
          status_label: configured ? I18n.t("resumes.helper.source_cloud_import.status.configured") : I18n.t("resumes.helper.source_cloud_import.status.setup_required"),
          status_tone: configured ? :neutral : :warning,
          message: if configured
            I18n.t("resumes.cloud_import_provider_catalog.feedback.configured", provider: provider_label)
                   else
            I18n.t("resumes.cloud_import_provider_catalog.feedback.setup_required", provider: provider_label, env_vars: provider.fetch(:required_env_vars).to_sentence)
                   end
        }
      end
    end

    private
      attr_reader :view_context

      def paste_text_present?
        resume.source_text.to_s.squish.present?
      end

      def upload_review_hash(key, attachment, content_type, tone:, panel_tone: nil)
        {
          title: I18n.t("resumes.helper.source_upload_review.#{key}.title"),
          badge_label: I18n.t("resumes.helper.source_upload_review.#{key}.badge_label"),
          badge_tone: tone,
          panel_tone: panel_tone || tone,
          filename: attachment.filename.to_s,
          content_type: content_type,
          file_size: view_context.number_to_human_size(attachment.byte_size),
          message: I18n.t("resumes.helper.source_upload_review.#{key}.message")
        }
      end
  end
end
