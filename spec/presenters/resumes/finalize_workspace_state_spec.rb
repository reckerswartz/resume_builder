require 'rails_helper'

RSpec.describe Resumes::FinalizeWorkspaceState do
  let(:view_context) { instance_double('view_context') }

  describe '#font_scale_options and shared spacing option groups' do
    it 'prepends template-default options before the explicit shared formatting presets' do
      template = create(
        :template,
        name: 'Classic Ivory',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )
      resume = create(:resume, template: template, settings: { 'accent_color' => '#1D4ED8', 'show_contact_icons' => true, 'page_size' => 'A4' })

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      expect(state.font_scale_options.first).to eq([ 'Template default (Small)', '' ])
      expect(state.font_scale_options).to include([ 'Base', 'base' ], [ 'Large', 'lg' ])
      expect(state.density_options.first).to eq([ 'Template default (Compact)', '' ])
      expect(state.density_options).to include([ 'Comfortable', 'comfortable' ], [ 'Relaxed', 'relaxed' ])
      expect(state.section_spacing_options.first).to eq([ 'Template default (Tight)', '' ])
      expect(state.section_spacing_options).to include([ 'Standard', 'standard' ], [ 'Relaxed', 'relaxed' ])
      expect(state.paragraph_spacing_options.first).to eq([ 'Template default (Tight)', '' ])
      expect(state.paragraph_spacing_options).to include([ 'Standard', 'standard' ], [ 'Relaxed', 'relaxed' ])
      expect(state.line_spacing_options.first).to eq([ 'Template default (Standard)', '' ])
      expect(state.line_spacing_options).to include([ 'Tight', 'tight' ], [ 'Relaxed', 'relaxed' ])
    end
  end

  describe '#selected_section_spacing, #selected_paragraph_spacing, and #selected_line_spacing' do
    it 'returns the explicit resume settings values when present' do
      template = create(
        :template,
        name: 'Modern Clean',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern-clean')
      )
      resume = create(
        :resume,
        template: template,
        settings: {
          'accent_color' => '#0D6B63',
          'show_contact_icons' => true,
          'page_size' => 'A4',
          'section_spacing' => 'tight',
          'paragraph_spacing' => 'standard',
          'line_spacing' => 'relaxed'
        }
      )

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      expect(state.selected_section_spacing).to eq('tight')
      expect(state.selected_paragraph_spacing).to eq('standard')
      expect(state.selected_line_spacing).to eq('relaxed')
    end
  end

  describe '#accent_color_palette and accent color state' do
    it 'returns curated palette swatches with selection state matching the resume accent color' do
      template = create(
        :template,
        name: 'Modern',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')
      )
      resume = create(:resume, template: template, settings: { 'accent_color' => '#1D4ED8', 'show_contact_icons' => true, 'page_size' => 'A4' })

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      palette = state.accent_color_palette
      expect(palette).to be_an(Array)
      expect(palette.size).to eq(ResumeTemplates::Catalog.accent_color_palette.size)

      selected = palette.select { |s| s.fetch(:selected) }
      expect(selected.size).to eq(1)
      expect(selected.first.fetch(:hex)).to eq('#1D4ED8')
      expect(selected.first.fetch(:label)).to eq('Blue')

      unselected = palette.reject { |s| s.fetch(:selected) }
      expect(unselected).to all(include(selected: false))
    end

    it 'reports accent_color_is_default? true when accent matches template default' do
      template = create(
        :template,
        name: 'Classic',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )
      resume = create(:resume, template: template, settings: { 'accent_color' => '#1D4ED8', 'show_contact_icons' => true, 'page_size' => 'A4' })

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      expect(state.accent_color_is_default?).to be(true)
      expect(state.default_accent_color).to eq('#1D4ED8')
    end

    it 'reports accent_color_is_default? false when accent differs from template default' do
      template = create(
        :template,
        name: 'Classic',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )
      resume = create(:resume, template: template, settings: { 'accent_color' => '#DC2626', 'show_contact_icons' => true, 'page_size' => 'A4' })

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      expect(state.accent_color_is_default?).to be(false)
    end

    it 'reports accent_color_is_custom? true when accent is not in the curated palette' do
      template = create(
        :template,
        name: 'Modern',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern')
      )
      resume = create(:resume, template: template, settings: { 'accent_color' => '#ABCDEF', 'show_contact_icons' => true, 'page_size' => 'A4' })

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      expect(state.accent_color_is_custom?).to be(true)
      expect(state.accent_color_palette.none? { |s| s.fetch(:selected) }).to be(true)
    end
  end

  describe '#section_visibility_states' do
    it 'groups sections by section type and marks hidden types from resume settings' do
      resume = create(:resume, settings: { 'accent_color' => '#0F172A', 'show_contact_icons' => true, 'page_size' => 'A4', 'hidden_sections' => [ 'projects' ] })
      experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
      projects_primary = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 1)
      projects_secondary = create(:section, resume: resume, title: 'Case Studies', section_type: 'projects', position: 2)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Engineer' })
      create(:entry, section: projects_primary, content: { 'name' => 'Resume Builder' })
      create(:entry, section: projects_secondary, content: { 'name' => 'Template Audit' })

      state = described_class.new(resume: resume, step_sections: [ projects_primary, projects_secondary ], view_context: view_context)

      expect(state.section_visibility_states).to include(
        include(
          section_type: 'experience',
          label: 'Experience',
          hidden: false,
          badge_label: 'Visible',
          badge_tone: :success,
          summary: '1 section · 1 entry'
        ),
        include(
          section_type: 'projects',
          label: 'Projects',
          hidden: true,
          badge_label: 'Hidden from output',
          badge_tone: :warning,
          summary: '2 sections · 2 entries'
        )
      )
      expect(state.has_section_visibility_controls?).to be(true)
    end
  end

  describe '#section_order_states' do
    it 'returns ordered section cards with finalize tab-aware move URLs' do
      resume = create(:resume, settings: { 'accent_color' => '#0F172A', 'show_contact_icons' => true, 'page_size' => 'A4', 'hidden_sections' => [ 'projects' ] })
      experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
      projects_section = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 1)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Engineer' })
      create(:entry, section: projects_section, content: { 'name' => 'Resume Builder' })

      allow(view_context).to receive(:resume_builder_step_params).with('finalize', tab: 'sections').and_return(step: 'finalize', tab: 'sections')
      allow(view_context).to receive(:move_resume_section_path).with(experience_section.resume, experience_section, step: 'finalize', tab: 'sections').and_return('/resumes/1/sections/1/move?step=finalize&tab=sections')
      allow(view_context).to receive(:move_resume_section_path).with(projects_section.resume, projects_section, step: 'finalize', tab: 'sections').and_return('/resumes/1/sections/2/move?step=finalize&tab=sections')

      state = described_class.new(resume: resume, step_sections: [ projects_section ], view_context: view_context)

      expect(state.section_order_states).to match([
        include(
          title: 'Experience',
          position_label: 'Position 1',
          entry_count_label: '1 entry',
          move_url: '/resumes/1/sections/1/move?step=finalize&tab=sections',
          visibility_badge_label: 'Visible'
        ),
        include(
          title: 'Projects',
          position_label: 'Position 2',
          entry_count_label: '1 entry',
          move_url: '/resumes/1/sections/2/move?step=finalize&tab=sections',
          visibility_badge_label: 'Hidden from output'
        )
      ])
      expect(state.has_section_order_controls?).to be(true)
    end
  end

  describe '#sections_badges' do
    it 'returns honest section-management counts for the finalize sections header' do
      resume = create(:resume, settings: { 'accent_color' => '#0F172A', 'show_contact_icons' => true, 'page_size' => 'A4' })
      experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
      skills_section = create(:section, resume: resume, title: 'Skills', section_type: 'skills', position: 1)
      projects_section = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 2)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Engineer' })
      create(:entry, section: skills_section, content: { 'name' => 'Ruby' })
      create(:entry, section: projects_section, content: { 'name' => 'Resume Builder' })

      state = described_class.new(resume: resume, step_sections: [ projects_section ], view_context: view_context)

      expect(state.sections_badges).to eq([
        { label: '3 sections managed', tone: :neutral },
        { label: '3 entries in review', tone: :neutral },
        { label: '1 additional section', tone: :neutral }
      ])
    end
  end

  describe '#spellcheck_review_states' do
    it 'returns honest review cards with step links and saved-content counts' do
      resume = create(
        :resume,
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
          'date_of_birth' => '',
          'nationality' => 'Indian',
          'marital_status' => '',
          'visa_status' => 'Authorized to work in India'
        },
        settings: { 'accent_color' => '#0F172A', 'show_contact_icons' => true, 'page_size' => 'A4' }
      )
      experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
      education_section = create(:section, resume: resume, title: 'Education', section_type: 'education', position: 1)
      skills_section = create(:section, resume: resume, title: 'Skills', section_type: 'skills', position: 2)
      projects_section = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 3)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Designer' })
      create(:entry, section: education_section, content: { 'degree' => 'B.Des' })
      create(:entry, section: skills_section, content: { 'name' => 'Figma' })
      create(:entry, section: projects_section, content: { 'name' => 'Resume Builder' })

      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'heading').and_return('/resumes/1/edit?step=heading')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'personal_details').and_return('/resumes/1/edit?step=personal_details')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'experience').and_return('/resumes/1/edit?step=experience')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'education').and_return('/resumes/1/edit?step=education')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'skills').and_return('/resumes/1/edit?step=skills')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'summary').and_return('/resumes/1/edit?step=summary')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'finalize', tab: 'sections').and_return('/resumes/1/edit?step=finalize&tab=sections')

      state = described_class.new(resume: resume, step_sections: [ projects_section ], view_context: view_context)

      expect(state.spellcheck_review_states).to include(
        include(key: 'heading', path: '/resumes/1/edit?step=heading', content_label: '6 saved fields', status_label: 'Ready to review'),
        include(key: 'personal_details', path: '/resumes/1/edit?step=personal_details', content_label: '2 saved fields', status_label: 'Ready to review'),
        include(key: 'experience', path: '/resumes/1/edit?step=experience', content_label: '1 section · 1 entry', status_label: 'Ready to review'),
        include(key: 'education', path: '/resumes/1/edit?step=education', content_label: '1 section · 1 entry', status_label: 'Ready to review'),
        include(key: 'skills', path: '/resumes/1/edit?step=skills', content_label: '1 section · 1 entry', status_label: 'Ready to review'),
        include(key: 'summary', path: '/resumes/1/edit?step=summary', content_label: '7 saved words', status_label: 'Ready to review'),
        include(key: 'additional_sections', path: '/resumes/1/edit?step=finalize&tab=sections', content_label: '1 section · 1 entry', status_label: 'Ready to review')
      )
    end

    it 'sorts ready review cards ahead of empty ones' do
      resume = create(
        :resume,
        headline: 'Senior Product Designer',
        summary: '',
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com'
        },
        personal_details: {},
        settings: { 'accent_color' => '#0F172A', 'show_contact_icons' => true, 'page_size' => 'A4' }
      )
      experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Designer' })

      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'heading').and_return('/resumes/1/edit?step=heading')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'personal_details').and_return('/resumes/1/edit?step=personal_details')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'experience').and_return('/resumes/1/edit?step=experience')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'education').and_return('/resumes/1/edit?step=education')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'skills').and_return('/resumes/1/edit?step=skills')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'summary').and_return('/resumes/1/edit?step=summary')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'finalize', tab: 'sections').and_return('/resumes/1/edit?step=finalize&tab=sections')

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      ordered_keys = state.spellcheck_review_states.map { |review_state| review_state.fetch(:key) }
      ready_prefix = state.spellcheck_review_states.take_while { |review_state| review_state.fetch(:ready) }.map { |review_state| review_state.fetch(:key) }
      empty_suffix = state.spellcheck_review_states.drop_while { |review_state| review_state.fetch(:ready) }.map { |review_state| review_state.fetch(:key) }

      expect(ordered_keys).to include('heading', 'experience', 'summary', 'additional_sections')
      expect(ready_prefix).to eq(%w[heading experience])
      expect(empty_suffix).to eq(%w[additional_sections education personal_details summary skills])
    end
  end

  describe '#spellcheck_badges' do
    it 'returns honest ready vs empty counts for the spellcheck header' do
      resume = create(
        :resume,
        headline: 'Senior Product Designer',
        summary: '',
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com'
        },
        personal_details: {},
        settings: { 'accent_color' => '#0F172A', 'show_contact_icons' => true, 'page_size' => 'A4' }
      )
      experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
      create(:entry, section: experience_section, content: { 'title' => 'Lead Designer' })

      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'heading').and_return('/resumes/1/edit?step=heading')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'personal_details').and_return('/resumes/1/edit?step=personal_details')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'experience').and_return('/resumes/1/edit?step=experience')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'education').and_return('/resumes/1/edit?step=education')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'skills').and_return('/resumes/1/edit?step=skills')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'summary').and_return('/resumes/1/edit?step=summary')
      allow(view_context).to receive(:edit_resume_path).with(resume, step: 'finalize', tab: 'sections').and_return('/resumes/1/edit?step=finalize&tab=sections')

      state = described_class.new(resume: resume, step_sections: [], view_context: view_context)

      expect(state.spellcheck_badges).to eq([
        { label: '2 ready to review', tone: :success },
        { label: '5 still empty', tone: :neutral }
      ])
    end
  end
end
