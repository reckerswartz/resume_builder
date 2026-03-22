module Admin::TemplatesHelper
  include ResumesHelper

  def template_status_badge_tone(template)
    template.active? ? :success : :neutral
  end

  def template_status_label(template)
    template.active? ? "Active" : "Inactive"
  end

  def template_layout_metadata(template)
    @template_layout_metadata ||= {}
    @template_layout_metadata[template.object_id] ||= begin
      layout_config = template.normalized_layout_config
      family = layout_config.fetch("family")
      family_label = ResumeTemplates::Catalog.family_label(family)
      sidebar_section_labels = Array(layout_config["sidebar_section_types"]).map do |section_type|
        ResumeBuilder::SectionRegistry.title_for(section_type)
      end

      {
        family:,
        family_label:,
        accent_color: layout_config.fetch("accent_color"),
        column_count: layout_config.fetch("column_count"),
        column_count_label: ResumeTemplates::Catalog.column_count_label(layout_config.fetch("column_count")),
        density: layout_config.fetch("density"),
        density_label: layout_config.fetch("density").titleize,
        font_scale: layout_config.fetch("font_scale"),
        font_scale_label: layout_config.fetch("font_scale").titleize,
        theme_tone: layout_config.fetch("theme_tone"),
        theme_tone_label: ResumeTemplates::Catalog.theme_tone_label(layout_config.fetch("theme_tone")),
        supports_headshot: layout_config.fetch("supports_headshot"),
        header_style: layout_config.fetch("header_style"),
        header_style_label: layout_config.fetch("header_style").titleize,
        entry_style: layout_config.fetch("entry_style"),
        entry_style_label: layout_config.fetch("entry_style").titleize,
        skill_style: layout_config.fetch("skill_style"),
        skill_style_label: layout_config.fetch("skill_style").titleize,
        section_heading_style: layout_config.fetch("section_heading_style"),
        section_heading_style_label: layout_config.fetch("section_heading_style").titleize,
        shell_style: layout_config.fetch("shell_style"),
        shell_style_label: layout_config.fetch("shell_style").titleize,
        sidebar_position: layout_config["sidebar_position"],
        sidebar_section_labels:,
        summary: template_card_summary(
          family_label:,
          header_style: layout_config.fetch("header_style"),
          section_heading_style: layout_config.fetch("section_heading_style"),
          entry_style: layout_config.fetch("entry_style"),
          sidebar_position: layout_config["sidebar_position"],
          sidebar_section_labels:
        ),
        short_label: family_label.first(2).upcase
      }
    end
  end

  def template_layout_focus_summary(template)
    metadata = template_layout_metadata(template)
    return "Balanced single-column section flow" if metadata.fetch(:sidebar_section_labels).blank?

    "#{metadata.fetch(:sidebar_position).to_s.titleize} sidebar for #{metadata.fetch(:sidebar_section_labels).to_sentence}"
  end

  def template_headshot_metadata_label(template)
    template_layout_metadata(template).fetch(:supports_headshot) ? "Supported" : "Fallback only"
  end

  def template_headshot_metadata_description(template)
    if template_layout_metadata(template).fetch(:supports_headshot)
      "This template can render an uploaded resume headshot in the live preview and PDF export. Drafts without a photo still fall back safely to the non-photo identity treatment."
    else
      "This template keeps its non-photo identity treatment even when a resume has a headshot attached."
    end
  end

  def template_headshot_metadata_tone(template)
    template_layout_metadata(template).fetch(:supports_headshot) ? :info : :neutral
  end

  def template_visibility_label(template)
    template.active? ? "User-visible" : "Admin-only"
  end

  def template_visibility_description(template)
    if template.active?
      "Signed-in users can choose this template in the template gallery and resume creation flow."
    else
      "Inactive templates stay available for admin review and existing resumes, but non-admin users will not see them in the gallery."
    end
  end

  def template_visibility_tone(template)
    template.active? ? :success : :neutral
  end

  def template_artifact_package(template)
    @template_artifact_packages ||= {}
    @template_artifact_packages[template.object_id] ||= ResumeTemplates::ArtifactPackage.new(template: template).call
  end

  def template_artifact_review_counts(template)
    package = template_artifact_package(template)

    {
      source_artifacts: Array(package.fetch(:source_artifacts, [])).size,
      documentation_artifacts: Array(package.fetch(:documentation_artifacts, [])).size,
      validation_artifacts: Array(package.fetch(:validation_artifacts, [])).size,
      derived_artifacts: Array(package.fetch(:derived_artifacts, [])).size,
      candidate_implementations: Array(package.fetch(:candidate_implementations, [])).size,
      validation_runs: Array(package.fetch(:validation_runs, [])).size
    }
  end

  def template_artifact_review_tone(template)
    package = template_artifact_package(template)
    draft_candidates = Array(package.fetch(:candidate_implementations, []))
    latest_validation_status = Array(package.fetch(:validation_runs, [])).first&.dig(:status).to_s
    return :warning if Array(package.fetch(:source_artifacts, [])).blank?
    return :neutral if package.fetch(:implementation, {}).blank? && draft_candidates.blank?

    return :danger if latest_validation_status == "failed"
    return :success if template_seed_baseline(template)[:ready]
    return :warning if template_seed_baseline(template)[:missing_artifact]
    return :info if package.fetch(:implementation, {}).blank? && draft_candidates.any?
    return :neutral if latest_validation_status.blank? || latest_validation_status == "pending" || latest_validation_status == "needs_review"

    :success
  end

  def template_artifact_review_title(template)
    package = template_artifact_package(template)
    draft_candidates = Array(package.fetch(:candidate_implementations, []))

    if Array(package.fetch(:source_artifacts, [])).blank?
      I18n.t("admin.templates.show.artifact_review.summary.states.source_capture_needed")
    elsif package.fetch(:implementation, {}).blank? && draft_candidates.blank?
      I18n.t("admin.templates.show.artifact_review.summary.states.implementation_follow_up")
    elsif package.fetch(:implementation, {}).blank? && draft_candidates.any?
      I18n.t("admin.templates.show.artifact_review.summary.states.draft_candidate_in_progress", count: draft_candidates.size)
    elsif template_seed_baseline(template)[:missing_artifact]
      I18n.t("admin.templates.show.artifact_review.summary.states.seed_baseline_follow_up")
    elsif template_seed_baseline(template)[:ready]
      I18n.t("admin.templates.show.artifact_review.summary.states.seed_baseline_ready")
    elsif template_artifact_review_tone(template) == :success
      I18n.t("admin.templates.show.artifact_review.summary.states.review_ready")
    else
      I18n.t("admin.templates.show.artifact_review.summary.states.validation_follow_up")
    end
  end

  def template_artifact_review_detail(template)
    counts = template_artifact_review_counts(template)

    [
      I18n.t("admin.templates.show.artifact_review.badges.sources", count: counts.fetch(:source_artifacts)),
      template_artifact_review_implementation_badge_label(template),
      I18n.t("admin.templates.show.artifact_review.badges.validation_runs", count: counts.fetch(:validation_runs))
    ].join(" · ")
  end

  def template_seed_baseline_status_label(template)
    seed_baseline = template_seed_baseline(template)
    return I18n.t("admin.templates.show.artifact_review.seed_baseline.states.ready") if seed_baseline[:ready]
    return I18n.t("admin.templates.show.artifact_review.seed_baseline.states.missing") if seed_baseline[:missing_artifact]

    I18n.t("admin.templates.show.artifact_review.seed_baseline.states.unavailable")
  end

  def template_seed_baseline_detail(template)
    seed_baseline = template_seed_baseline(template)
    return I18n.t("admin.templates.show.artifact_review.seed_baseline.descriptions.ready") if seed_baseline[:ready]
    return I18n.t("admin.templates.show.artifact_review.seed_baseline.descriptions.missing") if seed_baseline[:missing_artifact]

    I18n.t("admin.templates.show.artifact_review.seed_baseline.descriptions.unavailable")
  end

  def template_seed_baseline_tone(template)
    seed_baseline = template_seed_baseline(template)
    return :success if seed_baseline[:ready]
    return :warning if seed_baseline[:missing_artifact]

    :neutral
  end

  def template_artifact_review_implementation_badge_label(template)
    implementation = template_current_implementation(template)
    draft_candidates = template_candidate_implementations(template)
    return I18n.t("admin.templates.show.artifact_review.badges.draft_candidates", count: draft_candidates.size) if implementation.blank? && draft_candidates.any?
    return I18n.t("admin.templates.show.artifact_review.badges.implementation_pending") if implementation.blank?

    I18n.t(
      "admin.templates.show.artifact_review.badges.implementation_ready",
      status: template_lifecycle_status_label(implementation.fetch(:status, nil))
    )
  end

  def template_artifact_review_implementation_badge_tone(template)
    implementation = template_current_implementation(template)
    return :info if implementation.blank? && template_candidate_implementations(template).any?
    return :neutral if implementation.blank?

    template_implementation_status_tone(implementation.fetch(:status, nil))
  end

  def template_artifact_review_groups(template)
    package = template_artifact_package(template)
    group_keys = %i[source_artifacts documentation_artifacts validation_artifacts]
    group_keys << :derived_artifacts if Array(package.fetch(:derived_artifacts, [])).any?

    group_keys.map do |key|
      artifacts = Array(package.fetch(key, []))

      {
        key: key,
        title: I18n.t("admin.templates.show.artifact_review.groups.#{key}.title"),
        description: I18n.t("admin.templates.show.artifact_review.groups.#{key}.description"),
        empty_title: I18n.t("admin.templates.show.artifact_review.groups.#{key}.empty_title"),
        empty_description: I18n.t("admin.templates.show.artifact_review.groups.#{key}.empty_description"),
        artifacts: artifacts,
        count_label: pluralize(artifacts.count, "artifact"),
        tone: key == :source_artifacts && artifacts.any? ? :success : :neutral
      }
    end
  end

  def template_current_implementation(template)
    template_artifact_package(template).fetch(:implementation, {})
  end

  def template_seed_baseline(template)
    template_artifact_package(template).fetch(:seed_baseline, {})
  end

  def template_candidate_implementations(template)
    Array(template_artifact_package(template).fetch(:candidate_implementations, []))
  end

  def template_historical_implementations(template)
    Array(template_artifact_package(template).fetch(:historical_implementations, []))
  end

  def template_recent_validation_runs(template)
    Array(template_artifact_package(template).fetch(:validation_runs, []))
  end

  def template_candidate_created_at_label(candidate)
    return if candidate[:created_at].blank?

    I18n.l(candidate[:created_at], format: :long)
  end

  def template_candidate_summary(candidate)
    [
      candidate[:source_artifact_identifier].presence && "#{I18n.t("admin.templates.show.fields.source_artifact")}: #{candidate[:source_artifact_identifier]}",
      template_candidate_created_at_label(candidate)
    ].compact.join(" · ")
  end

  def template_implementation_history_summary(implementation)
    [
      implementation[:source_artifact_identifier].presence && "#{I18n.t("admin.templates.show.fields.source_artifact")}: #{implementation[:source_artifact_identifier]}",
      (I18n.l(implementation[:created_at], format: :long) if implementation[:created_at].present?)
    ].compact.join(" · ")
  end

  def template_candidate_latest_validation_run(candidate)
    candidate[:latest_validation_run] || {}
  end

  def template_candidate_latest_validation_label(candidate)
    validation_run = template_candidate_latest_validation_run(candidate)
    return I18n.t("admin.templates.show.implementation_validation.draft_candidates.validation.empty_state") if validation_run.blank?

    [
      template_lifecycle_status_label(validation_run[:validation_type]),
      template_lifecycle_status_label(validation_run[:status]),
      (I18n.l(validation_run[:validated_at], format: :long) if validation_run[:validated_at].present?)
    ].compact.join(" · ")
  end

  def template_candidate_latest_validation_tone(candidate)
    validation_run = template_candidate_latest_validation_run(candidate)
    return :neutral if validation_run.blank?

    template_validation_status_tone(validation_run[:status])
  end

  def template_candidate_promotion_message(candidate)
    validation_run = template_candidate_latest_validation_run(candidate)
    return I18n.t("admin.templates.show.implementation_validation.draft_candidates.guidance.promotion_ready") if candidate[:promotion_ready]
    return I18n.t("admin.templates.show.implementation_validation.draft_candidates.guidance.validation_required") if validation_run.blank?

    case validation_run[:status].to_s
    when "needs_review"
      I18n.t("admin.templates.show.implementation_validation.draft_candidates.guidance.follow_up_required")
    when "failed"
      I18n.t("admin.templates.show.implementation_validation.draft_candidates.guidance.failed_review")
    else
      I18n.t("admin.templates.show.implementation_validation.draft_candidates.guidance.validation_required")
    end
  end

  def template_implementation_promotion_message(implementation)
    case implementation[:next_promotion_target].to_s
    when "stable"
      I18n.t("admin.templates.show.implementation_validation.implementation_card.guidance.stable_ready")
    when "seeded"
      I18n.t("admin.templates.show.implementation_validation.implementation_card.guidance.seeded_ready")
    else
      if implementation[:status].to_s == "seeded"
        I18n.t("admin.templates.show.implementation_validation.implementation_card.guidance.seeded_complete")
      else
        I18n.t("admin.templates.show.implementation_validation.implementation_card.guidance.no_further_promotion")
      end
    end
  end

  def template_implementation_promotion_action_label(implementation)
    case implementation[:next_promotion_target].to_s
    when "stable"
      I18n.t("admin.templates.show.implementation_validation.implementation_card.actions.promote_to_stable")
    when "seeded"
      I18n.t("admin.templates.show.implementation_validation.implementation_card.actions.promote_to_seeded")
    end
  end

  def template_implementation_promotion_tone(implementation)
    return :success if implementation[:status].to_s == "seeded"
    return :info if implementation[:next_promotion_target].present?

    template_implementation_status_tone(implementation[:status])
  end

  def template_implementation_history_message(implementation)
    if implementation[:status].to_s == "archived"
      I18n.t(
        "admin.templates.show.implementation_validation.history.guidance.archived",
        status: template_lifecycle_status_label(implementation[:archived_from_status].presence || implementation[:status])
      )
    else
      I18n.t("admin.templates.show.implementation_validation.history.guidance.archive_ready")
    end
  end

  def template_implementation_history_tone(implementation)
    return :neutral if implementation[:status].to_s == "archived"

    template_implementation_status_tone(implementation[:status])
  end

  def template_implementation_archive_action_label(implementation)
    return unless implementation[:archivable]

    I18n.t("admin.templates.show.implementation_validation.history.actions.archive")
  end

  def template_implementation_archived_from_badge_label(implementation)
    return if implementation[:archived_from_status].blank?

    I18n.t(
      "admin.templates.show.implementation_validation.history.archived_from_badge",
      status: template_lifecycle_status_label(implementation[:archived_from_status])
    )
  end

  def template_implementation_status_tone(status)
    case status.to_s
    when "stable", "seeded"
      :success
    when "validated"
      :info
    else
      :neutral
    end
  end

  def template_validation_status_tone(status)
    case status.to_s
    when "passed"
      :success
    when "failed"
      :danger
    when "needs_review"
      :warning
    else
      :neutral
    end
  end

  def template_lifecycle_status_label(status)
    status.to_s.tr("_", " ").titleize
  end

  def template_artifact_type_label(artifact_type)
    artifact_type.to_s.tr("_", " ").titleize
  end

  def template_artifact_attachment_summary(artifact)
    attachment = artifact[:attachment] || {}
    return if attachment.blank?

    [ attachment["filename"], number_to_human_size(attachment["byte_size"]) ].compact.join(" · ")
  end

  def template_artifact_role_label(artifact)
    artifact.dig(:metadata, "artifact_role").to_s.tr("_", " ").titleize.presence
  end

  def template_validation_run_metric_summary(run)
    metrics = run[:metrics] || {}
    summary = [
      ("Pixel #{metrics["pixel_status"].to_s.tr("_", " ").titleize}" if metrics["pixel_status"].present?),
      (I18n.t("admin.templates.show.metric_labels.open_discrepancies", count: metrics["open_discrepancy_count"]) if metrics.key?("open_discrepancy_count")),
      (I18n.t("admin.templates.show.metric_labels.resolved_discrepancies", count: metrics["resolved_discrepancy_count"]) if metrics.key?("resolved_discrepancy_count"))
    ].compact

    return run[:notes].presence.to_s if summary.blank?

    summary.join(" · ")
  end
end
