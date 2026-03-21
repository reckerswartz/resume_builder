module Templates
  class MarketplaceState
    attr_reader :query, :family_filter, :density_filter, :column_count_filter, :theme_tone_filter, :shell_style_filter, :sort

    def initialize(templates:, filter_templates: nil, query:, family_filter:, density_filter:, column_count_filter:, theme_tone_filter:, shell_style_filter:, sort: nil, resume: nil, view_context:)
      @templates = templates
      @filter_templates = filter_templates
      @query = query.to_s.strip
      @family_filter = family_filter
      @density_filter = density_filter
      @column_count_filter = column_count_filter
      @theme_tone_filter = theme_tone_filter
      @shell_style_filter = shell_style_filter
      @sort = sort
      @resume = resume
      @view_context = view_context
    end

    def template_cards
      @template_cards ||= view_context.template_cards_for_builder(templates: templates)
    end

    def filter_template_cards
      @filter_template_cards ||= view_context.template_cards_for_builder(templates: resolved_filter_templates)
    end

    def page_header_attributes
      {
        eyebrow: I18n.t("templates.marketplace_state.page_header.eyebrow"),
        title: I18n.t("templates.marketplace_state.page_header.title"),
        description: I18n.t("templates.marketplace_state.page_header.description"),
        badges: [
          { label: template_badge_label(template_cards.count), tone: :neutral },
          { label: family_badge_label, tone: :neutral }
        ],
        actions: [
          { label: I18n.t("templates.marketplace_state.page_header.start_resume"), path: start_resume_path, style: :primary },
          { label: I18n.t("templates.marketplace_state.page_header.back_to_workspace"), path: view_context.resumes_path, style: :secondary }
        ]
      }
    end

    alias_method :hero_header_attributes, :page_header_attributes

    def start_resume_path
      use_template_path_for(nil)
    end

    def clear_filters_path
      path_params = resume_intake_params.present? ? { resume: { intake_details: resume_intake_params } } : {}
      view_context.templates_path(**path_params)
    end

    def filter_groups
      @filter_groups ||= [
        build_filter_group(
          key: "family",
          label: I18n.t("templates.marketplace_state.filter_groups.family"),
          selected_value: family_filter,
          options: filter_options_for(
            key: "family",
            value_proc: ->(template_card) { template_card.fetch(:family) },
            label_proc: ->(template_card) { template_card.fetch(:family_label) }
          )
        ),
        build_filter_group(
          key: "density",
          label: I18n.t("templates.marketplace_state.filter_groups.density"),
          selected_value: density_filter,
          options: filter_options_for(
            key: "density",
            value_proc: ->(template_card) { template_card.fetch(:density) },
            label_proc: ->(template_card) { template_card.fetch(:density_label) }
          )
        ),
        build_filter_group(
          key: "column_count",
          label: I18n.t("templates.marketplace_state.filter_groups.columns"),
          selected_value: column_count_filter,
          options: filter_options_for(
            key: "column_count",
            value_proc: ->(template_card) { template_card.fetch(:column_count) },
            label_proc: ->(template_card) { template_card.fetch(:column_count_label) }
          )
        ),
        build_filter_group(
          key: "theme_tone",
          label: I18n.t("templates.marketplace_state.filter_groups.theme"),
          selected_value: theme_tone_filter,
          options: filter_options_for(
            key: "theme_tone",
            value_proc: ->(template_card) { template_card.fetch(:theme_tone) },
            label_proc: ->(template_card) { template_card.fetch(:theme_tone_label) }
          )
        ),
        build_filter_group(
          key: "shell_style",
          label: I18n.t("templates.marketplace_state.filter_groups.layout"),
          selected_value: shell_style_filter,
          options: filter_options_for(
            key: "shell_style",
            value_proc: ->(template_card) { template_card.fetch(:shell_style) },
            label_proc: ->(template_card) { template_card.fetch(:shell_style_label) }
          )
        )
      ]
    end

    def results_label
      template_results_label(template_cards.size)
    end

    def filters_active?
      [ query, family_filter, density_filter, column_count_filter, theme_tone_filter, shell_style_filter ].any?(&:present?) || sort_active?
    end

    def active_filter_badges
      badges = []
      badges << { label: I18n.t("templates.marketplace_state.active_badges.query", query: query), tone: :neutral } if query.present?
      badges << { label: ResumeTemplates::Catalog.family_label(family_filter), tone: :neutral } if family_filter.present?
      badges << { label: ResumeTemplates::Catalog.density_label(density_filter), tone: :neutral } if density_filter.present?
      badges << { label: ResumeTemplates::Catalog.column_count_label(column_count_filter), tone: :neutral } if column_count_filter.present?
      badges << { label: ResumeTemplates::Catalog.theme_tone_label(theme_tone_filter), tone: :neutral } if theme_tone_filter.present?
      badges << { label: ResumeTemplates::Catalog.shell_style_label(shell_style_filter), tone: :neutral } if shell_style_filter.present?
      badges << { label: I18n.t("templates.marketplace_state.active_badges.sort", sort: selected_sort_label), tone: :neutral } if sort_active?
      badges
    end

    def search_placeholder
      I18n.t("templates.marketplace_state.search_placeholder")
    end

    def sort_options
      @sort_options ||= begin
        options = [
          { value: "family_asc", label: sort_option_label("family_asc") },
          { value: "name_asc", label: sort_option_label("name_asc") },
          { value: "density_asc", label: sort_option_label("density_asc") }
        ]

        recommendation_sort_available? ? [ { value: "recommended_first", label: sort_option_label("recommended_first") }, *options ] : options
      end
    end

    def default_sort_value
      recommendation_sort_available? ? "recommended_first" : sort_options.first.fetch(:value)
    end

    def selected_sort_value
      @selected_sort_value ||= sort_options.find { |option| option.fetch(:value) == sort }&.fetch(:value) || default_sort_value
    end

    def card_states
      @card_states ||= sort_template_cards(template_cards).map do |template_card|
        template = template_card.fetch(:template)
        recommendation = recommendations_by_template_id[template.id]
        recommendation_badge_label = recommendation&.fetch(:badge_label)
        recommendation_reason = recommendation&.fetch(:reason)
        selected_accent_color = template_card.fetch(:selected_accent_color, template_card.fetch(:accent_color))

        {
          template: template,
          template_card: template_card,
          filter_family: template_card.fetch(:family),
          filter_density: template_card.fetch(:density),
          filter_column_count: template_card.fetch(:column_count),
          filter_theme_tone: template_card.fetch(:theme_tone),
          filter_shell_style: template_card.fetch(:shell_style),
          search_text: searchable_text_for(template_card),
          sort_name: template.name.downcase,
          sort_family: template_card.fetch(:family_label).downcase,
          sort_density_rank: density_sort_rank(template_card.fetch(:density)),
          sort_recommendation_rank: recommendation_sort_rank(template.id),
          badge_labels: badge_labels(template_card, recommendation_badge_label: recommendation_badge_label),
          layout_focus_label: layout_focus_label(template_card),
          recommended: recommendation.present?,
          recommendation_badge_label: recommendation_badge_label,
          recommendation_reason: recommendation_reason,
          description_text: recommendation_reason.presence || template.description.presence || template_card.fetch(:summary),
          selected_accent_color: selected_accent_color,
          selected_accent_variant_label: selected_accent_variant_for(template_card, selected_accent_color).fetch(:label),
          accent_variants: accent_variant_states_for(template, template_card, selected_accent_color),
          preview_template_path: preview_template_path_for(template, accent_color: selected_accent_color),
          preview_template_paths_by_accent_color: preview_template_paths_by_accent_color(template, template_card),
          use_template_path: use_template_path_for(template, accent_color: selected_accent_color),
          use_template_paths_by_accent_color: use_template_paths_by_accent_color(template, template_card)
        }
      end
    end

    private
      attr_reader :resume, :templates, :view_context

      def resolved_filter_templates
        Array(@filter_templates.presence || templates)
      end

      def family_count
        @family_count ||= template_cards.map { |template_card| template_card.fetch(:family) }.uniq.count
      end

      def card_shell_count
        @card_shell_count ||= template_cards.count { |template_card| template_card.fetch(:shell_style) == "card" }
      end

      def sidebar_layout_count
        @sidebar_layout_count ||= template_cards.count { |template_card| template_card.fetch(:sidebar_section_labels).any? }
      end

      def family_badge_label
        I18n.t("templates.marketplace_state.family_badge", count: family_count)
      end

      def build_filter_group(key:, label:, selected_value:, options:)
        {
          key: key,
          label: label,
          options: [
            filter_option_state(key: key, value: "all", label: I18n.t("templates.marketplace_state.filter_groups.all"), count: filter_template_cards.size, active: selected_value.blank?),
            *options.map do |option|
              filter_option_state(
                key: key,
                value: option.fetch(:value),
                label: option.fetch(:label),
                count: option.fetch(:count),
                active: selected_value == option.fetch(:value)
              )
            end
          ]
        }
      end

      def filter_options_for(key:, value_proc:, label_proc:)
        filter_template_cards
          .group_by { |template_card| value_proc.call(template_card) }
          .map do |value, cards|
            representative_card = cards.first

            {
              key: key,
              value: value,
              label: label_proc.call(representative_card),
              count: cards.size
            }
          end
          .sort_by { |option| option.fetch(:label) }
      end

      def filter_option_state(key:, value:, label:, count:, active:)
        {
          key: key,
          value: value,
          label: label,
          count: count,
          button_classes: active ? selected_filter_chip_classes : unselected_filter_chip_classes,
          button_selected_classes: selected_filter_chip_classes,
          button_unselected_classes: unselected_filter_chip_classes,
          aria_pressed: active.to_s
        }
      end

      def searchable_text_for(template_card)
        template = template_card.fetch(:template)

        [
          template.name,
          template.description,
          template_card.fetch(:family_label),
          template_card.fetch(:density_label),
          template_card.fetch(:column_count_label),
          template_card.fetch(:theme_tone_label),
          template_card.fetch(:header_style_label),
          template_card.fetch(:entry_style_label),
          template_card.fetch(:skill_style_label),
          template_card.fetch(:section_heading_style_label),
          template_card.fetch(:shell_style_label),
          template_card.fetch(:summary),
          template_card.fetch(:sidebar_section_labels).join(" ")
        ].compact.join(" ").downcase
      end

      def density_sort_rank(density)
        {
          "compact" => 0,
          "comfortable" => 1,
          "relaxed" => 2
        }.fetch(density, 99)
      end

      def recommendation_sort_available?
        recommendations.present?
      end

      def recommendations
        @recommendations ||= if resume.present?
          Resumes::TemplateRecommendationService.new(resume: resume, template_cards: template_cards).call
        else
          []
        end
      end

      def recommendations_by_template_id
        @recommendations_by_template_id ||= recommendations.index_by { |recommendation| recommendation.fetch(:template_id) }
      end

      def recommendation_sort_rank(template_id)
        recommendation_sort_ranks.fetch(template_id, 99)
      end

      def recommendation_sort_ranks
        @recommendation_sort_ranks ||= recommendations.each_with_index.to_h do |recommendation, index|
          [ recommendation.fetch(:template_id), index ]
        end
      end

      def sort_template_cards(cards)
        cards.sort_by do |template_card|
          template = template_card.fetch(:template)

          case selected_sort_value
          when "recommended_first"
            [ recommendation_sort_rank(template.id), template.name.downcase ]
          when "density_asc"
            [ density_sort_rank(template_card.fetch(:density)), template.name.downcase ]
          when "name_asc"
            [ template.name.downcase ]
          else
            [ template_card.fetch(:family_label).downcase, template.name.downcase ]
          end
        end
      end

      def sort_active?
        selected_sort_value != default_sort_value
      end

      def selected_sort_label
        sort_option_label(selected_sort_value)
      end

      def badge_labels(template_card, recommendation_badge_label: nil)
        badges = [
          I18n.t("templates.marketplace_state.card_badges.density", density: template_card.fetch(:density_label)),
          I18n.t("templates.marketplace_state.card_badges.columns", columns: template_card.fetch(:column_count_label)),
          I18n.t("templates.marketplace_state.card_badges.theme", theme: template_card.fetch(:theme_tone_label)),
          I18n.t("templates.marketplace_state.card_badges.header", header: template_card.fetch(:header_style_label)),
          I18n.t("templates.marketplace_state.card_badges.entries", entries: template_card.fetch(:entry_style_label))
        ]

        badges.unshift(recommendation_badge_label) if recommendation_badge_label.present?

        if template_card.fetch(:sidebar_section_labels).any?
          badges << I18n.t("templates.marketplace_state.card_badges.sidebar", sections: template_card.fetch(:sidebar_section_labels).to_sentence)
        end

        badges
      end

      def layout_focus_label(template_card)
        if template_card.fetch(:sidebar_section_labels).any?
          I18n.t("templates.marketplace_state.layout_focus.sidebar", sections: template_card.fetch(:sidebar_section_labels).to_sentence)
        else
          I18n.t("templates.marketplace_state.layout_focus.balanced")
        end
      end

      def template_badge_label(count)
        I18n.t("templates.marketplace_state.template_badge", count: count)
      end

      def template_results_label(count)
        I18n.t("templates.marketplace_state.results_label", count: count)
      end

      def accent_variant_states_for(template, template_card, selected_accent_color)
        template_card_accent_variants(template_card).map do |accent_variant|
          accent_color = accent_variant.fetch(:accent_color)

          accent_variant.merge(
            selected: accent_color == selected_accent_color,
            preview_template_path: preview_template_path_for(template, accent_color: accent_color),
            use_template_path: use_template_path_for(template, accent_color: accent_color)
          )
        end
      end

      def preview_template_paths_by_accent_color(template, template_card)
        template_card_accent_variants(template_card).each_with_object({}) do |accent_variant, paths|
          accent_color = accent_variant.fetch(:accent_color)
          paths[accent_color] = preview_template_path_for(template, accent_color: accent_color)
        end
      end

      def use_template_paths_by_accent_color(template, template_card)
        template_card_accent_variants(template_card).each_with_object({}) do |accent_variant, paths|
          accent_color = accent_variant.fetch(:accent_color)
          paths[accent_color] = use_template_path_for(template, accent_color: accent_color)
        end
      end

      def selected_accent_variant_for(template_card, selected_accent_color)
        template_card_accent_variants(template_card).find do |accent_variant|
          accent_variant.fetch(:accent_color) == selected_accent_color
        end || template_card_accent_variants(template_card).first
      end

      def template_card_accent_variants(template_card)
        template_card.fetch(:accent_variants) do
          ResumeTemplates::Catalog.accent_variants(
            {
              "theme_tone" => template_card.fetch(:theme_tone),
              "accent_color" => template_card.fetch(:accent_color)
            },
            selected_accent_color: template_card.fetch(:selected_accent_color, template_card.fetch(:accent_color))
          )
        end
      end

      def use_template_path_for(template, accent_color: nil)
        path_params = template.present? ? { template_id: template.id } : {}
        resume_params = resume_context_params(template: template, accent_color: accent_color)
        path_params[:resume] = resume_params if resume_params.present?
        view_context.new_resume_path(**path_params)
      end

      def preview_template_path_for(template, accent_color: nil)
        path_params = { id: template }
        resume_params = resume_context_params(template: template, accent_color: accent_color)
        path_params[:resume] = resume_params if resume_params.present?
        view_context.template_path(**path_params)
      end

      def resume_context_params(template:, accent_color: nil)
        context = {}
        context[:intake_details] = resume_intake_params if resume_intake_params.present?
        if template.present? && accent_color.present? && accent_color != template.render_layout_config.fetch("accent_color")
          context[:settings] = { accent_color: accent_color }
        end
        context
      end

      def resume_intake_params
        @resume_intake_params ||= resume&.intake_details&.slice("experience_level", "student_status")&.compact_blank || {}
      end

      def sort_option_label(value)
        I18n.t("templates.marketplace_state.sort_options.#{value}", default: value.to_s.humanize)
      end

      def selected_filter_chip_classes
        @selected_filter_chip_classes ||= view_context.ui_filter_chip_classes(active: true)
      end

      def unselected_filter_chip_classes
        @unselected_filter_chip_classes ||= view_context.ui_filter_chip_classes(active: false)
      end
  end
end
