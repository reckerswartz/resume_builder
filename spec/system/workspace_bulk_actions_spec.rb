require "rails_helper"

RSpec.describe "Workspace bulk actions", type: :system, js: true do
  let(:user) { create(:user) }
  let!(:template) { create(:template) }

  before do
    sign_in_via_browser(user)
  end

  it "persists selected resumes across pagination and clears them when requested" do
    12.times { |index| create(:resume, user:, template:, title: "Resume #{index + 1}") }
    persistent_resume = create(:resume, user:, template:, title: "Persistent Selection Resume")

    visit resumes_path

    check I18n.t("resumes.resume_card.selection_label", title: persistent_resume.title)

    expect(page).to have_text(I18n.t("resumes.index.bulk_actions.selected_count_one"))
    expect(page).to have_button(I18n.t("resumes.index.bulk_actions.clear_selection"), disabled: false)
    expect(page).to have_button(I18n.t("resumes.index.bulk_actions.export_selected"), disabled: false)
    expect(page).to have_button(I18n.t("resumes.index.bulk_actions.delete_selected"), disabled: false)

    click_link I18n.t("shared.pagination.next")

    expect(page).to have_current_path(/\/resumes\?page=2&resume_ids%5B%5D=#{persistent_resume.id}|\/resumes\?resume_ids%5B%5D=#{persistent_resume.id}&page=2/, url: true)
    expect(page).to have_text(I18n.t("resumes.index.bulk_actions.selected_count_one"))
    expect(page).to have_css(%(input[type="hidden"][name="resume_ids[]"][value="#{persistent_resume.id}"]), visible: false)
    expect(page).to have_button(I18n.t("resumes.index.bulk_actions.clear_selection"), disabled: false)

    click_button I18n.t("resumes.index.bulk_actions.clear_selection")

    expect(page).to have_text(I18n.t("resumes.index.bulk_actions.selected_count_other", count: 0))
    expect(page).to have_no_button(I18n.t("resumes.index.bulk_actions.clear_selection"))
    expect(page).to have_button(I18n.t("resumes.index.bulk_actions.export_selected"), disabled: true)
    expect(page).to have_button(I18n.t("resumes.index.bulk_actions.delete_selected"), disabled: true)

    click_link I18n.t("shared.pagination.previous")

    checkbox = find(%(input[type="checkbox"][value="#{persistent_resume.id}"]), visible: :all)
    expect(checkbox).not_to be_checked
  end
end
