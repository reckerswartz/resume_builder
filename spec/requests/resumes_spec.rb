require 'rails_helper'
require 'zip'

RSpec.describe 'Resumes', type: :request do
  let(:template) { create(:template) }
  let(:user) { create(:user) }
  let(:llm_provider) { create(:llm_provider) }
  let(:llm_model) { create(:llm_model, llm_provider:, identifier: 'resume-autofill-request-model') }
  let(:authenticated) { true }
  let(:provider_client_class) do
    Class.new do
      def generate_text(model:, prompt:)
        {
          content: <<~JSON,
            {
              "resume": {
                "title": "Imported Resume",
                "headline": "Senior Product Engineer",
                "summary": "Builds workflow systems.",
                "contact_details": {
                  "full_name": "Pat Kumar",
                  "email": "pat@example.com",
                  "city": "Pune",
                  "country": "India"
                }
              },
              "sections": {
                "experience": [
                  {
                    "title": "Senior Product Engineer",
                    "organization": "Acme",
                    "start_date": "2022",
                    "end_date": "",
                    "current_role": true,
                    "highlights": ["Built guided builder flows"]
                  }
                ],
                "education": [],
                "skills": [
                  {
                    "name": "Ruby on Rails",
                    "level": "Advanced"
                  }
                ]
              }
            }
          JSON
          token_usage: { 'input_tokens' => 10, 'output_tokens' => 8 },
          metadata: { 'source' => 'request-spec' }
        }
      end
    end
  end

  def create_ready_photo_asset(photo_profile:, filename:, asset_kind: :enhanced, source_asset: nil)
    PhotoAsset.new(photo_profile:, source_asset:, asset_kind:, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  def with_feature_flags(overrides)
    platform_setting = PlatformSetting.current
    original_feature_flags = platform_setting.feature_flags.deep_dup

    platform_setting.update!(
      feature_flags: original_feature_flags.merge(overrides.transform_keys(&:to_s)),
      preferences: platform_setting.preferences
    )

    yield
  ensure
    platform_setting.update!(feature_flags: original_feature_flags, preferences: platform_setting.preferences) if defined?(original_feature_flags)
  end

  before do
    sign_in_as(user) if authenticated
  end

  describe 'GET /resumes/new' do
    it 'keeps the fast-start template picker copy inside a collapsed template disclosure on the setup form' do
      template

      get new_resume_path, params: {
        step: 'setup',
        resume: {
          intake_details: {
            experience_level: 'three_to_five_years'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      template_disclosure = document.at_css('details[data-resume-template-disclosure]')

      expect(response.body).to include(I18n.t('resumes.new.page_header.setup.title'))
      expect(response.body).to include(I18n.t('resumes.form.setup_overview_title'))
      expect(response.body).to include(I18n.t('resumes.form.setup_overview_badges.experience', label: I18n.t('resumes.start_flow_state.experience_options.three_to_five_years')))
      expect(template_disclosure).to be_present
      expect(template_disclosure['open']).to be_nil
      expect(template_disclosure.at_css('summary').text).to include(I18n.t('resumes.form.template_disclosure_summary'))
      expect(template_disclosure.at_css('summary').text).to include(I18n.t('resumes.form.template_disclosure_badge'))
      expect(template_disclosure.at_css('summary').text).to include(I18n.t('resumes.form.template_disclosure_choose_later'))
      expect(template_disclosure.text).to include(I18n.t('resumes.template_picker_compact.fast_start_pill'))
      expect(template_disclosure.text).to include(I18n.t('resumes.template_picker_compact.fast_start_description'))
      expect(template_disclosure.text).to include(I18n.t('resumes.template_picker_compact.choose_later_pill'))
      expect(template_disclosure.text).to include(I18n.t('resumes.template_picker_compact.choose_later_description'))
      expect(template_disclosure.text).to include(I18n.t('resumes.form.template_disclosure_description', template: template.name))
      expect(template_disclosure.at_css('.template-picker-compact')).to be_present
      expect(response.body).not_to include(I18n.t('resumes.editor_finalize_step.template_picker.fast_start_description'))
    end

    it 'preserves a requested accent selection in the setup picker state' do
      classic_template = create(
        :template,
        name: 'Classic Ivory',
        slug: 'classic-ivory',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )

      get new_resume_path, params: {
        step: 'setup',
        template_id: classic_template.id,
        resume: {
          intake_details: {
            experience_level: 'three_to_five_years'
          },
          settings: {
            accent_color: '#334155'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('name="resume[settings][accent_color]"')
      expect(response.body).to include('value="#334155"')
      expect(response.body).to include('Slate accent')

      document = Nokogiri::HTML.parse(response.body)
      compact_summary = document.at_css('.template-picker-compact-summary')
      expect(compact_summary).to be_present
      expect(compact_summary.text).to include(classic_template.name)
      expect(compact_summary.text).to include(I18n.t('resumes.template_picker_compact.accent_carry_through', variant: 'Slate'))
      expect(compact_summary.at_css('span[style*="#334155"]')).to be_present
      expect(response.body).to include(I18n.t('resumes.new.page_header.badges.selected_template', template: classic_template.name))
      expect(response.body).to include(I18n.t('resumes.form.setup_overview_badges.template', template: classic_template.name))
    end

    it 'renders richer experience-step onboarding cards before setup' do
      template

      get new_resume_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('resumes.new.page_header.experience.title'))
      expect(response.body).to include(I18n.t('resumes.start_flow_experience_step.option_descriptions.no_experience'))
      expect(response.body).to include(I18n.t('resumes.start_flow_experience_step.option_descriptions.ten_plus_years'))
      expect(response.body).to include(I18n.t('resumes.start_flow_experience_step.panel_title'))
    end

    it 'renders richer student-step onboarding cards when early-career experience is selected' do
      template

      get new_resume_path, params: {
        step: 'student',
        resume: {
          intake_details: {
            experience_level: 'less_than_3_years'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('resumes.new.page_header.student.title'))
      expect(response.body).to include(I18n.t('resumes.start_flow_student_step.option_descriptions.student'))
      expect(response.body).to include(I18n.t('resumes.start_flow_student_step.option_descriptions.not_student'))
      expect(response.body).to include(I18n.t('resumes.start_flow_student_step.skip_for_now'))
    end
  end

  describe 'POST /resumes' do
    it 'redirects scratch-mode resumes to the heading step instead of the source step' do
      template

      post resumes_path, params: {
        resume: {
          title: 'Scratch Resume',
          headline: 'Engineer',
          template_id: template.id
        }
      }

      created_resume = user.resumes.order(created_at: :desc).first
      expect(created_resume.source_mode).to eq('scratch')
      expect(response).to redirect_to(edit_resume_path(created_resume, step: 'heading'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.resume_created'))
    end

    it 'redirects paste-mode resumes to the source step so content can be reviewed' do
      template

      post resumes_path, params: {
        resume: {
          title: 'Pasted Resume',
          headline: 'Designer',
          source_mode: 'paste',
          source_text: 'Existing resume content here',
          template_id: template.id
        }
      }

      created_resume = user.resumes.order(created_at: :desc).first
      expect(created_resume.source_mode).to eq('paste')
      expect(response).to redirect_to(edit_resume_path(created_resume, step: 'source'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.resume_created'))
    end
  end

  describe 'GET /resumes' do
    it 'keeps workspace cards focused on status badges and actions' do
      resume = create(
        :resume,
        user:,
        template:,
        title: 'Customer Success Resume',
        slug: 'internal-workspace-slug',
        source_mode: 'scratch'
      )

      get resumes_path

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      card = document.css('article').find { |article| article.at_css('h2')&.text.to_s.squish == resume.title }
      metadata_badges = card.xpath('./div[2]/div[1]/div[2]/span').map { |element| element.text.squish }
      action_row = card.xpath('./div[2]/div[2]').first
      secondary_actions = card.at_css('details[data-controller="disclosure"]')

      expect(card).to be_present
      expect(metadata_badges.size).to eq(2)
      expect(metadata_badges.grep(/Updated/).size).to eq(1)
      expect(metadata_badges).to include(I18n.t('resumes.resume_card.metadata_badges.source_mode.scratch'))
      expect(action_row.css('p')).to be_empty
      expect(action_row.css('a, button').map { |element| element.text.squish }).to eq([
        I18n.t('resumes.resume_card.actions.edit'),
        I18n.t('resumes.resume_card.actions.preview'),
        I18n.t('resumes.resume_card.actions.export_pdf')
      ])
      expect(secondary_actions).to be_present
      expect(secondary_actions.text).to include(I18n.t('resumes.resume_card.actions.more_actions'))
      expect(secondary_actions.text).to include(I18n.t('resumes.resume_card.actions.duplicate'))
      expect(secondary_actions.text).to include(I18n.t('resumes.resume_card.actions.delete'))
      expect(card.text).not_to include(resume.slug)
    end

    it 'shows a welcome card for newly registered users with one resume' do
      user.update_column(:created_at, 30.minutes.ago)
      create(:resume, user:, template:, title: 'Starter Draft')

      get resumes_path

      expect(response).to have_http_status(:ok)

      doc = Nokogiri::HTML(response.body)
      welcome = doc.at_css('[data-testid="welcome-card"]')

      expect(welcome).to be_present
      expect(welcome.text).to include(I18n.t('resumes.index.welcome.title'))
      expect(welcome.text).to include(I18n.t('resumes.index.welcome.description'))

      edit_link = welcome.at_css('a')
      expect(edit_link).to be_present
      expect(edit_link.text.strip).to eq(I18n.t('resumes.index.welcome.action'))
      expect(edit_link['href']).to include('/edit')
      expect(edit_link['href']).to include('step=heading')
    end

    it 'hides the welcome card for established users' do
      user.update_column(:created_at, 2.hours.ago)
      create(:resume, user:, template:, title: 'Existing Draft')

      get resumes_path

      expect(response).to have_http_status(:ok)

      doc = Nokogiri::HTML(response.body)
      expect(doc.at_css('[data-testid="welcome-card"]')).to be_nil
    end

    it 'hides the welcome card when the user has multiple resumes' do
      user.update_column(:created_at, 10.minutes.ago)
      create(:resume, user:, template:, title: 'Resume One')
      create(:resume, user:, template:, title: 'Resume Two')

      get resumes_path

      expect(response).to have_http_status(:ok)

      doc = Nokogiri::HTML(response.body)
      expect(doc.at_css('[data-testid="welcome-card"]')).to be_nil
    end

    it 'shows review-ready guidance without a duplicate create action when every resume is ready' do
      create(:resume, user:, template:, title: 'Ready Resume One')
      create(:resume, user:, template:, title: 'Ready Resume Two')

      get resumes_path

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      workspace_aside = document.css('main aside').last

      expect(workspace_aside).to be_present
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.review_ready.title'))
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.review_ready.description'))
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.review_ready.counts_summary', count: 2))
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.review_ready.focus_note'))
      expect(workspace_aside.css('a, button').map { |element| element.text.squish }).to be_empty
      expect(workspace_aside.text).not_to include(I18n.t('resumes.index.quick_actions.create_resume'))
    end

    it 'keeps the quick-create rail when the workspace still has drafts in progress' do
      create(:resume, user:, template:, title: 'Ready Resume')
      create(:resume, user:, template:, title: 'Draft Resume', summary: '')

      get resumes_path

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      workspace_aside = document.css('main aside').last

      expect(workspace_aside).to be_present
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.title'))
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.description'))
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.counts_summary', ready_count: 1, draft_count: 1))
      expect(workspace_aside.text).to include(I18n.t('resumes.index.quick_actions.focus_note'))
      expect(workspace_aside.css('a, button').map { |element| element.text.squish }).to eq([
        I18n.t('resumes.index.quick_actions.create_resume'),
        I18n.t('resumes.index.quick_actions.browse_templates')
      ])
    end
  end

  describe 'GET /resumes (pagination)' do
    it 'paginates the workspace at 12 cards per page and renders navigation when needed' do
      15.times { |i| create(:resume, user:, template:, title: "Resume #{i + 1}") }

      get resumes_path

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      cards = document.css('article')
      pagination_nav = document.at_css('nav[aria-label]')

      expect(cards.size).to eq(12)
      expect(pagination_nav).to be_present
      expect(pagination_nav.text).to include(I18n.t('shared.pagination.page_info', current: 1, total: 2))
      expect(pagination_nav.text).to include(I18n.t('shared.pagination.next'))

      get resumes_path, params: { page: 2 }

      expect(response).to have_http_status(:ok)
      page2_doc = Nokogiri::HTML.parse(response.body)
      page2_cards = page2_doc.css('article')

      expect(page2_cards.size).to eq(3)
      expect(page2_doc.at_css('nav[aria-label]').text).to include(I18n.t('shared.pagination.previous'))
    end

    it 'preserves selected resume ids across pagination links and renders the persisted bulk selection state' do
      selected_resume = nil

      13.times do |i|
        resume = create(:resume, user:, template:, title: "Resume #{i + 1}")
        selected_resume ||= resume
      end

      get resumes_path, params: { resume_ids: [ selected_resume.id ] }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      next_link = document.at_css(%(a[href*="page=2"][href*="resume_ids%5B%5D=#{selected_resume.id}"]))

      expect(next_link).to be_present

      get resumes_path, params: { page: 2, resume_ids: [ selected_resume.id ] }

      expect(response).to have_http_status(:ok)
      page2_doc = Nokogiri::HTML.parse(response.body)
      bulk_form = page2_doc.at_css(%(form[action="#{bulk_action_resumes_path}"]))
      export_button = bulk_form.at_css(%(button[name="bulk_operation"][value="export"]))
      selection_input = bulk_form.at_css(%(input[type="hidden"][name="resume_ids[]"][value="#{selected_resume.id}"]))

      expect(page2_doc.css('article').size).to eq(1)
      expect(page2_doc.text).to include(I18n.t('resumes.index.bulk_actions.selected_count_one'))
      expect(selection_input).to be_present
      expect(export_button['disabled']).to be_nil
    end

    it 'omits pagination navigation when all resumes fit on one page' do
      3.times { |i| create(:resume, user:, template:, title: "Small Set #{i + 1}") }

      get resumes_path

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)

      expect(document.css('article').size).to eq(3)
      expect(document.at_css('nav[aria-label]')).to be_nil
    end
  end

  describe 'GET /resumes (sorting)' do
    it 'renders sort controls and orders resumes by name when requested' do
      create(:resume, user:, template:, title: 'Zulu Resume')
      create(:resume, user:, template:, title: 'Alpha Resume')
      create(:resume, user:, template:, title: 'Beta Resume')

      get resumes_path, params: { sort: 'name_asc' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      titles = document.css('article h2').map { |node| node.text.squish }
      selected_option = document.at_css('select[name="sort"] option[selected]')

      expect(response.body).to include(I18n.t('resumes.index.search.eyebrow'))
      expect(response.body).to include(I18n.t('resumes.index.sort.label'))
      expect(selected_option).to be_present
      expect(selected_option['value']).to eq('name_asc')
      expect(titles.first(3)).to eq([ 'Alpha Resume', 'Beta Resume', 'Zulu Resume' ])
    end

    it 'renders a collapsed mobile workspace controls disclosure that carries the current selection and query' do
      create(:resume, user:, template:, title: 'Designer Resume', headline: 'Senior Product Designer')
      create(:resume, user:, template:, title: 'Engineer Resume', headline: 'Backend Engineer')

      get resumes_path, params: { query: 'designer', sort: 'name_asc' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      controls_disclosure = document.at_css('details[data-workspace-controls-disclosure]')
      mobile_controls_form = controls_disclosure.at_css('form')
      query_field = mobile_controls_form.at_css('input[name="query"]')
      selected_mobile_option = mobile_controls_form.at_css('select[name="sort"] option[selected]')

      expect(controls_disclosure).to be_present
      expect(controls_disclosure['open']).to be_nil
      expect(controls_disclosure.at_css('summary').text).to include(I18n.t('resumes.index.search.label'))
      expect(controls_disclosure.at_css('summary').text).to include(I18n.t('resumes.index.sort.options.name_asc'))
      expect(query_field).to be_present
      expect(query_field['value']).to eq('designer')
      expect(selected_mobile_option).to be_present
      expect(selected_mobile_option['value']).to eq('name_asc')
    end

    it 'orders resumes by oldest updated first when requested' do
      newest_resume = create(:resume, user:, template:, title: 'Newest Resume')
      middle_resume = create(:resume, user:, template:, title: 'Middle Resume')
      oldest_resume = create(:resume, user:, template:, title: 'Oldest Resume')

      newest_resume.update_columns(created_at: 1.day.ago, updated_at: 1.day.ago)
      middle_resume.update_columns(created_at: 2.days.ago, updated_at: 2.days.ago)
      oldest_resume.update_columns(created_at: 3.days.ago, updated_at: 3.days.ago)

      get resumes_path, params: { sort: 'oldest_first' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      titles = document.css('article h2').map { |node| node.text.squish }

      expect(titles.first(3)).to eq([ 'Oldest Resume', 'Middle Resume', 'Newest Resume' ])
    end

    it 'preserves the selected sort across pagination links' do
      classic_template = create(:template, name: 'Classic Ivory', slug: 'classic-ivory')
      modern_template = create(:template, name: 'Modern Slate', slug: 'modern-slate')

      7.times { |i| create(:resume, user:, template: modern_template, title: "Modern #{i}") }
      7.times { |i| create(:resume, user:, template: classic_template, title: "Classic #{i}") }

      get resumes_path, params: { sort: 'template_asc' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      titles = document.css('article h2').map { |node| node.text.squish }
      next_link = document.at_css("a[href*='sort=template_asc'][href*='page=2']")

      expect(titles.first(7)).to all(start_with('Classic'))
      expect(next_link).to be_present
      expect(next_link['href']).to include('sort=template_asc')
      expect(next_link['href']).to include('page=2')
    end
  end

  describe 'GET /resumes (search)' do
    it 'filters resumes by title and headline and keeps the submitted query visible' do
      create(:resume, user:, template:, title: 'Designer Resume', headline: 'Senior Product Designer')
      create(:resume, user:, template:, title: 'Engineer Resume', headline: 'Backend Platform Engineer')
      create(:resume, user:, template:, title: 'Operations Resume', headline: 'People Operations Lead')

      get resumes_path, params: { query: 'designer' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      titles = document.css('article h2').map { |node| node.text.squish }
      search_input = document.at_css('input[name="query"]')

      expect(response.body).to include(I18n.t('resumes.index.search.eyebrow'))
      expect(search_input).to be_present
      expect(search_input['value']).to eq('designer')
      expect(titles).to eq([ 'Designer Resume' ])
      expect(response.body).not_to include('Engineer Resume')
    end

    it 'preserves the query and sort across pagination links' do
      13.times do |i|
        create(:resume, user:, template:, title: "Designer Resume #{i}", headline: 'Product Designer')
      end
      create(:resume, user:, template:, title: 'Engineer Resume', headline: 'Backend Engineer')

      get resumes_path, params: { query: 'designer', sort: 'name_asc' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      next_link = document.at_css("a[href*='query=designer'][href*='sort=name_asc'][href*='page=2']")

      expect(next_link).to be_present
      expect(next_link['href']).to include('query=designer')
      expect(next_link['href']).to include('sort=name_asc')
      expect(next_link['href']).to include('page=2')
    end

    it 'renders a filtered empty state with a clear-search action when nothing matches' do
      create(:resume, user:, template:, title: 'Engineer Resume', headline: 'Backend Engineer')

      get resumes_path, params: { query: 'designer', sort: 'name_asc' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      clear_link = document.at_css("a[href='#{resumes_path(sort: 'name_asc')}']")

      expect(document.css('article')).to be_empty
      expect(response.body).to include(I18n.t('resumes.index.empty_state.filtered_title'))
      expect(response.body).to include(I18n.t('resumes.index.empty_state.filtered_description'))
      expect(clear_link).to be_present
      expect(clear_link.text.squish).to eq(I18n.t('resumes.index.empty_state.clear_search'))
    end
  end

  describe 'GET /resumes (workspace card actions)' do
    it 'shows Download PDF on cards with an attached export and hides it on draft-only cards' do
      exported_resume = create(:resume, user:, template:, title: 'Exported Resume')
      exported_resume.pdf_export.attach(
        io: StringIO.new('%PDF-1.4 test'),
        filename: 'exported.pdf',
        content_type: 'application/pdf'
      )
      draft_resume = create(:resume, user:, template:, title: 'Draft Resume')

      get resumes_path

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      cards = document.css('article')

      exported_card = cards.find { |card| card.text.include?('Exported Resume') }
      draft_card = cards.find { |card| card.text.include?('Draft Resume') }

      expect(exported_card).to be_present
      expect(exported_card.css('a').map { |a| a.text.squish }).to include(I18n.t('resumes.resume_card.actions.download_pdf'))
      expect(exported_card.css("a[href='#{download_resume_path(exported_resume)}']")).to be_present

      expect(draft_card).to be_present
      expect(draft_card.css('a').map { |a| a.text.squish }).not_to include(I18n.t('resumes.resume_card.actions.download_pdf'))

      draft_card_buttons = draft_card.css('a, button').map { |el| el.text.squish }
      expect(draft_card_buttons).to include(I18n.t('resumes.resume_card.actions.export_pdf'))
      expect(draft_card.at_css("form[action='#{export_resume_path(draft_resume)}']")).to be_present

      exported_card_buttons = exported_card.css('a, button').map { |el| el.text.squish }
      expect(exported_card_buttons).not_to include(I18n.t('resumes.resume_card.actions.export_pdf'))
    end
  end

  describe 'POST /resumes/:id/duplicate' do
    it 'creates a deep copy and redirects to the builder heading step' do
      resume = create(:resume, user:, template:,
        title: 'Original Resume',
        headline: 'Product Designer',
        summary: 'Experienced designer.',
        contact_details: { 'full_name' => 'Alice Smith', 'email' => 'alice@example.com' },
        settings: { 'accent_color' => '#4338CA', 'page_size' => 'A4', 'show_contact_icons' => true }
      )
      resume.sections.create!(title: 'Experience', section_type: 'experience', position: 0, settings: {})
        .entries.create!(content: { 'title' => 'Lead Designer', 'company' => 'DesignCo' }, position: 0)

      expect { post duplicate_resume_path(resume) }.to change(Resume, :count).by(1)

      copy = Resume.last
      expect(copy.title).to eq('Copy of Original Resume')
      expect(copy.headline).to eq('Product Designer')
      expect(copy.summary).to eq('Experienced designer.')
      expect(copy.contact_details['full_name']).to eq('Alice Smith')
      expect(copy.sections.size).to eq(1)
      expect(copy.sections.first.entries.size).to eq(1)
      expect(response).to redirect_to(edit_resume_path(copy, step: :heading))
      follow_redirect!
      expect(response.body).to include(I18n.t('resumes.controller.resume_duplicated'))
    end
  end

  describe 'GET /resumes/:id' do
    it 'renders the preview page with export actions and without the redundant explainer block' do
      resume = create(:resume, user:, template:)

      get resume_path(resume)

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      preview_badges = document.css('[data-preview-artifact-badges] span').map { |badge| badge.text.squish }

      expect(response.body).to include(I18n.t('resumes.show.preview_title'))
      expect(response.body).to include(I18n.t('resumes.show.desktop_actions.title'))
      expect(response.body).to include(I18n.t('resumes.show.desktop_actions.description'))
      expect(response.body).not_to include(I18n.t('resumes.show.what_this_shows.eyebrow'))
      expect(preview_badges).to eq([ template.name, I18n.t('resumes.export_states.draft') ])
      expect(response.body).to include(I18n.t('resumes.export_actions_state.actions.export_pdf'))
      expect(response.body).to include(I18n.t('resumes.export_actions_state.actions.download_text'))
      expect(response.body).to include(I18n.t('resumes.helper.export_status.labels.draft_only'))
    end
  end

  describe 'GET /resumes/:id/edit' do
    it 'defaults to finalize step when all tracked steps are complete and no step param is given' do
      resume = create(:resume, user:, template:,
        title: 'Complete Resume',
        contact_details: { 'full_name' => 'Pat Kumar', 'email' => 'pat@example.com' },
        summary: 'A strong summary.')
      experience = create(:section, resume:, section_type: 'experience', title: 'Experience')
      education = create(:section, resume:, section_type: 'education', title: 'Education')
      skills = create(:section, resume:, section_type: 'skills', title: 'Skills')
      create(:entry, section: experience, content: { 'title' => 'Designer' })
      create(:entry, section: education, content: { 'degree' => 'B.Des' })
      create(:entry, section: skills, content: { 'name' => 'Figma' })

      get edit_resume_path(resume)

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      current_tab = document.css('nav a').find { |link| link.text.include?('Current') }

      expect(current_tab.text).to include('Finalize')
    end

    it 'auto-switches the template when visiting finalize with a marketplace template_id param' do
      original_template = template
      new_template = create(:template, name: 'Sidebar Accent', slug: 'sidebar-accent',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent'))
      resume = create(:resume, user:, template: original_template, title: 'Existing Resume')

      get edit_resume_path(resume, step: :finalize, template_id: new_template.id)

      expect(response).to have_http_status(:ok)
      expect(resume.reload.template).to eq(new_template)
      expect(response.body).to include(I18n.t('resumes.controller.template_applied'))
    end

    it 'does not switch template when template_id matches the current template' do
      resume = create(:resume, user:, template:, title: 'Same Template Resume')

      get edit_resume_path(resume, step: :finalize, template_id: template.id)

      expect(response).to have_http_status(:ok)
      expect(resume.reload.template).to eq(template)
      expect(response.body).not_to include(I18n.t('resumes.controller.template_applied'))
    end

    it 'ignores template_id param on non-finalize steps' do
      new_template = create(:template, name: 'Classic Ivory', slug: 'classic-ivory',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))
      resume = create(:resume, user:, template:, title: 'Heading Step Resume')

      get edit_resume_path(resume, step: :heading, template_id: new_template.id)

      expect(response).to have_http_status(:ok)
      expect(resume.reload.template).to eq(template)
    end

    it 'defaults to the first incomplete tracked step when no step param is given' do
      resume = create(:resume, user:, template:,
        title: 'Incomplete Resume',
        contact_details: { 'full_name' => 'Pat Kumar', 'email' => 'pat@example.com' },
        summary: 'A summary.')
      create(:section, resume:, section_type: 'experience', title: 'Experience')

      get edit_resume_path(resume)

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      current_tab = document.css('nav a').find { |link| link.text.include?('Current') }

      expect(current_tab.text).to include('Experience')
    end

    it 'preserves locale query params in builder navigation and preview handoff links' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume, locale: :en), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)
      hrefs = Nokogiri::HTML.parse(response.body).css('a[href]').map { |link| link['href'] }

      expect(hrefs).to include(resumes_path(locale: :en))
      expect(hrefs).to include(resume_path(resume, step: 'experience', locale: :en))
      expect(hrefs).to include(edit_resume_path(resume, step: 'education', locale: :en))
    end

    it 'only shows supported upload formats when the upload path is active on the source step' do
      scratch_resume = create(:resume, user:, template:, source_mode: 'scratch')
      upload_resume = create(:resume, user:, template:, source_mode: 'upload')

      get edit_resume_path(scratch_resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)
      scratch_document = Nokogiri::HTML.parse(response.body)
      scratch_widget_titles = scratch_document.css('article p').map { |node| node.text.squish }
      scratch_mode_index = response.body.index(I18n.t('resumes.source_import_fields.modes.scratch.title'))
      import_status_index = response.body.index(I18n.t('resumes.editor_source_step.import_status.eyebrow'))

      expect(scratch_widget_titles).to include(I18n.t('resumes.editor_source_step.import_status.eyebrow'))
      expect(scratch_widget_titles).not_to include(I18n.t('resumes.editor_source_step.supported_formats.eyebrow'))
      expect(scratch_mode_index).to be < import_status_index

      get edit_resume_path(upload_resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)
      upload_document = Nokogiri::HTML.parse(response.body)
      upload_widget_titles = upload_document.css('article p').map { |node| node.text.squish }

      expect(upload_widget_titles).to include(I18n.t('resumes.editor_source_step.supported_formats.eyebrow'))
      expect(response.body).to include(Resumes::SourceTextResolver.supported_upload_formats_label)
      expect(response.body).to include(I18n.t('resumes.editor_source_step.supported_formats.autofill_badge'))
    end

    it 'keeps cloud import provider guidance inline on the upload source step without launch links' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return(nil)
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return(nil)

      resume = create(:resume, user:, template:, source_mode: 'upload')

      get edit_resume_path(resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      hrefs = document.css('a[href]').map { |link| link['href'] }

      expect(response.body).to include(I18n.t('resumes.source_import_fields.cloud.title'))
      expect(response.body).to include(I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'))
      expect(response.body).to include(I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.label'))
      expect(response.body).to include(
        I18n.t(
          'resumes.cloud_import_provider_catalog.feedback.setup_required',
          provider: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
          env_vars: 'GOOGLE_DRIVE_CLIENT_ID and GOOGLE_DRIVE_CLIENT_SECRET'
        )
      )
      expect(hrefs.grep(%r{/resume_source_imports/})).to be_empty
    end

    it 'hides the extra mobile preview panel on section-based builder steps while collapsing secondary builder actions and repeated section-type cues' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)
      experience_document = Nokogiri::HTML.parse(response.body)
      experience_preview_frame = experience_document.at_css("turbo-frame##{ActionView::RecordIdentifier.dom_id(resume, :preview)}")
      experience_primary_actions = experience_document.css('[data-builder-primary-actions] a').map { |link| link.text.squish }
      experience_secondary_actions = experience_document.at_css('details[data-builder-secondary-actions]')
      experience_examples_link = experience_document.at_css('a[href="#experience-step-tips"]')
      expect(response.body).not_to include(%(id="#{ActionView::RecordIdentifier.dom_id(resume, :workspace_overview)}"))
      expect(response.body).not_to include(I18n.t('resumes.edit.mobile_preview_panel.title'))
      expect(experience_preview_frame).to be_present
      expect(experience_preview_frame.ancestors('div').map { |node| node['class'].to_s }).to include('hidden xl:block')
      expect(experience_primary_actions).to eq([
        I18n.t('resume_builder.editor_state.navigation.go_back'),
        I18n.t('resume_builder.editor_state.navigation.next', step: 'Education')
      ])
      expect(experience_secondary_actions).to be_present
      expect(experience_secondary_actions.at_css('summary').text).to include(I18n.t('resume_builder.editor_state.navigation.more_actions'))
      expect(experience_secondary_actions.css('a').map { |link| link.text.squish }).to eq([
        I18n.t('resume_builder.editor_state.navigation.back_to_workspace'),
        I18n.t('resume_builder.editor_state.navigation.preview')
      ])
      expect(experience_examples_link).to be_present
      expect(experience_examples_link.parent.css('span')).to be_empty
      expect(experience_document.css('[data-entry-section-type-badge]')).to be_empty

      get edit_resume_path(resume), params: { step: 'heading' }

      expect(response).to have_http_status(:ok)
      heading_document = Nokogiri::HTML.parse(response.body)
      heading_preview_frame = heading_document.at_css("turbo-frame##{ActionView::RecordIdentifier.dom_id(resume, :preview)}")
      heading_primary_actions = heading_document.css('[data-builder-primary-actions] a').map { |link| link.text.squish }
      expect(response.body).to include(I18n.t('resumes.edit.mobile_preview_panel.title'))
      expect(heading_preview_frame).to be_present
      expect(heading_preview_frame.ancestors('div').map { |node| node['class'].to_s }).not_to include('hidden xl:block')
      expect(heading_document.at_css('details[data-builder-secondary-actions]')).to be_nil
      expect(heading_primary_actions).to include(
        I18n.t('resume_builder.editor_state.navigation.back_to_workspace'),
        I18n.t('resume_builder.editor_state.navigation.preview'),
        I18n.t('resume_builder.editor_state.navigation.go_back')
      )
    end

    it 'renders the source step without a duplicate step title' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)
      expect(response.body.scan(I18n.t('resume_builder.step_registry.steps.source.title')).size).to eq(1)
      expect(response.body).to include(I18n.t('resumes.editor_source_step.import_status.eyebrow'))
      expect(response.body).not_to include(I18n.t('resumes.editor_source_step.supported_formats.eyebrow'))
      expect(response.body).to include(I18n.t('resumes.editor_source_step.guidance.description'))
      expect(response.body).not_to include('Once the source feels right, continue into heading and the rest of the guided builder.')
    end

    it 'renders the heading step without a duplicate step title while keeping the personal details widget' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'heading' }

      expect(response).to have_http_status(:ok)
      expect(response.body.scan(I18n.t('resume_builder.step_registry.steps.heading.title')).size).to eq(1)
      document = Nokogiri::HTML.parse(response.body)
      optional_next_step_heading = document.css('article p').find do |node|
        node.text.squish == I18n.t('resumes.editor_heading_step.optional_next_step.eyebrow')
      end
      personal_details_links = document.css('a').select do |link|
        link.text.squish == I18n.t('resumes.editor_heading_step.optional_next_step.open_personal_details')
      end

      expect(optional_next_step_heading).to be_nil
      expect(personal_details_links.size).to eq(1)
      expect(response.body).to include(I18n.t('resumes.editor_heading_step.footer_note'))
      expect(response.body).not_to include('Changes save in place and keep the preview in sync while you move between guided steps.')
    end

    it 'renders the personal details step without a duplicate step title and starts with the profile links panel' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'personal_details' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      profile_links_index = response.body.index(I18n.t('resumes.editor_personal_details_step.profile_links.eyebrow'))
      personal_information_index = response.body.index(I18n.t('resumes.editor_personal_details_step.personal_information.eyebrow'))
      headshot_index = response.body.index(I18n.t('resumes.editor_personal_details_step.headshot.eyebrow'))
      personal_information_disclosure = document.at_css('details[data-personal-information-disclosure]')
      headshot_disclosure = document.at_css('details[data-headshot-disclosure]')

      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.profile_links.eyebrow'))
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.personal_information.eyebrow'))
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.optional_step.skip_for_now'))
      expect(response.body).not_to include(I18n.t('resumes.editor_personal_details_step.optional_step.title'))
      expect(profile_links_index).to be < personal_information_index
      expect(personal_information_index).to be < headshot_index
      expect(personal_information_disclosure).to be_present
      expect(personal_information_disclosure['open']).to be_nil
      expect(headshot_disclosure).to be_present
      expect(headshot_disclosure['open']).to be_nil

      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.headshot.description'))
      expect(response.body).not_to include('truthful headshot support')
      expect(response.body).not_to include('non-photo fallback')
    end

    it 'renders the summary step without a duplicate step header card and starts with the curated library' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'summary' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      summary_library = document.at_css('details[data-summary-library-disclosure]')
      summary_field = document.at_css('textarea[name="resume[summary]"]')

      expect(response.body).to include(I18n.t('resumes.editor_summary_step.library.eyebrow'))
      expect(response.body).to include(I18n.t('resumes.editor_summary_step.save_summary'))
      expect(response.body).not_to include(I18n.t('resumes.editor_summary_step.guidance_card.title'))
      expect(summary_library).to be_present
      expect(summary_library['open']).to be_nil
      expect(summary_field).to be_present
      expect(response.body.index('data-summary-library-disclosure')).to be < response.body.index('name="resume[summary]"')
    end

    it 'keeps non-experience section steps focused without a duplicate step header card' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'education' }

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      step_content = document.at_css("##{ActionView::RecordIdentifier.dom_id(resume, :editor_step_content)}")

      expect(step_content).to be_present
      expect(step_content.element_children.map(&:name)).to eq([ 'section' ])

      expect(step_content.element_children.first['id']).to eq(ActionView::RecordIdentifier.dom_id(resume, :step_sections))
      expect(response.body.scan(I18n.t('resume_builder.step_registry.steps.education.description')).size).to eq(1)
      expect(document.at_css('a[href="#experience-step-tips"]')).to be_nil
      expect(document.at_css('[data-experience-entry-guidance]')).to be_nil
    end

    it 'recommends finalize on the education step when the tracked builder flow is already complete' do
      resume = create(
        :resume,
        user:,
        template:,
        summary: 'Short summary',
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com'
        }
      )
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience')
      education_section = create(:section, resume:, section_type: 'education', title: 'Education')
      skills_section = create(:section, resume:, section_type: 'skills', title: 'Skills')
      create(:entry, section: experience_section, content: { 'title' => 'Designer' })
      create(:entry, section: education_section, content: { 'degree' => 'B.Des' })
      create(:entry, section: skills_section, content: { 'name' => 'Figma' })

      get edit_resume_path(resume), params: { step: 'education' }

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      primary_actions = document.css('[data-builder-primary-actions] a').map { |link| link.text.squish }
      next_move_card = document.css('article').find do |article|
        article.at_css('p')&.text.to_s.squish == I18n.t('resume_builder.editor_state.next_step_card.eyebrow')
      end

      expect(primary_actions).to eq([
        I18n.t('resume_builder.editor_state.navigation.go_back'),
        I18n.t('resume_builder.editor_state.navigation.next', step: 'Finalize')
      ])
      expect(next_move_card).to be_present
      expect(next_move_card.text).to include(I18n.t('resume_builder.editor_state.next_step_card.finalize_title'))
      expect(next_move_card.text).to include(I18n.t('resume_builder.editor_state.next_step_card.finalize_description'))
    end

    it 'starts the finalize step with export actions in the preview panel and no duplicate step header' do
      resume = create(:resume, user:, template:)
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience', position: 0)
      projects_section = create(:section, resume:, section_type: 'projects', title: 'Projects', position: 1)
      create(:entry, section: experience_section, content: { 'title' => 'Designer' })
      create(:entry, section: projects_section, content: { 'name' => 'Resume Builder' })

      get edit_resume_path(resume), params: { step: 'finalize', tab: 'sections' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)

      expect(document.at_css('details[data-builder-secondary-actions]')).to be_nil
      expect(response.body).not_to include(%(id="#{ActionView::RecordIdentifier.dom_id(resume, :workspace_overview)}"))

      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.preview_action'))

      expect(response.body).to include('template-picker-compact')
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.template_picker.fast_start_description'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.template_picker.browse_all_templates'))
      workspace_tabs = document.at_css('nav[data-finalize-workspace-tabs]')
      expect(workspace_tabs).to be_present
      expect(workspace_tabs['aria-orientation']).to eq('horizontal')
      tab_buttons = workspace_tabs.css('button[data-tab-key]')
      tab_keys = tab_buttons.map { |btn| btn['data-tab-key'] }
      expect(tab_keys).to eq(%w[template design sections spellcheck])
      expect(tab_buttons.map { |btn| btn['data-action'] }).to all(include('keydown->workspace-tabs#navigate'))
      tab_labels = tab_buttons.map { |btn| btn.text.strip }
      expect(tab_labels).to include(
        I18n.t('resumes.editor_finalize_step.workspace_tabs.template'),
        I18n.t('resumes.editor_finalize_step.workspace_tabs.design'),
        I18n.t('resumes.editor_finalize_step.workspace_tabs.sections'),
        I18n.t('resumes.editor_finalize_step.workspace_tabs.spellcheck')
      )
      expect(document.at_css('button[data-tab-key="sections"][aria-selected="true"][tabindex="0"]')).to be_present
      expect(document.at_css('button[data-tab-key="template"][aria-selected="false"][tabindex="-1"]')).to be_present
      expect(document.at_css('button[data-tab-key="design"][aria-selected="false"][tabindex="-1"]')).to be_present
      expect(document.at_css('button[data-tab-key="spellcheck"][aria-selected="false"][tabindex="-1"]')).to be_present

      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.template_workspace.title'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.design_workspace.title'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.design_workspace.description'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.output_settings.eyebrow'))
      expect(response.body).to include(ERB::Util.html_escape(I18n.t('resumes.editor_finalize_step.design_workspace.type_settings.eyebrow')))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.design_workspace.type_settings.description'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.design_workspace.font_family'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.design_workspace.section_spacing'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.design_workspace.paragraph_spacing'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.design_workspace.line_spacing'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.footer_note'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.sections_workspace.title'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.sections_workspace.count_badges.managed_sections', count: 2))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.sections_workspace.count_badges.reviewed_entries', count: 2))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.sections_workspace.count_badges.additional_sections', count: 1))
      expect(document.at_css('input[name="tab"][value="sections"]')).to be_present
      section_order_panel = document.at_css('[data-finalize-section-order]')
      expect(section_order_panel).to be_present
      expect(section_order_panel.text).to include(I18n.t('resumes.editor_finalize_step.sections_workspace.order_title'))
      expect(section_order_panel.text).to include('Experience')
      expect(section_order_panel.text).to include('Projects')
      section_order_items = section_order_panel.css('[data-sortable-target="item"]')
      expect(section_order_items.size).to eq(2)
      expect(section_order_items.map { |item| item['data-sortable-move-url'] }).to all(include('step=finalize'))
      expect(section_order_items.map { |item| item['data-sortable-move-url'] }).to all(include('tab=sections'))

      expect(response.body).not_to include('renderer-backed')
      expect(response.body).not_to include('shared renderer')
      expect(response.body).not_to include('template identity')
      expect(response.body).not_to include('vertical rhythm')
      expect(response.body).not_to include('shared preview')
      expect(response.body).not_to include(I18n.t('resumes.template_picker_compact.fast_start_description'))

      output_settings = document.at_css('[data-finalize-output-settings]')
      sections_panels = document.css('[data-workspace-tabs-target="panel"][data-tab-key="sections"]')
      hidden_template_panel = document.at_css('[data-workspace-tabs-target="panel"][data-tab-key="template"][hidden]')
      hidden_design_panel = document.at_css('[data-workspace-tabs-target="panel"][data-tab-key="design"][hidden]')
      hidden_spellcheck_panel = document.at_css('[data-workspace-tabs-target="panel"][data-tab-key="spellcheck"][hidden]')
      additional_sections_surface = document.at_css('[data-finalize-additional-sections-surface]')
      expect(output_settings).to be_present
      expect(sections_panels.size).to eq(1)
      expect(hidden_template_panel).to be_present
      expect(hidden_design_panel).to be_present
      expect(hidden_spellcheck_panel).to be_present
      expect(additional_sections_surface).to be_present
      expect(additional_sections_surface.ancestors('[data-tab-key="sections"]')).not_to be_empty
      expect(document.at_css('details[data-finalize-additional-sections-disclosure]')).to be_nil
      expect(document.at_css('select[name="resume[settings][font_family]"]')).to be_present
      expect(document.at_css('select[name="resume[settings][section_spacing]"]')).to be_present
      expect(document.at_css('select[name="resume[settings][paragraph_spacing]"]')).to be_present
      expect(document.at_css('select[name="resume[settings][line_spacing]"]')).to be_present

      accent_palette = document.at_css('[data-controller="accent-palette"]')
      expect(accent_palette).to be_present
      accent_swatches = accent_palette.css('button[data-accent-palette-target="swatch"]')
      expect(accent_swatches.size).to eq(ResumeTemplates::Catalog.accent_color_palette.size)
      expect(accent_palette.at_css('input[name="resume[settings][accent_color]"]')).to be_present
      expect(accent_palette.at_css('button[data-accent-palette-target="resetButton"]')).to be_present
      expect(accent_palette.at_css('input[data-accent-palette-target="customInput"]')).to be_present
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.output_settings.accent_color_palette_label'))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.output_settings.accent_color_reset'))
    end

    it 'renders a spellcheck workspace with review links back to editable builder steps' do
      resume = create(
        :resume,
        user:,
        template:,
        headline: 'Senior Product Designer',
        summary: 'Design systems leader with strong research habits.',
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com',
          'phone' => '555-0100',
          'city' => 'Bengaluru',
          'country' => 'India'
        },
        personal_details: {
          'nationality' => 'Indian',
          'visa_status' => 'Authorized to work in India'
        }
      )
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience', position: 0)
      education_section = create(:section, resume:, section_type: 'education', title: 'Education', position: 1)
      skills_section = create(:section, resume:, section_type: 'skills', title: 'Skills', position: 2)
      projects_section = create(:section, resume:, section_type: 'projects', title: 'Projects', position: 3)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Designer' })
      create(:entry, section: education_section, content: { 'degree' => 'B.Des' })
      create(:entry, section: skills_section, content: { 'name' => 'Figma' })
      create(:entry, section: projects_section, content: { 'name' => 'Resume Builder' })

      get edit_resume_path(resume), params: { step: 'finalize', tab: 'spellcheck' }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)

      expect(document.at_css('button[data-tab-key="spellcheck"][aria-selected="true"][tabindex="0"]')).to be_present
      expect(document.at_css('[data-workspace-tabs-target="panel"][data-tab-key="sections"][hidden]')).to be_present

      spellcheck_panel = document.at_css('[data-finalize-spellcheck-panel]')
      expect(spellcheck_panel).to be_present
      expect(spellcheck_panel.text).to include(I18n.t('resumes.editor_finalize_step.spellcheck_workspace.title'))
      expect(spellcheck_panel.text).to include(I18n.t('resumes.editor_finalize_step.spellcheck_workspace.helper_text'))
      expect(spellcheck_panel.text).to include(I18n.t('resumes.editor_finalize_step.spellcheck_workspace.count_badges.ready', count: 7))
      expect(spellcheck_panel.text).to include(I18n.t('resumes.editor_finalize_step.spellcheck_workspace.count_badges.empty', count: 0))

      review_cards = spellcheck_panel.css('[data-finalize-spellcheck-card]')
      expect(review_cards.map { |card| card['data-review-key'] }).to eq(%w[additional_sections education heading personal_details summary skills experience])

      heading_link = spellcheck_panel.at_css('[data-review-key="heading"] a')
      summary_link = spellcheck_panel.at_css('[data-review-key="summary"] a')
      additional_sections_link = spellcheck_panel.at_css('[data-review-key="additional_sections"] a')
      expect(heading_link['href']).to include('step=heading')
      expect(summary_link['href']).to include('step=summary')
      expect(additional_sections_link['href']).to include('step=finalize')
      expect(additional_sections_link['href']).to include('tab=sections')
    end

    it 'collapses the shared add-section form on populated section steps' do
      resume = create(
        :resume,
        user:,
        template:,
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'student'
        }
      )
      create(:section, resume:, title: 'Experience', section_type: 'experience')

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      disclosure = document.at_css("details##{ActionView::RecordIdentifier.dom_id(resume, :add_section_form)}")
      experience_guidance = document.at_css('[data-experience-entry-guidance]')
      highlights_textarea = document.at_css('textarea[data-experience-suggestions-target="input"]')

      expect(disclosure).to be_present
      expect(disclosure.attribute('open')).to be_nil
      expect(disclosure.text).to include(I18n.t('resumes.section_form.summary_action'))
      expect(experience_guidance).to be_present
      expect(experience_guidance.text).to include(I18n.t('resumes.experience_step_state.eyebrow'))
      expect(experience_guidance.text).to include(I18n.t('resumes.experience_step_state.badges.early_career'))
      expect(experience_guidance.text).to include(I18n.t('resumes.experience_step_state.description_early_career'))
      expect(experience_guidance.text).to include(I18n.t('resumes.experience_step_state.insert_button_label'))
      expect(highlights_textarea).to be_present
      expect(highlights_textarea['name']).to include('[highlights_text]')
    end

    it 'renders role-aware skill suggestions on the skills step with clickable skill buttons' do
      resume = create(
        :resume,
        user:,
        template:,
        headline: 'Software Engineer',
        intake_details: {
          'experience_level' => 'three_to_five_years'
        }
      )
      skills_section = create(:section, resume:, title: 'Skills', section_type: 'skills')
      create(:entry, section: skills_section, content: { 'name' => 'Ruby on Rails', 'level' => 'Expert' })

      get edit_resume_path(resume), params: { step: 'skills' }

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      skills_tips = document.at_css('details#skills-step-tips')
      skills_guidance_blocks = document.css('[data-skills-entry-guidance]')
      skills_guidance = skills_guidance_blocks.first
      name_input = document.at_css('input[data-skills-suggestions-target="nameInput"]')

      expect(skills_tips).to be_present
      expect(skills_tips.text).to include(I18n.t('resumes.editor_section_step.skills_guidance.title'))
      expect(skills_guidance_blocks.count).to eq(1)
      expect(skills_guidance).to be_present
      expect(skills_guidance.text).to include(I18n.t('resumes.skills_step_state.eyebrow'))
      expect(skills_guidance.text).to include(I18n.t('resumes.skills_step_state.badges.role_aware'))
      expect(skills_guidance.text).to include(I18n.t('resumes.skill_suggestion_catalog.role_labels.software_engineer'))
      expect(name_input).to be_present
      expect(name_input['name']).to include('[name]')

      persisted_entry_card = document.at_css("details##{ActionView::RecordIdentifier.dom_id(skills_section.entries.first, :sortable_item)}")
      new_entry_card = document.at_css("details##{ActionView::RecordIdentifier.dom_id(skills_section, :new_entry)}")
      fallback_text = I18n.t('resumes.entry_form.supporting_text.persisted_fallback', section: 'Skills')

      expect(persisted_entry_card).to be_present
      expect(persisted_entry_card.at_css('summary').text).not_to include(fallback_text)
      expect(new_entry_card).to be_present
      expect(new_entry_card.at_css('summary').text).to include(I18n.t('resumes.entry_form.supporting_text.new_with_existing'))
    end

    it 'collapses section header actions on section-step pages while keeping finalize inline' do
      resume = create(:resume, user:, template:)
      create(:section, resume:, title: 'Experience', section_type: 'experience')
      create(:section, resume:, title: 'Education', section_type: 'education')
      create(:section, resume:, title: 'Projects', section_type: 'projects')

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)

      experience_document = Nokogiri::HTML.parse(response.body)
      experience_section_actions = experience_document.at_css('details[data-section-header-actions]')

      expect(experience_section_actions).to be_present
      expect(experience_document.at_css('[data-section-header-inline-actions]')).to be_nil
      expect(experience_section_actions.at_css('summary').text).to include(I18n.t('resumes.section_editor.actions.summary'))
      expect(experience_section_actions.css('form button').map { |button| button.text.squish }).to eq([
        I18n.t('resumes.section_editor.actions.up'),
        I18n.t('resumes.section_editor.actions.down'),
        I18n.t('resumes.section_editor.actions.remove')
      ])

      get edit_resume_path(resume), params: { step: 'education' }

      expect(response).to have_http_status(:ok)

      education_document = Nokogiri::HTML.parse(response.body)
      education_section_actions = education_document.at_css('details[data-section-header-actions]')

      expect(education_section_actions).to be_present
      expect(education_document.at_css('[data-section-header-inline-actions]')).to be_nil
      expect(education_section_actions.at_css('summary').text).to include(I18n.t('resumes.section_editor.actions.summary'))

      get edit_resume_path(resume), params: { step: 'finalize' }

      expect(response).to have_http_status(:ok)

      finalize_document = Nokogiri::HTML.parse(response.body)
      finalize_inline_actions = finalize_document.at_css('[data-section-header-inline-actions]')

      expect(finalize_document.at_css('details[data-section-header-actions]')).to be_nil
      expect(finalize_inline_actions).to be_present
      expect(finalize_inline_actions.css('form button').map { |button| button.text.squish }).to eq([
        I18n.t('resumes.section_editor.actions.up'),
        I18n.t('resumes.section_editor.actions.down'),
        I18n.t('resumes.section_editor.actions.remove')
      ])
    end

    it 'hides redundant default section titles on section-step pages while preserving custom titles' do
      resume = create(:resume, user:, template:)
      experience_section = create(:section, resume:, title: ResumeBuilder::SectionRegistry.title_for('experience'), section_type: 'experience')
      create(:section, resume:, title: ResumeBuilder::SectionRegistry.title_for('education'), section_type: 'education')

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)

      experience_document = Nokogiri::HTML.parse(response.body)
      experience_titles = experience_document.at_css("section##{ActionView::RecordIdentifier.dom_id(resume, :step_sections)}").css('h4').map { |element| element.text.squish }

      expect(experience_titles).to be_empty

      get edit_resume_path(resume), params: { step: 'education' }

      expect(response).to have_http_status(:ok)

      education_document = Nokogiri::HTML.parse(response.body)
      education_titles = education_document.at_css("section##{ActionView::RecordIdentifier.dom_id(resume, :step_sections)}").css('h4').map { |element| element.text.squish }

      expect(education_titles).to be_empty

      experience_section.update!(title: 'Leadership Experience')

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)

      updated_titles = Nokogiri::HTML.parse(response.body).at_css("section##{ActionView::RecordIdentifier.dom_id(resume, :step_sections)}").css('h4').map { |element| element.text.squish }

      expect(updated_titles).to include('Leadership Experience')
    end

    it 'opens the shared add-section form when the current step has no sections yet' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'finalize' }

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      disclosure = document.at_css("details##{ActionView::RecordIdentifier.dom_id(resume, :add_section_form)}")

      expect(disclosure).to be_present
      expect(disclosure.attribute('open')).to be_present
      expect(disclosure.text).to include(I18n.t('resumes.section_form.summary_action'))
    end

    it 'renders the shared photo library on the personal details step when photo processing is enabled' do
      editorial_template = create(
        :template,
        name: 'Editorial Split',
        slug: 'editorial-split',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'editorial-split')
      )
      resume = create(:resume, user:, template: editorial_template)
      photo_profile = user.photo_profiles.create!(name: 'Primary Photo Library', status: :active)
      source_asset = create_ready_photo_asset(photo_profile:, filename: 'source-headshot.png', asset_kind: :source)
      selected_asset = create_ready_photo_asset(photo_profile:, source_asset:, filename: 'enhanced-headshot.png')
      photo_profile.update!(selected_source_photo_asset: source_asset)
      resume.update!(photo_profile: photo_profile)
      resume.resume_photo_selections.create!(template: resume.template, photo_asset: selected_asset, slot_name: 'headshot', status: :active)
      PhotoProcessingRun.create!(
        photo_profile: photo_profile,
        resume: resume,
        template: resume.template,
        workflow_type: :background_remove,
        status: :succeeded,
        next_step_guidance: 'Legacy background removal guidance'
      )

      with_feature_flags(photo_processing: true) do
        get edit_resume_path(resume), params: { step: 'personal_details' }
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.photo_library.title'))
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.photo_library.selection_title'))
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.photo_library.current_selection_title'))
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.photo_library.recent_runs.guidance.background_remove'))
      expect(response.body).to include(selected_asset.display_name)
      expect(response.body).not_to include('Legacy background removal guidance')

      document = Nokogiri::HTML.parse(response.body)
      photo_library_disclosure = document.at_css('details[data-photo-library-disclosure]')

      expect(photo_library_disclosure).to be_present
      expect(photo_library_disclosure['open']).to be_nil

      expect(document.at_css("form[action*='/photo_profiles/#{photo_profile.id}/photo_assets']")).to be_present
      expect(document.at_css("input[name='resume[selected_headshot_photo_asset_id]'][value='#{selected_asset.id}']")).to be_present
      selected_radio = document.at_css("input[name='resume[selected_headshot_photo_asset_id]'][value='#{selected_asset.id}']")

      expect(selected_radio).to be_present
      expect(selected_radio['checked']).to eq('checked')
    end

    it 'returns a localized turbo alert when the selected shared headshot asset is unavailable' do
      editorial_template = create(
        :template,
        name: 'Editorial Split',
        slug: 'editorial-split',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'editorial-split')
      )
      resume = create(:resume, user:, template: editorial_template)
      missing_asset_id = PhotoAsset.maximum(:id).to_i + 1

      with_feature_flags(photo_processing: true) do
        patch resume_path(resume), params: {
          step: 'personal_details',
          resume: {
            selected_headshot_photo_asset_id: missing_asset_id
          }
        }, as: :turbo_stream
      end

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(I18n.t('resumes.controller.selected_photo_unavailable'))
      expect(resume.reload.resume_photo_selections).to be_empty
    end

    it 'switches source mode and preserves uploaded documents on update' do
      resume = create(:resume, user:, template:, source_mode: 'paste', source_text: 'Existing resume source')

      Tempfile.create([ 'resume-source-upload', '.txt' ]) do |file|
        file.binmode
        file.write('Updated resume source')
        file.rewind

        patch resume_path(resume), params: {
          step: 'source',
          resume: {
            source_mode: 'upload',
            source_text: 'Updated resume source',
            source_document: Rack::Test::UploadedFile.new(file.path, 'text/plain')
          }
        }
      end

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(resume.reload.source_mode).to eq('upload')
      expect(resume.source_text).to eq('Updated resume source')
      expect(resume.source_document).to be_attached
    end

    it 'switches the template immediately through the finalize turbo update and refreshes the preview' do
      resume = create(:resume, user:, template: create(:template, name: 'Modern Slate'))
      sidebar_template = create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )

      patch resume_path(resume), params: {
        step: 'finalize',
        resume: {
          template_id: sidebar_template.id
        }
      }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(resume.reload.template).to eq(sidebar_template)
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(resume, :preview)}"))
      expect(response.body).to match(/target="#{ActionView::RecordIdentifier.dom_id(resume, :preview)}".*Sidebar Indigo/m)
    end

    it 'saves finalize formatting and section visibility settings through the turbo update flow' do
      resume = create(:resume, user:, template: template)
      projects_section = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 3)
      create(:entry, section: projects_section, content: { 'name' => 'Resume Builder' })

      patch resume_path(resume), params: {
        step: 'finalize',
        resume: {
          settings: {
            page_size: 'Letter',
            font_family: 'serif',
            font_scale: 'lg',
            density: 'relaxed',
            accent_color: '#123456',
            show_contact_icons: false,
            hidden_sections: [ 'projects', 'unexpected' ]
          }
        }
      }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(resume.reload.settings).to include(
        'page_size' => 'Letter',
        'font_family' => 'serif',
        'font_scale' => 'lg',
        'density' => 'relaxed',
        'accent_color' => '#123456',
        'show_contact_icons' => false,
        'hidden_sections' => [ 'projects' ]
      )
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(resume, :preview)}"))
      expect(response.body).to include(I18n.t('resumes.editor_finalize_step.sections_workspace.badges.hidden'))
    end

    it 'saves source details and applies pasted-text autofill when requested' do
      resume = create(:resume, user:, template:, source_mode: 'scratch', source_text: '')
      create(:llm_model_assignment, llm_model:, role: 'text_generation')
      PlatformSetting.current.update!(
        feature_flags: {
          'llm_access' => true,
          'resume_suggestions' => true,
          'autofill_content' => true
        },
        preferences: PlatformSetting.current.preferences
      )
      allow(Llm::ClientFactory).to receive(:build).and_return(provider_client_class.new)

      patch resume_path(resume), params: {
        step: 'source',
        run_autofill: 'true',
        resume: {
          source_mode: 'paste',
          source_text: 'Pat Kumar Senior Product Engineer pat@example.com Pune India'
        }
      }

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.source_applied'))
      expect(resume.reload).to have_attributes(
        title: 'Imported Resume',
        headline: 'Senior Product Engineer',
        summary: 'Builds workflow systems.',
        source_mode: 'paste'
      )
      expect(resume.contact_details).to include(
        'full_name' => 'Pat Kumar',
        'email' => 'pat@example.com',
        'city' => 'Pune',
        'country' => 'India'
      )

      experience_section = resume.sections.find_by!(section_type: 'experience')
      expect(experience_section.entries.first.content).to include(
        'title' => 'Senior Product Engineer',
        'organization' => 'Acme',
        'end_date' => 'Present'
      )
      expect(resume.sections.find_by!(section_type: 'skills').entries.first.content).to include(
        'name' => 'Ruby on Rails',
        'level' => 'Advanced'
      )

      interaction = resume.llm_interactions.last
      expect(interaction).to be_succeeded
      expect(interaction.feature_name).to eq('autofill_content')
      expect(interaction.role).to eq('text_generation')
      expect(interaction.llm_model).to eq(llm_model)
      expect(interaction.llm_provider).to eq(llm_provider)
    end

    it 'saves source details and applies upload-based autofill when requested with a supported DOCX file' do
      resume = create(:resume, user:, template:, source_mode: 'scratch', source_text: '')
      create(:llm_model_assignment, llm_model:, role: 'text_generation')
      PlatformSetting.current.update!(
        feature_flags: {
          'llm_access' => true,
          'resume_suggestions' => true,
          'autofill_content' => true
        },
        preferences: PlatformSetting.current.preferences
      )
      allow(Llm::ClientFactory).to receive(:build).and_return(provider_client_class.new)

      docx_buffer = Zip::OutputStream.write_buffer do |zip|
        zip.put_next_entry('word/document.xml')
        zip.write <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:body>
              <w:p><w:r><w:t>Pat Kumar</w:t></w:r></w:p>
              <w:p><w:r><w:t>Senior Product Engineer</w:t></w:r></w:p>
              <w:p><w:r><w:t>pat@example.com</w:t></w:r></w:p>
              <w:p><w:r><w:t>Pune India</w:t></w:r></w:p>
            </w:body>
          </w:document>
        XML
      end

      Tempfile.create([ 'resume-source-upload', '.docx' ]) do |file|
        file.binmode
        file.write(docx_buffer.string)
        file.rewind

        patch resume_path(resume), params: {
          step: 'source',
          run_autofill: 'true',
          resume: {
            source_mode: 'upload',
            source_text: '',
            source_document: Rack::Test::UploadedFile.new(file.path, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
          }
        }
      end

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.source_applied'))
      expect(resume.reload).to have_attributes(
        title: 'Imported Resume',
        headline: 'Senior Product Engineer',
        summary: 'Builds workflow systems.',
        source_mode: 'upload'
      )
      expect(resume.source_document).to be_attached
      expect(resume.llm_interactions.last.metadata).to include(
        'source_kind' => 'uploaded_document',
        'source_content_type' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      )
    end

    it 'returns the localized source-resolver alert when autofill is requested with an unsupported upload' do
      resume = create(:resume, user:, template:, source_mode: 'scratch', source_text: '')
      PlatformSetting.current.update!(
        feature_flags: {
          'llm_access' => true,
          'resume_suggestions' => true,
          'autofill_content' => true
        },
        preferences: PlatformSetting.current.preferences
      )

      Tempfile.create([ 'resume-source-upload', '.doc' ]) do |file|
        file.binmode
        file.write('legacy doc sample')
        file.rewind

        patch resume_path(resume), params: {
          step: 'source',
          run_autofill: 'true',
          resume: {
            source_mode: 'upload',
            source_text: '',
            source_document: Rack::Test::UploadedFile.new(file.path, 'application/msword')
          }
        }
      end

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(flash[:alert]).to eq(
        I18n.t('resumes.source_text_resolver.unsupported_upload', formats: Resumes::SourceTextResolver.supported_upload_formats_label)
      )
      expect(resume.reload.source_document).to be_attached
      expect(resume.llm_interactions.last.error_message).to eq(
        I18n.t('resumes.source_text_resolver.unsupported_upload', formats: Resumes::SourceTextResolver.supported_upload_formats_label)
      )
    end
  end

  describe 'POST /resumes/:id/export' do
    it 'enqueues a PDF export job' do
      resume = create(:resume, user:, template:)
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      expect do
        post export_resume_path(resume)
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)

      enqueued_job = ActiveJob::Base.queue_adapter.enqueued_jobs.last
      queued_arguments = enqueued_job[:args].is_a?(Hash) ? enqueued_job.dig(:args, :arguments) : enqueued_job[:args]

      expect(enqueued_job[:job]).to eq(ResumeExportJob)
      expect(queued_arguments).to eq([ resume.id, user.id ])

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.pdf_export_started'))
    end

    it 'returns a localized turbo notice when export is triggered from the editor' do
      resume = create(:resume, user:, template:)
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      expect do
        post export_resume_path(resume), as: :turbo_stream
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(I18n.t('resumes.controller.pdf_export_started_turbo'))
    end

    it 'shows the queued export state after redirecting back to the editor' do
      resume = create(:resume, user:, template:)

      post export_resume_path(resume)
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Queued for export')
    end
  end

  describe 'POST /resumes/bulk_action' do
    it 'enqueues export jobs for the selected resumes and clears selection from the redirect params' do
      resumes = Array.new(2) { create(:resume, user:, template:) }
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      expect do
        post bulk_action_resumes_path, params: {
          bulk_operation: 'export',
          resume_ids: resumes.map(&:id),
          page: 2,
          query: 'designer',
          sort: 'name_asc'
        }
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)

      queued_arguments = ActiveJob::Base.queue_adapter.enqueued_jobs.map do |job|
        job[:args].is_a?(Hash) ? job.dig(:args, :arguments) : job[:args]
      end

      expect(queued_arguments).to match_array(resumes.map { |resume| [ resume.id, user.id ] })
      expect(response).to redirect_to(resumes_path(page: 2, query: 'designer', sort: 'name_asc'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.bulk_export_started', count: resumes.size))
    end

    it 'deletes the selected resumes and redirects back to the workspace without selected ids' do
      resumes = Array.new(2) { create(:resume, user:, template:) }

      expect do
        post bulk_action_resumes_path, params: {
          bulk_operation: 'delete',
          resume_ids: resumes.map(&:id),
          query: 'designer'
        }
      end.to change(Resume, :count).by(-2)

      expect(response).to redirect_to(resumes_path(query: 'designer'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.bulk_delete_completed', count: resumes.size))
    end

    it 'requires at least one selected resume' do
      post bulk_action_resumes_path, params: { bulk_operation: 'export', page: 2 }

      expect(response).to redirect_to(resumes_path(page: 2))
      expect(flash[:alert]).to eq(I18n.t('resumes.controller.bulk_selection_required'))
    end
  end

  describe 'POST /resumes/bulk_download' do
    context 'when not authenticated' do
      let(:authenticated) { false }

      it 'redirects to the sign-in page' do
        post bulk_download_resumes_path, params: { resume_ids: [ 1 ] }

        expect(response).to redirect_to(new_session_path)
      end
    end

    it 'returns a ZIP when all selected resumes have PDFs' do
      resumes = Array.new(2) { create(:resume, user:, template:) }
      resumes.each do |resume|
        resume.pdf_export.attach(
          io: StringIO.new("fake pdf for #{resume.slug}"),
          filename: "#{resume.slug}.pdf",
          content_type: "application/pdf"
        )
      end

      post bulk_download_resumes_path, params: { resume_ids: resumes.map(&:id) }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/zip")
      expect(response.headers["Content-Disposition"]).to include("resumes-")
      expect(response.headers["Content-Disposition"]).to include(Date.current.iso8601)

      entries = []
      Zip::InputStream.open(StringIO.new(response.body)) do |zip|
        while (entry = zip.get_next_entry)
          entries << entry.name
        end
      end

      expect(entries.size).to eq(2)
      resumes.each do |resume|
        expect(entries).to include("#{resume.slug}.pdf")
      end
    end

    it 'returns a see_other redirect with alert when some PDFs are missing' do
      resume_with_pdf = create(:resume, user:, template:)
      resume_without_pdf = create(:resume, user:, template:)
      resume_with_pdf.pdf_export.attach(
        io: StringIO.new("fake pdf"),
        filename: "test.pdf",
        content_type: "application/pdf"
      )

      post bulk_download_resumes_path, params: {
        resume_ids: [ resume_with_pdf.id, resume_without_pdf.id ],
        page: 2
      }

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(resumes_path(page: 2, resume_ids: [ resume_with_pdf.id, resume_without_pdf.id ]))
      expect(flash[:alert]).to eq(I18n.t('resumes.controller.bulk_download_not_ready', ready: 1, total: 2))
    end

    it 'returns a see_other redirect with alert when no resumes are selected' do
      post bulk_download_resumes_path, params: { page: 2 }

      expect(response).to redirect_to(resumes_path(page: 2))
      expect(flash[:alert]).to eq(I18n.t('resumes.controller.bulk_selection_required'))
    end

    it 'only includes resumes owned by the current user' do
      other_user = create(:user)
      own_resume = create(:resume, user:, template:)
      other_resume = create(:resume, user: other_user, template:)
      [ own_resume, other_resume ].each do |resume|
        resume.pdf_export.attach(
          io: StringIO.new("fake pdf for #{resume.slug}"),
          filename: "#{resume.slug}.pdf",
          content_type: "application/pdf"
        )
      end

      post bulk_download_resumes_path, params: { resume_ids: [ own_resume.id, other_resume.id ] }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/zip")

      entries = []
      Zip::InputStream.open(StringIO.new(response.body)) do |zip|
        while (entry = zip.get_next_entry)
          entries << entry.name
        end
      end

      expect(entries).to eq([ "#{own_resume.slug}.pdf" ])
    end
  end
end
