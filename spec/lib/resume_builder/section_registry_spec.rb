require 'rails_helper'

RSpec.describe ResumeBuilder::SectionRegistry do
  describe '.section_types_for_step' do
    it 'returns the section types mapped to a builder step' do
      expect(described_class.section_types_for_step('experience')).to eq(['experience'])
      expect(described_class.section_types_for_step('finalize')).to eq(['projects'])
    end
  end

  describe '.fetch' do
    it 'returns localized section titles and field labels' do
      experience = described_class.fetch('experience')
      projects = described_class.fetch('projects')

      expect(experience).to include(title: 'Experience')
      expect(experience.fetch(:fields)).to include(
        include(key: 'title', label: 'Job title *'),
        include(key: 'current_role', label: 'I currently work here'),
        include(key: 'summary', label: 'Summary')
      )

      expect(projects).to include(title: 'Projects')
      expect(projects.fetch(:fields)).to include(
        include(key: 'name', label: 'Project'),
        include(key: 'highlights_text', label: 'Highlights')
      )
    end
  end

  describe '.starter_sections' do
    it 'returns starter definitions for the registered resume sections' do
      expect(described_class.starter_sections.map { |definition| definition[:section_type] }).to eq(%w[experience education skills projects])
    end
  end
end
