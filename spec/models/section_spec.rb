require 'rails_helper'

RSpec.describe Section, type: :model do
  describe 'callbacks' do
    it 'assigns the next position, default title, and stringified settings keys' do
      resume = create(:resume)
      create(:section, resume:, position: 0)

      section = described_class.create!(resume:, section_type: 'education', title: '', settings: { display_style: 'compact' })

      expect(section.position).to eq(1)
      expect(section.title).to eq('Education')
      expect(section.settings).to eq('display_style' => 'compact')
    end
  end
end
