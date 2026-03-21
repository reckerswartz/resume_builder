module Resumes
  class PdfExporter
    DEFAULT_OPTIONS = {
      margin: {
        top: 12,
        bottom: 12,
        left: 12,
        right: 12
      },
      print_media_type: true,
      disable_smart_shrinking: false,
      encoding: "UTF-8"
    }.freeze

    def initialize(resume:)
      @resume = resume
    end

    def call
      WickedPdf.new.pdf_from_string(rendered_html, export_options)
    end

    private
      attr_reader :resume

      def export_options
        DEFAULT_OPTIONS.merge(page_size: resume.page_size)
      end

      def rendered_html
        ApplicationController.render(
          template: "resumes/pdf",
          layout: "pdf",
          assigns: { resume: resume }
        )
      end
  end
end
