require 'rails_helper'

RSpec.describe Resumes::ExportStatusState do
  let(:view_context) do
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.view_context
  end

  def build_state(resume:, context:)
    described_class.new(resume: resume, context: context, view_context: view_context)
  end

  describe '#status_label' do
    it 'returns the draft-only label for a resume without exports' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :editor).status_label).to eq(I18n.t('resumes.helper.export_status.labels.draft_only'))
    end

    it 'returns the ready label when a PDF export is attached' do
      resume = create(:resume)
      resume.pdf_export.attach(io: StringIO.new('pdf'), filename: 'resume.pdf', content_type: 'application/pdf')

      expect(build_state(resume: resume, context: :editor).status_label).to eq(I18n.t('resumes.helper.export_status.labels.ready'))
    end
  end

  describe '#status_message' do
    it 'returns the draft-only message for a fresh resume' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :preview).status_message).to eq(I18n.t('resumes.helper.export_status.messages.draft_only'))
    end

    it 'returns the queued message with download variant when a previous PDF exists' do
      resume = create(:resume)
      resume.pdf_export.attach(io: StringIO.new('pdf'), filename: 'resume.pdf', content_type: 'application/pdf')
      create(:job_log, :queued, job_type: 'ResumeExportJob', input: { 'arguments' => [resume.id] })

      expect(build_state(resume: resume, context: :editor).status_message).to eq(I18n.t('resumes.helper.export_status.messages.queued.with_download'))
    end

    it 'returns the queued message without download variant when no previous PDF exists' do
      resume = create(:resume)
      create(:job_log, :queued, job_type: 'ResumeExportJob', input: { 'arguments' => [resume.id] })

      expect(build_state(resume: resume, context: :editor).status_message).to eq(I18n.t('resumes.helper.export_status.messages.queued.without_download'))
    end
  end

  describe '#status_badge_classes' do
    it 'returns dark emerald classes for ready state in editor context' do
      resume = create(:resume)
      resume.pdf_export.attach(io: StringIO.new('pdf'), filename: 'resume.pdf', content_type: 'application/pdf')

      expect(build_state(resume: resume, context: :editor).status_badge_classes).to include('emerald')
    end

    it 'returns light slate classes for draft state in preview context' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :preview).status_badge_classes).to include('border border-canvas-200/80 bg-canvas-50/88 text-ink-700')
    end
  end

  describe '#widget_attributes' do
    it 'builds widget attributes for the shared export summary card' do
      resume = create(:resume)
      state = build_state(resume: resume, context: :preview)

      attrs = state.widget_attributes

      expect(attrs[:eyebrow]).to eq('Export status')
      expect(attrs[:title]).to eq(state.status_label)
      expect(attrs[:description]).to eq(state.status_message)
      expect(attrs[:tone]).to eq(:subtle)
      expect(attrs[:badge_classes]).to include(state.status_badge_classes)
    end

    it 'uses the dark tone in editor context' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :editor).widget_attributes[:tone]).to eq(:dark)
    end

    it 'uses the default tone in show context' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :show).widget_attributes[:tone]).to eq(:default)
    end
  end

  describe '#download_available?' do
    it 'is true when a PDF is attached in editor context' do
      resume = create(:resume)
      resume.pdf_export.attach(io: StringIO.new('pdf'), filename: 'resume.pdf', content_type: 'application/pdf')

      expect(build_state(resume: resume, context: :editor).download_available?).to be(true)
    end

    it 'is false on the show page even when a PDF is attached' do
      resume = create(:resume)
      resume.pdf_export.attach(io: StringIO.new('pdf'), filename: 'resume.pdf', content_type: 'application/pdf')

      expect(build_state(resume: resume, context: :show).download_available?).to be(false)
    end

    it 'is false when no PDF is attached' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :editor).download_available?).to be(false)
    end
  end

  describe '#download_button_style' do
    it 'returns hero_secondary in editor context' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :editor).download_button_style).to eq(:hero_secondary)
    end

    it 'returns secondary in other contexts' do
      resume = create(:resume)

      expect(build_state(resume: resume, context: :show).download_button_style).to eq(:secondary)
    end
  end
end
