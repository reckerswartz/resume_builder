require 'rails_helper'

RSpec.describe ResumeTemplates::ComponentResolver do
  describe '.component_class_for' do
    it 'uses the normalized template family instead of relying on slug-only mapping' do
      template = create(
        :template,
        slug: 'legacy-template',
        layout_config: {
          'family' => 'classic',
          'variant' => 'classic',
          'accent_color' => '#1D4ED8',
          'font_scale' => 'sm',
          'density' => 'compact'
        }
      )
      resume = create(:resume, template: template)

      expect(described_class.component_class_for(resume)).to eq(ResumeTemplates::ClassicComponent)
    end

    it 'falls back to the modern component for unknown families' do
      template = create(
        :template,
        slug: 'legacy-template',
        layout_config: {
          'family' => 'unknown',
          'accent_color' => '#0F172A'
        }
      )
      resume = create(:resume, template: template)

      expect(described_class.component_class_for(resume)).to eq(ResumeTemplates::ModernComponent)
    end
  end
end
