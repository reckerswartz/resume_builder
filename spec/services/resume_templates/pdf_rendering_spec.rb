require 'rails_helper'

RSpec.describe 'Resume template PDF rendering' do
  def build_resume_for(family:, accent_color:)
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
        'highlights' => ['Scaled template rendering across preview and PDF surfaces'],
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

    resume
  end

  {
    'ats-minimal' => '#334155',
    'professional' => '#0F4C81',
    'modern-clean' => '#0F766E',
    'sidebar-accent' => '#4338CA'
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
end
