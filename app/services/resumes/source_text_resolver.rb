require "cgi"

module Resumes
  class SourceTextResolver
    Result = Data.define(:success, :text, :error_message, :source_kind, :content_type) do
      def success?
        success
      end
    end

    SUPPORTED_UPLOAD_CONTENT_TYPES = %w[
      application/pdf
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      text/plain
      text/markdown
      text/html
      application/xhtml+xml
      text/rtf
      application/rtf
    ].freeze
    SUPPORTED_UPLOAD_EXTENSIONS = %w[pdf docx txt text md markdown html htm rtf].freeze

    class << self
      def supported_upload?(attachment)
        return false unless attachment&.attached?

        content_type = attachment.blob.content_type.to_s
        extension = attachment.filename.extension_without_delimiter.to_s.downcase

        SUPPORTED_UPLOAD_CONTENT_TYPES.include?(content_type) || SUPPORTED_UPLOAD_EXTENSIONS.include?(extension)
      end

      def supported_upload_content_types
        SUPPORTED_UPLOAD_CONTENT_TYPES
      end

      def supported_upload_extensions
        SUPPORTED_UPLOAD_EXTENSIONS
      end

      def supported_upload_formats_label
        I18n.t("resumes.source_text_resolver.supported_upload_formats_label")
      end
    end

    def initialize(resume:)
      @resume = resume
    end

    def call
      case resume.source_mode
      when "paste"
        return failure(I18n.t("resumes.source_text_resolver.paste_required")) if normalized_text(resume.source_text).blank?

        Result.new(
          success: true,
          text: normalized_text(resume.source_text),
          error_message: nil,
          source_kind: "pasted_text",
          content_type: "text/plain"
        )
      when "upload"
        return failure(I18n.t("resumes.source_text_resolver.upload_required")) unless resume.source_document.attached?
        return failure(upload_not_supported_message) unless self.class.supported_upload?(resume.source_document)

        extracted_text = extract_uploaded_text
        return failure(I18n.t("resumes.source_text_resolver.unreadable_upload")) if extracted_text.blank?

        Result.new(
          success: true,
          text: extracted_text,
          error_message: nil,
          source_kind: "uploaded_document",
          content_type: detected_content_type.presence || "text/plain"
        )
      else
        failure(I18n.t("resumes.source_text_resolver.choose_source"))
      end
    end

    private
      attr_reader :resume

      def extract_uploaded_text
        raw_text = resume.source_document.download
        return "" if raw_text.blank?

        normalized_text(
          case document_kind
          when :pdf
            Resumes::PdfTextExtractor.new(document_data: raw_text).call
          when :docx
            Resumes::DocxTextExtractor.new(document_data: raw_text).call
          when :html
            html_to_text(raw_text)
          when :rtf
            rtf_to_text(raw_text)
          else
            raw_text
          end
        )
      rescue StandardError
        ""
      end

      def normalized_text(value)
        value.to_s
          .encode("UTF-8", invalid: :replace, undef: :replace, replace: " ")
          .gsub("\u0000", " ")
          .gsub(/\r\n?/, "\n")
          .lines
          .map(&:strip)
          .join("\n")
          .gsub(/\n{3,}/, "\n\n")
          .strip
      end

      def html_to_text(value)
        normalized_html = value.to_s
          .gsub(/<br\s*\/?\s*>/i, "\n")
          .gsub(%r{</(?:p|div|section|article|li|tr|td|h1|h2|h3|h4|h5|h6)>}i, "\n")

        CGI.unescapeHTML(ActionView::Base.full_sanitizer.sanitize(normalized_html))
      end

      def rtf_to_text(value)
        value.to_s
          .gsub(/\\par[d]?/, "\n")
          .gsub(/\\tab/, "\t")
          .gsub(/\\'[0-9a-fA-F]{2}/, " ")
          .gsub(/\\[a-z]+-?\d* ?/, "")
          .tr("{}", " ")
      end

      def document_kind
        return :pdf if pdf_document?
        return :docx if docx_document?
        return :html if html_document?
        return :rtf if rtf_document?

        :text
      end

      def pdf_document?
        detected_content_type == "application/pdf" || detected_extension == "pdf"
      end

      def docx_document?
        detected_content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" || detected_extension == "docx"
      end

      def html_document?
        %w[text/html application/xhtml+xml].include?(detected_content_type) || %w[html htm].include?(detected_extension)
      end

      def rtf_document?
        %w[text/rtf application/rtf].include?(detected_content_type) || detected_extension == "rtf"
      end

      def detected_content_type
        resume.source_document.blob.content_type.to_s
      end

      def detected_extension
        resume.source_document.filename.extension_without_delimiter.to_s.downcase
      end

      def failure(message)
        Result.new(success: false, text: "", error_message: message, source_kind: nil, content_type: nil)
      end

      def upload_not_supported_message
        I18n.t("resumes.source_text_resolver.unsupported_upload", formats: self.class.supported_upload_formats_label)
      end
  end
end
