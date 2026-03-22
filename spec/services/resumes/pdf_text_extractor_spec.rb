require "rails_helper"

RSpec.describe Resumes::PdfTextExtractor do
  describe "#call" do
    it "extracts text from all pages joined by double newlines" do
      reader = instance_double(PDF::Reader)
      page1 = instance_double(PDF::Reader::Page, text: "Pat Kumar\nSenior Engineer")
      page2 = instance_double(PDF::Reader::Page, text: "Experience\nBuilt systems")

      allow(PDF::Reader).to receive(:new).and_return(reader)
      allow(reader).to receive(:pages).and_return([ page1, page2 ])

      result = described_class.new(document_data: "fake-pdf-bytes").call

      expect(result).to eq("Pat Kumar\nSenior Engineer\n\nExperience\nBuilt systems")
    end

    it "returns text from a single-page document without trailing separators" do
      reader = instance_double(PDF::Reader)
      page = instance_double(PDF::Reader::Page, text: "One page resume content")

      allow(PDF::Reader).to receive(:new).and_return(reader)
      allow(reader).to receive(:pages).and_return([ page ])

      result = described_class.new(document_data: "fake-pdf-bytes").call

      expect(result).to eq("One page resume content")
    end

    it "returns an empty string when the PDF has no pages" do
      reader = instance_double(PDF::Reader)

      allow(PDF::Reader).to receive(:new).and_return(reader)
      allow(reader).to receive(:pages).and_return([])

      result = described_class.new(document_data: "fake-pdf-bytes").call

      expect(result).to eq("")
    end

    it "returns an empty string when PDF::Reader raises a MalformedPDFError" do
      allow(PDF::Reader).to receive(:new).and_raise(PDF::Reader::MalformedPDFError, "corrupt")

      result = described_class.new(document_data: "not-a-pdf").call

      expect(result).to eq("")
    end

    it "returns an empty string when PDF::Reader raises a generic error" do
      allow(PDF::Reader).to receive(:new).and_raise(StandardError, "unexpected")

      result = described_class.new(document_data: "garbage-bytes").call

      expect(result).to eq("")
    end

    it "passes document_data through a StringIO to PDF::Reader" do
      raw_data = "raw-pdf-binary-data"
      reader = instance_double(PDF::Reader, pages: [])

      allow(PDF::Reader).to receive(:new) do |io|
        expect(io).to be_a(StringIO)
        expect(io.read).to eq(raw_data)
        reader
      end

      described_class.new(document_data: raw_data).call
    end
  end
end
