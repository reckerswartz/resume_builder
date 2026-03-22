require 'rails_helper'

RSpec.describe Resumes::SkillsStepState do
  describe '#section_guidance' do
    it 'returns early-career framing when the resume has no_experience' do
      resume = build(:resume, intake_details: { 'experience_level' => 'no_experience' })
      guidance = described_class.new(resume: resume).section_guidance

      expect(guidance[:title]).to eq('Start with what you know')
      expect(guidance[:badge]).to eq('Early-career friendly')
      expect(guidance[:description]).to include('tools, languages, and soft skills')
      expect(guidance[:suggestions]).to be_present
      expect(guidance[:suggestions].first[:skills]).to be_an(Array)
      expect(guidance[:suggestions].first[:audience_badge_label]).to eq('Early career')
    end

    it 'returns experienced framing when the resume has five_to_ten_years' do
      resume = build(:resume, intake_details: { 'experience_level' => 'five_to_ten_years' })
      guidance = described_class.new(resume: resume).section_guidance

      expect(guidance[:title]).to eq('Lead with your strongest skills')
      expect(guidance[:badge]).to eq('Role-aware')
      expect(guidance[:description]).to include('driven results')
      expect(guidance[:suggestions]).to be_present
      expect(guidance[:suggestions].first[:audience_badge_label]).to eq('Growth stage')
    end

    it 'returns experienced framing when the resume has no experience level set' do
      resume = build(:resume, intake_details: {})
      guidance = described_class.new(resume: resume).section_guidance

      expect(guidance[:title]).to eq('Lead with your strongest skills')
    end

    it 'includes strength-ordered skills with rank metadata' do
      resume = build(:resume, intake_details: { 'experience_level' => 'three_to_five_years' })
      guidance = described_class.new(resume: resume).section_guidance

      suggestion = guidance[:suggestions].first
      expect(suggestion[:strength_order]).to be_an(Array)
      expect(suggestion[:strength_order].first).to include(:skill, :rank)
      expect(suggestion[:strength_order].first[:rank]).to eq(1)
    end
  end
end
