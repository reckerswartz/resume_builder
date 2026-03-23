require 'rails_helper'

RSpec.describe Resumes::ShowState do
  let(:resume) { create(:resume, title: 'Guided Resume') }
  let(:builder_state) do
    instance_double(
      ResumeBuilder::EditorState,
      completion_percentage: 40,
      current_step: { key: 'experience' }
    )
  end
  let(:view_context) { instance_double('view_context') }
  let(:export_actions_state) { instance_double(Resumes::ExportActionsState) }
  let(:export_status_state) { instance_double(Resumes::ExportStatusState) }

  subject(:show_state) { described_class.new(resume:, builder_state:, view_context:) }

  before do
    allow(view_context).to receive(:resumes_path).and_return('/resumes')
    allow(view_context).to receive(:edit_resume_path).with(resume, step: 'experience').and_return("/resumes/#{resume.id}/edit?step=experience")
    allow(view_context).to receive(:resume_export_actions_state).with(resume, context: :show).and_return(export_actions_state)
    allow(view_context).to receive(:resume_export_status_state).with(resume, context: :show).and_return(export_status_state)
  end

  describe '#page_header_attributes' do
    it 'builds the shared show-page header payload' do
      expect(show_state.page_header_attributes).to eq(
        eyebrow: 'Preview',
        title: 'Guided Resume',
        description: 'Review the latest preview, check export status, and decide whether to download or keep editing.',
        badges: [
          { label: resume.template.name, tone: :neutral },
          { label: '40% complete', tone: :neutral },
          { label: 'Draft', tone: :neutral }
        ],
        actions: [
          { label: 'Back to workspace', path: '/resumes', style: :secondary, size: :sm },
          { label: 'Edit resume', path: "/resumes/#{resume.id}/edit?step=experience", style: :secondary, size: :sm }
        ],
        density: :compact
      )
    end
  end

  describe '#artifact_badges' do
    it 'builds the preview artifact badge cluster' do
      expect(show_state.artifact_badges).to eq(
        [
          { label: resume.template.name, tone: :neutral },
          { label: 'Draft', tone: :neutral }
        ]
      )
    end
  end

  describe '#export_actions_state' do
    it 'delegates shared export action state for the show context' do
      expect(show_state.export_actions_state).to eq(export_actions_state)
    end
  end

  describe '#export_status_state' do
    it 'delegates shared export status state for the show context' do
      expect(show_state.export_status_state).to eq(export_status_state)
    end
  end

  describe '#preview_surface_attributes' do
    it 'builds the presenter-backed preview body wrapper attributes' do
      expect(show_state.preview_surface_attributes).to eq(
        tag: :div,
        padding: :none,
        extra_classes: 'p-4 sm:p-6'
      )
    end
  end
end
