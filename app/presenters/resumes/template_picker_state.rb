module Resumes
  class TemplatePickerState
    include TemplateBrowserSupport

    attr_reader :description, :field_label, :mode

    def initialize(resume:, form_object_name:, field_label:, description:, mode: :default, view_context:)
      @resume = resume
      @form_object_name = form_object_name
      @field_label = field_label
      @description = description
      @mode = mode.to_sym
      @view_context = view_context
    end

    def template_cards
      @template_cards ||= sort_template_cards(raw_template_cards)
    end

    def selected_template_card
      @selected_template_card ||= template_cards.find { |template_card| template_card.fetch(:template).id == selected_template_id } || template_cards.first
    end

    def compact?
      mode == :compact
    end

    def accent_field_id
      "#{form_object_name}_settings_accent_color"
    end

    def selected_accent_color
      selected_card_state&.fetch(:selected_accent_color) || resume.accent_color
    end

    def selected_accent_variant_label
      selected_card_state&.fetch(:selected_accent_variant_label)
    end

    def has_custom_accent?
      return false if selected_card_state.blank?

      default_accent = selected_card_state.dig(:template_card, :accent_color)
      selected_card_state.fetch(:selected_accent_color) != default_accent
    end

    def selected_card_state
      @selected_card_state ||= card_states.find { |card_state| card_state.fetch(:selected) } || card_states.first
    end

    def recommended_card_states
      @recommended_card_states ||= card_states.select { |card_state| card_state.fetch(:recommended) }
    end

    def filter_groups
      @filter_groups ||= [
        build_filter_group(
          key: "family",
          label: picker_text("filter_groups.family"),
          options: filter_options_for(
            template_cards: template_cards,
            key: "family",
            value_proc: ->(template_card) { template_card.fetch(:family) },
            label_proc: ->(template_card) { template_card.fetch(:family_label) }
          )
        ),
        build_filter_group(
          key: "density",
          label: picker_text("filter_groups.density"),
          options: filter_options_for(
            template_cards: template_cards,
            key: "density",
            value_proc: ->(template_card) { template_card.fetch(:density) },
            label_proc: ->(template_card) { template_card.fetch(:density_label) }
          )
        ),
        build_filter_group(
          key: "column_count",
          label: picker_text("filter_groups.columns"),
          options: filter_options_for(
            template_cards: template_cards,
            key: "column_count",
            value_proc: ->(template_card) { template_card.fetch(:column_count) },
            label_proc: ->(template_card) { template_card.fetch(:column_count_label) }
          )
        ),
        build_filter_group(
          key: "theme_tone",
          label: picker_text("filter_groups.theme"),
          options: filter_options_for(
            template_cards: template_cards,
            key: "theme_tone",
            value_proc: ->(template_card) { template_card.fetch(:theme_tone) },
            label_proc: ->(template_card) { template_card.fetch(:theme_tone_label) }
          )
        ),
        build_filter_group(
          key: "shell_style",
          label: picker_text("filter_groups.layout"),
          options: filter_options_for(
            template_cards: template_cards,
            key: "shell_style",
            value_proc: ->(template_card) { template_card.fetch(:shell_style) },
            label_proc: ->(template_card) { template_card.fetch(:shell_style_label) }
          )
        )
      ]
    end

    def results_label
      template_count_label(template_cards.size)
    end

    def search_placeholder
      picker_text("search_placeholder")
    end

    def sort_options
      @sort_options ||= begin
        options = [
          { value: "selected_first", label: picker_text("sort_options.selected_first") },
          { value: "name_asc", label: picker_text("sort_options.name_asc") },
          { value: "family_asc", label: picker_text("sort_options.family_asc") },
          { value: "density_asc", label: picker_text("sort_options.density_asc") }
        ]

        recommendation_sort_available? ? [ { value: "recommended_first", label: picker_text("sort_options.recommended_first") }, *options ] : options
      end
    end

    def default_sort_value
      recommendation_sort_available? ? "recommended_first" : sort_options.first.fetch(:value)
    end

    def card_states
      @card_states ||= template_cards.map do |template_card|
        template = template_card.fetch(:template)
        selected = selected_template_card.present? && selected_template_card.fetch(:template).id == template.id
        recommendation = recommendation_for(template)
        selected_accent_color = template_card.fetch(:selected_accent_color, template_card.fetch(:accent_color))
        selected_accent_variant = selected_accent_variant_for(template_card, selected_accent_color)

        {
          template: template,
          template_card: template_card,
          selected: selected,
          recommended: recommendation.present?,
          recommendation_badge_label: recommendation&.fetch(:badge_label),
          recommendation_reason: recommendation&.fetch(:reason),
          card_id: "#{form_object_name}_template_id_#{template.id}",
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
          card_classes: selected ? selected_card_classes : unselected_card_classes,
          card_selected_classes: selected_card_classes,
          card_unselected_classes: unselected_card_classes,
          eyebrow_classes: selected ? selected_eyebrow_classes : unselected_eyebrow_classes,
          eyebrow_selected_classes: selected_eyebrow_classes,
          eyebrow_unselected_classes: unselected_eyebrow_classes,
          supporting_classes: selected ? selected_supporting_classes : unselected_supporting_classes,
          supporting_selected_classes: selected_supporting_classes,
          supporting_unselected_classes: unselected_supporting_classes,
          indicator_classes: selected ? selected_indicator_classes : unselected_indicator_classes,
          indicator_selected_classes: selected_indicator_classes,
          indicator_unselected_classes: unselected_indicator_classes,
          indicator_text: selected ? "✓" : template_card.fetch(:short_label),
          indicator_selected_text: "✓",
          indicator_unselected_text: template_card.fetch(:short_label),
          badge_classes: selected ? selected_badge_classes : unselected_badge_classes,
          badge_selected_classes: selected_badge_classes,
          badge_unselected_classes: unselected_badge_classes,
          current_badge_classes: selected ? selected_current_badge_classes : unselected_current_badge_classes,
          current_badge_selected_classes: selected_current_badge_classes,
          current_badge_unselected_classes: unselected_current_badge_classes,
          supporting_text: template.description.presence || template_card.fetch(:summary),
          selection_badges: selection_badges(template_card, recommendation: recommendation),
          show_current_only_badge: !template.active?,
          current_only_badge_label: picker_text("current_only_badge"),
          selected_accent_color: selected_accent_color,
          selected_accent_variant_label: selected_accent_variant.fetch(:label),
          accent_variants: accent_variant_states_for(template, template_card, selected_accent_color),
          preview_template_path: preview_template_path_for(template, accent_color: selected_accent_color),
          preview_template_paths_by_accent_color: preview_template_paths_by_accent_color(template, template_card),
          accent_label: picker_text("accent_label", variant: selected_accent_variant.fetch(:label)),
          summary_hidden: !selected,
          summary_aria_hidden: (!selected).to_s,
          summary_card_attributes: summary_card_attributes_for(template, template_card),
          summary_badges: summary_badges(template_card, recommendation: recommendation),
          summary_detail_text: picker_text(
            "summary_detail",
            shell: template_card.fetch(:shell_style_label),
            headings: template_card.fetch(:section_heading_style_label)
          ),
          summary_note: summary_note
        }
      end
    end

    private
      attr_reader :form_object_name, :resume, :view_context

      def raw_template_cards
        @raw_template_cards ||= begin
          args = { selected_template: selected_template }
          args[:selected_accent_colors] = selected_accent_colors if selected_accent_colors.present?
          view_context.template_cards_for_builder(**args)
        end
      end

      def selected_template
        @selected_template ||= Template.find_by(id: resume.template_id) || resume.template.presence
      end

      def selected_template_id
        selected_template&.id || resume.template_id
      end

      def summary_card_attributes_for(template, template_card)
        {
          eyebrow: compact? ? picker_text("summary_card_eyebrows.compact") : picker_text("summary_card_eyebrows.default"),
          title: template.name,
          description: template_card.fetch(:summary),
          tone: :default,
          padding: :sm
        }
      end

      def summary_note
        if compact?
          picker_text("summary_notes.compact")
        else
          picker_text("summary_notes.default")
        end
      end

      def selection_badges(template_card, recommendation: nil)
        badges = []
        badges << recommendation.fetch(:badge_label) if recommendation.present?
        badges.concat([
          picker_text("selection_badges.density", density: template_card.fetch(:density_label)),
          picker_text("selection_badges.columns", columns: template_card.fetch(:column_count_label)),
          picker_text("selection_badges.theme", theme: template_card.fetch(:theme_tone_label)),
          picker_text("selection_badges.header", header: template_card.fetch(:header_style_label)),
          picker_text("selection_badges.entries", entries: template_card.fetch(:entry_style_label))
        ])

        if template_card.fetch(:sidebar_section_labels).any?
          badges << picker_text("selection_badges.sidebar", sections: template_card.fetch(:sidebar_section_labels).to_sentence)
        end

        badges
      end

      def summary_badges(template_card, recommendation: nil)
        badges = []
        badges << recommendation.fetch(:badge_label) if recommendation.present?
        badges.concat([
          template_card.fetch(:family_label),
          picker_text("summary_badges.columns", columns: template_card.fetch(:column_count_label)),
          picker_text("summary_badges.theme", theme: template_card.fetch(:theme_tone_label)),
          picker_text("summary_badges.skills", skills: template_card.fetch(:skill_style_label))
        ])

        if template_card.fetch(:sidebar_section_labels).any?
          badges << picker_text("summary_badges.sidebar", sections: template_card.fetch(:sidebar_section_labels).to_sentence)
        end

        badges
      end

      def build_filter_group(key:, label:, options:)
        {
          key: key,
          label: label,
          options: [
            filter_option_state(key: key, value: "all", label: picker_text("filter_groups.all"), count: template_cards.size, active: true),
            *options.map do |option|
              filter_option_state(
                key: key,
                value: option.fetch(:value),
                label: option.fetch(:label),
                count: option.fetch(:count),
                active: false
              )
            end
          ]
        }
      end

      def template_count_label(count)
        picker_text("template_count", count: count)
      end

      def picker_text(key, **options)
        I18n.t("resumes.template_picker_state.#{key}", **options)
      end

      def accent_variant_states_for(template, template_card, selected_accent_color)
        template_card_accent_variants(template_card).map do |accent_variant|
          accent_color = accent_variant.fetch(:accent_color)

          accent_variant.merge(
            selected: accent_color == selected_accent_color,
            preview_template_path: preview_template_path_for(template, accent_color: accent_color)
          )
        end
      end

      def preview_template_path_for(template, accent_color:)
        path_params = { id: template }
        path_params[:resume] = resume_context_params(template: template, accent_color: accent_color) if resume_context_params(template: template, accent_color: accent_color).present?
        view_context.template_path(**path_params)
      end

      def resume_context_params(template:, accent_color:)
        context = {}
        intake_details = resume.intake_details.slice("experience_level", "student_status").compact_blank
        context[:intake_details] = intake_details if intake_details.present?
        if accent_color.present? && accent_color != template.render_layout_config.fetch("accent_color")
          context[:settings] = { accent_color: accent_color }
        end
        context
      end

      def selected_accent_colors
        return {} if selected_template_id.blank?
        return {} if selected_template.blank?
        return {} if resume.accent_color == selected_template.render_layout_config.fetch("accent_color")

        { selected_template_id => resume.accent_color }
      end

      def recommendations
        @recommendations ||= Resumes::TemplateRecommendationService.new(resume: resume, template_cards: raw_template_cards).call
      end

      def recommendation_for(template)
        recommendations_by_template_id[template.id]
      end

      def sort_template_cards(template_cards)
        return template_cards unless recommendation_sort_available?

        template_cards.sort_by do |template_card|
          template = template_card.fetch(:template)

          [ recommendation_sort_rank(template.id), template.name.downcase ]
        end
      end

      def selected_card_classes
        @selected_card_classes ||= view_context.ui_selectable_card_classes(selected: true, size: :lg)
      end

      def unselected_card_classes
        @unselected_card_classes ||= view_context.ui_selectable_card_classes(selected: false, size: :lg)
      end

      def selected_indicator_classes
        @selected_indicator_classes ||= view_context.ui_selectable_indicator_classes(selected: true)
      end

      def unselected_indicator_classes
        @unselected_indicator_classes ||= view_context.ui_selectable_indicator_classes(selected: false)
      end

      def selected_eyebrow_classes
        @selected_eyebrow_classes ||= view_context.ui_selectable_eyebrow_classes(selected: true)
      end

      def unselected_eyebrow_classes
        @unselected_eyebrow_classes ||= view_context.ui_selectable_eyebrow_classes(selected: false)
      end

      def selected_supporting_classes
        @selected_supporting_classes ||= view_context.ui_selectable_supporting_text_classes(selected: true)
      end

      def unselected_supporting_classes
        @unselected_supporting_classes ||= view_context.ui_selectable_supporting_text_classes(selected: false)
      end

      def selected_badge_classes
        @selected_badge_classes ||= view_context.ui_badge_classes(:hero)
      end

      def unselected_badge_classes
        @unselected_badge_classes ||= view_context.ui_badge_classes(:neutral)
      end

      def selected_current_badge_classes
        @selected_current_badge_classes ||= view_context.ui_badge_classes(:hero)
      end

      def unselected_current_badge_classes
        @unselected_current_badge_classes ||= view_context.ui_badge_classes(:warning)
      end

      def selected_filter_chip_classes
        @selected_filter_chip_classes ||= view_context.ui_filter_chip_classes(active: true)
      end

      def unselected_filter_chip_classes
        @unselected_filter_chip_classes ||= view_context.ui_filter_chip_classes(active: false)
      end
  end
end
