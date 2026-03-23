module TemplateBrowserSupport
  private
    def filter_options_for(template_cards:, key:, value_proc:, label_proc:)
      template_cards
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

    def preview_template_paths_by_accent_color(template, template_card)
      template_card_accent_variants(template_card).each_with_object({}) do |accent_variant, paths|
        accent_color = accent_variant.fetch(:accent_color)
        paths[accent_color] = preview_template_path_for(template, accent_color: accent_color)
      end
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

    def selected_accent_variant_for(template_card, selected_accent_color)
      template_card_accent_variants(template_card).find do |accent_variant|
        accent_variant.fetch(:accent_color) == selected_accent_color
      end || template_card_accent_variants(template_card).first
    end
end
