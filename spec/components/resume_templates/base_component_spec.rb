require 'rails_helper'

RSpec.describe ResumeTemplates::BaseComponent do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'modern' }
  let(:template) do
    create(
      :template,
      name: ResumeTemplates::Catalog.family_label(family),
      slug: "#{family}-#{SecureRandom.hex(4)}",
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: family)
    )
  end
  let(:settings) do
    {
      'accent_color' => '#0F172A',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Jordan',
      'surname' => 'Rivera',
      'email' => 'jordan@example.com',
      'phone' => '555-0100',
      'location' => '',
      'city' => 'Remote',
      'country' => 'USA',
      'website' => '',
      'linkedin' => 'https://linkedin.com/in/jordan',
      'driving_licence' => ''
    }
  end
  let(:resume) do
    create(
      :resume,
      template:,
      settings:,
      contact_details:
    )
  end

  describe '#shell_classes' do
    it 'combines the shared density padding, font family, and card shell chrome' do
      expect(component.shell_classes).to include('font-sans')
      expect(component.shell_classes).to include('p-8')
      expect(component.shell_classes).to include('rounded-[2rem]')
      expect(component.shell_classes).to include('shadow-sm')
    end

    context 'when the resume overrides the font family and the template uses a flat shell' do
      let(:family) { 'classic' }
      let(:settings) { super().merge('font_family' => 'mono') }

      it 'uses the overridden font family without card shell chrome' do
        expect(component.shell_classes).to include('font-mono')
        expect(component.shell_classes).to include('p-6')
        expect(component.shell_classes).not_to include('rounded-[2rem]')
      end
    end
  end

  describe 'spacing helpers' do
    it 'keeps density defaults unless explicit spacing settings are stored on the resume' do
      expect(component.section_stack_classes).to eq('mt-8 space-y-8')
      expect(component.section_stack_spacing_class(fallback: 'space-y-4')).to eq('space-y-4')
      expect(component.section_margin_top_class(fallback: 'mt-4')).to eq('mt-4')
      expect(component.summary_margin_top_class).to eq('mt-5')
      expect(component.body_leading_class(default: 'leading-8')).to eq('leading-8')
    end

    context 'when the resume stores explicit spacing overrides' do
      let(:settings) do
        super().merge(
          'section_spacing' => 'tight',
          'paragraph_spacing' => 'tight',
          'line_spacing' => 'tight'
        )
      end

      it 'uses the explicit section, paragraph, and line spacing scales' do
        expect(component.section_stack_classes).to eq('mt-7 space-y-7')
        expect(component.section_stack_spacing_class(fallback: 'space-y-4')).to eq('space-y-7')
        expect(component.section_margin_top_class(fallback: 'mt-4')).to eq('mt-7')
        expect(component.entry_body_spacing_class(fallback: 'mt-9')).to eq('mt-2')
        expect(component.summary_margin_top_class(fallback: 'mt-9')).to eq('mt-4')
        expect(component.body_leading_class(default: 'leading-8')).to eq('leading-5')
      end
    end
  end

  describe 'shared resume content helpers' do
    let!(:experience_section) do
      create(:section, resume:, title: 'Experience', section_type: 'experience', position: 0)
    end
    let!(:experience_entry) do
      create(
        :entry,
        section: experience_section,
        content: {
          'title' => 'Staff Engineer',
          'organization' => 'Acme',
          'role' => 'Platform Lead',
          'level' => 'Expert',
          'start_date' => '2022',
          'current_role' => true,
          'summary' => 'Built shared preview and export rendering flows.',
          'highlights' => ['Led the migration to reusable template helpers.'],
          'url' => 'https://example.com/platform'
        }
      )
    end

    it 'normalizes contact values and shared entry formatting for template views' do
      expect(component.full_name).to eq('Jordan Rivera')
      expect(component.contact_items).to include(
        ['Email', 'jordan@example.com'],
        ['Phone', '555-0100'],
        ['Location', 'Remote, USA'],
        ['LinkedIn', 'https://linkedin.com/in/jordan']
      )
      expect(component.entry_title(experience_entry)).to eq('Staff Engineer')
      expect(component.entry_subtitle(experience_entry)).to eq('Acme · Platform Lead · Expert')
      expect(component.entry_body_paragraphs(experience_entry)).to eq(['Built shared preview and export rendering flows.'])
      expect(component.entry_highlights(experience_entry)).to eq(['Led the migration to reusable template helpers.'])
      expect(component.entry_url(experience_entry)).to eq('https://example.com/platform')
      expect(component.date_range_for(experience_entry)).to eq('2022 - Current')
    end
  end

  describe '#visible_sections' do
    let(:settings) { super().merge('hidden_sections' => ['projects']) }
    let!(:experience_section) do
      create(:section, resume:, title: 'Experience', section_type: 'experience', position: 0)
    end
    let!(:projects_section) do
      create(:section, resume:, title: 'Projects', section_type: 'projects', position: 1)
    end
    let!(:skills_section) do
      create(:section, resume:, title: 'Skills', section_type: 'skills', position: 2)
    end

    before do
      create(:entry, section: experience_section)
      create(:entry, section: projects_section, content: { 'name' => 'Hidden Project' })
    end

    it 'filters out hidden sections and empty sections from the shared section list' do
      expect(component.visible_sections.map(&:section_type)).to eq(['experience'])
      expect(component.section_visible?(projects_section)).to be(false)
      expect(component.empty_section?(skills_section)).to be(true)
    end
  end

  describe 'headshot helpers' do
    let(:family) { 'editorial-split' }

    before do
      resume.headshot.attach(io: StringIO.new('image-bytes'), filename: 'headshot.png', content_type: 'image/png')
    end

    it 'builds a shared data URL for headshot-capable templates' do
      expect(component.supports_headshot?).to be(true)
      expect(component.headshot_attached?).to be(true)
      expect(component.headshot_alt_text).to eq('Jordan Rivera headshot')
      expect(component.headshot_data_url).to start_with('data:image/png;base64,')
    end
  end
end
