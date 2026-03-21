require 'rails_helper'

RSpec.describe ResumeTemplates::PreviewResumeBuilder do
  describe '#call' do
    it 'builds an unsaved sample resume with starter sections for gallery rendering' do
      template = create(:template, name: 'Modern Slate')

      preview_resume = described_class.new(template: template).call

      expect(preview_resume).to be_a(Resume)
      expect(preview_resume).not_to be_persisted
      expect(preview_resume.template).to eq(template)
      expect(preview_resume.title).to eq('Modern Slate Preview')
      expect(preview_resume.headline).to eq('Lead Product Engineer')
      expect(preview_resume.summary).to include('ATS-friendly resume experiences')
      expect(preview_resume.contact_field('full_name')).to eq('Jordan Lee')
      expect(preview_resume.contact_field('location')).to eq('Austin, United States')
      expect(preview_resume.settings).to include('accent_color' => template.normalized_layout_config.fetch('accent_color'))
      expect(preview_resume.ordered_sections.map(&:section_type)).to eq(ResumeBuilder::SectionRegistry.types)
      expect(preview_resume.ordered_sections.flat_map(&:ordered_entries)).not_to be_empty
    end

    it 'uses the render-ready implementation accent color when building the preview resume' do
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

      preview_resume = described_class.new(template: template).call

      expect(preview_resume.settings).to include('accent_color' => '#1D4ED8')
    end

    it 'uses the requested accent color when rendering a variant preview' do
      template = create(
        :template,
        slug: 'classic-ivory',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )

      preview_resume = described_class.new(template: template, accent_color: '#334155').call

      expect(preview_resume.settings).to include('accent_color' => '#334155')
    end
  end
end
