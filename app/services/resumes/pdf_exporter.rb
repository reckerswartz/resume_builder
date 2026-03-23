module Resumes
  class PdfExporter
    def initialize(resume:)
      @resume = resume
    end

    def call
      Grover.new(rendered_html, **grover_options).to_pdf
    end

    private
      attr_reader :resume

      def grover_options
        {
          format: resume.page_size.presence || "A4",
          display_url: "http://localhost"
        }
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
