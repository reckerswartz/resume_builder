require 'rails_helper'
require 'zip'

RSpec.describe Resumes::BulkZipExporter do
  let(:resumes) { [] }
  let(:exporter) { described_class.new(resumes: resumes) }

  def attach_pdf_export(resume, content: "fake pdf content for #{resume.slug}")
    resume.pdf_export.attach(
      io: StringIO.new(content),
      filename: "#{resume.slug}.pdf",
      content_type: "application/pdf"
    )
  end

  describe '#all_exports_ready?' do
    it 'returns true when all resumes have pdf_export attached' do
      resumes_with_pdfs = Array.new(2) { create(:resume) }
      resumes_with_pdfs.each { |resume| attach_pdf_export(resume) }
      exporter = described_class.new(resumes: resumes_with_pdfs)

      expect(exporter.all_exports_ready?).to be true
    end

    it 'returns false when some resumes lack pdf_export' do
      resume_with_pdf = create(:resume)
      resume_without_pdf = create(:resume)
      attach_pdf_export(resume_with_pdf)
      exporter = described_class.new(resumes: [ resume_with_pdf, resume_without_pdf ])

      expect(exporter.all_exports_ready?).to be false
    end
  end

  describe '#ready_count' do
    it 'returns the count of resumes with pdf_export attached' do
      resume_with_pdf = create(:resume)
      resume_without_pdf_1 = create(:resume)
      resume_without_pdf_2 = create(:resume)
      attach_pdf_export(resume_with_pdf)
      exporter = described_class.new(resumes: [ resume_with_pdf, resume_without_pdf_1, resume_without_pdf_2 ])

      expect(exporter.ready_count).to eq(1)
    end
  end

  describe '#call' do
    it 'creates a valid ZIP containing PDFs for each resume' do
      resumes = Array.new(2) { create(:resume) }
      resumes.each { |resume| attach_pdf_export(resume) }
      exporter = described_class.new(resumes: resumes)

      zip_data = exporter.call
      entries = []

      Zip::InputStream.open(StringIO.new(zip_data)) do |zip|
        while (entry = zip.get_next_entry)
          entries << { name: entry.name, content: zip.read }
        end
      end

      expect(entries.size).to eq(2)
      resumes.each do |resume|
        matching_entry = entries.find { |e| e[:name] == "#{resume.slug}.pdf" }
        expect(matching_entry).to be_present
        expect(matching_entry[:content]).to include("fake pdf content for #{resume.slug}")
      end
    end

    it 'uses resume slug as filename in the ZIP' do
      resume = create(:resume, slug: 'senior-engineer-2025')
      attach_pdf_export(resume)
      exporter = described_class.new(resumes: [ resume ])

      zip_data = exporter.call
      entries = []

      Zip::InputStream.open(StringIO.new(zip_data)) do |zip|
        while (entry = zip.get_next_entry)
          entries << entry.name
        end
      end

      expect(entries).to eq([ 'senior-engineer-2025.pdf' ])
    end

    it 'skips resumes without attached PDFs' do
      resume_with_pdf = create(:resume, slug: 'has-pdf')
      resume_without_pdf = create(:resume, slug: 'no-pdf')
      attach_pdf_export(resume_with_pdf)
      exporter = described_class.new(resumes: [ resume_with_pdf, resume_without_pdf ])

      zip_data = exporter.call
      entries = []

      Zip::InputStream.open(StringIO.new(zip_data)) do |zip|
        while (entry = zip.get_next_entry)
          entries << entry.name
        end
      end

      expect(entries).to eq([ 'has-pdf.pdf' ])
    end

    it 'handles a single resume' do
      resume = create(:resume, slug: 'only-one')
      attach_pdf_export(resume, content: 'single pdf bytes')
      exporter = described_class.new(resumes: [ resume ])

      zip_data = exporter.call
      entries = []

      Zip::InputStream.open(StringIO.new(zip_data)) do |zip|
        while (entry = zip.get_next_entry)
          entries << { name: entry.name, content: zip.read }
        end
      end

      expect(entries.size).to eq(1)
      expect(entries.first[:name]).to eq('only-one.pdf')
      expect(entries.first[:content]).to eq('single pdf bytes')
    end
  end
end
