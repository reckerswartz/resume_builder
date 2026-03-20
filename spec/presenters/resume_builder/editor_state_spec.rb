require 'rails_helper'

RSpec.describe ResumeBuilder::EditorState do
  let(:resume) do
    create(
      :resume,
      title: 'Guided Resume',
      contact_details: {
        'full_name' => 'Pat Kumar',
        'email' => 'pat@example.com'
      }
    )
  end
  let(:view_context) { instance_double('view_context') }
  let(:flow) { ResumeBuilder::Flow.new(resume:, requested_step:, view_context:) }

  subject(:editor_state) { described_class.new(resume:, flow:, view_context:) }

  before do
    allow(view_context).to receive(:edit_resume_path) do |resume_record, step:|
      "/resumes/#{resume_record.id}/edit?step=#{step}"
    end
    allow(view_context).to receive(:resume_primary_identity).with(resume).and_return('Pat Kumar')
    allow(view_context).to receive(:resumes_path).and_return('/resumes')
    allow(view_context).to receive(:resume_path) do |resume_record, step: nil|
      path = "/resumes/#{resume_record.id}"
      step.present? ? "#{path}?step=#{step}" : path
    end
  end

  context 'when the source step is active' do
    let(:requested_step) { 'source' }

    it 'exposes the initial builder shell state' do
      expect(editor_state.current_step).to include(key: 'source', current: true)
      expect(editor_state.step_partial).to eq('editor_source_step')
      expect(editor_state.next_step).to include(key: 'heading')
      expect(editor_state.go_back_path).to eq('/resumes')
      expect(editor_state.go_back_link_options).to eq(data: { turbo_frame: '_top' })
      expect(editor_state.step_sections).to eq([])
      expect(editor_state.add_section_types).to eq([])
      expect(editor_state.primary_identity).to eq('Pat Kumar')
      expect(editor_state.current_step_avatar_text).to eq('SO')
      expect(editor_state.hero_badges).to include(label: 'Pat Kumar', tone: :hero)
      expect(editor_state.progress_card_attributes).to include(eyebrow: 'Progress', tone: :default, padding: :sm)
      expect(editor_state.next_step_card_attributes).to include(title: 'Heading', eyebrow: 'Next move', tone: :subtle)
      expect(editor_state.navigation_actions.map { |action| action[:label] }).to eq([ 'Back to workspace', 'Preview', 'Go back', 'Next: Heading' ])
      expect(editor_state.navigation_actions.second).to include(path: "/resumes/#{resume.id}?step=source")
      expect(editor_state.builder_tab_items.first).to include(label: 'Source', current: true, badge: 1, status: 'Current')
    end
  end

  context 'when the optional personal details step is active' do
    let(:requested_step) { 'personal_details' }

    it 'routes through the dedicated optional step' do
      expect(editor_state.current_step).to include(key: 'personal_details', current: true)
      expect(editor_state.step_partial).to eq('editor_personal_details_step')
      expect(editor_state.next_step).to include(key: 'experience')
      expect(editor_state.go_back_path).to eq("/resumes/#{resume.id}/edit?step=heading")
      expect(editor_state.builder_tab_items.third).to include(label: 'Personal details', current: true, badge: 3, status: 'Current')
    end
  end

  context 'when a section-backed step is active' do
    let(:requested_step) { 'experience' }
    let!(:experience_section) { create(:section, resume:, section_type: 'experience', title: 'Experience') }
    let!(:project_section) { create(:section, resume:, section_type: 'projects', title: 'Projects') }

    it 'scopes sections and navigation to the active step' do
      expect(editor_state.current_step).to include(key: 'experience', current: true)
      expect(editor_state.step_partial).to eq('editor_section_step')
      expect(editor_state.step_sections).to eq([ experience_section ])
      expect(editor_state.add_section_types).to eq([ 'experience' ])
      expect(editor_state.next_step).to include(key: 'education')
      expect(editor_state.go_back_path).to eq("/resumes/#{resume.id}/edit?step=personal_details")
      expect(editor_state.go_back_link_options).to eq({})
      expect(editor_state.next_step_card_attributes).to include(title: 'Education')
      expect(editor_state.navigation_actions.second).to include(path: "/resumes/#{resume.id}?step=experience")
      expect(editor_state.navigation_actions.last).to include(label: 'Next: Education', path: "/resumes/#{resume.id}/edit?step=education")
      expect(editor_state.builder_tab_items.fourth).to include(label: 'Experience', current: true, badge: 4, status: 'Current')
      expect(editor_state.builder_tab_items.map { |item| item[:label] }).not_to include(project_section.title)
    end
  end
end
