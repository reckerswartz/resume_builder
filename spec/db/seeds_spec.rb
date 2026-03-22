require "rails_helper"

RSpec.describe "db/seeds.rb" do
  let(:seed_file) { Rails.root.join("db/seeds.rb") }

  def load_seeds
    load seed_file.to_s
  end

  it "seeds a demo resume with photo library headshot data" do
    load_seeds

    expect(PlatformSetting.current.feature_enabled?("photo_processing")).to eq(true)
    expect(PlatformSetting.current.feature_enabled?("resume_image_generation")).to eq(false)

    user = User.find_by!(email_address: "demo-with-photo@resume-builder.local")
    resume = user.resumes.find_by!(template: Template.find_by!(slug: "editorial-split"))
    photo_profile = resume.photo_profile

    expect(photo_profile).to be_present
    expect(photo_profile.user).to eq(user)
    expect(photo_profile).to be_active

    source_asset = photo_profile.selected_source_photo_asset
    expect(source_asset).to be_present
    expect(source_asset).to be_source
    expect(source_asset.file).to be_attached

    selection = resume.resume_photo_selections.find_by!(template: resume.template, slot_name: "headshot")
    expect(selection).to be_active
    expect(selection.photo_asset).to eq(photo_profile.photo_assets.find_by!(asset_kind: "enhanced"))
    expect(selection.photo_asset.file).to be_attached
  end

  it "seeds expanded resume content with enough sections and entries for 3 pages" do
    load_seeds

    admin_user = User.find_by!(email_address: "admin@resume-builder.local")
    resume = admin_user.resumes.first

    section_types = resume.sections.pluck(:section_type)
    expect(section_types).to include("experience", "education", "skills", "projects", "certifications", "languages")

    experience_section = resume.sections.find_by!(section_type: "experience")
    expect(experience_section.entries.count).to be >= 5

    education_section = resume.sections.find_by!(section_type: "education")
    expect(education_section.entries.count).to be >= 2

    skills_section = resume.sections.find_by!(section_type: "skills")
    expect(skills_section.entries.count).to be >= 10

    certifications_section = resume.sections.find_by!(section_type: "certifications")
    expect(certifications_section.entries.count).to be >= 2

    languages_section = resume.sections.find_by!(section_type: "languages")
    expect(languages_section.entries.count).to be >= 2
  end

  it "seeds template artifacts for all template families" do
    load_seeds

    Template.find_each do |template|
      artifacts = template.template_artifacts
      expect(artifacts.count).to be >= 2, "Expected at least 2 artifacts for #{template.slug}, got #{artifacts.count}"

      reference = artifacts.find_by(artifact_type: "reference_design")
      expect(reference).to be_present, "Expected a reference_design artifact for #{template.slug}"
      expect(reference.metadata["pixel_status"]).to be_present

      discrepancy = artifacts.find_by(artifact_type: "discrepancy_report")
      expect(discrepancy).to be_present, "Expected a discrepancy_report artifact for #{template.slug}"
      expect(discrepancy.metadata["discrepancies"]).to be_a(Array)
      expect(discrepancy.metadata["discrepancies"]).not_to be_empty

      decision = artifacts.find_by(artifact_type: "decision_log")
      expect(decision).to be_present, "Expected a decision_log artifact for #{template.slug}"

      implementation = template.template_implementations.find_by!(identifier: "#{template.slug}-baseline")
      expect(implementation.source_artifact).to eq(reference)
      expect(implementation.render_profile).to eq(template.normalized_layout_config)

      seed_snapshot = artifacts.find_by(artifact_type: "seed_snapshot", version_label: "#{implementation.identifier}-seeded")
      if implementation.seeded?
        expect(seed_snapshot).to be_present, "Expected a seed_snapshot artifact for seeded baseline #{template.slug}"
        expect(seed_snapshot).to be_active
        expect(seed_snapshot.metadata["template_implementation_identifier"]).to eq(implementation.identifier)
      else
        if seed_snapshot.present?
          expect(seed_snapshot.status).to eq("superseded")
        else
          expect(seed_snapshot).to be_nil
        end
      end

      validation_run = template.template_validation_runs.find_by!(identifier: "#{template.slug}-baseline-manual-review")
      expect(validation_run.template_implementation).to eq(implementation)
      expect(validation_run.reference_artifact).to eq(reference)
    end
  end

  it "seeds template audit resumes for all profiles and templates" do
    load_seeds

    audit_user = User.find_by!(email_address: "template-audit@resume-builder.local")
    template_count = Template.count
    profile_count = Resumes::SeedProfileCatalog.profile_count

    expected_audit_resumes = template_count * profile_count * 2
    expect(audit_user.resumes.count).to eq(expected_audit_resumes),
      "Expected #{expected_audit_resumes} audit resumes (#{template_count} templates × #{profile_count} profiles × 2 modes), got #{audit_user.resumes.count}"

    full_resume = audit_user.resumes.find_by!(slug: "audit-senior-engineer-modern-full")
    expect(full_resume.sections.pluck(:section_type)).to include("experience", "education", "skills", "projects", "certifications", "languages")
    expect(full_resume.sections.find_by!(section_type: "experience").entries.count).to eq(8)
    expect(full_resume.sections.find_by!(section_type: "skills").entries.count).to eq(15)

    minimal_resume = audit_user.resumes.find_by!(slug: "audit-senior-engineer-modern-minimal")
    minimal_section_types = minimal_resume.sections.pluck(:section_type)
    expect(minimal_section_types).to include("experience", "education", "skills")
    expect(minimal_section_types).not_to include("projects", "certifications", "languages")

    hidden = minimal_resume.settings.fetch("hidden_sections", [])
    expect(hidden).to include("projects", "certifications", "languages")
  end

  it "keeps the seeded records idempotent" do
    load_seeds

    baseline_counts = {
      users: User.count,
      resumes: Resume.count,
      photo_profiles: PhotoProfile.count,
      photo_assets: PhotoAsset.count,
      resume_photo_selections: ResumePhotoSelection.count,
      template_artifacts: TemplateArtifact.count,
      template_implementations: TemplateImplementation.count,
      template_validation_runs: TemplateValidationRun.count
    }

    load_seeds

    expect(
      users: User.count,
      resumes: Resume.count,
      photo_profiles: PhotoProfile.count,
      photo_assets: PhotoAsset.count,
      resume_photo_selections: ResumePhotoSelection.count,
      template_artifacts: TemplateArtifact.count,
      template_implementations: TemplateImplementation.count,
      template_validation_runs: TemplateValidationRun.count
    ).to eq(baseline_counts)
  end
end
