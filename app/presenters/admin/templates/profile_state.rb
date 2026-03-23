module Admin
  module Templates
    class ProfileState
      def initialize(template:, summary_builder:)
        @template = template
        @summary_builder = summary_builder
      end

      def layout_metadata
        @layout_metadata ||= begin
          family = layout_config.fetch("family")
          family_label = ResumeTemplates::Catalog.family_label(family)
          sidebar_section_labels = Array(layout_config["sidebar_section_types"]).map do |section_type|
            ResumeBuilder::SectionRegistry.title_for(section_type)
          end

          {
            family: family,
            family_label: family_label,
            accent_color: layout_config.fetch("accent_color"),
            column_count: layout_config.fetch("column_count"),
            column_count_label: ResumeTemplates::Catalog.column_count_label(layout_config.fetch("column_count")),
            density: layout_config.fetch("density"),
            density_label: ResumeTemplates::Catalog.density_label(layout_config.fetch("density")),
            font_scale: layout_config.fetch("font_scale"),
            font_scale_label: ResumeTemplates::Catalog.font_scale_label(layout_config.fetch("font_scale")),
            theme_tone: layout_config.fetch("theme_tone"),
            theme_tone_label: ResumeTemplates::Catalog.theme_tone_label(layout_config.fetch("theme_tone")),
            supports_headshot: layout_config.fetch("supports_headshot"),
            header_style: layout_config.fetch("header_style"),
            header_style_label: ResumeTemplates::Catalog.header_style_label(layout_config.fetch("header_style")),
            entry_style: layout_config.fetch("entry_style"),
            entry_style_label: ResumeTemplates::Catalog.entry_style_label(layout_config.fetch("entry_style")),
            skill_style: layout_config.fetch("skill_style"),
            skill_style_label: ResumeTemplates::Catalog.skill_style_label(layout_config.fetch("skill_style")),
            section_heading_style: layout_config.fetch("section_heading_style"),
            section_heading_style_label: ResumeTemplates::Catalog.section_heading_style_label(layout_config.fetch("section_heading_style")),
            shell_style: layout_config.fetch("shell_style"),
            shell_style_label: ResumeTemplates::Catalog.shell_style_label(layout_config.fetch("shell_style")),
            sidebar_position: layout_config["sidebar_position"],
            sidebar_section_labels: sidebar_section_labels,
            summary: summary_builder.call(
              family_label: family_label,
              header_style: layout_config.fetch("header_style"),
              section_heading_style: layout_config.fetch("section_heading_style"),
              entry_style: layout_config.fetch("entry_style"),
              sidebar_position: layout_config["sidebar_position"],
              sidebar_section_labels: sidebar_section_labels
            ),
            short_label: family_label.first(2).upcase
          }
        end
      end

      def layout_focus_summary
        return "Balanced single-column section flow" if layout_metadata.fetch(:sidebar_section_labels).blank?

        "#{layout_metadata.fetch(:sidebar_position).to_s.titleize} sidebar for #{layout_metadata.fetch(:sidebar_section_labels).to_sentence}"
      end

      def headshot_metadata_label
        layout_metadata.fetch(:supports_headshot) ? "Supported" : "Fallback only"
      end

      def headshot_metadata_description
        if layout_metadata.fetch(:supports_headshot)
          "This template can render an uploaded resume headshot in the live preview and PDF export. Drafts without a photo still fall back safely to the non-photo identity treatment."
        else
          "This template keeps its non-photo identity treatment even when a resume has a headshot attached."
        end
      end

      def headshot_metadata_tone
        layout_metadata.fetch(:supports_headshot) ? :info : :neutral
      end

      def visibility_label
        template.active? ? "User-visible" : "Admin-only"
      end

      def visibility_description
        if template.active?
          "Signed-in users can choose this template in the template gallery and resume creation flow."
        else
          "Inactive templates stay available for admin review and existing resumes, but non-admin users will not see them in the gallery."
        end
      end

      def visibility_tone
        template.active? ? :success : :neutral
      end

      private
        attr_reader :summary_builder, :template

        def layout_config
          @layout_config ||= template.normalized_layout_config
        end
    end
  end
end
