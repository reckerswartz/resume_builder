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

    it 'prefers the render-ready implementation profile when selecting the component class' do
      template = create(
        :template,
        slug: 'modern',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')
      )
      create(
        :template_implementation,
        template: template,
        status: 'validated',
        renderer_family: 'classic',
        render_profile: {
          'family' => 'classic',
          'accent_color' => '#1D4ED8'
        }
      )
      resume = create(:resume, template: template)

      expect(described_class.component_class_for(resume)).to eq(ResumeTemplates::ClassicComponent)
    end
  end
end
