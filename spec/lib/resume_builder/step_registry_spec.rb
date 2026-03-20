require 'rails_helper'

RSpec.describe ResumeBuilder::StepRegistry do
  describe '.fetch' do
    it 'falls back to the heading step when the requested step is unknown' do
      expect(described_class.fetch('unknown').fetch(:key)).to eq('heading')
    end
  end

  describe '.section_types_for' do
    it 'returns the registered section types for the finalize step' do
      expect(described_class.section_types_for('finalize')).to eq(['projects'])
    end
  end

  describe '.tracked_steps' do
    it 'excludes the finalize step from completion tracking' do
      expect(described_class.tracked_steps.map { |step| step.fetch(:key) }).to eq(%w[heading experience education skills summary])
    end
  end
end
