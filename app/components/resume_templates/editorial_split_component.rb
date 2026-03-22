module ResumeTemplates
  class EditorialSplitComponent < BaseComponent
    DEFAULT_SIDEBAR_SECTION_TYPES = %w[education skills projects].freeze
    UTILITY_BADGES = [ [ "A4", "Paper size" ], [ "US", "Letter size" ] ].freeze
    CONTACT_BADGE_LABELS = {
      "Email" => "@",
      "Phone" => "P",
      "Location" => "L",
      "Website" => "W",
      "LinkedIn" => "in",
      "Driving licence" => "ID"
    }.freeze

    def sidebar_sections
      visible_sections.select { |section| sidebar_section_types.include?(section.section_type) }
    end

    def main_sections
      visible_sections.reject { |section| sidebar_section_types.include?(section.section_type) }
    end

    def sidebar_section_types
      Array(layout_config["sidebar_section_types"]).presence || DEFAULT_SIDEBAR_SECTION_TYPES
    end

    def leading_name
      name_segments.first.presence || full_name
    end

    def accent_name
      name_segments.second.presence || full_name
    end

    def trailing_name
      name_segments.drop(2).join(" ")
    end

    def identity_initials
      name_segments.first(2).filter_map { |segment| segment.first&.upcase }.join
    end

    def header_contact_items
      contact_items.first(3)
    end

    def rail_contact_items
      contact_items.first(3)
    end

    def contact_badge_label(label)
      CONTACT_BADGE_LABELS.fetch(label, label.to_s.first.to_s.upcase)
    end

    def utility_badges
      UTILITY_BADGES
    end

    private
      def name_segments
        @name_segments ||= full_name.split.reject(&:blank?)
      end
  end
end
