require 'rails_helper'

RSpec.describe TemplatesHelper, type: :helper do
  describe '#template_marketplace_filter_groups' do
    it 'builds filter groups with active option state and counts from the provided templates' do
      modern_template = create(:template, name: 'Modern Slate')
      sidebar_template = create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )

      filter_groups = helper.template_marketplace_filter_groups(
        templates: [modern_template, sidebar_template],
        family_filter: 'sidebar-accent',
        density_filter: 'comfortable',
        column_count_filter: 'two_column',
        theme_tone_filter: 'indigo',
        shell_style_filter: 'card'
      )

      family_group = filter_groups.find { |group| group.fetch(:key) == 'family' }
      density_group = filter_groups.find { |group| group.fetch(:key) == 'density' }
      column_group = filter_groups.find { |group| group.fetch(:key) == 'column_count' }
      theme_group = filter_groups.find { |group| group.fetch(:key) == 'theme_tone' }
      shell_group = filter_groups.find { |group| group.fetch(:key) == 'shell_style' }

      expect(family_group.fetch(:options)).to include(include(value: 'sidebar-accent', label: 'Sidebar Accent', count: 1, active: true))
      expect(density_group.fetch(:options)).to include(include(value: 'comfortable', label: 'Comfortable', count: 2, active: true))
      expect(column_group.fetch(:options)).to include(include(value: 'two_column', label: '2 columns', count: 1, active: true))
      expect(theme_group.fetch(:options)).to include(include(value: 'indigo', label: 'Indigo', count: 1, active: true))
      expect(shell_group.fetch(:options)).to include(include(value: 'card', label: 'Card', count: 2, active: true))
    end
  end

  describe '#template_marketplace_active_badges' do
    it 'builds readable badges for the current marketplace filters' do
      expect(
        helper.template_marketplace_active_badges(
          query: 'sidebar',
          family_filter: 'sidebar-accent',
          density_filter: 'comfortable',
          column_count_filter: 'two_column',
          theme_tone_filter: 'indigo',
          shell_style_filter: 'card',
          sort: 'density_asc',
          default_sort_value: 'family_asc',
          sort_options: [
            { value: 'family_asc', label: 'Layout family' },
            { value: 'density_asc', label: 'Density' }
          ]
        )
      ).to eq([
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

  describe '#template_marketplace_filters_active?' do
    it 'treats non-default sort state as an active marketplace control' do
      expect(
        helper.template_marketplace_filters_active?(
          query: '',
          family_filter: nil,
          density_filter: nil,
          column_count_filter: nil,
          theme_tone_filter: nil,
          shell_style_filter: nil,
          sort: 'density_asc',
          default_sort_value: 'family_asc'
        )
      ).to be(true)
    end
  end
end
