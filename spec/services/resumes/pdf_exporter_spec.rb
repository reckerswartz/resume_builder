require 'rails_helper'

RSpec.describe Resumes::PdfExporter do
  describe '#call' do
    it 'renders the shared PDF template and passes it to WickedPdf' do
      resume = create(
        :resume,
        title: 'Export Resume',
        settings: {
          'accent_color' => '#111827',
          'show_contact_icons' => true,
          'page_size' => 'A4'
        },
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
        expect(html).to include('#111827')
        expect(options).to include(page_size: 'A4')
        'pdf-binary'
      end

      pdf = described_class.new(resume:).call

      expect(pdf).to eq('pdf-binary')
    end

    it 'renders classic family templates through the shared export path' do
      template = create(:template, layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))
      resume = create(
        :resume,
        template: template,
        title: 'Classic Export Resume',
        settings: {
          'accent_color' => '#1D4ED8',
          'show_contact_icons' => true,
          'page_size' => 'A4'
        },
        contact_details: {
          'full_name' => 'Classic User',
          'email' => 'classic@example.com'
        }
      )
      wicked_pdf = instance_double(WickedPdf)

      allow(WickedPdf).to receive(:new).and_return(wicked_pdf)
      allow(wicked_pdf).to receive(:pdf_from_string) do |html, _options|
        expect(html).to include('Classic User')
        expect(html).to include('classic@example.com')
        expect(html).to include('#1D4ED8')
        'pdf-binary'
      end

      pdf = described_class.new(resume:).call

      expect(pdf).to eq('pdf-binary')
    end
  end
end
