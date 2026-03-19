module Resumes
  class PdfExporter
    DEFAULT_OPTIONS = {
      margin: {
        top: 12,
        bottom: 12,
        left: 12,
        right: 12
      },
      page_size: "A4",
      print_media_type: true,
      disable_smart_shrinking: false,
      encoding: "UTF-8"
    }.freeze

    def initialize(resume:)
      @resume = resume
    end

    def call
      WickedPdf.new.pdf_from_string(rendered_html, DEFAULT_OPTIONS)
    end

    private
      attr_reader :resume

      def rendered_html
        ApplicationController.render(
          template: "resumes/pdf",
          layout: "pdf",
          assigns: { resume: resume }
        )
      end
  end
end
