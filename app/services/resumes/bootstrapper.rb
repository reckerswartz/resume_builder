module Resumes
  class Bootstrapper
    def initialize(user:)
      @user = user
    end

    def call(attributes = {})
      Resume.transaction do
        resume = user.resumes.create!(
          title: attributes[:title].presence || "Untitled Resume",
          headline: attributes[:headline].to_s,
          summary: attributes[:summary].to_s,
          source_mode: attributes[:source_mode].presence || "scratch",
          source_text: attributes[:source_text].to_s,
          source_document: attributes[:source_document],
          contact_details: default_contact_details.merge(attributes[:contact_details] || {}),
          intake_details: attributes[:intake_details] || {},
          personal_details: attributes[:personal_details] || {},
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
        ResumeBuilder::SectionRegistry.starter_sections.each.with_index do |definition, index|
          section = resume.sections.create!(
            title: definition[:title],
            section_type: definition[:section_type],
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
          "linkedin" => "",
          "driving_licence" => ""
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
