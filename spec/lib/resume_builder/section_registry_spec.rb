require 'rails_helper'

RSpec.describe ResumeBuilder::SectionRegistry do
  describe '.section_types_for_step' do
    it 'returns the section types mapped to a builder step' do
      expect(described_class.section_types_for_step('experience')).to eq(['experience'])
      expect(described_class.section_types_for_step('finalize')).to eq(['projects'])
    end
  end

  describe '.starter_sections' do
    it 'returns starter definitions for the registered resume sections' do
      expect(described_class.starter_sections.map { |definition| definition[:section_type] }).to eq(%w[experience education skills projects])
    end
  end
end
