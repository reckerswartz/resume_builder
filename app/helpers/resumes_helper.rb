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

  def template_cards_for_builder(selected_template: nil, templates: nil)
    builder_templates(selected_template:, templates:).map do |template|
      layout_config = template.normalized_layout_config
      family = layout_config.fetch("family")
      family_label = ResumeTemplates::Catalog.family_label(layout_config.fetch("family"))
      sidebar_section_labels = Array(layout_config["sidebar_section_types"]).map do |section_type|
        ResumeBuilder::SectionRegistry.title_for(section_type)
      end

      {
        template: template,
        preview_resume: template_preview_resume(template),
        family: family,
        family_label: family_label,
        accent_color: layout_config.fetch("accent_color"),
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

  def template_preview_resume(template)
    @template_preview_resumes ||= {}
    @template_preview_resumes[template.id || template.slug] ||= ResumeTemplates::PreviewResumeBuilder.new(template: template).call
  end

  def resume_template_picker_state(resume:, form_object_name:, field_label:, description:, mode: :default)
    @resume_template_picker_states ||= Hash.new { |hash, key| hash[key] = {} }
    state_key = [ resume.template_id, resume.template&.id, form_object_name, field_label, description, mode ]

    @resume_template_picker_states[resume.object_id][state_key] ||= Resumes::TemplatePickerState.new(
      resume: resume,
      form_object_name: form_object_name,
      field_label: field_label,
      description: description,
      mode: mode,
      view_context: self
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

  def resume_builder_step_params(step = current_resume_builder_step)
    { step: step }
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

  def entry_field_value(entry, key)
    case key
    when "highlights_text"
      Array(entry.content["highlights"]).join("\n")
    when "start_month"
      entry_date_part(entry.content["start_date"], :month)
    when "start_year"
      entry_date_part(entry.content["start_date"], :year)
    when "end_month"
      entry_current_role?(entry) ? "" : entry_date_part(entry.content["end_date"], :month)
    when "end_year"
      entry_current_role?(entry) ? "" : entry_date_part(entry.content["end_date"], :year)
    when "remote"
      ActiveModel::Type::Boolean.new.cast(entry.content["remote"])
    when "current_role"
      entry_current_role?(entry)
    else
      entry.content.fetch(key, "")
    end
  end

  def entry_field_text_area?(field)
    field[:as] == :textarea
  end

  def entry_field_checkbox?(field)
    field[:as] == :checkbox
  end

  def entry_field_checked?(entry, key)
    ActiveModel::Type::Boolean.new.cast(entry_field_value(entry, key))
  end

  def entry_editor_title(entry, section)
    fallback = I18n.t("resumes.entry_form.titles.entry_fallback", section: ResumeBuilder::SectionRegistry.title_for(section.section_type))

    case section.section_type
    when "experience"
      entry.content["title"].presence || entry.content["organization"].presence || fallback
    when "education"
      entry.content["degree"].presence || entry.content["institution"].presence || fallback
    when "skills"
      entry.content["name"].presence || fallback
    when "projects"
      entry.content["name"].presence || entry.content["role"].presence || fallback
    else
      entry_first_present_value(entry) || fallback
    end
  end

  def entry_editor_metadata(entry, section)
    case section.section_type
    when "experience"
      [ entry.content["organization"], entry_date_range_label(entry) ].compact_blank.join(" · ").presence
    when "education"
      [ entry.content["institution"], entry_date_range_label(entry) ].compact_blank.join(" · ").presence
    when "skills"
      entry.content["level"].presence
    when "projects"
      [ entry.content["role"], entry.content["url"] ].compact_blank.join(" · ").presence
    end
  end

  def entry_editor_supporting_text(entry, section)
    case section.section_type
    when "experience", "projects"
      entry.content["summary"].presence || Array(entry.content["highlights"]).first.presence
    when "education"
      entry.content["details"].presence
    end
  end

  def resume_export_status_label(resume)
    case resume.export_state
    when "queued"
      I18n.t("resumes.helper.export_status.labels.queued")
    when "running"
      I18n.t("resumes.helper.export_status.labels.running")
    when "failed"
      I18n.t("resumes.helper.export_status.labels.failed")
    when "ready"
      I18n.t("resumes.helper.export_status.labels.ready")
    else
      I18n.t("resumes.helper.export_status.labels.draft_only")
    end
  end

  def resume_export_status_message(resume)
    case resume.export_state
    when "queued"
      resume.pdf_export.attached? ? I18n.t("resumes.helper.export_status.messages.queued.with_download") : I18n.t("resumes.helper.export_status.messages.queued.without_download")
    when "running"
      resume.pdf_export.attached? ? I18n.t("resumes.helper.export_status.messages.running.with_download") : I18n.t("resumes.helper.export_status.messages.running.without_download")
    when "failed"
      resume.pdf_export.attached? ? I18n.t("resumes.helper.export_status.messages.failed.with_download") : I18n.t("resumes.helper.export_status.messages.failed.without_download")
    when "ready"
      I18n.t("resumes.helper.export_status.messages.ready")
    else
      I18n.t("resumes.helper.export_status.messages.draft_only")
    end
  end

  def resume_export_status_badge_classes(resume, context: :editor)
    dark_context = context.to_sym == :editor

    case resume.export_state
    when "ready"
      dark_context ? "border border-emerald-300/30 bg-emerald-300/15 text-emerald-100" : "border border-emerald-200 bg-emerald-50 text-emerald-700"
    when "failed"
      dark_context ? "border border-rose-300/30 bg-rose-300/15 text-rose-100" : "border border-rose-200 bg-rose-50 text-rose-700"
    when "running"
      dark_context ? "border border-amber-300/30 bg-amber-300/15 text-amber-100" : "border border-amber-200 bg-amber-50 text-amber-700"
    when "queued"
      dark_context ? "border border-sky-300/30 bg-sky-300/15 text-sky-100" : "border border-sky-200 bg-sky-50 text-sky-700"
    else
      dark_context ? "border border-white/15 bg-white/10 text-white/80" : "border border-slate-200 bg-white text-slate-600"
    end
  end

  def resume_source_document_autofill_supported?(resume)
    Resumes::SourceTextResolver.supported_upload?(resume.source_document)
  end

  def resume_source_cloud_import_provider_states(resume)
    return_to = request&.fullpath.to_s
    resume_id = resume&.persisted? ? resume.id : nil

    Resumes::CloudImportProviderCatalog.all.map do |provider|
      configured = provider.fetch(:configured)
      provider_label = provider.fetch(:label)

      {
        key: provider.fetch(:key),
        label: provider_label,
        description: provider.fetch(:description),
        status_label: configured ? I18n.t("resumes.helper.source_cloud_import.status.configured") : I18n.t("resumes.helper.source_cloud_import.status.setup_required"),
        status_tone: configured ? :neutral : :warning,
        action_label: configured ? I18n.t("resumes.helper.source_cloud_import.actions.connect_soon") : I18n.t("resumes.helper.source_cloud_import.actions.see_setup"),
        action_path: resume_source_import_path(provider.fetch(:key), return_to: return_to.presence, resume_id: resume_id),
        message: if configured
          I18n.t("resumes.cloud_import_provider_catalog.feedback.configured", provider: provider_label)
        else
          I18n.t("resumes.cloud_import_provider_catalog.feedback.setup_required", provider: provider_label, env_vars: provider.fetch(:required_env_vars).to_sentence)
        end
      }
    end
  end

  def resume_source_upload_review_state(resume, autofill_enabled:)
    return unless resume.source_document.attached?

    attachment = resume.source_document
    supported_upload = resume_source_document_autofill_supported?(resume)
    content_type = attachment.blob.content_type.presence || I18n.t("resumes.helper.source_upload_review.unknown_type")

    if supported_upload && autofill_enabled
      {
        title: I18n.t("resumes.helper.source_upload_review.ready_for_ai_import.title"),
        badge_label: I18n.t("resumes.helper.source_upload_review.ready_for_ai_import.badge_label"),
        badge_tone: :success,
        panel_tone: :success,
        filename: attachment.filename.to_s,
        content_type: content_type,
        file_size: number_to_human_size(attachment.byte_size),
        message: I18n.t("resumes.helper.source_upload_review.ready_for_ai_import.message")
      }
    elsif supported_upload
      {
        title: I18n.t("resumes.helper.source_upload_review.supported_upload_attached.title"),
        badge_label: I18n.t("resumes.helper.source_upload_review.supported_upload_attached.badge_label"),
        badge_tone: :neutral,
        panel_tone: :default,
        filename: attachment.filename.to_s,
        content_type: content_type,
        file_size: number_to_human_size(attachment.byte_size),
        message: I18n.t("resumes.helper.source_upload_review.supported_upload_attached.message")
      }
    else
      {
        title: I18n.t("resumes.helper.source_upload_review.reference_file_only.title"),
        badge_label: I18n.t("resumes.helper.source_upload_review.reference_file_only.badge_label"),
        badge_tone: :neutral,
        panel_tone: :default,
        filename: attachment.filename.to_s,
        content_type: content_type,
        file_size: number_to_human_size(attachment.byte_size),
        message: I18n.t("resumes.helper.source_upload_review.reference_file_only.message")
      }
    end
  end

  def resume_source_autofill_status_label(resume, autofill_enabled:)
    return I18n.t("resumes.helper.source_autofill.labels.unavailable") unless autofill_enabled

    case resume.source_mode
    when "paste"
      resume.source_text.to_s.squish.present? ? I18n.t("resumes.helper.source_autofill.labels.paste_ready") : I18n.t("resumes.helper.source_autofill.labels.paste_required")
    when "upload"
      return I18n.t("resumes.helper.source_autofill.labels.attach_file") unless resume.source_document.attached?

      resume_source_document_autofill_supported?(resume) ? I18n.t("resumes.helper.source_autofill.labels.upload_ready") : I18n.t("resumes.helper.source_autofill.labels.reference_file_only")
    else
      I18n.t("resumes.helper.source_autofill.labels.choose_import_path")
    end
  end

  def resume_source_autofill_status_message(resume, autofill_enabled:)
    return I18n.t("resumes.helper.source_autofill.messages.unavailable") unless autofill_enabled

    case resume.source_mode
    when "paste"
      if resume.source_text.to_s.squish.present?
        I18n.t("resumes.helper.source_autofill.messages.paste_ready")
      else
        I18n.t("resumes.helper.source_autofill.messages.paste_required")
      end
    when "upload"
      return I18n.t("resumes.helper.source_autofill.messages.attach_document") unless resume.source_document.attached?

      if resume_source_document_autofill_supported?(resume)
        I18n.t("resumes.helper.source_autofill.messages.upload_ready")
      else
        I18n.t("resumes.helper.source_autofill.messages.upload_reference_only", formats: Resumes::SourceTextResolver.supported_upload_formats_label)
      end
    else
      I18n.t("resumes.helper.source_autofill.messages.scratch_mode")
    end
  end

  def resume_source_autofill_action_ready?(resume, autofill_enabled:)
    return false unless autofill_enabled

    case resume.source_mode
    when "paste"
      resume.source_text.to_s.squish.present?
    when "upload"
      resume.source_document.attached? && resume_source_document_autofill_supported?(resume)
    else
      false
    end
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

    def entry_current_role?(entry)
      ActiveModel::Type::Boolean.new.cast(entry.content["current_role"]) || %w[Current Present].include?(entry.content["end_date"])
    end

    def entry_date_range_label(entry)
      start_date = entry.content["start_date"].presence
      end_date = entry_current_role?(entry) ? "Present" : entry.content["end_date"].presence

      return if start_date.blank? && end_date.blank?

      [ start_date, end_date ].compact.join(" - ")
    end

    def entry_date_part(value, part)
      normalized_value = value.to_s.squish
      return "" if normalized_value.blank?

      components = normalized_value.split(" ", 2)
      return components.first if part == :year && components.one?
      return components.first if part == :month && components.many?
      return components.last.to_s if part == :year && components.many?

      ""
    end

    def entry_first_present_value(entry)
      entry.content.values.flatten.map { |value| value.to_s.squish }.find(&:present?)
    end

end
