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
          'accent_color' => '#0F766E',
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
end
