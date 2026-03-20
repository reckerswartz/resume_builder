require 'rails_helper'

RSpec.describe ResumeBuilder::Flow do
  let(:resume) do
    create(
      :resume,
      title: 'Guided Resume',
      summary: 'Short summary',
      contact_details: {
        'full_name' => 'Pat Kumar',
        'email' => 'pat@example.com'
      }
    )
  end
  let(:view_context) { instance_double('view_context') }

  before do
    allow(view_context).to receive(:edit_resume_path) do |resume_record, step:|
      "/resumes/#{resume_record.id}/edit?step=#{step}"
    end
  end

  describe '#total_steps' do
    it 'counts only tracked steps' do
      flow = described_class.new(resume:, requested_step: 'heading', view_context:)

      expect(flow.total_steps).to eq(5)
    end
  end

  describe '#steps' do
    it 'builds step metadata with current state, completion state, and paths' do
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience')
      create(:entry, section: experience_section, content: { 'title' => 'Designer' })

      flow = described_class.new(resume:, requested_step: 'experience', view_context:)
      steps = flow.steps.index_by { |step| step[:key] }

      expect(steps.fetch('source')).to include(current: false, completed: true, path: "/resumes/#{resume.id}/edit?step=source")
      expect(steps.fetch('heading')).to include(current: false, completed: true, path: "/resumes/#{resume.id}/edit?step=heading")
      expect(steps.fetch('personal_details')).to include(current: false, completed: false, path: "/resumes/#{resume.id}/edit?step=personal_details")
      expect(steps.fetch('experience')).to include(current: true, completed: true, path: "/resumes/#{resume.id}/edit?step=experience")
      expect(steps.fetch('finalize')).to include(current: false, completed: false, path: "/resumes/#{resume.id}/edit?step=finalize")
    end
  end

  describe 'step navigation' do
    it 'routes the optional personal details step between heading and experience' do
      flow = described_class.new(resume:, requested_step: 'personal_details', view_context:)

      expect(flow.previous_step_path).to eq("/resumes/#{resume.id}/edit?step=heading")
      expect(flow.next_step_path).to eq("/resumes/#{resume.id}/edit?step=experience")
    end

    it 'returns the previous and next step paths around the current step' do
      flow = described_class.new(resume:, requested_step: 'education', view_context:)

      expect(flow.previous_step_path).to eq("/resumes/#{resume.id}/edit?step=experience")
      expect(flow.next_step_path).to eq("/resumes/#{resume.id}/edit?step=skills")
    end
  end
end
