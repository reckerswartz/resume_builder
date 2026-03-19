require 'rails_helper'

RSpec.describe Resumes::PdfExporter do
  describe '#call' do
    it 'renders the shared PDF template and passes it to WickedPdf' do
      resume = create(
        :resume,
        title: 'Export Resume',
        contact_details: {
          'full_name' => 'Export User',
          'email' => 'export@example.com'
        }
      )
      wicked_pdf = instance_double(WickedPdf)

      allow(WickedPdf).to receive(:new).and_return(wicked_pdf)
      allow(wicked_pdf).to receive(:pdf_from_string) do |html, options|
        expect(html).to include('Export User')
        expect(html).to include('export@example.com')
        expect(options).to include(page_size: 'A4')
        'pdf-binary'
      end

      pdf = described_class.new(resume:).call

      expect(pdf).to eq('pdf-binary')
    end
  end
end
