require 'cgi'
require 'rails_helper'

RSpec.describe 'Admin::Templates', type: :request do
  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'GET /admin/templates' do
    it 'renders the template index summary and filter shell' do
      create(:template)

      get admin_templates_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Templates')
      expect(response.body).to include('Template gallery')
      expect(response.body).to include('Template index snapshot')
      expect(response.body).to include('Shared renderer')
      expect(response.body).to include('Filter templates')
      expect(response.body).to include('Filter by live visibility or cleanup targets')
      expect(response.body).to include('Layout families')
      expect(response.body).to include('page-header-compact')
    end

    it 'builds summary cards from the full filtered scope, not only the current page' do
      10.times do |index|
        create(
          :template,
          name: format('Template %02d', index),
          slug: format('template-%02d', index),
          active: false,
          layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
        )
      end
      create(
        :template,
        name: 'Zulu Sidebar',
        slug: 'zulu-sidebar',
        active: true,
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )

      get admin_templates_path

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      matches_card = document.xpath("//article[.//p[normalize-space()='Matches']]").first
      user_visible_card = document.xpath("//article[.//p[normalize-space()='User-visible']]").first
      families_card = document.xpath("//article[.//p[normalize-space()='Layout families']]").first
      sidebar_card = document.xpath("//article[.//p[normalize-space()='Sidebar layouts']]").first

      expect(matches_card.css('p')[1].text.strip).to eq('11')
      expect(matches_card.at_css('span')&.text&.strip).to eq('10 on this page')
      expect(user_visible_card.css('p')[1].text.strip).to eq('1')
      expect(families_card.css('p')[1].text.strip).to eq('2')
      expect(families_card.at_css('span')&.text&.strip).to eq('1 card shells')
      expect(sidebar_card.css('p')[1].text.strip).to eq('1')
      expect(sidebar_card.at_css('span')&.text&.strip).to eq('Varied')
    end

    it 'filters and sorts templates' do
      create(:template, name: 'Alpha Template', slug: 'alpha-template', active: true)
      create(:template, name: 'Classic Template', slug: 'classic-template', active: false)
      create(:template, name: 'Zeta Template', slug: 'zeta-template', active: false)

      get admin_templates_path, params: {
        query: 'template',
        status: 'inactive',
        sort: 'name',
        direction: 'desc'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Zeta Template')
      expect(response.body).to include('Classic Template')
      expect(response.body).not_to include('Alpha Template')
      expect(response.body.index('Zeta Template')).to be < response.body.index('Classic Template')
    end
  end

  describe 'GET /admin/templates/:id' do
    it 'renders the grouped template hub with shared preview, lifecycle review, and config guidance' do
      template = create(:template, name: 'Modern', active: true)

      get admin_template_path(template)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('page-header-compact')
      expect(response_body).to include('Review summary')
      expect(response_body).to include('Review this template')
      expect(response_body).to include('Shared preview')
      expect(response_body).to include('Live sample')
      expect(response_body).to include('Layout profile')
      expect(response_body).to include('Layout summary')
      expect(response_body).to include('Artifact review')
      expect(response_body).to include('Captured references')
      expect(response_body).to include('No source artifacts yet')
      expect(response_body).to include('Implementation & validation')
      expect(response_body).to include('No render-ready implementation yet')
      expect(response_body).to include('No draft candidates yet')
      expect(response_body).to include('No validation runs yet')
      expect(response_body).to include('Shell profile')
      expect(response_body).to include('Columns')
      expect(response_body).to include('Theme tone')
      expect(response_body).to include('Headshot metadata')
      expect(response_body).to include('Preview accent')
      expect(response_body).to include('Configuration')
      expect(response_body).to include('Raw layout config')
      expect(response_body).to include('Fallback only')
    end

    it 'renders stored artifacts, the current implementation, and recent validation history' do
      template = create(:template, name: 'Editorial Split', slug: 'editorial-split', active: true)
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'reference_design',
        lineage_kind: 'source',
        name: 'Behance capture',
        metadata: { 'reference_source_url' => 'https://www.behance.net/gallery/245736819/Resume-Cv-Template' }
      )
      source_artifact.reference_image.attach(io: StringIO.new('image-bytes'), filename: 'reference.png', content_type: 'image/png')
      create(
        :template_artifact,
        template: template,
        artifact_type: 'design_note',
        lineage_kind: 'documentation',
        name: 'Capture notes',
        parent_artifact: source_artifact,
        metadata: { 'summary' => 'Reviewed against Behance capture' }
      )
      create(
        :template_artifact,
        template: template,
        artifact_type: 'validation_report',
        lineage_kind: 'validation',
        name: 'Audit findings',
        parent_artifact: source_artifact,
        metadata: { 'pixel_status' => 'close' }
      )
      implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'stable',
        renderer_family: 'editorial-split',
        render_profile: template.normalized_layout_config,
        metadata: { 'pixel_status' => 'close', 'open_discrepancy_count' => 2 }
      )
      create(
        :template_validation_run,
        template: template,
        template_implementation: implementation,
        reference_artifact: source_artifact,
        validation_type: 'manual_review',
        status: 'needs_review',
        validator_name: 'Artifact audit',
        metrics: {
          'pixel_status' => 'close',
          'open_discrepancy_count' => 2,
          'resolved_discrepancy_count' => 1
        },
        metadata: { 'capture_signature' => 'behance:245736819:resume-cv-template:editorial-split' }
      )

      get admin_template_path(template)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('Validation follow-up needed')
      expect(response_body).to include('Behance capture')
      expect(response_body).to include('Capture notes')
      expect(response_body).to include('Audit findings')
      expect(response_body).to include('Implementation Stable')
      expect(response_body).to include('Current implementation')
      expect(response_body).to include('Recent validation runs')
      expect(response_body).to include('Artifact audit')
      expect(response_body).to include('Pixel Close')
      expect(response_body).to include('2 open discrepancies')
      expect(response_body).to include('reference.png')
    end

    it 'renders draft candidates and candidate creation actions when reviewed source artifacts exist' do
      template = create(:template, name: 'Editorial Split', slug: 'editorial-split', active: true)
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'reference_design',
        lineage_kind: 'source',
        name: 'Behance capture'
      )
      draft_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'draft',
        renderer_family: 'editorial-split',
        render_profile: template.render_layout_config,
        notes: 'Draft candidate created from Behance capture.'
      )
      create(
        :template_validation_run,
        template: template,
        template_implementation: draft_candidate,
        reference_artifact: source_artifact,
        validation_type: 'manual_review',
        status: 'passed',
        validator_name: 'Artifact audit'
      )

      get admin_template_path(template)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('1 draft candidate in progress')
      expect(response_body).to include('1 draft candidate')
      expect(response_body).to include('Draft candidates')
      expect(response_body).to include(draft_candidate.name)
      expect(response_body).to include('Create draft candidate')
      expect(response_body).to include('Create draft from latest source')
      expect(response_body).to include('Latest validation')
      expect(response_body).to include('Record review pass')
      expect(response_body).to include('Needs follow-up')
      expect(response_body).to include('Promote to validated')
    end
  end

  describe 'POST /admin/templates/:template_id/implementation_candidates' do
    it 'creates a draft candidate from a reviewed source artifact and redirects back to implementation validation' do
      template = create(:template, name: 'Editorial Split', slug: 'editorial-split')
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'reference_design',
        lineage_kind: 'source',
        name: 'Behance capture'
      )

      expect do
        post admin_template_implementation_candidates_path(template), params: { source_artifact_id: source_artifact.id }
      end.to change(TemplateImplementation, :count).by(1)
        .and change { template.template_artifacts.where(artifact_type: 'implementation_snapshot').count }.by(1)

      candidate = TemplateImplementation.order(:created_at).last

      expect(response).to redirect_to(admin_template_path(template, anchor: 'implementation-validation'))
      expect(flash[:notice]).to eq("#{candidate.name} created from Behance capture.")
      expect(candidate.status).to eq('draft')
      expect(candidate.source_artifact).to eq(source_artifact)
    end

    it 'rejects non-source artifacts and redirects back to the artifact review section' do
      template = create(:template)
      note_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'design_note',
        lineage_kind: 'documentation',
        name: 'Capture notes'
      )

      expect do
        post admin_template_implementation_candidates_path(template), params: { source_artifact_id: note_artifact.id }
      end.not_to change(TemplateImplementation, :count)

      expect(response).to redirect_to(admin_template_path(template, anchor: 'artifact-review'))
      expect(flash[:alert]).to eq('Selected artifact must be an active source artifact.')
    end
  end

  describe 'POST /admin/templates/:template_id/implementations/:implementation_id/validation_runs' do
    it 'records a validation run for a draft candidate and stores a validation artifact' do
      template = create(:template, name: 'Editorial Split', slug: 'editorial-split')
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'reference_design',
        lineage_kind: 'source',
        name: 'Behance capture'
      )
      draft_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'draft',
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config
      )

      expect do
        post admin_template_implementation_validation_runs_path(template, draft_candidate), params: {
          validation_run: {
            validation_type: 'manual_review',
            status: 'passed'
          }
        }
      end.to change(TemplateValidationRun, :count).by(1)
        .and change { template.template_artifacts.where(artifact_type: 'validation_report').count }.by(1)

      validation_run = TemplateValidationRun.order(:created_at).last

      expect(response).to redirect_to(admin_template_path(template, anchor: 'implementation-validation'))
      expect(flash[:notice]).to eq("Manual Review recorded for #{draft_candidate.name} as Passed.")
      expect(validation_run.template_implementation).to eq(draft_candidate)
      expect(validation_run.reference_artifact).to eq(source_artifact)
      expect(validation_run.status).to eq('passed')
    end
  end

  describe 'POST /admin/templates/:template_id/implementations/:implementation_id/promotion' do
    it 'promotes a reviewed draft candidate to validated and records a version snapshot' do
      template = create(:template, name: 'Editorial Split', slug: 'editorial-split')
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'reference_design',
        lineage_kind: 'source',
        name: 'Behance capture'
      )
      draft_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'draft',
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: nil
      )
      validation_run = create(
        :template_validation_run,
        template: template,
        template_implementation: draft_candidate,
        reference_artifact: source_artifact,
        validation_type: 'manual_review',
        status: 'passed'
      )

      expect do
        post admin_template_implementation_promotion_path(template, draft_candidate)
      end.to change { draft_candidate.reload.status }.from('draft').to('validated')
        .and change { template.template_artifacts.where(artifact_type: 'version_snapshot').count }.by(1)

      expect(response).to redirect_to(admin_template_path(template, anchor: 'implementation-validation'))
      expect(flash[:notice]).to eq("#{draft_candidate.name} promoted to a render-ready validated implementation.")
      expect(draft_candidate.reload.validated_at).to eq(validation_run.validated_at)
    end

    it 'rejects promotion when the draft candidate has no passed validation run' do
      template = create(:template, name: 'Editorial Split', slug: 'editorial-split')
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'reference_design',
        lineage_kind: 'source',
        name: 'Behance capture'
      )
      draft_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'draft',
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: nil
      )
      create(
        :template_validation_run,
        template: template,
        template_implementation: draft_candidate,
        reference_artifact: source_artifact,
        validation_type: 'manual_review',
        status: 'needs_review'
      )

      expect do
        post admin_template_implementation_promotion_path(template, draft_candidate)
      end.not_to change { draft_candidate.reload.status }

      expect(response).to redirect_to(admin_template_path(template, anchor: 'implementation-validation'))
      expect(flash[:alert]).to eq('Record a passed validation run before promoting this draft implementation.')
    end
  end

  describe 'GET /admin/templates/new' do
    it 'renders the grouped template setup form' do
      get new_admin_template_path
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('New template')
      expect(response.body).to include('page-header-compact')
      expect(response_body).to include('Template setup')
      expect(response_body).to include('Template identity')
      expect(response_body).to include('Layout system')
      expect(response_body).to include('Availability & preview')
      expect(response_body).to include('Preview behavior')
      expect(response_body).to include('Shared preview')
      expect(response_body).to include('Current renderer sample')
      expect(response_body).to include('Theme tone')
      expect(response_body).to include('Headshot metadata')
      expect(response_body).to include('Advanced layout metadata')
      expect(response_body).to include('Save behavior')
      expect(response_body).to include('Accent color')
    end
  end

  describe 'GET /admin/templates/:id/edit' do
    it 'renders the grouped template edit form' do
      template = create(:template)

      get edit_admin_template_path(template)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Edit template')
      expect(response.body).to include('page-header-compact')
      expect(response_body).to include('Template setup')
      expect(response_body).to include('Layout system')
      expect(response_body).to include('Availability & preview')
      expect(response_body).to include('Save template')
      expect(response_body).to include('Current renderer sample')
      expect(response_body).to include('Shared preview')
      expect(response_body).to include('Theme tone')
      expect(response_body).to include('Headshot metadata')
      expect(response_body).to include('Advanced layout metadata')
      expect(response_body).to include('Preview behavior')
      expect(response_body).to include('Save behavior')
      expect(response.body).to include('sticky-action-bar-compact')
    end
  end

  describe 'POST /admin/templates' do
    it 'creates a template' do
      expect do
        post admin_templates_path, params: {
          template: {
            name: 'Classic',
            slug: 'classic',
            description: 'Classic layout',
            active: 'true',
            layout_config: {
              family: 'classic',
              accent_color: '#abc',
              font_scale: 'sm',
              density: 'compact',
              column_count: 'single_column',
              theme_tone: 'blue',
              supports_headshot: 'true'
            }
          }
        }
      end.to change(Template, :count).by(1)

      expect(response).to redirect_to(admin_template_path(Template.last))
      expect(Template.last.layout_config).to include(
        'family' => 'classic',
        'variant' => 'classic',
        'accent_color' => '#aabbcc',
        'font_scale' => 'sm',
        'density' => 'compact',
        'column_count' => 'single_column',
        'theme_tone' => 'blue',
        'supports_headshot' => true
      )
    end
  end
end
