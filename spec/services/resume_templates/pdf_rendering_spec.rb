require 'rails_helper'

RSpec.describe 'Resume template PDF rendering' do
  def create_ready_photo_asset(photo_profile:, filename:, asset_kind: :enhanced)
    PhotoAsset.new(photo_profile:, asset_kind:, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  def build_resume_for(family:, accent_color:, attach_headshot: false)
    template = create(
      :template,
      name: ResumeTemplates::Catalog.family_label(family),
      slug: family,
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: family)
    )

    resume = create(
      :resume,
      template: template,
      title: "#{ResumeTemplates::Catalog.family_label(family)} Resume",
      headline: 'Lead Platform Engineer',
      summary: 'Built a flexible resume system with shared preview and export rendering.',
      settings: {
        'accent_color' => accent_color,
        'show_contact_icons' => true,
        'page_size' => 'A4'
      },
      contact_details: {
        'full_name' => 'Jordan Rivera',
        'email' => 'jordan@example.com',
        'phone' => '555-0100',
        'location' => 'Remote',
        'website' => 'https://portfolio.example.com',
        'linkedin' => 'https://linkedin.com/in/jordan-rivera'
      }
    )

    experience_section = create(:section, resume: resume, title: 'Experience', section_type: 'experience', position: 0)
    create(
      :entry,
      section: experience_section,
      content: {
        'title' => 'Lead Platform Engineer',
        'organization' => 'Acme Cloud',
        'location' => 'Remote',
        'start_date' => '2021',
        'end_date' => '2024',
        'summary' => 'Led the rendering platform for resume previews and exports.',
        'highlights' => [ 'Scaled template rendering across preview and PDF surfaces' ],
        'url' => 'https://example.com/platform'
      }
    )

    education_section = create(:section, resume: resume, title: 'Education', section_type: 'education', position: 1)
    create(
      :entry,
      section: education_section,
      content: {
        'institution' => 'State University',
        'degree' => 'B.S. Computer Science',
        'location' => 'Boston, MA',
        'start_date' => '2014',
        'end_date' => '2018',
        'details' => 'Graduated with honors.'
      }
    )

    skills_section = create(:section, resume: resume, title: 'Skills', section_type: 'skills', position: 2)
    create(:entry, section: skills_section, content: { 'name' => 'Ruby on Rails', 'level' => 'Expert' })

    if attach_headshot
      resume.headshot.attach(io: StringIO.new('image-bytes'), filename: 'headshot.png', content_type: 'image/png')
    end

    resume
  end

  {
    'ats-minimal' => '#334155',
    'professional' => '#0F4C81',
    'modern-clean' => '#0F766E',
    'sidebar-accent' => '#4338CA',
    'editorial-split' => '#D7F038'
  }.each do |family, accent_color|
    it "renders #{family} through the shared PDF template" do
      resume = build_resume_for(family: family, accent_color: accent_color)

      html = ApplicationController.render(
        template: 'resumes/pdf',
        layout: 'pdf',
        assigns: { resume: resume }
      )

      expect(html).to include('Jordan Rivera')
      expect(html).to include('Lead Platform Engineer')
      expect(html).to include('Ruby on Rails')
      expect(html).to include(accent_color)
    end
  end

  it 'applies the template default font family class and allows user override' do
    resume = build_resume_for(family: 'classic', accent_color: '#1D4ED8')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    doc = Nokogiri::HTML.parse(html)
    shell = doc.at_css('div[class*="max-w-3xl"]')
    expect(shell['class']).to include('font-serif')

    resume.update!(settings: resume.settings.merge('font_family' => 'mono'))

    overridden_html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume.reload }
    )

    overridden_doc = Nokogiri::HTML.parse(overridden_html)
    overridden_shell = overridden_doc.at_css('div[class*="max-w-3xl"]')
    expect(overridden_shell['class']).to include('font-mono')
    expect(overridden_shell['class']).not_to include('font-serif')
  end

  it 'applies font scale, density, and spacing overrides through the shared rendered HTML path' do
    resume = build_resume_for(family: 'modern', accent_color: '#0F172A')
    resume.update!(settings: resume.settings.merge('font_scale' => 'lg', 'density' => 'relaxed', 'section_spacing' => 'tight', 'paragraph_spacing' => 'tight', 'line_spacing' => 'tight'))

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)
    summary_paragraph = document.css('p').find { |node| node.text.include?('Built a flexible resume system with shared preview and export rendering.') }
    section_stack = document.css('div').find do |node|
      class_names = node['class'].to_s.split
      class_names.include?('mt-7') && class_names.include?('space-y-7')
    end

    expect(html).to include('text-5xl')
    expect(html).to include('p-10 sm:p-12')
    expect(section_stack).to be_present
    expect(summary_paragraph).to be_present
    expect(summary_paragraph['class'].to_s.split).to include('mt-4', 'leading-5')
  end

  it 'renders Modern Clean at compact density with tight spacing and card padding' do
    resume = build_resume_for(family: 'modern-clean', accent_color: '#0F766E')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)

    # Compact density container
    expect(html).to include('p-6 sm:p-8')

    # Card padding (px-4 py-3)
    entry_card = document.at_css('article.rounded-xl')
    expect(entry_card).to be_present
    card_classes = entry_card['class'].to_s.split
    expect(card_classes).to include('px-4', 'py-3')

    # Tighter contact chip padding
    contact_chip = document.at_css('span.rounded-full.border-slate-200')
    expect(contact_chip).to be_present
    chip_classes = contact_chip['class'].to_s.split
    expect(chip_classes).to include('px-2.5', 'py-1')

    # Tighter highlight bullet spacing
    highlight_list = document.at_css('ul')
    expect(highlight_list).to be_present
    expect(highlight_list['class']).to include('space-y-1.5')
  end

  it 'renders ATS Minimal section headings with stronger hierarchy than entry titles' do
    resume = build_resume_for(family: 'ats-minimal', accent_color: '#334155')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)
    experience_heading = document.css('h2').find { |node| node.text.strip == 'Experience' }

    expect(experience_heading).to be_present

    heading_classes = experience_heading['class'].to_s.split

    expect(heading_classes).to include('text-lg', 'font-semibold', 'uppercase', 'tracking-[0.18em]', 'text-slate-700')
    expect(heading_classes).not_to include('text-slate-500')
  end

  it 'renders ATS Minimal entries with a reserved trailing date column and no-wrap date range' do
    resume = build_resume_for(family: 'ats-minimal', accent_color: '#334155')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)
    experience_article = document.css('article').find { |node| node.text.include?('Lead Platform Engineer') }

    expect(experience_article).to be_present

    header_layout = experience_article.at_css('div[class*="sm:grid-cols-"]')
    date_range = experience_article.at_css('div.whitespace-nowrap')

    expect(header_layout['class']).to include('sm:grid', 'sm:grid-cols-[minmax(0,1fr)_auto]', 'sm:gap-x-6')
    expect(date_range).to be_present
    expect(date_range.text).to include('2021 - 2024')
  end

  it 'renders ATS Minimal header and section rules with stronger accent visibility' do
    resume = build_resume_for(family: 'ats-minimal', accent_color: '#334155')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)
    header = document.at_css('header')
    section_rule = document.at_css('section div span.h-0\.5.w-10')
    section_trailing_rule = document.at_css('section div span.h-0\.5.flex-1')

    expect(header).to be_present
    expect(header['class']).to include('border-b-2')
    expect(header['style']).to include('border-color: #33415566')

    expect(section_rule).to be_present
    expect(section_rule['style']).to include('background-color: #334155')

    expect(section_trailing_rule).to be_present
    expect(section_trailing_rule['style']).to include('background-color: #33415544')
  end

  it 'renders Sidebar Accent with a narrower desktop sidebar ratio for the main content column' do
    resume = build_resume_for(family: 'sidebar-accent', accent_color: '#4338CA')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)
    grid = document.at_css('div.sidebar-accent-layout')
    main_column = grid&.at_css('div[class*="lg:order-"]')
    sidebar = grid&.at_css('aside')

    expect(grid).to be_present
    expect(grid['class']).to include('sidebar-accent-layout')
    expect(main_column).to be_present
    expect(sidebar).to be_present
    expect(main_column['class']).to include('lg:col-span-1')
    expect(main_column['class']).not_to include('lg:col-span-2')
    expect(sidebar['style']).to include('background-color: #4338CA15')
  end

  it 'renders an attached headshot for the editorial split family through the shared PDF template' do
    resume = build_resume_for(family: 'editorial-split', accent_color: '#D7F038', attach_headshot: true)

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    expect(html).to include('Jordan Rivera headshot')
    expect(html).to include('data:image/png;base64')
  end

  it 'renders a selected photo-library headshot for the editorial split family through the shared PDF template' do
    resume = build_resume_for(family: 'editorial-split', accent_color: '#D7F038')
    photo_profile = PhotoProfile.create!(user: resume.user, name: 'Jordan Rivera Photo Library', status: :active)
    selected_asset = create_ready_photo_asset(photo_profile:, filename: 'selected-headshot.png')

    resume.update!(photo_profile:)
    ResumePhotoSelection.create!(
      resume:,
      template: resume.template,
      photo_asset: selected_asset,
      slot_name: 'headshot',
      status: :active
    )

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    expect(html).to include('Jordan Rivera headshot')
    expect(html).to include('data:image/png;base64')
  end

  it 'renders Modern with consistent contact pill gaps when wrapping' do
    resume = build_resume_for(family: 'modern', accent_color: '#0F172A')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)

    contact_container = document.css('div').find { |n| n['class'].to_s.include?('flex-wrap') && n['class'].to_s.include?('gap-2') }
    expect(contact_container).to be_present
    expect(contact_container['class']).not_to include('gap-x-2')
    expect(contact_container['class']).not_to include('gap-y-1.5')
    expect(contact_container['class']).to include('items-start')
  end

  it 'renders Modern with baseline-aligned marker dots and shadowed entry cards' do
    resume = build_resume_for(family: 'modern', accent_color: '#0F172A')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)

    marker_container = document.css('div').find { |n| n['class'].to_s.include?('items-baseline') }
    expect(marker_container).to be_present

    marker_dot = marker_container&.at_css('span.rounded-full')
    expect(marker_dot).to be_present
    expect(marker_dot['class']).to include('shrink-0')

    entry_card = document.at_css('article.rounded-2xl')
    expect(entry_card).to be_present
    expect(entry_card['class']).to include('shadow-sm')
  end

  it 'renders Professional with a max-width constraint on the contact column' do
    resume = build_resume_for(family: 'professional', accent_color: '#0F4C81')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)
    contact_column = document.css('div').find { |n| n['class'].to_s.include?('sm:max-w-xs') && n['class'].to_s.include?('sm:text-right') }
    expect(contact_column).to be_present
  end

  it 'renders Sidebar Accent with consistent card radius, blended skill chips, and medium-weight contact labels' do
    resume = build_resume_for(family: 'sidebar-accent', accent_color: '#4338CA')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)

    profile_card = document.at_css('section.rounded-2xl')
    expect(profile_card).to be_present

    skill_chip = document.css('span.rounded-full').find { |n| n['style'].to_s.include?('#4338CA08') }
    expect(skill_chip).to be_present

    contact_label = document.css('aside p.font-medium.text-slate-900').first
    expect(contact_label).to be_present
  end

  it 'renders Editorial Split with larger badges, darker contact border, and scroll rail on mobile' do
    resume = build_resume_for(family: 'editorial-split', accent_color: '#D7F038')

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    document = Nokogiri::HTML.parse(html)

    desktop_badge = document.css('aside div.rounded-full.bg-slate-950').first
    expect(desktop_badge).to be_present
    expect(desktop_badge['class']).to include('h-[4.5rem]', 'w-[4.5rem]')
    expect(desktop_badge.at_css('span')['class']).to include('text-lg')

    contact_badge = document.css('div.rounded-full.border-slate-400').first
    expect(contact_badge).to be_present

    mobile_rail = document.css('aside').find { |n| n['class'].to_s.include?('overflow-x-auto') && n['class'].to_s.include?('lg:hidden') }
    expect(mobile_rail).to be_present
  end

  it 'respects hidden_sections setting and excludes hidden section content from rendered HTML' do
    resume = build_resume_for(family: 'modern', accent_color: '#0F172A')
    projects_section = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 3)
    create(:entry, section: projects_section, content: { 'name' => 'Hidden Project', 'role' => 'Lead' })

    resume.update!(settings: resume.settings.merge('hidden_sections' => [ 'projects' ]))

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    expect(html).to include('Jordan Rivera')
    expect(html).to include('Ruby on Rails')
    expect(html).not_to include('Hidden Project')
  end

  it 'renders all sections when hidden_sections is empty' do
    resume = build_resume_for(family: 'classic', accent_color: '#1D4ED8')
    projects_section = create(:section, resume: resume, title: 'Projects', section_type: 'projects', position: 3)
    create(:entry, section: projects_section, content: { 'name' => 'Visible Project', 'role' => 'Lead' })

    resume.update!(settings: resume.settings.merge('hidden_sections' => []))

    html = ApplicationController.render(
      template: 'resumes/pdf',
      layout: 'pdf',
      assigns: { resume: resume }
    )

    expect(html).to include('Visible Project')
    expect(html).to include('Ruby on Rails')
  end
end
