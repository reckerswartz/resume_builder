require 'rails_helper'

RSpec.describe Resume, type: :model do
  describe 'callbacks' do
    it 'assigns the default template and normalizes stored JSON values' do
      template = create(:template, slug: 'modern')

      resume = described_class.create!(
        user: create(:user),
        title: 'Lead Resume',
        template: nil,
        slug: nil,
        contact_details: { full_name: 'Casey Example' },
        settings: { show_contact_icons: 'false' },
        summary: 'Summary'
      )

      expect(resume.template).to eq(template)
      expect(resume.slug).to eq('lead-resume')
      expect(resume.contact_details).to eq('full_name' => 'Casey Example')
      expect(resume.settings['show_contact_icons']).to eq(false)
    end
  end

  describe '#ordered_sections' do
    it 'returns sections ordered by position' do
      resume = create(:resume)
      later_section = create(:section, resume:, title: 'Projects', position: 2, section_type: 'projects')
      earlier_section = create(:section, resume:, title: 'Experience', position: 0, section_type: 'experience')

      expect(resume.ordered_sections).to eq([earlier_section, later_section])
    end
  end
end
