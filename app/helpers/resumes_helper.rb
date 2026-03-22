module ResumesHelper
  def builder_templates(selected_template: nil, templates: nil)
    templates = templates.nil? ? Template.user_visible.order(:name).to_a : Array(templates)

    if selected_template.present? && templates.none? { |template| template.id == selected_template.id }
      templates << selected_template
    end

    templates.uniq(&:id).sort_by(&:name)
  end

  def template_options_for_builder(selected_template: nil, templates: nil)
    builder_templates(selected_template:, templates:).map { |template| [ template.name, template.id ] }
  end

  def template_cards_for_builder(selected_template: nil, templates: nil, selected_accent_colors: nil)
    accent_color_overrides = (selected_accent_colors || {}).to_h.stringify_keys

    builder_templates(selected_template:, templates:).map do |template|
      layout_config = template.render_layout_config
      family = layout_config.fetch("family")
      family_label = ResumeTemplates::Catalog.family_label(layout_config.fetch("family"))
      selected_accent_color = template_card_selected_accent_color(
        template: template,
        layout_config: layout_config,
        selected_accent_colors: accent_color_overrides
      )
      accent_variants = ResumeTemplates::Catalog.accent_variants(
        layout_config,
        selected_accent_color: selected_accent_color
      )
      preview_resumes_by_accent_color = accent_variants.each_with_object({}) do |accent_variant, previews|
        accent_color = accent_variant.fetch(:accent_color)
        previews[accent_color] = template_preview_resume(template, accent_color: accent_color)
      end
      sidebar_section_labels = Array(layout_config["sidebar_section_types"]).map do |section_type|
        ResumeBuilder::SectionRegistry.title_for(section_type)
      end

      {
        template: template,
        preview_resume: preview_resumes_by_accent_color.fetch(selected_accent_color),
        preview_resumes_by_accent_color: preview_resumes_by_accent_color,
        family: family,
        family_label: family_label,
        accent_color: layout_config.fetch("accent_color"),
        selected_accent_color: selected_accent_color,
        accent_variants: accent_variants,
        column_count: layout_config.fetch("column_count"),
        column_count_label: ResumeTemplates::Catalog.column_count_label(layout_config.fetch("column_count")),
        density: layout_config.fetch("density"),
        density_label: ResumeTemplates::Catalog.density_label(layout_config.fetch("density")),
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
        summary: template_card_summary(
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

  def template_card_summary(family_label:, header_style:, section_heading_style:, entry_style:, sidebar_position:, sidebar_section_labels: [])
    if sidebar_position.present? && sidebar_section_labels.any?
      "#{family_label} layout with a #{sidebar_position} sidebar for #{sidebar_section_labels.to_sentence} and #{entry_style} main entries."
    else
      "#{family_label} layout with #{header_style} headers, #{section_heading_style} section headings, and #{entry_style} entries."
    end
  end

  def template_preview_resume(template, accent_color: nil)
    @template_preview_resumes ||= {}
    normalized_accent_color = ResumeTemplates::Catalog.normalized_accent_color(
      accent_color,
      fallback: template.render_layout_config.fetch("accent_color")
    )
    cache_key = [ template.id || template.slug, normalized_accent_color ]

    @template_preview_resumes[cache_key] ||= ResumeTemplates::PreviewResumeBuilder.new(
      template: template,
      accent_color: normalized_accent_color
    ).call
  end

  def resume_template_picker_state(resume:, form_object_name:, field_label:, description:, mode: :default)
    @resume_template_picker_states ||= Hash.new { |hash, key| hash[key] = {} }
    state_key = [ resume.template_id, resume.template&.id, resume.accent_color, form_object_name, field_label, description, mode ]

    @resume_template_picker_states[resume.object_id][state_key] ||= Resumes::TemplatePickerState.new(
      resume: resume,
      form_object_name: form_object_name,
      field_label: field_label,
      description: description,
      mode: mode,
      view_context: self
    )
  end

  def template_card_selected_accent_color(template:, layout_config:, selected_accent_colors: {})
    selected_accent_color = selected_accent_colors[template.id.to_s] || selected_accent_colors[template.id]

    ResumeTemplates::Catalog.normalized_accent_color(
      selected_accent_color,
      fallback: layout_config.fetch("accent_color")
    )
  end

  def resume_summary_suggestion_state(resume, query: nil)
    @resume_summary_suggestion_states ||= Hash.new { |hash, key| hash[key] = {} }
    state_key = [ query.to_s, resume.headline.to_s, resume.experience_level, resume.student_status ]

    @resume_summary_suggestion_states[resume.object_id][state_key] ||= Resumes::SummarySuggestionCatalog.new(
      resume: resume,
      query: query
    ).call
  end

  def section_type_options_for_builder(only: nil)
    section_types = only.present? ? Array(only).map(&:to_s) : ResumeBuilder::SectionRegistry.types
    section_types.map { |section_type| [ ResumeBuilder::SectionRegistry.title_for(section_type), section_type ] }
  end

  def current_resume_builder_step
    resume_builder_catalog.current_step_key(params[:step])
  end

  def current_resume_builder_step_config
    resume_builder_catalog.fetch(current_resume_builder_step)
  end

  def resume_builder_step_params(step = current_resume_builder_step, tab: params[:tab].presence)
    {
      step: step,
      tab: tab
    }.compact
  end

  def resume_builder_steps(resume)
    resume_builder_flow(resume).steps
  end

  def previous_resume_builder_step_path(resume)
    resume_builder_flow(resume).previous_step_path
  end

  def next_resume_builder_step_path(resume)
    resume_builder_flow(resume).next_step_path
  end

  def resume_builder_editor_state(resume)
    @resume_builder_editor_states ||= {}
    @resume_builder_editor_states[resume.object_id] ||= ResumeBuilder::EditorState.new(
      resume: resume,
      flow: resume_builder_flow(resume),
      view_context: self
    )
  end

  def resume_builder_workspace_state(resume)
    @resume_builder_workspace_states ||= {}
    @resume_builder_workspace_states[resume.object_id] ||= ResumeBuilder::WorkspaceState.new(
      resume: resume,
      builder_state: resume_builder_editor_state(resume),
      view_context: self
    )
  end

  def resume_builder_preview_state(resume)
    @resume_builder_preview_states ||= {}
    @resume_builder_preview_states[resume.object_id] ||= ResumeBuilder::PreviewState.new(
      resume: resume,
      builder_state: resume_builder_editor_state(resume),
      view_context: self
    )
  end

  def resume_summary_step_state(resume)
    @resume_summary_step_states ||= Hash.new { |hash, key| hash[key] = {} }
    query = params[:summary_query].to_s

    @resume_summary_step_states[resume.object_id][query] ||= Resumes::SummaryStepState.new(
      resume: resume,
      query: query,
      view_context: self
    )
  end

  def resume_experience_step_state(resume)
    @resume_experience_step_states ||= {}
    @resume_experience_step_states[resume.object_id] ||= Resumes::ExperienceStepState.new(resume: resume)
  end

  def resume_skills_step_state(resume)
    @resume_skills_step_states ||= {}
    @resume_skills_step_states[resume.object_id] ||= Resumes::SkillsStepState.new(resume: resume)
  end

  def resume_show_state(resume)
    @resume_show_states ||= {}
    @resume_show_states[resume.object_id] ||= Resumes::ShowState.new(
      resume: resume,
      builder_state: resume_builder_editor_state(resume),
      view_context: self
    )
  end

  def resume_export_actions_state(resume, context:)
    @resume_export_actions_states ||= Hash.new { |hash, key| hash[key] = {} }
    @resume_export_actions_states[resume.object_id][context.to_sym] ||= Resumes::ExportActionsState.new(
      resume: resume,
      context: context,
      view_context: self
    )
  end

  def resume_finalize_workspace_state(resume, step_sections:)
    Resumes::FinalizeWorkspaceState.new(
      resume: resume,
      step_sections: step_sections,
      view_context: self
    )
  end

  def resume_export_status_state(resume, context:)
    @resume_export_status_states ||= Hash.new { |hash, key| hash[key] = {} }
    @resume_export_status_states[resume.object_id][context.to_sym] ||= Resumes::ExportStatusState.new(
      resume: resume,
      context: context,
      view_context: self
    )
  end

  def resume_primary_identity(resume)
    resume.contact_field("full_name").presence || resume.user.email_address.split("@").first.tr("._", " ").titleize
  end

  def resume_identity_initials(resume)
    resume_primary_identity(resume).split.filter_map { |part| part.first }.first(2).join.upcase.presence || "RB"
  end

  def resume_builder_total_steps(_resume = nil)
    tracked_builder_steps.count
  end

  def resume_builder_completed_steps_count(resume)
    resume_builder_flow(resume).completed_steps_count
  end

  def resume_builder_completion_percentage(resume)
    resume_builder_flow(resume).completion_percentage
  end

  def resume_builder_step_completed?(resume, step_key)
    resume_builder_flow(resume).step_completed?(step_key)
  end

  def resume_builder_sections_for_step(resume, step_key = current_resume_builder_step)
    resume_builder_flow(resume).sections_for_step(step_key)
  end

  def resume_builder_secondary_section_types
    resume_builder_catalog.secondary_section_types
  end

  def resume_builder_add_section_types(step_key = current_resume_builder_step)
    resume_builder_catalog.add_section_types_for(step_key)
  end

  def entry_fields_for(section)
    resume_builder_catalog.entry_fields_for(section.section_type)
  end

  def entry_field_state(entry, section)
    Resumes::EntryFieldState.new(entry: entry, section: section)
  end

  def entry_field_value(entry, key)
    entry_field_state(entry, entry.section).field_value(key)
  end

  def entry_field_text_area?(field)
    field[:as] == :textarea
  end

  def entry_field_checkbox?(field)
    field[:as] == :checkbox
  end

  def entry_field_checked?(entry, key)
    entry_field_state(entry, entry.section).field_checked?(key)
  end

  def entry_editor_title(entry, section)
    entry_field_state(entry, section).editor_title
  end

  def entry_editor_metadata(entry, section)
    entry_field_state(entry, section).editor_metadata
  end

  def entry_editor_supporting_text(entry, section)
    entry_field_state(entry, section).editor_supporting_text
  end

  def resume_export_status_label(resume)
    resume_export_status_state(resume, context: :editor).status_label
  end

  def resume_export_status_message(resume)
    resume_export_status_state(resume, context: :editor).status_message
  end

  def resume_export_status_badge_classes(resume, context: :editor)
    resume_export_status_state(resume, context: context).status_badge_classes
  end

  def resume_source_step_state(resume, autofill_enabled:)
    @resume_source_step_states ||= Hash.new { |hash, key| hash[key] = {} }
    @resume_source_step_states[resume.object_id][autofill_enabled] ||= Resumes::SourceStepState.new(
      resume: resume,
      autofill_enabled: autofill_enabled,
      view_context: self
    )
  end

  def resume_source_document_autofill_supported?(resume)
    resume_source_step_state(resume, autofill_enabled: false).document_autofill_supported?
  end

  def resume_source_cloud_import_provider_states(resume)
    resume_source_step_state(resume, autofill_enabled: false).cloud_import_provider_states
  end

  def resume_source_upload_review_state(resume, autofill_enabled:)
    resume_source_step_state(resume, autofill_enabled: autofill_enabled).upload_review_state
  end

  def resume_source_autofill_status_label(resume, autofill_enabled:)
    resume_source_step_state(resume, autofill_enabled: autofill_enabled).autofill_status_label
  end

  def resume_source_autofill_status_message(resume, autofill_enabled:)
    resume_source_step_state(resume, autofill_enabled: autofill_enabled).autofill_status_message
  end

  def resume_source_autofill_action_ready?(resume, autofill_enabled:)
    resume_source_step_state(resume, autofill_enabled: autofill_enabled).autofill_action_ready?
  end

  private
    def tracked_builder_steps
      resume_builder_catalog.tracked_steps
    end

    def resume_builder_catalog
      ResumeBuilder::StepCatalog
    end

    def resume_builder_flow(resume)
      @resume_builder_flows ||= {}
      @resume_builder_flows[resume.object_id] ||= ResumeBuilder::Flow.new(
        resume: resume,
        requested_step: params[:step],
        view_context: self
      )
    end
end
