require "nokogiri"
require "stringio"
require "zip"

module Resumes
  class DocxTextExtractor
    WORD_NAMESPACE = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }.freeze

    def initialize(document_data:)
      @document_data = document_data
    end

    def call
      xml_documents
        .flat_map { |xml_document| paragraph_texts(xml_document) }
        .reject(&:blank?)
        .join("\n")
    rescue StandardError
      ""
    end

    private
      attr_reader :document_data

      def xml_documents
        documents = []

        Zip::File.open_buffer(StringIO.new(document_data)) do |zip_file|
          documents = [
            *zip_file.glob("word/header*.xml").sort_by(&:name),
            *zip_file.glob("word/document.xml"),
            *zip_file.glob("word/footer*.xml").sort_by(&:name)
          ].map { |entry| entry.get_input_stream.read.to_s }
        end

        documents
      end

      def paragraph_texts(xml_document)
        document = Nokogiri::XML(xml_document)

        document.xpath("//w:p", WORD_NAMESPACE).map do |paragraph|
          paragraph_text(paragraph)
        end
      end

      def paragraph_text(paragraph)
        paragraph.xpath(".//w:t|.//w:tab|.//w:br|.//w:cr", WORD_NAMESPACE).map do |node|
          case node.name
          when "t"
            node.text
          when "tab"
            "\t"
          else
            "\n"
          end
        end.join
      end
  end
end
