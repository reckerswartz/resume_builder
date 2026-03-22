require 'rails_helper'

RSpec.describe Resumes::TemplatePickerState do
  let(:selected_template) { create(:template, name: 'Legacy Blue', active: false) }
  let(:classic_template) do
    create(
      :template,
      name: 'Classic Ivory',
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
    )
  end
  let(:active_template) do
    create(
      :template,
      name: 'Sidebar Indigo',
      slug: 'sidebar-indigo',
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
    )
  end
  let(:resume) { build(:resume, template: selected_template, template_id: selected_template.id) }
  let(:view_context) { instance_double('view_context') }
  let(:template_cards) do
    [
      {
        template: selected_template,
        family: 'legacy',
        family_label: 'Legacy',
        density: 'comfortable',
        density_label: 'Comfortable',
        column_count: 'single_column',
        column_count_label: '1 column',
        theme_tone: 'slate',
        theme_tone_label: 'Slate',
        supports_headshot: false,
        header_style: 'split',
        header_style_label: 'Split',
        entry_style: 'cards',
        entry_style_label: 'Cards',
        skill_style: 'chips',
        skill_style_label: 'Chips',
        section_heading_style: 'marker',
        section_heading_style_label: 'Marker',
        shell_style: 'card',
        shell_style_label: 'Card',
        sidebar_section_labels: [],
        accent_color: '#0F172A',
        summary: 'Legacy summary',
        short_label: 'LE'
      },
      {
        template: active_template,
        family: 'sidebar-accent',
        family_label: 'Sidebar Accent',
        density: 'comfortable',
        density_label: 'Comfortable',
        column_count: 'two_column',
        column_count_label: '2 columns',
        theme_tone: 'indigo',
        theme_tone_label: 'Indigo',
        supports_headshot: true,
        header_style: 'split',
        header_style_label: 'Split',
        entry_style: 'list',
        entry_style_label: 'List',
        skill_style: 'chips',
        skill_style_label: 'Chips',
        section_heading_style: 'rule',
        section_heading_style_label: 'Rule',
        shell_style: 'card',
        shell_style_label: 'Card',
        sidebar_section_labels: [ 'Skills', 'Education' ],
        accent_color: '#4338CA',
        summary: 'Sidebar summary',
        short_label: 'SI'
      },
      {
        template: classic_template,
        family: 'classic',
        family_label: 'Classic',
        density: 'compact',
        density_label: 'Compact',
        column_count: 'single_column',
        column_count_label: '1 column',
        theme_tone: 'blue',
        theme_tone_label: 'Blue',
        supports_headshot: false,
        header_style: 'rule',
        header_style_label: 'Rule',
        entry_style: 'list',
        entry_style_label: 'List',
        skill_style: 'inline',
        skill_style_label: 'Inline',
        section_heading_style: 'rule',
        section_heading_style_label: 'Rule',
        shell_style: 'flat',
        shell_style_label: 'Flat',
        sidebar_section_labels: [],
        accent_color: '#1D4ED8',
        summary: 'Classic summary',
        short_label: 'CL'
      }
    ]
  end

  subject(:template_picker_state) do
    described_class.new(
      resume: resume,
      form_object_name: 'resume',
      field_label: 'Template',
      description: 'Choose the template used by the live preview and exported PDF.',
      view_context: view_context
    )
  end

  before do
    allow(view_context).to receive(:template_cards_for_builder).with(selected_template: selected_template).and_return(template_cards)
    allow(view_context).to receive(:template_path).and_return('/templates/preview')
    allow(view_context).to receive(:ui_selectable_card_classes).with(selected: true, size: :lg).and_return('card-selected')
    allow(view_context).to receive(:ui_selectable_card_classes).with(selected: false, size: :lg).and_return('card-unselected')
    allow(view_context).to receive(:ui_selectable_indicator_classes).with(selected: true).and_return('indicator-selected')
    allow(view_context).to receive(:ui_selectable_indicator_classes).with(selected: false).and_return('indicator-unselected')
    allow(view_context).to receive(:ui_selectable_eyebrow_classes).with(selected: true).and_return('eyebrow-selected')
    allow(view_context).to receive(:ui_selectable_eyebrow_classes).with(selected: false).and_return('eyebrow-unselected')
    allow(view_context).to receive(:ui_selectable_supporting_text_classes).with(selected: true).and_return('supporting-selected')
    allow(view_context).to receive(:ui_selectable_supporting_text_classes).with(selected: false).and_return('supporting-unselected')
    allow(view_context).to receive(:ui_badge_classes).with(:hero).and_return('badge-hero')
    allow(view_context).to receive(:ui_badge_classes).with(:neutral).and_return('badge-neutral')
    allow(view_context).to receive(:ui_badge_classes).with(:warning).and_return('badge-warning')
    allow(view_context).to receive(:ui_filter_chip_classes).with(active: true).and_return('filter-active')
    allow(view_context).to receive(:ui_filter_chip_classes).with(active: false).and_return('filter-inactive')
  end

  describe '#selected_template_card' do
    it 'keeps the current selected template card even when it is inactive' do
      expect(template_picker_state.selected_template_card).to eq(template_cards.first)
    end
  end

  describe '#card_states' do
    it 'builds explicit selection state for the picker cards and summaries' do
      selected_card_state = template_picker_state.card_states.find { |card_state| card_state.fetch(:template) == selected_template }
      active_card_state = template_picker_state.card_states.find { |card_state| card_state.fetch(:template) == active_template }

      expect(selected_card_state).to include(
        selected: true,
        card_id: "resume_template_id_#{selected_template.id}",
        filter_family: 'legacy',
        filter_density: 'comfortable',
        filter_column_count: 'single_column',
        filter_theme_tone: 'slate',
        filter_shell_style: 'card',
        card_classes: 'card-selected',
        indicator_text: '✓',
        indicator_selected_text: '✓',
        indicator_unselected_text: 'LE',
        supporting_text: 'Clean professional resume layout',
        badge_classes: 'badge-hero',
        current_badge_classes: 'badge-hero',
        selection_badges: [ 'Density: Comfortable', 'Columns: 1 column', 'Theme: Slate', 'Header: Split', 'Entries: Cards' ],
        show_current_only_badge: true,
        current_only_badge_label: 'Current only',
        selected_accent_color: '#0F172A',
        selected_accent_variant_label: 'Slate',
        preview_template_path: '/templates/preview',
        accent_label: 'Accent: Slate',
        summary_hidden: false,
        summary_aria_hidden: 'false',
        summary_card_attributes: { eyebrow: 'Selection summary', title: 'Legacy Blue', description: 'Legacy summary', tone: :default, padding: :sm },
        summary_badges: [ 'Legacy', 'Columns: 1 column', 'Theme: Slate', 'Skills: Chips' ],
        summary_detail_text: 'Card shell · Marker headings',
        summary_note: 'You can change this template later without losing content.'
      )

      expect(active_card_state).to include(
        selected: false,
        card_id: "resume_template_id_#{active_template.id}",
        filter_family: 'sidebar-accent',
        filter_density: 'comfortable',
        filter_column_count: 'two_column',
        filter_theme_tone: 'indigo',
        filter_shell_style: 'card',
        card_classes: 'card-unselected',
        indicator_text: 'SI',
        supporting_text: 'Clean professional resume layout',
        badge_classes: 'badge-neutral',
        current_badge_classes: 'badge-warning',
        selection_badges: [ 'Density: Comfortable', 'Columns: 2 columns', 'Theme: Indigo', 'Header: Split', 'Entries: List', 'Sidebar: Skills and Education' ],
        show_current_only_badge: false,
        selected_accent_color: '#4338CA',
        selected_accent_variant_label: 'Indigo',
        preview_template_path: '/templates/preview',
        accent_label: 'Accent: Indigo',
        summary_hidden: true,
        summary_aria_hidden: 'true',
        summary_badges: [ 'Sidebar Accent', 'Columns: 2 columns', 'Theme: Indigo', 'Skills: Chips', 'Sidebar: Skills and Education' ],
        summary_detail_text: 'Card shell · Rule headings',
        summary_note: 'You can change this template later without losing content.'
      )
    end
  end

  describe '#filter_groups' do
    it 'builds filter groups with all/default options and per-value counts' do
      expect(template_picker_state.filter_groups).to eq(
        [
          {
            key: 'family',
            label: 'Family',
            options: [
              { key: 'family', value: 'all', label: 'All', count: 3, button_classes: 'filter-active', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'true' },
              { key: 'family', value: 'classic', label: 'Classic', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' },
              { key: 'family', value: 'legacy', label: 'Legacy', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' },
              { key: 'family', value: 'sidebar-accent', label: 'Sidebar Accent', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' }
            ]
          },
          {
            key: 'density',
            label: 'Density',
            options: [
              { key: 'density', value: 'all', label: 'All', count: 3, button_classes: 'filter-active', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'true' },
              { key: 'density', value: 'comfortable', label: 'Comfortable', count: 2, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' },
              { key: 'density', value: 'compact', label: 'Compact', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' }
            ]
          },
          {
            key: 'column_count',
            label: 'Columns',
            options: [
              { key: 'column_count', value: 'all', label: 'All', count: 3, button_classes: 'filter-active', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'true' },
              { key: 'column_count', value: 'single_column', label: '1 column', count: 2, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' },
              { key: 'column_count', value: 'two_column', label: '2 columns', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' }
            ]
          },
          {
            key: 'theme_tone',
            label: 'Theme',
            options: [
              { key: 'theme_tone', value: 'all', label: 'All', count: 3, button_classes: 'filter-active', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'true' },
              { key: 'theme_tone', value: 'blue', label: 'Blue', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' },
              { key: 'theme_tone', value: 'indigo', label: 'Indigo', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' },
              { key: 'theme_tone', value: 'slate', label: 'Slate', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' }
            ]
          },
          {
            key: 'shell_style',
            label: 'Layout',
            options: [
              { key: 'shell_style', value: 'all', label: 'All', count: 3, button_classes: 'filter-active', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'true' },
              { key: 'shell_style', value: 'card', label: 'Card', count: 2, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' },
              { key: 'shell_style', value: 'flat', label: 'Flat', count: 1, button_classes: 'filter-inactive', button_selected_classes: 'filter-active', button_unselected_classes: 'filter-inactive', aria_pressed: 'false' }
            ]
          }
        ]
      )
    end
  end

  describe '#search_placeholder' do
    it 'describes the searchable picker fields' do
      expect(template_picker_state.search_placeholder).to eq('Search by name, family, or layout details')
    end
  end

  describe 'compact mode' do
    subject(:compact_template_picker_state) do
      described_class.new(
        resume: resume,
        form_object_name: 'resume',
        field_label: 'Template',
        description: 'Start with the selected look now.',
        mode: :compact,
        view_context: view_context
      )
    end

    it 'exposes compact summary metadata for the fast-create flow' do
      expect(compact_template_picker_state).to be_compact
      expect(compact_template_picker_state.selected_card_state.fetch(:template)).to eq(selected_template)
      expect(compact_template_picker_state.selected_card_state.fetch(:summary_card_attributes)).to include(
        eyebrow: 'Selected template',
        title: 'Legacy Blue'
      )
      expect(compact_template_picker_state.selected_card_state.fetch(:summary_note)).to eq(
        'You can change this template later without losing content.'
      )
    end
  end

  describe 'accent field metadata' do
    it 'exposes the shared accent field id and selected accent value' do
      expect(template_picker_state.accent_field_id).to eq('resume_settings_accent_color')
      expect(template_picker_state.selected_accent_color).to eq('#0F172A')
    end

    it 'exposes the selected accent variant label' do
      expect(template_picker_state.selected_accent_variant_label).to eq('Slate')
    end

    it 'reports no custom accent when using the default accent color' do
      expect(template_picker_state.has_custom_accent?).to be false
    end

    context 'when the resume has a non-default accent color' do
      let(:resume) { build(:resume, template: classic_template, template_id: classic_template.id, settings: { 'accent_color' => '#334155' }) }

      before do
        allow(view_context).to receive(:template_cards_for_builder).with(selected_template: classic_template, selected_accent_colors: { classic_template.id => '#334155' }).and_return(
          template_cards.map do |card|
            if card[:template] == classic_template
              card.merge(selected_accent_color: '#334155')
            else
              card
            end
          end
        )
      end

      it 'reports a custom accent when the selected color differs from the template default' do
        expect(template_picker_state.has_custom_accent?).to be true
        expect(template_picker_state.selected_accent_variant_label).to eq('Slate')
      end
    end
  end

  describe '#sort_options' do
    it 'exposes the available picker sort modes and default' do
      expect(template_picker_state.sort_options).to eq(
        [
          { value: 'selected_first', label: 'Current first' },
          { value: 'name_asc', label: 'Name A–Z' },
          { value: 'family_asc', label: 'Family A–Z' },
          { value: 'density_asc', label: 'Density' }
        ]
      )
      expect(template_picker_state.default_sort_value).to eq('selected_first')
    end
  end

  describe 'search and sort card metadata' do
    it 'builds searchable text and sort keys for each card' do
      selected_card_state = template_picker_state.card_states.find { |card_state| card_state.fetch(:template) == selected_template }
      active_card_state = template_picker_state.card_states.find { |card_state| card_state.fetch(:template) == active_template }

      expect(selected_card_state.fetch(:search_text)).to include('legacy blue')
      expect(selected_card_state.fetch(:search_text)).to include('legacy')
      expect(selected_card_state.fetch(:search_text)).to include('1 column')
      expect(selected_card_state.fetch(:search_text)).to include('slate')
      expect(selected_card_state.fetch(:sort_name)).to eq('legacy blue')
      expect(selected_card_state.fetch(:sort_family)).to eq('legacy')
      expect(selected_card_state.fetch(:sort_density_rank)).to eq(1)

      expect(active_card_state.fetch(:search_text)).to include('sidebar indigo')
      expect(active_card_state.fetch(:search_text)).to include('2 columns')
      expect(active_card_state.fetch(:search_text)).to include('indigo')
      expect(active_card_state.fetch(:search_text)).to include('skills education')
      expect(active_card_state.fetch(:sort_name)).to eq('sidebar indigo')
      expect(active_card_state.fetch(:sort_family)).to eq('sidebar accent')
      expect(active_card_state.fetch(:sort_density_rank)).to eq(1)
    end
  end

  describe 'intake-driven recommendations' do
    let(:active_template) { create(:template, name: 'Modern Slate', slug: 'modern-slate', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')) }
    let(:student_resume) do
      build(
        :resume,
        template: active_template,
        template_id: active_template.id,
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'student'
        }
      )
    end
    let(:ats_template) { create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal')) }
    let(:sidebar_template) { create(:template, name: 'Sidebar Indigo', slug: 'sidebar-indigo', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')) }
    let(:student_template_cards) do
      [
        {
          template: ats_template,
          family: 'ats-minimal',
          family_label: 'ATS Minimal',
          density: 'compact',
          density_label: 'Compact',
          column_count: 'single_column',
          column_count_label: '1 column',
          theme_tone: 'slate',
          theme_tone_label: 'Slate',
          supports_headshot: false,
          header_style: 'rule',
          header_style_label: 'Rule',
          entry_style: 'list',
          entry_style_label: 'List',
          skill_style: 'inline',
          skill_style_label: 'Inline',
          section_heading_style: 'rule',
          section_heading_style_label: 'Rule',
          shell_style: 'flat',
          shell_style_label: 'Flat',
          sidebar_section_labels: [],
          accent_color: '#334155',
          summary: 'ATS summary',
          short_label: 'AT'
        },
        {
          template: sidebar_template,
          family: 'sidebar-accent',
          family_label: 'Sidebar Accent',
          density: 'comfortable',
          density_label: 'Comfortable',
          column_count: 'two_column',
          column_count_label: '2 columns',
          theme_tone: 'indigo',
          theme_tone_label: 'Indigo',
          supports_headshot: true,
          header_style: 'split',
          header_style_label: 'Split',
          entry_style: 'list',
          entry_style_label: 'List',
          skill_style: 'chips',
          skill_style_label: 'Chips',
          section_heading_style: 'rule',
          section_heading_style_label: 'Rule',
          shell_style: 'card',
          shell_style_label: 'Card',
          sidebar_section_labels: [ 'Education', 'Skills' ],
          accent_color: '#4338CA',
          summary: 'Sidebar summary',
          short_label: 'SI'
        },
        {
          template: active_template,
          family: 'modern',
          family_label: 'Modern',
          density: 'compact',
          density_label: 'Compact',
          column_count: 'single_column',
          column_count_label: '1 column',
          theme_tone: 'slate',
          theme_tone_label: 'Slate',
          supports_headshot: false,
          header_style: 'stacked',
          header_style_label: 'Stacked',
          entry_style: 'timeline',
          entry_style_label: 'Timeline',
          skill_style: 'bars',
          skill_style_label: 'Bars',
          section_heading_style: 'rule',
          section_heading_style_label: 'Rule',
          shell_style: 'sheet',
          shell_style_label: 'Sheet',
          sidebar_section_labels: [ 'Skills', 'Education' ],
          accent_color: '#1D4ED8',
          summary: 'Modern summary',
          short_label: 'MO'
        }
      ]
    end
    subject(:recommended_template_picker_state) do
      described_class.new(
        resume: student_resume,
        form_object_name: 'resume',
        field_label: 'Template',
        description: 'Choose the template used by the live preview and exported PDF.',
        view_context: view_context
      )
    end

    before do
      allow(view_context).to receive(:template_cards_for_builder).with(selected_template: active_template).and_return(student_template_cards)
    end

    it 'adds recommendation badges and reasons to matching cards' do
      ats_state = recommended_template_picker_state.card_states.find { |card_state| card_state.fetch(:template) == ats_template }
      sidebar_state = recommended_template_picker_state.card_states.find { |card_state| card_state.fetch(:template) == sidebar_template }
      modern_state = recommended_template_picker_state.card_states.find { |card_state| card_state.fetch(:template) == active_template }

      expect(ats_state).to include(
        recommended: true,
        recommendation_badge_label: 'Recommended',
        recommendation_reason: 'Best for early-career resumes'
      )
      expect(ats_state.fetch(:selection_badges)).to include('Recommended')

      expect(sidebar_state).to include(
        recommended: true,
        recommendation_badge_label: 'Recommended',
        recommendation_reason: 'Highlights education and skills for student resumes'
      )
      expect(sidebar_state.fetch(:selection_badges)).to include('Recommended')

      expect(modern_state).to include(
        recommended: false,
        recommendation_badge_label: nil,
        recommendation_reason: nil
      )
    end
  end
end
