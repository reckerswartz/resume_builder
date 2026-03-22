require 'rails_helper'

RSpec.describe Resumes::SkillsStepState do
  describe '#suggestions' do
    it 'returns role-aware skill suggestions shaped for the skills step UI' do
      resume = build(
        :resume,
        headline: 'Product Designer',
        intake_details: {
          'experience_level' => 'three_to_five_years',
          'student_status' => 'not_student'
        }
      )

      state = described_class.new(resume: resume)
      suggestions = state.suggestions

      expect(suggestions.fetch(:title)).to include('Product Designer')
      expect(suggestions.fetch(:badge_label)).to eq('Role-aware')
      expect(suggestions.fetch(:results_label)).to match(/\d+ skill sets?/)
      expect(suggestions.fetch(:add_button_label)).to eq('Add this skill')
      expect(suggestions.fetch(:results)).to be_an(Array)
      expect(suggestions.fetch(:results).first).to include(:role_title, :skills, :skills_text, :expert_badge_label, :audience_badge_label)
    end

    it 'returns early-career badge for early-career resumes' do
      resume = build(
        :resume,
        headline: '',
        intake_details: {
          'experience_level' => 'no_experience',
          'student_status' => 'not_student'
        }
      )

      state = described_class.new(resume: resume)
      suggestions = state.suggestions

      expect(suggestions.fetch(:badge_label)).to eq('Early-career friendly')
      expect(suggestions.fetch(:description)).to include('coursework')
    end

    it 'provides skills_text as newline-joined skill names' do
      resume = build(
        :resume,
        headline: 'Software Engineer',
        intake_details: { 'experience_level' => 'five_to_ten_years' }
      )

      state = described_class.new(resume: resume)
      result = state.suggestions.fetch(:results).first

      expect(result.fetch(:skills_text)).to eq(result.fetch(:skills).join("\n"))
    end
  end
end
