require 'rails_helper'

RSpec.describe ResumeBuilder::WorkspaceState do
  let(:resume) do
    create(
      :resume,
      title: 'Guided Resume',
      headline: headline,
      contact_details: {
        'full_name' => 'Pat Kumar',
        'email' => 'pat@example.com'
      }
    )
  end
  let(:headline) { '' }
  let(:builder_state) do
    instance_double(
      ResumeBuilder::EditorState,
      primary_identity: 'Pat Kumar',
      completed_steps_count: 2,
      total_steps: 5,
      completion_percentage: 40,
      current_step: { key: 'experience' }
    )
  end
  let(:view_context) { instance_double('view_context') }

  subject(:workspace_state) { described_class.new(resume:, builder_state:, view_context:) }

  before do
    create(:section, resume:, section_type: 'experience', title: 'Experience').tap do |section|
      create(:entry, section:)
    end
    create(:section, resume:, section_type: 'skills', title: 'Skills').tap do |section|
      create(:entry, section:, content: { 'name' => 'Ruby on Rails', 'level' => 'Advanced' })
    end

    allow(view_context).to receive(:resume_identity_initials).with(resume).and_return('PK')
    allow(view_context).to receive(:resumes_path).and_return('/resumes')
    allow(view_context).to receive(:resume_path).with(resume, step: 'experience').and_return("/resumes/#{resume.id}?step=experience")
    allow(view_context).to receive(:pluralize).with(2, 'entry').and_return('2 entries')
  end

  describe '#page_header_attributes' do
    it 'builds the shared page header payload for the edit workspace' do
      expect(workspace_state.page_header_attributes).to eq(
        eyebrow: 'Guided builder',
        title: 'Guided Resume',
        description: 'Work through each step for Pat Kumar while the preview stays visible.',
        badges: [
          { label: resume.template.name, tone: :neutral },
          { label: '2/5 steps ready', tone: :neutral }
        ],
        actions: [
          { label: 'Back to workspace', path: '/resumes', style: :secondary },
          { label: 'Open preview', path: "/resumes/#{resume.id}?step=experience", style: :primary }
        ],
        density: :compact
      )
    end

    context 'when the resume already has a headline' do
      let(:headline) { 'Senior Product Engineer' }

      it 'prefers the existing headline over the fallback description' do
        expect(workspace_state.page_header_attributes.fetch(:description)).to eq('Senior Product Engineer')
      end
    end
  end
end
