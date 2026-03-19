require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'callbacks' do
    it 'normalizes the slug from the name when needed' do
      template = described_class.create!(
        name: 'Modern Resume',
        slug: '',
        description: 'Description',
        active: true,
        layout_config: {}
      )

      expect(template.slug).to eq('modern-resume')
    end
  end

  describe '.default!' do
    it 'returns the first active template' do
      described_class.update_all(active: false)
      inactive = create(:template, active: false, created_at: 2.days.ago)
      active = create(:template, active: true, created_at: 1.day.ago)

      expect(described_class.default!).to eq(active)
      expect(described_class.default!).not_to eq(inactive)
    end
  end
end
