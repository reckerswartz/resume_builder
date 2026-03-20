require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe 'callbacks' do
    it 'assigns the next position and strips blank highlights' do
      section = create(:section)
      create(:entry, section:, position: 0)

      entry = described_class.create!(section:, content: { title: 'Lead Engineer', highlights: ['Improved search', ''] })

      expect(entry.position).to eq(1)
      expect(entry.content['title']).to eq('Lead Engineer')
      expect(entry.highlights).to eq(['Improved search'])
    end

    it 'keeps experience boolean fields stored as normalized JSON values' do
      entry = described_class.create!(section: create(:section), content: { remote: true, current_role: false })

      expect(entry.content).to include('remote' => true, 'current_role' => false)
    end
  end
end
