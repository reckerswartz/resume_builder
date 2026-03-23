module Resumes
  class BulkZipExporter
    def initialize(resumes:)
      @resumes = resumes
    end

    def call
      zip_buffer = Zip::OutputStream.write_buffer do |zip|
        resumes_with_exports.each do |resume|
          filename = unique_filename(resume)
          resume.pdf_export.open do |tempfile|
            zip.put_next_entry(filename)
            zip.write(tempfile.read)
          end
        end
      end

      zip_buffer.string
    end

    def all_exports_ready?
      resumes.all? { |resume| resume.pdf_export.attached? }
    end

    def ready_count
      resumes.count { |resume| resume.pdf_export.attached? }
    end

    private
      attr_reader :resumes

      def resumes_with_exports
        resumes.select { |resume| resume.pdf_export.attached? }
      end

      def unique_filename(resume)
        slug = resume.slug.presence || "resume-#{resume.id}"
        "#{slug}.pdf"
      end
  end
end
