require 'rails_helper'

RSpec.describe Resumes::TemplateRecommendationService do
  let(:resume) { build(:resume, intake_details:) }
  let(:ats_template) { create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal')) }
  let(:sidebar_template) { create(:template, name: 'Sidebar Indigo', slug: 'sidebar-indigo', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')) }
  let(:modern_template) { create(:template, name: 'Modern Slate', slug: 'modern-slate', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')) }
  let(:template_cards) do
    [
      {
        template: ats_template,
        family: 'ats-minimal',
        density: 'compact',
        shell_style: 'flat',
        entry_style: 'list',
        sidebar_section_labels: []
      },
      {
        template: sidebar_template,
        family: 'sidebar-accent',
        density: 'comfortable',
        shell_style: 'card',
        entry_style: 'list',
        sidebar_section_labels: ['Education', 'Skills']
      },
      {
        template: modern_template,
        family: 'modern',
        density: 'comfortable',
        shell_style: 'card',
        entry_style: 'cards',
        sidebar_section_labels: []
      }
    ]
  end

  subject(:recommendations) do
    described_class.new(resume: resume, template_cards: template_cards).call
  end

  context 'when the resume has no intake signal' do
    let(:intake_details) { {} }

    it 'returns no recommendations' do
      expect(recommendations).to eq([])
    end
  end

  context 'when the resume is for an early-career student' do
    let(:intake_details) do
      {
        'experience_level' => 'less_than_3_years',
        'student_status' => 'student'
      }
    end

    it 'prioritizes ATS-friendly and education-forward templates' do
      expect(recommendations).to eq(
        [
          {
            template_id: ats_template.id,
            badge_label: 'Recommended',
            reason: 'Best for early-career resumes'
          },
          {
            template_id: sidebar_template.id,
            badge_label: 'Recommended',
            reason: 'Highlights education and skills for student resumes'
          }
        ]
      )
    end
  end
end
