require 'rails_helper'

RSpec.describe Resumes::ExperienceStepState do
  describe '#suggestions_for' do
    it 'uses the current entry title for role-aware guidance when present' do
      resume = build(
        :resume,
        headline: 'Product Manager',
        intake_details: {
          'experience_level' => 'three_to_five_years',
          'student_status' => 'not_student'
        }
      )
      entry = build(:entry, content: { 'title' => 'Software Engineer' })

      state = described_class.new(resume: resume)
      guidance = state.suggestions_for(entry)

      expect(guidance.fetch(:title)).to eq('Bullet ideas for Software Engineer')
      expect(guidance.fetch(:badge_label)).to eq('Role-aware')
      expect(guidance.fetch(:results).first).to include(
        role_title: 'Software Engineer',
        audience_badge_label: 'Growth stage'
      )
    end

    it 'falls back to early-career framing when the resume has early-career intake signals' do
      resume = build(
        :resume,
        headline: '',
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'student'
        }
      )
      entry = build(:entry, content: {})

      state = described_class.new(resume: resume)
      guidance = state.suggestions_for(entry)

      expect(guidance.fetch(:badge_label)).to eq('Early-career friendly')
      expect(guidance.fetch(:description)).to include('Internships, teaching help, tutoring, volunteering')
      expect(guidance.fetch(:results).map { |result| result.fetch(:role_title) }).to include('Teaching Assistant', 'Tutor')
    end
  end
end
