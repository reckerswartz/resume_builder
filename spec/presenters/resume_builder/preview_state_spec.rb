require 'rails_helper'

RSpec.describe ResumeBuilder::PreviewState do
  let(:resume) { create(:resume, title: 'Guided Resume') }
  let(:builder_state) do
    instance_double(
      ResumeBuilder::EditorState,
      completion_percentage: 40,
      current_step: { key: 'experience' }
    )
  end
  let(:view_context) { instance_double('view_context') }
  let(:export_status_state) { instance_double(Resumes::ExportStatusState) }

  subject(:preview_state) { described_class.new(resume:, builder_state:, view_context:) }

  before do
    allow(view_context).to receive(:resume_export_status_state).with(resume, context: :preview).and_return(export_status_state)
    allow(view_context).to receive(:resume_path).with(resume, step: 'experience').and_return("/resumes/#{resume.id}?step=experience")
  end

  describe '#panel_attributes' do
    it 'builds the shared preview panel payload' do
      expect(preview_state.panel_attributes).to eq(
        eyebrow: 'Live preview',
        title: 'Check the page as you edit',
        description: 'Use this rail to compare changes without leaving the builder.',
        padding: :sm,
        density: :compact
      )
    end
  end

  describe '#badges' do
    it 'exposes preview badges from the resume and builder progress' do
      expect(preview_state.badges).to eq([
        { label: resume.template.name, tone: :neutral },
        { label: '40% complete', tone: :neutral }
      ])
    end
  end

  describe '#sync_card_attributes' do
    it 'describes the live sync state card' do
      expect(preview_state.sync_card_attributes).to eq(
        eyebrow: 'Save status',
        title: 'Autosave on',
        description: 'Field changes save in place while the live preview refreshes.',
        padding: :sm
      )
    end
  end

  describe '#preview_page_action' do
    it 'links to the dedicated preview page while preserving the current builder step' do
      expect(preview_state.preview_page_action).to eq(
        label: 'Open preview',
        path: "/resumes/#{resume.id}?step=experience",
        style: :secondary,
        size: :sm,
        options: { data: { turbo_frame: '_top' } }
      )
    end
  end

  describe '#export_status_state' do
    it 'delegates preview export summary state to the shared export status presenter' do
      expect(preview_state.export_status_state).to eq(export_status_state)
    end
  end
end
