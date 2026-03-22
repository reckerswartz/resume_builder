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

  describe '#current_implementation' do
    it 'returns the most recent render-ready implementation' do
      template = create(:template, slug: 'modern')
      create(:template_implementation, template: template, status: 'draft', created_at: 3.days.ago)
      older = create(:template_implementation, template: template, status: 'validated', created_at: 2.days.ago)
      newer = create(:template_implementation, template: template, status: 'stable', created_at: 1.day.ago)

      expect(template.current_implementation).to eq(newer)
      expect(template.current_implementation).not_to eq(older)
    end

    it 'prefers higher lifecycle stages over newer lower-stage render-ready records' do
      template = create(:template, slug: 'modern')
      seeded = create(:template_implementation, template: template, status: 'seeded', seeded_at: 2.days.ago, validated_at: 4.days.ago)
      create(:template_implementation, template: template, status: 'validated', validated_at: 1.hour.ago)

      expect(template.current_implementation).to eq(seeded)
    end

    it 'ignores archived implementations when resolving the current implementation' do
      template = create(:template, slug: 'modern')
      create(:template_implementation, template: template, status: 'archived', metadata: { 'archived_at' => Time.current.iso8601, 'archived_from_status' => 'seeded' }, seeded_at: 2.hours.ago, validated_at: 1.day.ago)
      validated = create(:template_implementation, template: template, status: 'validated', validated_at: 1.hour.ago)

      expect(template.current_implementation).to eq(validated)
    end
  end

  describe '#render_layout_config' do
    it 'prefers the current implementation render profile over the raw template layout config' do
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
          'accent_color' => '#1d4ed8',
          'density' => 'compact'
        }
      )

      expect(template.render_layout_config).to include(
        'family' => 'classic',
        'accent_color' => '#1d4ed8',
        'density' => 'compact'
      )
    end

    it 'falls back to the normalized template layout config when no render-ready implementation exists' do
      template = create(
        :template,
        slug: 'modern',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')
      )
      create(:template_implementation, template: template, status: 'draft', renderer_family: 'classic', render_profile: { 'family' => 'classic' })

      expect(template.render_layout_config).to include('family' => 'modern')
    end
  end
end
