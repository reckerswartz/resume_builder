require 'rails_helper'
require 'zip'

RSpec.describe Resumes::DocxTextExtractor do
  def build_docx(**xml_parts)
    Zip::OutputStream.write_buffer do |zip|
      xml_parts.each do |path, content|
        zip.put_next_entry(path.to_s)
        zip.write(content)
      end
    end.string
  end

  def word_xml(body_xml)
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>#{body_xml}</w:body>
      </w:document>
    XML
  end

  def paragraph(*runs)
    "<w:p>#{runs.join}</w:p>"
  end

  def text_run(value)
    "<w:r><w:t>#{value}</w:t></w:r>"
  end

  describe '#call' do
    it 'extracts paragraph text from word/document.xml' do
      docx = build_docx(
        "word/document.xml" => word_xml(
          paragraph(text_run("Pat Kumar")) +
          paragraph(text_run("Senior Engineer"))
        )
      )

      result = described_class.new(document_data: docx).call

      expect(result).to eq("Pat Kumar\nSenior Engineer")
    end

    it 'concatenates multiple text runs within a single paragraph' do
      docx = build_docx(
        "word/document.xml" => word_xml(
          paragraph(text_run("Pat"), text_run(" Kumar"))
        )
      )

      result = described_class.new(document_data: docx).call

      expect(result).to eq("Pat Kumar")
    end

    it 'reads headers before document and footers after document' do
      header_xml = word_xml(paragraph(text_run("Header Content")))
      document_xml = word_xml(paragraph(text_run("Body Content")))
      footer_xml = word_xml(paragraph(text_run("Footer Content")))

      docx = build_docx(
        "word/header1.xml" => header_xml,
        "word/document.xml" => document_xml,
        "word/footer1.xml" => footer_xml
      )

      result = described_class.new(document_data: docx).call

      expect(result).to eq("Header Content\nBody Content\nFooter Content")
    end

    it 'sorts multiple headers and footers by filename' do
      header1 = word_xml(paragraph(text_run("First Header")))
      header2 = word_xml(paragraph(text_run("Second Header")))
      footer1 = word_xml(paragraph(text_run("First Footer")))
      footer2 = word_xml(paragraph(text_run("Second Footer")))
      document_xml = word_xml(paragraph(text_run("Body")))

      docx = build_docx(
        "word/header2.xml" => header2,
        "word/header1.xml" => header1,
        "word/document.xml" => document_xml,
        "word/footer2.xml" => footer2,
        "word/footer1.xml" => footer1
      )

      result = described_class.new(document_data: docx).call

      expect(result).to eq("First Header\nSecond Header\nBody\nFirst Footer\nSecond Footer")
    end

    it 'converts tab nodes to tab characters' do
      docx = build_docx(
        "word/document.xml" => word_xml(
          paragraph(text_run("Name"), "<w:r><w:tab/></w:r>", text_run("Pat Kumar"))
        )
      )

      result = described_class.new(document_data: docx).call

      expect(result).to eq("Name\tPat Kumar")
    end

    it 'converts break and carriage return nodes to newlines' do
      docx = build_docx(
        "word/document.xml" => word_xml(
          paragraph(text_run("Line one"), "<w:r><w:br/></w:r>", text_run("Line two")) +
          paragraph(text_run("After CR"), "<w:r><w:cr/></w:r>", text_run("Next"))
        )
      )

      result = described_class.new(document_data: docx).call

      expect(result).to eq("Line one\nLine two\nAfter CR\nNext")
    end

    it 'rejects blank paragraphs' do
      docx = build_docx(
        "word/document.xml" => word_xml(
          paragraph(text_run("First")) +
          paragraph +
          paragraph(text_run("  ")) +
          paragraph(text_run("Second"))
        )
      )

      result = described_class.new(document_data: docx).call

      expect(result).to eq("First\nSecond")
    end

    it 'returns an empty string for invalid document data' do
      result = described_class.new(document_data: "not a zip file").call

      expect(result).to eq("")
    end

    it 'returns an empty string for a zip without word/document.xml' do
      docx = build_docx("other/file.txt" => "hello")

      result = described_class.new(document_data: docx).call

      expect(result).to eq("")
    end
  end
end
