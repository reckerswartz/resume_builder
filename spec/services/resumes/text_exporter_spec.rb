require 'rails_helper'

RSpec.describe Resumes::TextExporter do
  describe '#call' do
    it 'serializes core resume details and ordered sections into plain text' do
      resume = create(
        :resume,
        title: 'Product Resume',
        headline: 'Senior Product Engineer',
        summary: 'Builds workflow systems.',
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com',
          'phone' => '555-0100',
          'city' => 'Pune',
          'country' => 'India',
          'pin_code' => '411001',
          'website' => 'https://example.com',
          'linkedin' => 'linkedin.com/in/patkumar',
          'location' => '',
          'driving_licence' => ''
        }
      )
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience')
      skills_section = create(:section, resume:, section_type: 'skills', title: 'Skills')
      create(
        :entry,
        section: experience_section,
        content: {
          'title' => 'Senior Product Engineer',
          'organization' => 'Acme',
          'location' => 'Remote',
          'remote' => true,
          'start_date' => '2022',
          'end_date' => '',
          'current_role' => true,
          'summary' => 'Led the guided builder rollout.',
          'highlights' => ['Built workflow systems', 'Shipped export improvements']
        }
      )
      create(:entry, section: skills_section, content: { 'name' => 'Ruby on Rails', 'level' => 'Expert' })

      text_export = described_class.new(resume: resume).call

      expect(text_export).to include('Product Resume')
      expect(text_export).to include('Senior Product Engineer')
      expect(text_export).to include('Pat Kumar | pat@example.com | 555-0100 | Pune, India 411001 | https://example.com | linkedin.com/in/patkumar')
      expect(text_export).to include("SUMMARY\nBuilds workflow systems.")
      expect(text_export).to include('Experience')
      expect(text_export).to include('Senior Product Engineer - Acme')
      expect(text_export).to include('2022 - Present | Remote | Remote')
      expect(text_export).to include('Led the guided builder rollout.')
      expect(text_export).to include('- Built workflow systems')
      expect(text_export).to include('- Shipped export improvements')
      expect(text_export).to include('Skills')
      expect(text_export).to include('Ruby on Rails - Expert')
    end
  end
end
