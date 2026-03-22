require "rails_helper"
require "zip"

RSpec.describe Resumes::DocxTextExtractor do
  describe "#call" do
    def build_docx_buffer(entries = {})
      Zip::OutputStream.write_buffer do |zip|
        entries.each do |name, content|
          zip.put_next_entry(name)
          zip.write(content)
        end
      end.string
    end

    def word_document_xml(body_xml)
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

    it "extracts paragraph text from word/document.xml" do
      data = build_docx_buffer(
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Pat Kumar</w:t></w:r></w:p>' \
          '<w:p><w:r><w:t>Senior Engineer</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Pat Kumar\nSenior Engineer")
    end

    it "joins multiple text runs within a single paragraph" do
      data = build_docx_buffer(
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Pat</w:t></w:r><w:r><w:t> Kumar</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Pat Kumar")
    end

    it "converts tab nodes to tab characters" do
      data = build_docx_buffer(
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Name</w:t></w:r><w:r><w:tab/></w:r><w:r><w:t>Pat Kumar</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Name\tPat Kumar")
    end

    it "converts break and carriage-return nodes to newlines" do
      data = build_docx_buffer(
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Line 1</w:t></w:r><w:r><w:br/></w:r><w:r><w:t>Line 2</w:t></w:r>' \
          '<w:r><w:cr/></w:r><w:r><w:t>Line 3</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Line 1\nLine 2\nLine 3")
    end

    it "includes header content before document content" do
      data = build_docx_buffer(
        "word/header1.xml" => header_xml(
          '<w:p><w:r><w:t>Header Text</w:t></w:r></w:p>'
        ),
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Body Text</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Header Text\nBody Text")
    end

    it "includes footer content after document content" do
      data = build_docx_buffer(
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Body Text</w:t></w:r></w:p>'
        ),
        "word/footer1.xml" => footer_xml(
          '<w:p><w:r><w:t>Footer Text</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Body Text\nFooter Text")
    end

    it "orders multiple headers numerically" do
      data = build_docx_buffer(
        "word/header2.xml" => header_xml(
          '<w:p><w:r><w:t>Second Header</w:t></w:r></w:p>'
        ),
        "word/header1.xml" => header_xml(
          '<w:p><w:r><w:t>First Header</w:t></w:r></w:p>'
        ),
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Body</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("First Header\nSecond Header\nBody")
    end

    it "skips blank paragraphs" do
      data = build_docx_buffer(
        "word/document.xml" => word_document_xml(
          '<w:p><w:r><w:t>Content</w:t></w:r></w:p>' \
          '<w:p></w:p>' \
          '<w:p><w:r><w:t>More Content</w:t></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("Content\nMore Content")
    end

    it "returns an empty string for a corrupt ZIP file" do
      result = described_class.new(document_data: "not-a-zip-file").call

      expect(result).to eq("")
    end

    it "returns an empty string when word/document.xml is missing" do
      data = build_docx_buffer(
        "word/styles.xml" => "<styles/>"
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("")
    end

    it "returns an empty string when document contains only empty paragraphs" do
      data = build_docx_buffer(
        "word/document.xml" => word_document_xml(
          '<w:p></w:p><w:p><w:r></w:r></w:p>'
        )
      )

      result = described_class.new(document_data: data).call

      expect(result).to eq("")
    end
  end
end
