require "rails_helper"

RSpec.describe "Template accent variants", type: :system, js: true do
  let(:user) { create(:user) }
  let(:experience_level) { "three_to_five_years" }
  let(:resume_intake_params) do
    {
      intake_details: {
        experience_level: experience_level
      }
    }
  end
  let!(:modern_template) do
    create(
      :template,
      name: "Modern Slate",
      slug: "modern-slate",
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: "modern")
    )
  end
  let!(:sidebar_template) do
    create(
      :template,
      name: "Sidebar Indigo",
      slug: "sidebar-indigo",
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: "sidebar-accent")
    )
  end

  before do
    sign_in_via_browser(user)
  end

  it "updates the selected picker card preview state when an accent swatch is chosen" do
    visit new_resume_path(step: "setup", template_id: modern_template.id, resume: resume_intake_params)

    find("details[data-resume-template-disclosure] summary").click
    find("details.template-picker-disclosure summary", wait: 5).click
    find(%([data-template-picker-target="card"][data-template-id="#{modern_template.id}"]), wait: 5)

    find(
      %(button[data-template-variant-button="true"][data-template-id="#{modern_template.id}"][data-accent-color="#1D4ED8"]),
      visible: true
    ).click

    expect(page).to have_css(%([data-template-variant-label="true"][data-template-id="#{modern_template.id}"]), text: "Blue accent")

    expect(find('input[name="resume[settings][accent_color]"]', visible: :all).value).to eq("#1D4ED8")
    expect(page).to have_css(
      %([data-template-variant-preview="true"][data-template-id="#{modern_template.id}"][data-accent-color="#1D4ED8"]),
      visible: true
    )
    expect(page).to have_no_css(
      %([data-template-variant-preview="true"][data-template-id="#{modern_template.id}"][data-accent-color="#0F172A"]),
      visible: true
    )

    find(".template-picker-compact-summary details summary").click

    expect(page).to have_link(
      "Open full preview",
      href: template_path(
        modern_template,
        resume: resume_intake_params.deep_merge(settings: { accent_color: "#1D4ED8" })
      )
    )
  end

  it "carries the selected marketplace accent through preview and detail actions" do
    preview_path = template_path(
      sidebar_template,
      resume: resume_intake_params.deep_merge(settings: { accent_color: "#1D4ED8" })
    )
    use_template_path = new_resume_path(
      template_id: sidebar_template.id,
      resume: resume_intake_params.deep_merge(settings: { accent_color: "#1D4ED8" })
    )
    templates_with_accent_path = templates_path(
      resume: resume_intake_params.deep_merge(settings: { accent_color: "#1D4ED8" })
    )

    visit templates_path(resume: resume_intake_params)

    find(
      %(button[data-template-variant-button="true"][data-template-id="#{sidebar_template.id}"][data-accent-color="#1D4ED8"]),
      visible: true
    ).click

    expect(page).to have_css(%([data-template-variant-label="true"][data-template-id="#{sidebar_template.id}"]), text: "Blue accent")
    expect(page).to have_link("Preview template", href: preview_path)
    expect(page).to have_link("Use template", href: use_template_path)

    find(%(a[data-template-variant-preview-link="true"][data-template-id="#{sidebar_template.id}"])).click

    expect(page).to have_current_path(preview_path, ignore_query: false)
    expect(page).to have_text("Blue accent")
    expect(page).to have_link("Use this template", href: use_template_path)
    expect(page).to have_link("Browse all templates", href: templates_with_accent_path)
  end
end
