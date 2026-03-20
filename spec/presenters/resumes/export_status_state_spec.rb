require 'rails_helper'

RSpec.describe Resumes::ExportStatusState do
  let(:resume) { create(:resume) }
  let(:view_context) { instance_double('view_context') }

  subject(:export_status_state) { described_class.new(resume:, context:, view_context:) }

  before do
    allow(view_context).to receive(:resume_export_status_label).with(resume).and_return('Draft only')
    allow(view_context).to receive(:resume_export_status_message).with(resume).and_return('No PDF export has been generated yet.')
    allow(view_context).to receive(:resume_export_status_badge_classes).with(resume, context: context).and_return('border border-slate-200 bg-white text-slate-600')
    allow(view_context).to receive(:download_resume_path).with(resume).and_return("/resumes/#{resume.id}/download")
  end

  context 'when rendered in the preview context' do
    let(:context) { :preview }

    it 'builds widget attributes for the shared export summary card' do
      expect(export_status_state.widget_attributes).to eq(
        eyebrow: 'Export status',
        title: 'Draft only',
        description: 'No PDF export has been generated yet.',
        tone: :subtle,
        padding: :sm,
        badge: 'Draft',
        badge_classes: 'rounded-full px-3 py-1 text-xs font-medium border border-slate-200 bg-white text-slate-600',
        title_size: :xl
      )
    end

    it 'uses the secondary download button style and reports when no file is attached' do
      expect(export_status_state.download_button_style).to eq(:secondary)
      expect(export_status_state.download_available?).to be(false)
    end
  end

  context 'when rendered on the show page with a generated PDF' do
    let(:context) { :show }

    before do
      resume.pdf_export.attach(io: StringIO.new('pdf data'), filename: 'resume.pdf', content_type: 'application/pdf')
      allow(view_context).to receive(:resume_export_status_label).with(resume).and_return('PDF ready')
      allow(view_context).to receive(:resume_export_status_message).with(resume).and_return('The latest PDF export is attached and ready to download.')
    end

    it 'uses the white-canvas show card tone and keeps downloads in the action rail' do
      expect(export_status_state.widget_attributes).to eq(
        eyebrow: 'Export status',
        title: 'PDF ready',
        description: 'The latest PDF export is attached and ready to download.',
        tone: :default,
        padding: :sm,
        badge: 'Ready',
        badge_classes: 'rounded-full px-3 py-1 text-xs font-medium border border-slate-200 bg-white text-slate-600',
        title_size: :xl
      )
      expect(export_status_state.download_button_style).to eq(:secondary)
      expect(export_status_state.download_available?).to be(false)
      expect(export_status_state.download_path).to eq("/resumes/#{resume.id}/download")
    end
  end

  context 'when rendered in the editor context with a generated PDF' do
    let(:context) { :editor }

    before do
      resume.pdf_export.attach(io: StringIO.new('pdf data'), filename: 'resume.pdf', content_type: 'application/pdf')
    end

    it 'uses the editor button style and exposes the download path' do
      expect(export_status_state.download_button_style).to eq(:hero_secondary)
      expect(export_status_state.download_available?).to be(true)
      expect(export_status_state.download_path).to eq("/resumes/#{resume.id}/download")
    end
  end
end
