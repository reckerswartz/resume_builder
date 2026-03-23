require 'rails_helper'

RSpec.describe Templates::MarketplaceState do
  let(:modern_template) { create(:template, name: 'Modern Slate') }
  let(:classic_template) do
    create(
      :template,
      name: 'Classic Ivory',
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
    )
  end
  let(:sidebar_template) do
    create(
      :template,
      name: 'Sidebar Indigo',
      slug: 'sidebar-indigo',
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
    )
  end
  let(:templates) { [ modern_template, sidebar_template ] }
  let(:filter_templates) { [ modern_template, classic_template, sidebar_template ] }
  let(:view_context) { instance_double('view_context') }
  let(:template_cards) do
    [
      {
        template: modern_template,
        family: 'modern',
        family_label: 'Modern',
        density: 'comfortable',
        density_label: 'Comfortable',
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
        shell_style: 'card',
        shell_style_label: 'Card',
        sidebar_section_labels: [],
        accent_color: '#1D4ED8',
        summary: 'Modern summary',
        short_label: 'MO'
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
        sidebar_section_labels: [ 'Skills', 'Education' ],
        accent_color: '#0F172A',
        summary: 'Sidebar summary',
        short_label: 'SB'
      }
    ]
  end
  let(:filter_template_cards) do
    [
      *template_cards,
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

  subject(:marketplace_state) do
    described_class.new(
      templates: templates,
      filter_templates: filter_templates,
      query: 'sidebar',
      family_filter: 'sidebar-accent',
      density_filter: 'comfortable',
      column_count_filter: 'two_column',
      theme_tone_filter: 'indigo',
      shell_style_filter: 'card',
      sort: 'density_asc',
      view_context: view_context
    )
  end

  before do
    allow(view_context).to receive(:template_cards_for_builder).with(templates: templates).and_return(template_cards)
    allow(view_context).to receive(:template_cards_for_builder).with(templates: filter_templates).and_return(filter_template_cards)
    allow(view_context).to receive(:current_user).and_return(build(:user))
    allow(view_context).to receive(:new_resume_path).and_return('/resumes/new')
    allow(view_context).to receive(:template_path).and_return('/templates/preview')
    allow(view_context).to receive(:resumes_path).and_return('/resumes')
    allow(view_context).to receive(:ui_filter_chip_classes).with(active: true).and_return('filter-active')
    allow(view_context).to receive(:ui_filter_chip_classes).with(active: false).and_return('filter-inactive')
  end

  describe '#page_header_attributes' do
    it 'builds the shared compact page header payload for the marketplace index' do
      expect(marketplace_state.page_header_attributes).to eq(
        eyebrow: 'Template marketplace',
        title: 'Browse templates',
        description: 'Compare layouts quickly, open a live sample when one stands out, and start a draft with the look you want.',
        badges: [
          { label: '2 templates in view', tone: :neutral },
          { label: '2 layout families', tone: :neutral }
        ],
        actions: [
          { label: 'Start a resume', path: '/resumes/new', style: :primary },
          { label: 'Back to workspace', path: '/resumes', style: :secondary }
        ]
      )
    end
  end

  describe '#filter_groups' do
    it 'builds filter groups with active option state and counts' do
      family_group = marketplace_state.filter_groups.find { |group| group.fetch(:key) == 'family' }
      density_group = marketplace_state.filter_groups.find { |group| group.fetch(:key) == 'density' }
      column_group = marketplace_state.filter_groups.find { |group| group.fetch(:key) == 'column_count' }
      theme_group = marketplace_state.filter_groups.find { |group| group.fetch(:key) == 'theme_tone' }
      shell_group = marketplace_state.filter_groups.find { |group| group.fetch(:key) == 'shell_style' }

      expect(family_group.fetch(:options)).to include(include(value: 'sidebar-accent', label: 'Sidebar Accent', count: 1, button_classes: 'filter-active', aria_pressed: 'true'))
      expect(density_group.fetch(:options)).to include(include(value: 'comfortable', label: 'Comfortable', count: 2, button_classes: 'filter-active', aria_pressed: 'true'))
      expect(density_group.fetch(:options)).to include(include(value: 'compact', label: 'Compact', count: 1, button_classes: 'filter-inactive', aria_pressed: 'false'))
      expect(column_group.fetch(:options)).to include(include(value: 'two_column', label: '2 columns', count: 1, button_classes: 'filter-active', aria_pressed: 'true'))
      expect(column_group.fetch(:options)).to include(include(value: 'single_column', label: '1 column', count: 2, button_classes: 'filter-inactive', aria_pressed: 'false'))
      expect(theme_group.fetch(:options)).to include(include(value: 'indigo', label: 'Indigo', count: 1, button_classes: 'filter-active', aria_pressed: 'true'))
      expect(theme_group.fetch(:options)).to include(include(value: 'slate', label: 'Slate', count: 1, button_classes: 'filter-inactive', aria_pressed: 'false'))
      expect(shell_group.fetch(:options)).to include(include(value: 'card', label: 'Card', count: 2, button_classes: 'filter-active', aria_pressed: 'true'))
      expect(shell_group.fetch(:options)).to include(include(value: 'flat', label: 'Flat', count: 1, button_classes: 'filter-inactive', aria_pressed: 'false'))
    end
  end

  describe '#sort_options and #results_label' do
    it 'exposes marketplace discovery controls' do
      expect(marketplace_state.results_label).to eq('2 templates shown')
      expect(marketplace_state.search_placeholder).to eq('Search by name, family, or layout details')
      expect(marketplace_state.sort_options).to eq(
        [
          { value: 'family_asc', label: 'Layout family' },
          { value: 'name_asc', label: 'Name A–Z' },
          { value: 'density_asc', label: 'Density' }
        ]
      )
      expect(marketplace_state.default_sort_value).to eq('family_asc')
      expect(marketplace_state.selected_sort_value).to eq('density_asc')
      expect(marketplace_state.filters_active?).to be(true)
      expect(marketplace_state.active_filter_badges).to eq([
        { label: 'Query: "sidebar"', tone: :neutral },
        { label: 'Sidebar Accent', tone: :neutral },
        { label: 'Comfortable', tone: :neutral },
        { label: '2 columns', tone: :neutral },
        { label: 'Indigo', tone: :neutral },
        { label: 'Card', tone: :neutral },
        { label: 'Sort: Density', tone: :neutral }
      ])
    end
  end

  describe '#card_states' do
    it 'builds searchable, sortable card metadata for the gallery' do
      modern_card_state = marketplace_state.card_states.find { |card_state| card_state.fetch(:template) == modern_template }
      sidebar_card_state = marketplace_state.card_states.find { |card_state| card_state.fetch(:template) == sidebar_template }

      expect(modern_card_state).to include(
        filter_family: 'modern',
        filter_density: 'comfortable',
        filter_column_count: 'single_column',
        filter_theme_tone: 'slate',
        filter_shell_style: 'card',
        sort_name: 'modern slate',
        sort_family: 'modern',
        sort_density_rank: 1,
        selected_accent_color: '#1D4ED8',
        selected_accent_variant_label: 'Slate',
        badge_labels: [ 'Density: Comfortable', 'Columns: 1 column', 'Theme: Slate', 'Header: Stacked', 'Entries: Timeline' ],
        layout_focus_label: 'Balanced single-column flow'
      )
      expect(modern_card_state.fetch(:search_text)).to include('modern slate')
      expect(modern_card_state.fetch(:search_text)).to include('1 column')
      expect(modern_card_state.fetch(:search_text)).to include('slate')

      expect(sidebar_card_state).to include(
        filter_family: 'sidebar-accent',
        filter_density: 'comfortable',
        filter_column_count: 'two_column',
        filter_theme_tone: 'indigo',
        filter_shell_style: 'card',
        sort_name: 'sidebar indigo',
        sort_family: 'sidebar accent',
        sort_density_rank: 1,
        selected_accent_color: '#0F172A',
        selected_accent_variant_label: 'Indigo',
        badge_labels: [ 'Density: Comfortable', 'Columns: 2 columns', 'Theme: Indigo', 'Header: Split', 'Entries: Cards', 'Sidebar: Skills and Education' ],
        layout_focus_label: 'Sidebar: Skills and Education'
      )
      expect(sidebar_card_state.fetch(:search_text)).to include('sidebar indigo')
      expect(sidebar_card_state.fetch(:search_text)).to include('2 columns')
      expect(sidebar_card_state.fetch(:search_text)).to include('indigo')
      expect(sidebar_card_state.fetch(:search_text)).to include('skills education')
    end
  end

  describe 'apply-to-existing chooser state' do
    let(:chooser_user) { create(:user) }
    let!(:older_resume) { create(:resume, user: chooser_user, template: modern_template, title: 'Platform Resume', updated_at: 2.days.ago) }
    let!(:newer_resume) { create(:resume, user: chooser_user, template: classic_template, title: 'Legal Resume', updated_at: 1.day.ago) }

    before do
      allow(view_context).to receive(:current_user).and_return(chooser_user)
      allow(view_context).to receive(:apply_to_resume_template_path) { |template| "/templates/#{template.id}/apply_to_resume" }
    end

    it 'exposes ordered resume options and chooser redirect paths for applying templates' do
      modern_card_state = marketplace_state.card_states.find { |card_state| card_state.fetch(:template) == modern_template }

      expect(marketplace_state.apply_to_resume_available?).to be(true)
      expect(marketplace_state.selected_apply_resume_id).to eq(newer_resume.id)
      expect(marketplace_state.apply_resume_options).to eq([
        [ 'Legal Resume · Classic Ivory', newer_resume.id ],
        [ 'Platform Resume · Modern Slate', older_resume.id ]
      ])
      expect(marketplace_state.apply_to_resume_path_for(modern_template)).to eq("/templates/#{modern_template.id}/apply_to_resume")
      expect(modern_card_state.fetch(:apply_resume_options)).to eq([
        [ 'Legal Resume · Classic Ivory', newer_resume.id ],
        [ 'Platform Resume · Modern Slate', older_resume.id ]
      ])
      expect(modern_card_state.fetch(:selected_apply_resume_id)).to eq(newer_resume.id)
    end
  end

  describe 'intake-driven recommendations' do
    let(:ats_template) do
      create(
        :template,
        name: 'ATS Minimal',
        slug: 'ats-minimal',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal')
      )
    end
    let(:modern_template) do
      create(
        :template,
        name: 'Modern Slate',
        slug: 'modern-slate',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')
      )
    end
    let(:sidebar_template) do
      create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )
    end
    let(:templates) { [ modern_template, sidebar_template, ats_template ] }
    let(:filter_templates) { templates }
    let(:template_cards) do
      [
        {
          template: modern_template,
          family: 'modern',
          family_label: 'Modern',
          density: 'comfortable',
          density_label: 'Comfortable',
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
          shell_style: 'card',
          shell_style_label: 'Card',
          sidebar_section_labels: [],
          accent_color: '#1D4ED8',
          summary: 'Modern summary',
          short_label: 'MO'
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
          supports_headshot: false,
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
          short_label: 'SB'
        },
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
        }
      ]
    end
    let(:recommendation_resume) do
      build(
        :resume,
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'student'
        }
      )
    end
    subject(:recommended_marketplace_state) do
      described_class.new(
        templates: templates,
        filter_templates: filter_templates,
        query: '',
        family_filter: nil,
        density_filter: nil,
        column_count_filter: nil,
        theme_tone_filter: nil,
        shell_style_filter: nil,
        sort: nil,
        resume: recommendation_resume,
        view_context: view_context
      )
    end

    before do
      allow(view_context).to receive(:template_cards_for_builder).with(templates: templates).and_return(template_cards)
      allow(view_context).to receive(:template_cards_for_builder).with(templates: filter_templates).and_return(template_cards)
    end

    it 'adds recommendation badges and reasons and defaults to recommendation-first sorting' do
      expect(recommended_marketplace_state.sort_options.first).to eq(value: 'recommended_first', label: 'Recommended first')
      expect(recommended_marketplace_state.default_sort_value).to eq('recommended_first')
      expect(recommended_marketplace_state.selected_sort_value).to eq('recommended_first')

      expect(recommended_marketplace_state.card_states.map { |card_state| card_state.fetch(:template) }).to eq([
        ats_template,
        sidebar_template,
        modern_template
      ])

      ats_card_state = recommended_marketplace_state.card_states.find { |card_state| card_state.fetch(:template) == ats_template }
      sidebar_card_state = recommended_marketplace_state.card_states.find { |card_state| card_state.fetch(:template) == sidebar_template }
      modern_card_state = recommended_marketplace_state.card_states.find { |card_state| card_state.fetch(:template) == modern_template }

      expect(ats_card_state).to include(
        recommended: true,
        recommendation_badge_label: 'Recommended',
        recommendation_reason: 'Best for early-career resumes'
      )
      expect(ats_card_state.fetch(:badge_labels)).to include('Recommended')

      expect(sidebar_card_state).to include(
        recommended: true,
        recommendation_badge_label: 'Recommended',
        recommendation_reason: 'Highlights education and skills for student resumes'
      )
      expect(sidebar_card_state.fetch(:badge_labels)).to include('Recommended')

      expect(modern_card_state).to include(
        recommended: false,
        recommendation_badge_label: nil,
        recommendation_reason: nil
      )
    end
  end
end
