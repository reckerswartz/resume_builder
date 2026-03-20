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

    it 'normalizes layout config into a renderable family-based shape' do
      template = described_class.create!(
        name: 'Legacy Classic',
        slug: 'legacy-classic',
        description: 'Description',
        active: true,
        layout_config: {
          variant: 'classic',
          accent_color: '#abc',
          font_scale: 'invalid',
          density: 'invalid'
        }
      )

      expect(template.layout_family).to eq('classic')
      expect(template.layout_config).to include(
        'family' => 'classic',
        'variant' => 'classic',
        'accent_color' => '#aabbcc',
        'font_scale' => 'sm',
        'density' => 'compact',
        'column_count' => 'single_column',
        'theme_tone' => 'blue',
        'supports_headshot' => false,
        'shell_style' => 'flat',
        'header_style' => 'rule',
        'section_heading_style' => 'rule',
        'skill_style' => 'inline',
        'entry_style' => 'list'
      )
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
