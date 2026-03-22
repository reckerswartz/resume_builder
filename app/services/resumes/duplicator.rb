module Resumes
  class Duplicator
    def initialize(resume:)
      @resume = resume
    end

    def call
      Resume.transaction do
        copy = resume.user.resumes.create!(
          title: "Copy of #{resume.title}",
          headline: resume.headline.to_s,
          summary: resume.summary.to_s,
          source_mode: "scratch",
          source_text: "",
          template: resume.template,
          contact_details: resume.contact_details.deep_dup,
          personal_details: resume.personal_details.deep_dup,
          intake_details: resume.intake_details.deep_dup,
          settings: resume.settings.deep_dup,
          photo_profile_id: resume.photo_profile_id
        )

        duplicate_sections(copy)
        copy
      end
    end

    private
      attr_reader :resume

      def duplicate_sections(copy)
        resume.sections.includes(:entries).find_each do |section|
          new_section = copy.sections.create!(
            title: section.title,
            section_type: section.section_type,
            position: section.position,
            settings: section.settings.deep_dup
          )

          section.entries.each do |entry|
            new_section.entries.create!(
              content: entry.content.deep_dup,
              position: entry.position
            )
          end
        end
      end
  end
end
