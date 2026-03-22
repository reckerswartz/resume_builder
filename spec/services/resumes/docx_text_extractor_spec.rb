require 'rails_helper'
require 'zip'
require 'stringio'

RSpec.describe Resumes::DocxTextExtractor do
  def build_docx(parts = {})
    buffer = StringIO.new
    Zip::OutputStream.write_buffer(buffer) do |zip|
      parts.each do |path, xml|
        zip.put_next_entry(path)
        zip.write(xml)
      end
    end
    buffer.string
  end

  def word_xml(paragraphs)
    runs = paragraphs.map { |text| "<w:p><w:r><w:t>#{text}</w:t></w:r></w:p>" }.join
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>#{runs}</w:body>
      </w:document>
    XML
  end

  it 'extracts paragraph text from word/document.xml' do
    data = build_docx("word/document.xml" => word_xml(["Hello world", "Second paragraph"]))
    result = described_class.new(document_data: data).call

    expect(result).to eq("Hello world\nSecond paragraph")
  end

  it 'includes header and footer text in reading order' do
    data = build_docx(
      "word/header1.xml" => word_xml(["Header text"]),
      "word/document.xml" => word_xml(["Body text"]),
      "word/footer1.xml" => word_xml(["Footer text"])
    )
    result = described_class.new(document_data: data).call

    expect(result).to eq("Header text\nBody text\nFooter text")
  end

  it 'handles tabs and line breaks within paragraphs' do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r><w:t>Before tab</w:t></w:r>
            <w:r><w:tab/></w:r>
            <w:r><w:t>After tab</w:t></w:r>
          </w:p>
          <w:p>
            <w:r><w:t>Before break</w:t></w:r>
            <w:r><w:br/></w:r>
            <w:r><w:t>After break</w:t></w:r>
          </w:p>
        </w:body>
      </w:document>
    XML
    data = build_docx("word/document.xml" => xml)
    result = described_class.new(document_data: data).call

    expect(result).to include("Before tab\tAfter tab")
    expect(result).to include("Before break\nAfter break")
  end

  it 'skips blank paragraphs' do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p><w:r><w:t>First</w:t></w:r></w:p>
          <w:p></w:p>
          <w:p><w:r><w:t>Third</w:t></w:r></w:p>
        </w:body>
      </w:document>
    XML
    data = build_docx("word/document.xml" => xml)
    result = described_class.new(document_data: data).call

    expect(result).to eq("First\nThird")
  end

  it 'returns empty string for corrupt or invalid data' do
    result = described_class.new(document_data: "not a zip file").call

    expect(result).to eq("")
  end

  it 'returns empty string for a zip without word/document.xml' do
    data = build_docx("other/file.txt" => "some content")
    result = described_class.new(document_data: data).call

    expect(result).to eq("")
  end
end
