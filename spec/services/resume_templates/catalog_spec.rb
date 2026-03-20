require 'rails_helper'

RSpec.describe ResumeTemplates::Catalog do
  describe '.families' do
    it 'includes the new phase 2 families' do
      expect(described_class.families).to include('ats-minimal', 'professional', 'modern-clean', 'sidebar-accent')
    end
  end

  describe '.default_layout_config' do
    it 'returns the sidebar accent defaults with sidebar metadata intact' do
      expect(described_class.default_layout_config(family: 'sidebar-accent')).to include(
        'family' => 'sidebar-accent',
        'variant' => 'sidebar-accent',
        'accent_color' => '#4338CA',
        'font_scale' => 'base',
        'density' => 'comfortable',
        'column_count' => 'two_column',
        'theme_tone' => 'indigo',
        'supports_headshot' => false,
        'sidebar_position' => 'left',
        'sidebar_section_types' => %w[skills education]
      )
    end
  end

  describe '.component_class_for' do
    it 'maps the new families to their renderer classes' do
      expect(described_class.component_class_for('ats-minimal')).to eq(ResumeTemplates::AtsMinimalComponent)
      expect(described_class.component_class_for('professional')).to eq(ResumeTemplates::ProfessionalComponent)
      expect(described_class.component_class_for('modern-clean')).to eq(ResumeTemplates::ModernCleanComponent)
      expect(described_class.component_class_for('sidebar-accent')).to eq(ResumeTemplates::SidebarAccentComponent)
    end
  end
end
