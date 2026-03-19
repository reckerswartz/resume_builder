module Resumes
  class Bootstrapper
    DEFAULT_SECTIONS = {
      "experience" => {
        title: "Experience",
        entries: [
          {
            "title" => "Senior Product Designer",
            "organization" => "Acme Inc.",
            "location" => "Remote",
            "start_date" => "2022",
            "end_date" => "Present",
            "summary" => "Led cross-functional resume product improvements.",
            "highlights" => [
              "Improved conversion through iterative UX changes",
              "Partnered with engineering on scalable editor workflows"
            ]
          }
        ]
      },
      "education" => {
        title: "Education",
        entries: [
          {
            "institution" => "State University",
            "degree" => "B.S. Computer Science",
            "location" => "Boston, MA",
            "start_date" => "2016",
            "end_date" => "2020",
            "details" => "Graduated with honors."
          }
        ]
      },
      "skills" => {
        title: "Skills",
        entries: [
          { "name" => "Ruby on Rails", "level" => "Expert" },
          { "name" => "Hotwire", "level" => "Advanced" },
          { "name" => "PostgreSQL", "level" => "Advanced" }
        ]
      },
      "projects" => {
        title: "Projects",
        entries: [
          {
            "name" => "Resume Builder",
            "role" => "Lead Engineer",
            "url" => "https://example.com",
            "summary" => "Built a live-editing resume platform.",
            "highlights" => [
              "Implemented Turbo-driven split-screen editing",
              "Shared rendering between preview and export"
            ]
          }
        ]
      }
    }.freeze

    def initialize(user:)
      @user = user
    end

    def call(attributes = {})
      Resume.transaction do
        resume = user.resumes.create!(
          title: attributes[:title].presence || "Untitled Resume",
          headline: attributes[:headline].to_s,
          summary: attributes[:summary].to_s,
          contact_details: default_contact_details.merge(attributes[:contact_details] || {}),
          settings: default_settings.merge(attributes[:settings] || {}),
          template: attributes[:template] || Template.default!
        )

        build_default_sections(resume)
        resume
      end
    end

    private
      attr_reader :user

      def build_default_sections(resume)
        DEFAULT_SECTIONS.each.with_index do |(section_type, definition), index|
          section = resume.sections.create!(
            title: definition[:title],
            section_type: section_type,
            position: index,
            settings: {}
          )

          definition[:entries].each_with_index do |content, entry_index|
            section.entries.create!(content: content, position: entry_index)
          end
        end
      end

      def default_contact_details
        {
          "full_name" => user.display_name,
          "email" => user.email_address,
          "phone" => "",
          "location" => "",
          "website" => "",
          "linkedin" => ""
        }
      end

      def default_settings
        {
          "accent_color" => "#0F172A",
          "show_contact_icons" => true,
          "page_size" => "A4"
        }
      end
  end
end
