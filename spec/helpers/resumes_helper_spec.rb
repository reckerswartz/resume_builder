require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ResumesHelper. For example:
#
# describe ResumesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ResumesHelper, type: :helper do
  describe '#current_resume_builder_step' do
    it 'falls back to heading for unknown steps' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(step: 'unknown'))

      expect(helper.current_resume_builder_step).to eq('heading')
    end

    it 'returns the requested step when it is known' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(step: 'education'))

      expect(helper.current_resume_builder_step).to eq('education')
    end
  end

  describe '#builder_templates' do
    it 'returns active templates by default and preserves a selected inactive template' do
      active_template = create(:template, name: 'Modern Slate')
      selected_inactive_template = create(:template, name: 'Legacy Blue', active: false)
      create(:template, name: 'Legacy Hidden', active: false)

      expect(helper.builder_templates).to include(active_template)
      expect(helper.builder_templates).not_to include(selected_inactive_template)

      expect(helper.builder_templates(selected_template: selected_inactive_template)).to include(active_template, selected_inactive_template)
    end
  end

  describe '#template_cards_for_builder' do
    it 'returns gallery metadata for each available template' do
      template = create(:template, name: 'Modern Slate')

      template_card = helper.template_cards_for_builder(selected_template: template).find { |card| card.fetch(:template) == template }
      preview_resume = template_card.fetch(:preview_resume)

      expect(template_card).to include(
        family: 'modern',
        family_label: 'Modern',
        density: 'comfortable',
        density_label: 'Comfortable',
        column_count: 'single_column',
        column_count_label: '1 column',
        theme_tone: 'slate',
        theme_tone_label: 'Slate',
        supports_headshot: false,
        header_style: 'split',
        header_style_label: 'Split',
        entry_style: 'cards',
        entry_style_label: 'Cards',
        skill_style: 'chips',
        skill_style_label: 'Chips',
        section_heading_style: 'marker',
        section_heading_style_label: 'Marker',
        shell_style: 'card',
        shell_style_label: 'Card',
        sidebar_section_labels: [],
        summary: 'Modern layout with split headers, marker section headings, and cards entries.',
        short_label: 'MO'
      )
      expect(preview_resume).to be_a(Resume)
      expect(preview_resume.template).to eq(template)
      expect(preview_resume.sections.size).to eq(ResumeBuilder::SectionRegistry.starter_sections.size)
      expect(template_card.fetch(:selected_accent_color)).to eq('#0F172A')
      expect(template_card.fetch(:accent_variants)).to include(
        include(key: 'slate', label: 'Slate', accent_color: '#0F172A', default: true, custom: false),
        include(key: 'blue', label: 'Blue', accent_color: '#1D4ED8', default: false, custom: false),
        include(key: 'teal', label: 'Teal', accent_color: '#0D6B63', default: false, custom: false)
      )
      expect(template_card.fetch(:preview_resumes_by_accent_color).keys).to match_array([ '#0F172A', '#1D4ED8', '#0D6B63' ])
    end

    it 'uses the render-ready implementation profile for shared builder card metadata' do
      template = create(
        :template,
        name: 'Modern Slate',
        slug: 'modern-slate',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')
      )
      create(
        :template_implementation,
        template: template,
        status: 'validated',
        renderer_family: 'classic',
        render_profile: {
          'family' => 'classic',
          'accent_color' => '#1D4ED8',
          'density' => 'compact'
        }
      )

      template_card = helper.template_cards_for_builder(selected_template: template).find { |card| card.fetch(:template) == template }

      expect(template_card).to include(
        family: 'classic',
        family_label: 'Classic',
        density: 'compact',
        density_label: 'Compact',
        accent_color: '#1D4ED8'
      )
    end

    it 'uses selected accent overrides when building shared template card previews' do
      classic_template = create(
        :template,
        name: 'Classic Ivory',
        slug: 'classic-ivory',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )

      template_card = helper.template_cards_for_builder(
        selected_template: classic_template,
        selected_accent_colors: { classic_template.id => '#334155' }
      ).find { |card| card.fetch(:template) == classic_template }

      expect(template_card.fetch(:selected_accent_color)).to eq('#334155')
      expect(template_card.fetch(:preview_resume).settings).to include('accent_color' => '#334155')
      expect(template_card.fetch(:preview_resumes_by_accent_color).keys).to include('#334155')
    end
  end

  describe '#resume_finalize_workspace_state' do
    it 'builds finalize workspace state with section visibility metadata' do
      resume = create(:resume, settings: { 'accent_color' => '#0F172A', 'show_contact_icons' => true, 'page_size' => 'A4', 'hidden_sections' => [ 'projects' ] })
      experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
      projects_section = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 3)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Engineer' })
      create(:entry, section: projects_section, content: { 'name' => 'Resume Builder' })

      finalize_workspace_state = helper.resume_finalize_workspace_state(resume, step_sections: [ projects_section ])

      expect(finalize_workspace_state.design_badges).to include(
        include(label: 'Page: A4'),
        include(label: 'Type: Base'),
        include(label: 'Density: Comfortable')
      )
      expect(finalize_workspace_state.section_visibility_states).to include(
        include(section_type: 'projects', hidden: true, badge_label: 'Hidden from output')
      )
      expect(finalize_workspace_state.section_order_states).to include(
        include(title: 'Experience', position_label: 'Position 1'),
        include(title: 'Projects', position_label: 'Position 2', visibility_badge_label: 'Hidden from output')
      )
    end
  end

  describe '#resume_builder_step_params' do
    it 'preserves the active finalize tab when present' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(step: 'finalize', tab: 'sections'))

      expect(helper.resume_builder_step_params).to eq(step: 'finalize', tab: 'sections')
      expect(helper.resume_builder_step_params('finalize')).to eq(step: 'finalize', tab: 'sections')
      expect(helper.resume_builder_step_params('finalize', tab: 'design')).to eq(step: 'finalize', tab: 'design')
    end
  end

  describe '#template_card_summary' do
    it 'describes sidebar families using sidebar content labels' do
      summary = helper.template_card_summary(
        family_label: 'Sidebar Accent',
        header_style: 'split',
        section_heading_style: 'rule',
        entry_style: 'list',
        sidebar_position: 'left',
        sidebar_section_labels: [ 'Skills', 'Education' ]
      )

      expect(summary).to eq('Sidebar Accent layout with a left sidebar for Skills and Education and list main entries.')
    end
  end

  describe '#resume_builder_completion_percentage' do
    it 'tracks completion across heading, experience, education, skills, and summary' do
      resume = create(
        :resume,
        title: 'Guided Resume',
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

      expect(helper.resume_builder_completion_percentage(resume)).to eq(100)
    end
  end

  describe '#resume_builder_sections_for_step' do
    it 'returns only sections relevant to the active step' do
      resume = create(:resume)
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience')
      education_section = create(:section, resume:, section_type: 'education', title: 'Education')
      project_section = create(:section, resume:, section_type: 'projects', title: 'Projects')

      expect(helper.resume_builder_sections_for_step(resume, 'experience')).to eq([ experience_section ])
      expect(helper.resume_builder_sections_for_step(resume, 'education')).to eq([ education_section ])
      expect(helper.resume_builder_sections_for_step(resume, 'finalize')).to eq([ project_section ])
    end
  end

  describe '#entry editor helpers' do
    it 'builds a compact experience summary for collapsed entry cards' do
      section = create(:section, section_type: 'experience', title: 'Experience')
      entry = build(
        :entry,
        section: section,
        content: {
          'title' => 'Engineering Manager',
          'organization' => 'Acme',
          'start_date' => '2022',
          'current_role' => true,
          'summary' => 'Led a Rails delivery team.'
        }
      )

      expect(helper.entry_editor_title(entry, section)).to eq('Engineering Manager')
      expect(helper.entry_editor_metadata(entry, section)).to eq('Acme · 2022 - Present')
      expect(helper.entry_editor_supporting_text(entry, section)).to eq('Led a Rails delivery team.')
    end

    it 'builds a compact project summary for collapsed finalize cards' do
      section = create(:section, section_type: 'projects', title: 'Projects')
      entry = build(
        :entry,
        section: section,
        content: {
          'name' => 'Resume Builder',
          'role' => 'Lead Engineer',
          'url' => 'https://example.com',
          'highlights' => [ 'Implemented shared preview rendering' ]
        }
      )

      expect(helper.entry_editor_title(entry, section)).to eq('Resume Builder')
      expect(helper.entry_editor_metadata(entry, section)).to eq('Lead Engineer · https://example.com')
      expect(helper.entry_editor_supporting_text(entry, section)).to eq('Implemented shared preview rendering')
    end

    it 'falls back to the localized section entry title when an entry is blank' do
      section = create(:section, section_type: 'projects', title: 'Projects')
      entry = Entry.new(section: section, content: {})

      expect(helper.entry_editor_title(entry, section)).to eq('Projects entry')
    end
  end

  describe '#resume_source_autofill_status_label' do
    it 'returns a ready label for pasted source text' do
      resume = create(:resume, source_mode: 'paste', source_text: 'Existing resume text')

      expect(helper.resume_source_autofill_status_label(resume, autofill_enabled: true)).to eq('Paste import ready')
    end

    it 'returns a reference-only label for unsupported uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('legacy doc sample'), filename: 'resume.doc', content_type: 'application/msword')

      expect(helper.resume_source_autofill_status_label(resume, autofill_enabled: true)).to eq('Reference file only')
    end
  end

  describe '#resume_source_autofill_status_message' do
    it 'describes supported upload autofill when a text-like file is attached' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('resume text'), filename: 'resume.txt', content_type: 'text/plain')

      expect(helper.resume_source_autofill_status_message(resume, autofill_enabled: true)).to include('converted into source text for AI autofill')
    end
  end

  describe '#resume_source_autofill_action_ready?' do
    it 'returns true for a supported uploaded source document' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('resume text'), filename: 'resume.txt', content_type: 'text/plain')

      expect(helper.resume_source_autofill_action_ready?(resume, autofill_enabled: true)).to be(true)
    end

    it 'returns false when autofill is disabled' do
      resume = create(:resume, source_mode: 'paste', source_text: 'Existing resume text')

      expect(helper.resume_source_autofill_action_ready?(resume, autofill_enabled: false)).to be(false)
    end
  end

  describe '#resume_source_cloud_import_provider_states' do
    before do
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, fullpath: '/resumes/new?step=setup'))
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return(nil)
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return(nil)
    end

    it 'builds setup guidance for unconfigured providers' do
      resume = create(:resume)

      google_drive_state = helper.resume_source_cloud_import_provider_states(resume).find do |provider_state|
        provider_state.fetch(:key) == 'google_drive'
      end

      expect(google_drive_state).to include(
        label: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
        description: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.description'),
        status_label: I18n.t('resumes.helper.source_cloud_import.status.setup_required'),
        status_tone: :warning
      )
      expect(google_drive_state.fetch(:message)).to eq(
        I18n.t(
          'resumes.cloud_import_provider_catalog.feedback.setup_required',
          provider: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
          env_vars: 'GOOGLE_DRIVE_CLIENT_ID and GOOGLE_DRIVE_CLIENT_SECRET'
        )
      )
    end

    it 'marks configured providers separately when environment credentials are present' do
      resume = create(:resume)
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return('client-id')
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return('client-secret')

      google_drive_state = helper.resume_source_cloud_import_provider_states(resume).find do |provider_state|
        provider_state.fetch(:key) == 'google_drive'
      end

      expect(google_drive_state).to include(
        label: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
        description: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.description'),
        status_label: I18n.t('resumes.helper.source_cloud_import.status.configured'),
        status_tone: :neutral
      )
      expect(google_drive_state.fetch(:message)).to eq(
        I18n.t(
          'resumes.cloud_import_provider_catalog.feedback.configured',
          provider: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label')
        )
      )
    end
  end

  describe '#resume_source_upload_review_state' do
    it 'builds a review state for supported autofill uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('resume text'), filename: 'resume.txt', content_type: 'text/plain')

      expect(helper.resume_source_upload_review_state(resume, autofill_enabled: true)).to include(
        title: 'Ready for AI import',
        badge_label: 'Autofill supported',
        badge_tone: :success,
        filename: 'resume.txt',
        content_type: 'text/plain'
      )
      expect(helper.resume_source_upload_review_state(resume, autofill_enabled: true).fetch(:message)).to include('converted into source text during autofill')
    end

    it 'builds a review state for reference-only uploads' do
      resume = create(:resume, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('legacy doc sample'), filename: 'resume.doc', content_type: 'application/msword')

      expect(helper.resume_source_upload_review_state(resume, autofill_enabled: true)).to include(
        title: 'Reference file only',
        badge_label: 'Reference only',
        badge_tone: :neutral,
        filename: 'resume.doc',
        content_type: 'application/msword'
      )
      expect(helper.resume_source_upload_review_state(resume, autofill_enabled: true).fetch(:message)).to include('Keep this file attached for reference')
    end
  end
end
