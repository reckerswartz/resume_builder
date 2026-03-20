require 'rails_helper'
require 'zip'

RSpec.describe Resumes::SourceTextResolver do
  describe '#call' do
    let(:resume) { create(:resume, source_mode: 'paste', source_text: " Pat Kumar\n\nSenior Engineer ") }

    it 'returns normalized pasted source text' do
      result = described_class.new(resume: resume).call

      expect(result).to be_success
      expect(result.text).to eq("Pat Kumar\n\nSenior Engineer")
      expect(result.source_kind).to eq('pasted_text')
      expect(result.content_type).to eq('text/plain')
    end

    it 'extracts normalized text from supported uploaded documents' do
      resume.update!(source_mode: 'upload', source_text: '')
      resume.source_document.attach(
        io: StringIO.new("<h1>Pat Kumar</h1><p>Senior Engineer</p>"),
        filename: 'resume.html',
        content_type: 'text/html'
      )

      result = described_class.new(resume: resume).call

      expect(result).to be_success
      expect(result.text).to eq("Pat Kumar\nSenior Engineer")
      expect(result.source_kind).to eq('uploaded_document')
      expect(result.content_type).to eq('text/html')
    end

    it 'extracts normalized text from supported PDF uploads' do
      resume.update!(source_mode: 'upload', source_text: '')
      resume.source_document.attach(
        io: StringIO.new('%PDF-1.7 sample'),
        filename: 'resume.pdf',
        content_type: 'application/pdf'
      )
      allow_any_instance_of(Resumes::PdfTextExtractor).to receive(:call).and_return(" Pat Kumar\n\nSenior Engineer ")

      result = described_class.new(resume: resume).call

      expect(result).to be_success
      expect(result.text).to eq("Pat Kumar\n\nSenior Engineer")
      expect(result.source_kind).to eq('uploaded_document')
      expect(result.content_type).to eq('application/pdf')
    end

    it 'extracts normalized text from supported DOCX uploads' do
      resume.update!(source_mode: 'upload', source_text: '')
      docx_buffer = Zip::OutputStream.write_buffer do |zip|
        zip.put_next_entry('word/document.xml')
        zip.write <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:body>
              <w:p><w:r><w:t>Pat Kumar</w:t></w:r></w:p>
              <w:p><w:r><w:t>Senior Engineer</w:t></w:r></w:p>
            </w:body>
          </w:document>
        XML
      end

      resume.source_document.attach(
        io: StringIO.new(docx_buffer.string),
        filename: 'resume.docx',
        content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      )

      result = described_class.new(resume: resume).call

      expect(result).to be_success
      expect(result.text).to eq("Pat Kumar\nSenior Engineer")
      expect(result.source_kind).to eq('uploaded_document')
      expect(result.content_type).to eq('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    end

    it 'returns a readable-text failure when a supported PDF upload cannot be parsed' do
      resume.update!(source_mode: 'upload', source_text: '')
      resume.source_document.attach(
        io: StringIO.new('%PDF-1.7 sample'),
        filename: 'resume.pdf',
        content_type: 'application/pdf'
      )
      allow_any_instance_of(Resumes::PdfTextExtractor).to receive(:call).and_return('')

      result = described_class.new(resume: resume).call

      expect(result).not_to be_success
      expect(result.error_message).to eq('The attached source document did not contain readable text.')
    end

    it 'returns a helpful failure for unsupported uploaded documents' do
      resume.update!(source_mode: 'upload', source_text: '')
      resume.source_document.attach(
        io: StringIO.new('legacy doc sample'),
        filename: 'resume.doc',
        content_type: 'application/msword'
      )

      result = described_class.new(resume: resume).call

      expect(result).not_to be_success
      expect(result.error_message).to include('Autofill currently supports PDF, DOCX, TXT, Markdown, HTML, and RTF uploads')
    end
  end
end
