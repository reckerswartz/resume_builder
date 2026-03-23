require 'rails_helper'

RSpec.describe ResumeTemplates::Catalog do
  describe '.families' do
    it 'includes the new phase 2 families' do
      expect(described_class.families).to include('ats-minimal', 'professional', 'modern-clean', 'sidebar-accent', 'editorial-split')
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
        'section_spacing' => 'standard',
        'paragraph_spacing' => 'standard',
        'line_spacing' => 'standard',
        'column_count' => 'two_column',
        'theme_tone' => 'indigo',
        'supports_headshot' => false,
        'sidebar_position' => 'left',
        'sidebar_section_types' => %w[skills education]
      )
    end

    it 'returns the editorial split defaults with the editorial sidebar metadata intact' do
      expect(described_class.default_layout_config(family: 'editorial-split')).to include(
        'family' => 'editorial-split',
        'variant' => 'editorial-split',
        'accent_color' => '#D7F038',
        'font_scale' => 'sm',
        'density' => 'compact',
        'section_spacing' => 'standard',
        'paragraph_spacing' => 'standard',
        'line_spacing' => 'standard',
        'column_count' => 'two_column',
        'theme_tone' => 'lime',
        'supports_headshot' => true,
        'sidebar_section_types' => %w[education skills projects]
      )
    end
  end

  describe '.component_class_for' do
    it 'maps the new families to their renderer classes' do
      expect(described_class.component_class_for('ats-minimal')).to eq(ResumeTemplates::AtsMinimalComponent)
      expect(described_class.component_class_for('professional')).to eq(ResumeTemplates::ProfessionalComponent)
      expect(described_class.component_class_for('modern-clean')).to eq(ResumeTemplates::ModernCleanComponent)
      expect(described_class.component_class_for('sidebar-accent')).to eq(ResumeTemplates::SidebarAccentComponent)
      expect(described_class.component_class_for('editorial-split')).to eq(ResumeTemplates::EditorialSplitComponent)
    end
  end

  describe '.font_family_class' do
    it 'maps valid font family keys to Tailwind font classes' do
      expect(described_class.font_family_class('sans')).to eq('font-sans')
      expect(described_class.font_family_class('serif')).to eq('font-serif')
      expect(described_class.font_family_class('mono')).to eq('font-mono')
    end

    it 'falls back to font-sans for unknown values' do
      expect(described_class.font_family_class('comic')).to eq('font-sans')
    end
  end

  describe '.normalized_font_family' do
    it 'normalizes valid font family keys and falls back for unknown values' do
      expect(described_class.normalized_font_family('serif')).to eq('serif')
      expect(described_class.normalized_font_family('invalid', fallback: 'mono')).to eq('mono')
      expect(described_class.normalized_font_family(nil)).to eq('sans')
    end
  end

  describe '.font_family_options' do
    it 'returns label-value pairs for all font families' do
      expect(described_class.font_family_options).to include(
        ['Sans-serif', 'sans'],
        ['Serif', 'serif'],
        ['Monospace', 'mono']
      )
    end
  end

  describe 'shared metadata labels' do
    it 'returns locale-backed labels for shared template metadata and readable fallbacks for unknown values' do
      expect(described_class.family_label('sidebar-accent')).to eq('Sidebar Accent')
      expect(described_class.family_label('legacy')).to eq('Legacy')
      expect(described_class.font_family_label('sans')).to eq('Sans-serif')
      expect(described_class.font_family_label('serif')).to eq('Serif')
      expect(described_class.font_family_label('mono')).to eq('Monospace')
      expect(described_class.font_scale_label('base')).to eq('Base')
      expect(described_class.density_label('comfortable')).to eq('Comfortable')
      expect(described_class.section_spacing_label('tight')).to eq('Tight')
      expect(described_class.paragraph_spacing_label('standard')).to eq('Standard')
      expect(described_class.line_spacing_label('relaxed')).to eq('Relaxed')
      expect(described_class.column_count_label('two_column')).to eq('2 columns')
      expect(described_class.theme_tone_label('lime')).to eq('Lime')
      expect(described_class.shell_style_label('card')).to eq('Card')
      expect(described_class.header_style_label('stacked')).to eq('Stacked')
      expect(described_class.entry_style_label('timeline')).to eq('Timeline')
      expect(described_class.skill_style_label('bars')).to eq('Bars')
      expect(described_class.section_heading_style_label('marker')).to eq('Marker')
      expect(described_class.sidebar_position_label('left')).to eq('Left')
      expect(described_class.density_options).to include([ 'Compact', 'compact' ], [ 'Comfortable', 'comfortable' ], [ 'Relaxed', 'relaxed' ])
      expect(described_class.section_spacing_options).to include([ 'Tight', 'tight' ], [ 'Standard', 'standard' ], [ 'Relaxed', 'relaxed' ])
      expect(described_class.paragraph_spacing_options).to include([ 'Tight', 'tight' ], [ 'Standard', 'standard' ], [ 'Relaxed', 'relaxed' ])
      expect(described_class.line_spacing_options).to include([ 'Tight', 'tight' ], [ 'Standard', 'standard' ], [ 'Relaxed', 'relaxed' ])
      expect(described_class.shell_style_options).to include([ 'Flat', 'flat' ], [ 'Card', 'card' ])
    end
  end

  describe '.accent_color_palette' do
    it 'returns a curated array of professional color swatches with key, hex, and label' do
      palette = described_class.accent_color_palette
      expect(palette).to be_an(Array)
      expect(palette.size).to be >= 15

      palette.each do |swatch|
        expect(swatch).to include(:key, :hex, :label)
        expect(swatch.fetch(:hex)).to match(/\A#\h{6}\z/)
      end

      hex_values = palette.map { |s| s.fetch(:hex) }
      expect(hex_values).to include('#334155', '#1D4ED8', '#0D6B63', '#4338CA', '#DC2626')
    end
  end

  describe '.default_accent_color_for' do
    it 'returns the template default accent color for a given family' do
      expect(described_class.default_accent_color_for('classic')).to eq('#1D4ED8')
      expect(described_class.default_accent_color_for('modern')).to eq('#0F172A')
      expect(described_class.default_accent_color_for('sidebar-accent')).to eq('#4338CA')
    end
  end

  describe '.normalized_accent_color' do
    it 'expands shorthand hex values and falls back for invalid colors' do
      expect(described_class.normalized_accent_color('#abc', fallback: '#123456')).to eq('#aabbcc')
      expect(described_class.normalized_accent_color('not-a-color', fallback: '#123456')).to eq('#123456')
    end
  end

  describe '.accent_variants' do
    it 'returns the template default accent plus curated related swatches and appends a custom fallback when needed' do
      classic_layout = described_class.default_layout_config(family: 'classic')

      expect(described_class.accent_variants(classic_layout)).to eq([
        { key: 'blue', label: 'Blue', accent_color: '#1D4ED8', default: true, custom: false },
        { key: 'slate', label: 'Slate', accent_color: '#334155', default: false, custom: false },
        { key: 'indigo', label: 'Indigo', accent_color: '#4338CA', default: false, custom: false }
      ])

      expect(described_class.accent_variants(classic_layout, selected_accent_color: '#123456').last).to eq(
        key: 'custom',
        label: 'Custom',
        accent_color: '#123456',
        default: false,
        custom: true
      )
    end
  end
end
