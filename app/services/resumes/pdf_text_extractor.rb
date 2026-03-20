require "pdf/reader"
require "stringio"

module Resumes
  class PdfTextExtractor
    def initialize(document_data:)
      @document_data = document_data
    end

    def call
      PDF::Reader.new(StringIO.new(document_data)).pages.map(&:text).join("\n\n")
    rescue StandardError
      ""
    end

    private
      attr_reader :document_data
  end
end
