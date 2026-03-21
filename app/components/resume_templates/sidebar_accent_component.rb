module ResumeTemplates
  class SidebarAccentComponent < BaseComponent
    DEFAULT_SIDEBAR_SECTION_TYPES = %w[skills education].freeze

    def sidebar_left?
      layout_config.fetch("sidebar_position", "left") == "left"
    end

    def sidebar_sections
      visible_sections.select { |section| sidebar_section_types.include?(section.section_type) }
    end

    def main_sections
      visible_sections.reject { |section| sidebar_section_types.include?(section.section_type) }
    end

    def sidebar_section_types
      Array(layout_config["sidebar_section_types"]).presence || DEFAULT_SIDEBAR_SECTION_TYPES
    end
  end
end
