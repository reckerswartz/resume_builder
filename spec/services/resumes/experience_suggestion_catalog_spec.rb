require 'rails_helper'

RSpec.describe Resumes::ExperienceSuggestionCatalog do
  describe '#call' do
    it 'returns role-aware bullet suggestions for a matching experience title' do
      resume = build(
        :resume,
        headline: 'Senior Product Engineer',
        intake_details: {
          'experience_level' => 'three_to_five_years',
          'student_status' => 'not_student'
        }
      )

      state = described_class.new(resume: resume, query: 'software engineer').call

      expect(state.query).to eq('Software Engineer')
      expect(state.results.first).to include(
        role_key: 'software_engineer',
        role_title: 'Software Engineer',
        audience_key: 'growth_stage'
      )
      expect(state.results.first.fetch(:highlights).first).to include('Led end-to-end delivery')
    end

    it 'prefers early-career-friendly examples when the resume has early-career student signals' do
      resume = build(
        :resume,
        headline: '',
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'student'
        }
      )

      state = described_class.new(resume: resume, query: '').call

      expect(state.results.first).to include(
        role_key: 'teaching_assistant',
        audience_key: 'student_friendly'
      )
      expect(state.results.map { |result| result.fetch(:role_title) }).to include('Teaching Assistant', 'Tutor', 'Internship Experience')
    end
  end
end
