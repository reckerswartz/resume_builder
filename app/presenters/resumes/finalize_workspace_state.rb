module Resumes
  class FinalizeWorkspaceState
    def initialize(resume:, step_sections:, view_context:)
      @resume = resume
      @step_sections = Array(step_sections)
      @view_context = view_context
    end

    def template_badges
      @template_badges ||= [
        { label: ResumeTemplates::Catalog.family_label(layout_config.fetch("family")), tone: :neutral },
        { label: I18n.t("resumes.editor_finalize_step.template_workspace.badges.switch_anytime"), tone: :neutral }
      ]
    end

    def design_badges
      @design_badges ||= [
        { label: I18n.t("resumes.editor_finalize_step.design_workspace.badges.page_size", page_size: resume.page_size), tone: :neutral },
        { label: I18n.t("resumes.editor_finalize_step.design_workspace.badges.font_family", font_family: ResumeTemplates::Catalog.font_family_label(resume.font_family)), tone: :neutral },
        { label: I18n.t("resumes.editor_finalize_step.design_workspace.badges.font_scale", font_scale: ResumeTemplates::Catalog.font_scale_label(resume.font_scale)), tone: :neutral },
        { label: I18n.t("resumes.editor_finalize_step.design_workspace.badges.density", density: ResumeTemplates::Catalog.density_label(resume.density)), tone: :neutral }
      ]
    end

    def font_family_options
      [
        [
          I18n.t(
            "resumes.editor_finalize_step.design_workspace.template_default_font_family",
            font_family: ResumeTemplates::Catalog.font_family_label(default_font_family)
          ),
          ""
        ],
        *ResumeTemplates::Catalog.font_family_options
      ]
    end

    def selected_font_family
      (resume.settings || {})["font_family"].to_s
    end

    def font_scale_options
      [
        [
          I18n.t(
            "resumes.editor_finalize_step.design_workspace.template_default_font_scale",
            font_scale: ResumeTemplates::Catalog.font_scale_label(default_font_scale)
          ),
          ""
        ],
        *ResumeTemplates::Catalog.font_scale_options
      ]
    end

    def density_options
      [
        [
          I18n.t(
            "resumes.editor_finalize_step.design_workspace.template_default_density",
            density: ResumeTemplates::Catalog.density_label(default_density)
          ),
          ""
        ],
        *ResumeTemplates::Catalog.density_options
      ]
    end

    def section_spacing_options
      [
        [
          I18n.t(
            "resumes.editor_finalize_step.design_workspace.template_default_section_spacing",
            section_spacing: ResumeTemplates::Catalog.section_spacing_label(default_section_spacing)
          ),
          ""
        ],
        *ResumeTemplates::Catalog.section_spacing_options
      ]
    end

    def paragraph_spacing_options
      [
        [
          I18n.t(
            "resumes.editor_finalize_step.design_workspace.template_default_paragraph_spacing",
            paragraph_spacing: ResumeTemplates::Catalog.paragraph_spacing_label(default_paragraph_spacing)
          ),
          ""
        ],
        *ResumeTemplates::Catalog.paragraph_spacing_options
      ]
    end

    def line_spacing_options
      [
        [
          I18n.t(
            "resumes.editor_finalize_step.design_workspace.template_default_line_spacing",
            line_spacing: ResumeTemplates::Catalog.line_spacing_label(default_line_spacing)
          ),
          ""
        ],
        *ResumeTemplates::Catalog.line_spacing_options
      ]
    end

    def page_size_options
      Resume::PAGE_SIZES.map { |page_size| [ page_size, page_size ] }
    end

    def selected_font_scale
      (resume.settings || {})["font_scale"].to_s
    end

    def selected_density
      (resume.settings || {})["density"].to_s
    end

    def selected_section_spacing
      (resume.settings || {})["section_spacing"].to_s
    end

    def selected_paragraph_spacing
      (resume.settings || {})["paragraph_spacing"].to_s
    end

    def selected_line_spacing
      (resume.settings || {})["line_spacing"].to_s
    end

    def selected_page_size
      resume.page_size
    end

    def selected_accent_color
      resume.accent_color
    end

    def show_contact_icons?
      resume.show_contact_icons?
    end

    def section_visibility_states
      @section_visibility_states ||= grouped_sections.map do |section_type, sections|
        hidden = resume.hidden_section_types.include?(section_type)

        {
          section_type: section_type,
          label: ResumeBuilder::SectionRegistry.title_for(section_type),
          input_id: "resume_settings_hidden_sections_#{section_type.tr('-', '_')}",
          hidden: hidden,
          badge_label: I18n.t("resumes.editor_finalize_step.sections_workspace.badges.#{hidden ? :hidden : :visible}"),
          badge_tone: hidden ? :warning : :success,
          summary: I18n.t(
            "resumes.editor_finalize_step.sections_workspace.summary",
            section_label: I18n.t("resumes.editor_finalize_step.sections_workspace.section_count", count: sections.size),
            entry_label: I18n.t("resumes.editor_finalize_step.sections_workspace.entry_count", count: sections.sum { |section| section.ordered_entries.size })
          )
        }
      end
    end

    def has_section_visibility_controls?
      section_visibility_states.any?
    end

    def additional_section_count
      step_sections.size
    end

    private
      attr_reader :resume, :step_sections, :view_context

      def layout_config
        @layout_config ||= resume.template.render_layout_config
      end

      def default_font_family
        layout_config.fetch("font_family")
      end

      def default_font_scale
        layout_config.fetch("font_scale")
      end

      def default_density
        layout_config.fetch("density")
      end

      def default_section_spacing
        layout_config.fetch("section_spacing")
      end

      def default_paragraph_spacing
        layout_config.fetch("paragraph_spacing")
      end

      def default_line_spacing
        layout_config.fetch("line_spacing")
      end

      def grouped_sections
        resume.ordered_sections.group_by(&:section_type)
      end
  end
end
