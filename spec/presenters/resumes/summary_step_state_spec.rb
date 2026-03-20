require 'rails_helper'

RSpec.describe Resumes::SummaryStepState do
  let(:view_context) { instance_double('view_context') }

  describe '#query' do
    it 'falls back to the resume headline when no explicit query is provided' do
      resume = build(:resume, headline: 'Product Manager')

      state = described_class.new(resume: resume, query: '', view_context: view_context)

      expect(state.query).to eq('Product Manager')
      expect(state.related_roles).to include(
        include(title: 'Project Manager', query: 'Project Manager'),
        include(title: 'Customer Success Manager', query: 'Customer Success Manager')
      )
      expect(state.results.first).to include(
        role_title: 'Product Manager',
        expert_recommended: true,
        expert_badge_label: 'Expert Recommended'
      )
      expect(state.results_label).to eq('2 summary examples')
    end
  end

  describe '#results' do
    it 'applies experience-aware labels for early-career searches' do
      resume = build(
        :resume,
        headline: 'Software Engineer',
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'student'
        }
      )

      state = described_class.new(resume: resume, query: 'software engineer', view_context: view_context)

      expect(state.results.first).to include(
        role_title: 'Software Engineer',
        experience_badge_label: 'Early career'
      )
      expect(state.guidance_message).to include('Software Engineer')
    end
  end
end
