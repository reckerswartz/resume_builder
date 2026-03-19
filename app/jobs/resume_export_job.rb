class ResumeExportJob < ApplicationJob
  queue_as :default

  def perform(resume_id, requested_by_id)
    resume = Resume.find(resume_id)
    requested_by = User.find(requested_by_id)
    pdf = Resumes::PdfExporter.new(resume:).call

    resume.pdf_export.attach(
      io: StringIO.new(pdf),
      filename: "#{resume.slug}.pdf",
      content_type: "application/pdf"
    )

    track_output(
      attachment_filename: resume.pdf_export.filename.to_s,
      requested_by_id: requested_by.id,
      resume_id: resume.id
    )
  end
end
