module Admin::TemplatesHelper
  include ResumesHelper

  def template_status_badge_tone(template)
    template.active? ? :success : :neutral
  end

  def template_status_label(template)
    template.active? ? "Active" : "Inactive"
  end

  def template_profile_state(template)
    Admin::Templates::ProfileState.new(template: template, summary_builder: method(:template_card_summary))
  end

  def template_layout_metadata(template)
    template_profile_state(template).layout_metadata
  end

  def template_layout_focus_summary(template)
    template_profile_state(template).layout_focus_summary
  end

  def template_headshot_metadata_label(template)
    template_profile_state(template).headshot_metadata_label
  end

  def template_headshot_metadata_description(template)
    template_profile_state(template).headshot_metadata_description
  end

  def template_headshot_metadata_tone(template)
    template_profile_state(template).headshot_metadata_tone
  end

  def template_visibility_label(template)
    template_profile_state(template).visibility_label
  end

  def template_visibility_description(template)
    template_profile_state(template).visibility_description
  end

  def template_visibility_tone(template)
    template_profile_state(template).visibility_tone
  end

  def template_artifact_review_state(template)
    Admin::Templates::ArtifactReviewState.new(template: template)
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
