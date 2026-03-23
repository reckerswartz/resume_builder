require "rails_helper"
require "zip"

RSpec.describe Resumes::DocxTextExtractor do
  def build_docx(*parts)
    Zip::OutputStream.write_buffer do |zip|
      parts.each do |entry_name, content|
        zip.put_next_entry(entry_name)
        zip.write(content)
      end
    end.string
  end

  def document_xml(body_xml)
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>#{body_xml}</w:body>
      </w:document>
    XML
  end

  def header_xml(body_xml)
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        #{body_xml}
      </w:hdr>
    XML
  end

  def footer_xml(body_xml)
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        #{body_xml}
      </w:ftr>
    XML
  end

  describe "#call" do
    it "extracts paragraph text from word/document.xml" do
      data = build_docx(
        [ "word/document.xml", document_xml('<w:p><w:r><w:t>Hello World</w:t></w:r></w:p>') ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Hello World")
    end

    it "joins multiple text runs within a paragraph" do
      data = build_docx(
        [ "word/document.xml", document_xml(
          '<w:p><w:r><w:t>Pat</w:t></w:r><w:r><w:t> Kumar</w:t></w:r></w:p>'
        ) ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Pat Kumar")
    end

    it "converts tab nodes to tab characters" do
      data = build_docx(
        [ "word/document.xml", document_xml(
          '<w:p><w:r><w:t>Name</w:t></w:r><w:r><w:tab/></w:r><w:r><w:t>Value</w:t></w:r></w:p>'
        ) ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to include("Name\tValue")
    end

    it "converts break and carriage-return nodes to newlines" do
      data = build_docx(
        [ "word/document.xml", document_xml(
          '<w:p><w:r><w:t>Line1</w:t></w:r><w:r><w:br/></w:r><w:r><w:t>Line2</w:t></w:r>' \
          '<w:r><w:cr/></w:r><w:r><w:t>Line3</w:t></w:r></w:p>'
        ) ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to include("Line1\nLine2\nLine3")
    end

    it "places headers before document content" do
      data = build_docx(
        [ "word/header1.xml", header_xml('<w:p><w:r><w:t>Header Text</w:t></w:r></w:p>') ],
        [ "word/document.xml", document_xml('<w:p><w:r><w:t>Body Text</w:t></w:r></w:p>') ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Header Text\nBody Text")
    end

    it "places footers after document content" do
      data = build_docx(
        [ "word/document.xml", document_xml('<w:p><w:r><w:t>Body Text</w:t></w:r></w:p>') ],
        [ "word/footer1.xml", footer_xml('<w:p><w:r><w:t>Footer Text</w:t></w:r></w:p>') ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Body Text\nFooter Text")
    end

    it "sorts multiple headers numerically" do
      data = build_docx(
        [ "word/header2.xml", header_xml('<w:p><w:r><w:t>Second Header</w:t></w:r></w:p>') ],
        [ "word/header1.xml", header_xml('<w:p><w:r><w:t>First Header</w:t></w:r></w:p>') ],
        [ "word/document.xml", document_xml('<w:p><w:r><w:t>Body</w:t></w:r></w:p>') ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("First Header\nSecond Header\nBody")
    end

    it "skips blank paragraphs" do
      data = build_docx(
        [ "word/document.xml", document_xml(
          '<w:p><w:r><w:t>Line1</w:t></w:r></w:p>' \
          '<w:p></w:p>' \
          '<w:p><w:r><w:t>  </w:t></w:r></w:p>' \
          '<w:p><w:r><w:t>Line2</w:t></w:r></w:p>'
        ) ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Line1\nLine2")
    end

    it "returns empty string for corrupt ZIP data" do
      result = described_class.new(document_data: "not-a-zip-file").call

      expect(result).to eq("")
    end

    it "returns empty string when word/document.xml is missing" do
      data = build_docx(
        [ "word/styles.xml", "<styles/>" ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("")
    end

    it "returns empty string when all paragraphs are empty" do
      data = build_docx(
        [ "word/document.xml", document_xml('<w:p></w:p><w:p><w:r><w:t>   </w:t></w:r></w:p>') ]
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("")
    end
  end
end
