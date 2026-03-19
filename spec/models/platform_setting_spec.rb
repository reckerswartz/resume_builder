require 'rails_helper'

RSpec.describe PlatformSetting, type: :model do
  describe '.current' do
    it 'returns the global settings record' do
      expect { described_class.current }.to change(described_class, :count).by(1)
      expect(described_class.current.name).to eq('global')
    end
  end

  describe '#feature_enabled?' do
    it 'casts stored feature flag values to booleans' do
      setting = described_class.create!(name: 'global', feature_flags: { llm_access: 'true' }, preferences: {})

      expect(setting.feature_enabled?('llm_access')).to eq(true)
    end
  end
end
