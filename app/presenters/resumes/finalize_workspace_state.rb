module Resumes
  class FinalizeWorkspaceState
    def initialize(resume:, step_sections:, view_context:)
      @resume = resume
      @step_sections = Array(step_sections)
      @view_context = view_context
    end

    def workspace_tabs
      @workspace_tabs ||= [
        { key: "template", label: I18n.t("resumes.editor_finalize_step.workspace_tabs.template"), glyph: :layers },
        { key: "design", label: I18n.t("resumes.editor_finalize_step.workspace_tabs.design"), glyph: :swatches },
        { key: "sections", label: I18n.t("resumes.editor_finalize_step.workspace_tabs.sections"), glyph: :preview },
        { key: "spellcheck", label: I18n.t("resumes.editor_finalize_step.workspace_tabs.spellcheck"), glyph: :shield }
      ]
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

    def default_accent_color
      layout_config.fetch("accent_color")
    end

    def accent_color_is_default?
      selected_accent_color == default_accent_color
    end

    def accent_color_palette
      @accent_color_palette ||= ResumeTemplates::Catalog.accent_color_palette.map do |swatch|
        swatch.merge(selected: swatch.fetch(:hex) == selected_accent_color)
      end
    end

    def accent_color_is_custom?
      accent_color_palette.none? { |swatch| swatch.fetch(:selected) }
    end

    def show_contact_icons?
      resume.show_contact_icons?
    end

    def section_order_states
      @section_order_states ||= resume.ordered_sections.map.with_index(1) do |section, index|
        {
          id: "finalize-sections-order-#{section.id}",
          move_url: view_context.move_resume_section_path(section.resume, section, **view_context.resume_builder_step_params("finalize", tab: "sections")),
          title: section.title,
          section_type_label: ResumeBuilder::SectionRegistry.title_for(section.section_type),
          position_label: I18n.t("resumes.editor_finalize_step.sections_workspace.order_position", position: index),
          entry_count_label: I18n.t("resumes.editor_finalize_step.sections_workspace.entry_count", count: section.ordered_entries.count),
          hidden: resume.hidden_section_types.include?(section.section_type),
          visibility_badge_label: I18n.t("resumes.editor_finalize_step.sections_workspace.badges.#{resume.hidden_section_types.include?(section.section_type) ? :hidden : :visible}"),
          visibility_badge_tone: resume.hidden_section_types.include?(section.section_type) ? :warning : :success
        }
      end
    end

    def has_section_order_controls?
      section_order_states.any?
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

    def spellcheck_review_states
      @spellcheck_review_states ||= [
        build_field_review_state(step_key: "heading", content_count: heading_field_count),
        build_field_review_state(step_key: "personal_details", content_count: personal_details_field_count),
        build_section_review_state("experience"),
        build_section_review_state("education"),
        build_section_review_state("skills"),
        build_summary_review_state,
        build_additional_sections_review_state
      ]
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

      def build_field_review_state(step_key:, content_count:)
        build_review_state(
          key: step_key,
          title: step_title(step_key),
          description: step_description(step_key),
          path: view_context.edit_resume_path(resume, step: step_key),
          content_label: I18n.t("resumes.editor_finalize_step.spellcheck_workspace.counts.field_count", count: content_count),
          ready: content_count.positive?
        )
      end

      def build_section_review_state(step_key)
        section_types = ResumeBuilder::StepCatalog.fetch(step_key).fetch(:section_types)
        sections = resume.ordered_sections.select { |section| section_types.include?(section.section_type) }
        entry_count = sections.sum { |section| section.ordered_entries.size }

        build_review_state(
          key: step_key,
          title: step_title(step_key),
          description: step_description(step_key),
          path: view_context.edit_resume_path(resume, step: step_key),
          content_label: section_entry_label(section_count: sections.size, entry_count: entry_count),
          ready: sections.any? || entry_count.positive?
        )
      end

      def build_summary_review_state
        word_count = summary_word_count

        build_review_state(
          key: "summary",
          title: step_title("summary"),
          description: step_description("summary"),
          path: view_context.edit_resume_path(resume, step: "summary"),
          content_label: I18n.t("resumes.editor_finalize_step.spellcheck_workspace.counts.word_count", count: word_count),
          ready: word_count.positive?
        )
      end

      def build_additional_sections_review_state
        entry_count = step_sections.sum { |section| section.ordered_entries.size }

        build_review_state(
          key: "additional_sections",
          title: I18n.t("resumes.editor_finalize_step.spellcheck_workspace.cards.additional_sections.title"),
          description: I18n.t("resumes.editor_finalize_step.spellcheck_workspace.cards.additional_sections.description"),
          path: view_context.edit_resume_path(resume, step: "finalize", tab: "sections"),
          content_label: section_entry_label(section_count: step_sections.size, entry_count: entry_count),
          ready: step_sections.any? || entry_count.positive?
        )
      end

      def build_review_state(key:, title:, description:, path:, content_label:, ready:)
        {
          key: key,
          title: title,
          description: description,
          path: path,
          content_label: content_label,
          ready: ready,
          status_label: I18n.t("resumes.editor_finalize_step.spellcheck_workspace.statuses.#{ready ? :ready : :empty}"),
          status_tone: ready ? :success : :neutral,
          action_style: ready ? :primary : :secondary
        }
      end

      def step_title(step_key)
        ResumeBuilder::StepCatalog.fetch(step_key).fetch(:title)
      end

      def step_description(step_key)
        ResumeBuilder::StepCatalog.fetch(step_key).fetch(:description)
      end

      def section_entry_label(section_count:, entry_count:)
        I18n.t(
          "resumes.editor_finalize_step.spellcheck_workspace.counts.section_entry_summary",
          section_label: I18n.t("resumes.editor_finalize_step.sections_workspace.section_count", count: section_count),
          entry_label: I18n.t("resumes.editor_finalize_step.sections_workspace.entry_count", count: entry_count)
        )
      end

      def heading_field_count
        [
          resume.contact_field("full_name"),
          resume.headline,
          resume.contact_field("email"),
          resume.contact_field("phone"),
          resume.contact_field("city"),
          resume.contact_field("country"),
          resume.contact_field("website"),
          resume.contact_field("linkedin")
        ].count(&:present?)
      end

      def personal_details_field_count
        Resume::PERSONAL_DETAIL_FIELDS.count { |field| resume.personal_detail_field(field).present? } +
          (resume.contact_field("driving_licence").present? ? 1 : 0)
      end

      def summary_word_count
        resume.summary.to_s.scan(/\S+/).size
      end
  end
end
