require 'rails_helper'

RSpec.describe Resumes::SkillSuggestionCatalog do
  describe '#call' do
    it 'returns role-aware skill suggestions for a matching headline' do
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
      expect(state.results.first.fetch(:skills)).to include('Ruby on Rails', 'PostgreSQL')
    end

    it 'prefers early-career skill sets for early-career experience levels' do
      resume = build(
        :resume,
        headline: '',
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'not_student'
        }
      )

      state = described_class.new(resume: resume, query: '').call

      expect(state.results.first).to include(
        role_key: 'software_engineer',
        audience_key: 'early_career'
      )
      expect(state.results.first.fetch(:skills)).to include('Python', 'JavaScript')
    end

    it 'returns up to 4 unique role results' do
      resume = build(
        :resume,
        headline: '',
        intake_details: { 'experience_level' => 'five_to_ten_years' }
      )

      state = described_class.new(resume: resume, query: '').call

      expect(state.results.size).to be <= 4
      role_keys = state.results.map { |r| r.fetch(:role_key) }
      expect(role_keys).to eq(role_keys.uniq)
    end

    it 'returns skills as an array of strings for each result' do
      resume = build(
        :resume,
        headline: 'Data Analyst',
        intake_details: { 'experience_level' => 'three_to_five_years' }
      )

      state = described_class.new(resume: resume, query: 'data analyst').call

      state.results.each do |result|
        expect(result.fetch(:skills)).to all(be_a(String))
        expect(result.fetch(:skills).size).to be >= 1
      end
    end
  end
end
