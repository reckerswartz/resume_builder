module SystemTestHelpers
  def sign_in_via_browser(user, password: "password123")
    visit new_session_path
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: password
    click_button I18n.t("sessions.new.form.submit")
    expect(page).to have_current_path(resumes_path, ignore_query: true)
  end
end

RSpec.configure do |config|
  config.include SystemTestHelpers, type: :system

  config.before(type: :system) do
    driven_by(:rack_test)
  end

  config.before(type: :system, js: true) do
    driven_by(:selenium, using: :headless_chrome, screen_size: [1400, 2200])
  end
end
