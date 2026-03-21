module TemplatesHelper
  include ResumesHelper

  def template_marketplace_state(templates:, query:, family_filter:, density_filter:, column_count_filter:, theme_tone_filter:, shell_style_filter:, filter_templates: nil, sort: nil, resume: nil)
    @template_marketplace_states ||= {}
    resolved_templates = Array(templates)
    resolved_filter_templates = Array(filter_templates)
    resume_key = [
      resume&.intake_details&.slice('experience_level', 'student_status')&.compact_blank || {},
      resume&.settings&.to_h&.fetch('accent_color', nil)
    ]
    state_key = [ resolved_templates.map(&:id), resolved_filter_templates.map(&:id), query, family_filter, density_filter, column_count_filter, theme_tone_filter, shell_style_filter, sort, resume_key ]

    @template_marketplace_states[state_key] ||= Templates::MarketplaceState.new(
      templates: resolved_templates,
      filter_templates: filter_templates,
      query: query,
      family_filter: family_filter,
      density_filter: density_filter,
      column_count_filter: column_count_filter,
      theme_tone_filter: theme_tone_filter,
      shell_style_filter: shell_style_filter,
      sort: sort,
      resume: resume,
      view_context: self
    )
  end

  def marketplace_template_card(template, selected_accent_color: nil)
    template_cards_for_builder(
      selected_template: template,
      selected_accent_colors: { template.id => selected_accent_color }
    ).find { |template_card| template_card.fetch(:template).id == template.id }
  end

  def template_marketplace_filter_groups(templates:, family_filter:, density_filter:, column_count_filter:, theme_tone_filter:, shell_style_filter:)
    template_cards = template_cards_for_builder(templates: templates)

    [
      build_template_marketplace_filter_group(
        label: I18n.t("templates.marketplace_state.filter_groups.family"),
        key: "family",
        selected_value: family_filter,
        options: template_cards.group_by { |template_card| template_card.fetch(:family) }.map do |value, cards|
          { value: value, label: cards.first.fetch(:family_label), count: cards.size }
        end.sort_by { |option| option.fetch(:label) }
      ),
      build_template_marketplace_filter_group(
        label: I18n.t("templates.marketplace_state.filter_groups.density"),
        key: "density",
        selected_value: density_filter,
        options: ResumeTemplates::Catalog.density_options.filter_map do |label, value|
          count = template_cards.count { |template_card| template_card.fetch(:density) == value }
          next if count.zero?

          { value: value, label: label, count: count }
        end
      ),
      build_template_marketplace_filter_group(
        label: I18n.t("templates.marketplace_state.filter_groups.columns"),
        key: "column_count",
        selected_value: column_count_filter,
        options: ResumeTemplates::Catalog.column_count_options.filter_map do |label, value|
          count = template_cards.count { |template_card| template_card.fetch(:column_count) == value }
          next if count.zero?

          { value: value, label: label, count: count }
        end
      ),
      build_template_marketplace_filter_group(
        label: I18n.t("templates.marketplace_state.filter_groups.theme"),
        key: "theme_tone",
        selected_value: theme_tone_filter,
        options: ResumeTemplates::Catalog.theme_tone_options.filter_map do |label, value|
          count = template_cards.count { |template_card| template_card.fetch(:theme_tone) == value }
          next if count.zero?

          { value: value, label: label, count: count }
        end
      ),
      build_template_marketplace_filter_group(
        label: I18n.t("templates.marketplace_state.filter_groups.layout"),
        key: "shell_style",
        selected_value: shell_style_filter,
        options: ResumeTemplates::Catalog.shell_style_options.filter_map do |label, value|
          count = template_cards.count { |template_card| template_card.fetch(:shell_style) == value }
          next if count.zero?

          { value: value, label: label, count: count }
        end
      )
    ]
  end

  def template_marketplace_filters_active?(query:, family_filter:, density_filter:, column_count_filter:, theme_tone_filter:, shell_style_filter:, sort: nil, default_sort_value: nil)
    [ query, family_filter, density_filter, column_count_filter, theme_tone_filter, shell_style_filter ].any?(&:present?) || (sort.present? && sort != default_sort_value)
  end

  def template_marketplace_active_badges(query:, family_filter:, density_filter:, column_count_filter:, theme_tone_filter:, shell_style_filter:, sort: nil, default_sort_value: nil, sort_options: [])
    badges = []
    badges << { label: I18n.t("templates.marketplace_state.active_badges.query", query: query), tone: :neutral } if query.present?
    badges << { label: ResumeTemplates::Catalog.family_label(family_filter), tone: :neutral } if family_filter.present?
    badges << { label: ResumeTemplates::Catalog.density_label(density_filter), tone: :neutral } if density_filter.present?
    badges << { label: ResumeTemplates::Catalog.column_count_label(column_count_filter), tone: :neutral } if column_count_filter.present?
    badges << { label: ResumeTemplates::Catalog.theme_tone_label(theme_tone_filter), tone: :neutral } if theme_tone_filter.present?
    badges << { label: ResumeTemplates::Catalog.shell_style_label(shell_style_filter), tone: :neutral } if shell_style_filter.present?
    if sort.present? && sort != default_sort_value
      sort_label = sort_options.find { |option| option.fetch(:value) == sort }&.fetch(:label) || I18n.t("templates.marketplace_state.sort_options.#{sort}", default: sort.to_s.humanize)
      badges << { label: I18n.t("templates.marketplace_state.active_badges.sort", sort: sort_label), tone: :neutral }
    end
    badges
  end

  def template_marketplace_filter_path(current_params:, key:, value:)
    params = current_params.to_h.symbolize_keys
    params[key.to_sym] = value == "all" ? nil : value
    table_query_path(templates_path, params)
  end

  private
    def build_template_marketplace_filter_group(label:, key:, selected_value:, options:)
      {
        label: label,
        key: key,
        options: [
          { value: "all", label: I18n.t("templates.marketplace_state.filter_groups.all"), count: options.sum { |option| option.fetch(:count) }, active: selected_value.blank? },
          *options.map { |option| option.merge(active: selected_value == option.fetch(:value)) }
        ]
      }
    end
end
