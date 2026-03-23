require "rails_helper"

RSpec.describe Resumes::PdfTextExtractor do
  describe "#call" do
    it "joins multi-page text with double newlines" do
      reader = instance_double(PDF::Reader)
      page1 = instance_double(PDF::Reader::Page, text: "Pat Kumar")
      page2 = instance_double(PDF::Reader::Page, text: "Senior Engineer")
      allow(PDF::Reader).to receive(:new).and_return(reader)
      allow(reader).to receive(:pages).and_return([ page1, page2 ])

      result = described_class.new(document_data: "fake-pdf-bytes").call

      expect(result).to eq("Pat Kumar\n\nSenior Engineer")
    end

    it "returns single-page text without trailing separators" do
      reader = instance_double(PDF::Reader)
      page = instance_double(PDF::Reader::Page, text: "One page resume")
      allow(PDF::Reader).to receive(:new).and_return(reader)
      allow(reader).to receive(:pages).and_return([ page ])

      result = described_class.new(document_data: "fake-pdf-bytes").call

      expect(result).to eq("One page resume")
    end

    it "returns empty string when PDF::Reader raises MalformedPDFError" do
      allow(PDF::Reader).to receive(:new).and_raise(PDF::Reader::MalformedPDFError, "corrupt")

      result = described_class.new(document_data: "corrupt-bytes").call

      expect(result).to eq("")
    end

    it "returns empty string when a generic error occurs" do
      allow(PDF::Reader).to receive(:new).and_raise(StandardError, "unexpected")

      result = described_class.new(document_data: "bad-bytes").call

      expect(result).to eq("")
    end

    it "wraps raw string data in a StringIO for PDF::Reader" do
      allow(PDF::Reader).to receive(:new).with(instance_of(StringIO)).and_return(
        instance_double(PDF::Reader, pages: [ instance_double(PDF::Reader::Page, text: "OK") ])
      )

      described_class.new(document_data: "raw-bytes").call

      expect(PDF::Reader).to have_received(:new).with(instance_of(StringIO))
    end
  end
end
