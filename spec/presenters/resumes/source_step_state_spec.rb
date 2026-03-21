require 'rails_helper'

RSpec.describe Resumes::SourceStepState do
  let(:view_context) do
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    view = controller.view_context
    view
  end

  def build_state(resume:, autofill_enabled: true)
    described_class.new(resume: resume, autofill_enabled: autofill_enabled, view_context: view_context)
  end

  describe '#autofill_status_label' do
    it 'returns a ready label for pasted source text' do
      resume = create(:resume, source_mode: 'paste', source_text: 'Existing resume text')

      expect(build_state(resume: resume).autofill_status_label).to eq('Paste import ready')
    end

    it 'returns a paste-required label when paste text is blank' do
      resume = create(:resume, source_mode: 'paste', source_text: '')

      expect(build_state(resume: resume).autofill_status_label).to eq(I18n.t('resumes.helper.source_autofill.labels.paste_required'))
    end

    it 'returns a reference-only label for unsupported uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('legacy'), filename: 'resume.doc', content_type: 'application/msword')

      expect(build_state(resume: resume).autofill_status_label).to eq('Reference file only')
    end

    it 'returns an upload-ready label for supported uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('resume'), filename: 'resume.txt', content_type: 'text/plain')

      expect(build_state(resume: resume).autofill_status_label).to eq('Upload import ready')
    end

    it 'returns an unavailable label when autofill is disabled' do
      resume = create(:resume, source_mode: 'paste', source_text: 'Text')

      expect(build_state(resume: resume, autofill_enabled: false).autofill_status_label).to eq(I18n.t('resumes.helper.source_autofill.labels.unavailable'))
    end

    it 'returns a choose-import label for scratch mode' do
      resume = create(:resume, source_mode: nil)

      expect(build_state(resume: resume).autofill_status_label).to eq('Choose an import path')
    end
  end

  describe '#autofill_status_message' do
    it 'returns a ready message for pasted text' do
      resume = create(:resume, source_mode: 'paste', source_text: 'Some text')

      expect(build_state(resume: resume).autofill_status_message).to include('Pasted text')
    end

    it 'returns a ready message for supported uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('text'), filename: 'resume.txt', content_type: 'text/plain')

      expect(build_state(resume: resume).autofill_status_message).to include('converted into source text')
    end
  end

  describe '#autofill_action_ready?' do
    it 'returns true for a supported uploaded source document' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('text'), filename: 'resume.txt', content_type: 'text/plain')

      expect(build_state(resume: resume).autofill_action_ready?).to be(true)
    end

    it 'returns false when autofill is disabled' do
      resume = create(:resume, source_mode: 'paste', source_text: 'Text')

      expect(build_state(resume: resume, autofill_enabled: false).autofill_action_ready?).to be(false)
    end

    it 'returns true for paste mode with text present' do
      resume = create(:resume, source_mode: 'paste', source_text: 'Resume text')

      expect(build_state(resume: resume).autofill_action_ready?).to be(true)
    end

    it 'returns false for scratch mode' do
      resume = create(:resume, source_mode: nil)

      expect(build_state(resume: resume).autofill_action_ready?).to be(false)
    end
  end

  describe '#upload_review_state' do
    it 'returns nil when no document is attached' do
      resume = create(:resume)

      expect(build_state(resume: resume).upload_review_state).to be_nil
    end

    it 'returns a ready-for-AI review state for supported uploads with autofill' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('text'), filename: 'resume.txt', content_type: 'text/plain')

      state = build_state(resume: resume).upload_review_state

      expect(state).to include(
        title: 'Ready for AI import',
        badge_label: 'Autofill supported',
        badge_tone: :success,
        filename: 'resume.txt',
        content_type: 'text/plain'
      )
    end

    it 'returns a reference-only review state for unsupported uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('doc'), filename: 'resume.doc', content_type: 'application/msword')

      state = build_state(resume: resume).upload_review_state

      expect(state).to include(
        title: 'Reference file only',
        badge_label: 'Reference only',
        badge_tone: :neutral,
        filename: 'resume.doc'
      )
    end
  end

  describe '#document_autofill_supported?' do
    it 'returns true for text uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('text'), filename: 'resume.txt', content_type: 'text/plain')

      expect(build_state(resume: resume).document_autofill_supported?).to be(true)
    end

    it 'returns false for unsupported uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('doc'), filename: 'resume.doc', content_type: 'application/msword')

      expect(build_state(resume: resume).document_autofill_supported?).to be(false)
    end
  end

  describe '#cloud_import_provider_states' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return(nil)
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return(nil)
    end

    it 'returns provider states with setup-required status for unconfigured providers' do
      resume = create(:resume)

      states = build_state(resume: resume).cloud_import_provider_states
      google = states.find { |s| s[:key] == 'google_drive' }

      expect(google).to include(
        status_tone: :warning,
        status_label: I18n.t('resumes.helper.source_cloud_import.status.setup_required')
      )
    end
  end
end
