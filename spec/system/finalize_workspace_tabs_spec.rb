require "rails_helper"

RSpec.describe "Finalize workspace tabs", type: :system, js: true do
  let(:user) { create(:user) }
  let!(:template) { create(:template) }

  before do
    sign_in_via_browser(user)
  end

  it "supports keyboard navigation across finalize tabs" do
    resume = create(:resume, user: user, template: template)
    experience_section = create(:section, resume: resume, section_type: "experience", title: "Experience", position: 0)
    create(:section, resume: resume, section_type: "projects", title: "Projects", position: 1)
    create(:entry, section: experience_section, content: { "title" => "Designer" })

    visit edit_resume_path(resume, step: "finalize")

    expect(page).to have_css('button[data-tab-key="template"][aria-selected="true"][tabindex="0"]')
    expect(page).to have_css('button[data-tab-key="design"][aria-selected="false"][tabindex="-1"]')

    find('button[data-tab-key="template"]').send_keys(:arrow_right)

    expect(page).to have_css('button[data-tab-key="design"][aria-selected="true"][tabindex="0"]')
    expect(page).to have_css('select[name="resume[settings][font_family]"]', visible: true)

    find('button[data-tab-key="design"]').send_keys(:end)

    expect(page).to have_css('button[data-tab-key="sections"][aria-selected="true"][tabindex="0"]')
    expect(page).to have_css('[data-finalize-section-order]', visible: true)

    find('button[data-tab-key="sections"]').send_keys(:home)

    expect(page).to have_css('button[data-tab-key="template"][aria-selected="true"][tabindex="0"]')
    expect(page).to have_css('button[data-tab-key="sections"][aria-selected="false"][tabindex="-1"]')
  end
end
