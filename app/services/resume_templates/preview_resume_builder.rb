module ResumeTemplates
  class PreviewResumeBuilder
    SAMPLE_CONTACT_DETAILS = {
      "full_name" => "Jordan Lee",
      "email" => "jordan.lee@example.com",
      "phone" => "+1 (555) 010-2458",
      "city" => "Austin",
      "country" => "United States",
      "website" => "jordancode.dev",
      "linkedin" => "linkedin.com/in/jordanlee"
    }.freeze
    SAMPLE_SETTINGS = {
      "page_size" => "A4",
      "show_contact_icons" => true
    }.freeze
    SAMPLE_HEADLINE = "Lead Product Engineer".freeze
    SAMPLE_SUMMARY = "Builds polished, ATS-friendly resume experiences with structured content, shared rendering, and fast iteration loops across product, design, and engineering.".freeze

    def initialize(template:, accent_color: nil)
      @template = template
      @accent_color = accent_color
    end

    def call
      layout_config = template.render_layout_config

      Resume.new(
        user: preview_user,
        template: template,
        title: "#{template.name} Preview",
        headline: SAMPLE_HEADLINE,
        summary: SAMPLE_SUMMARY,
        slug: "#{template.slug}-preview",
        source_mode: "scratch",
        source_text: "",
        contact_details: SAMPLE_CONTACT_DETAILS.dup,
        settings: SAMPLE_SETTINGS.merge("accent_color" => selected_accent_color(layout_config))
      ).tap do |resume|
        build_sections(resume)
      end
    end

    private
      attr_reader :accent_color, :template

      def preview_user
        @preview_user ||= User.new(email_address: "jordan.lee@example.com", role: :user)
      end

      def selected_accent_color(layout_config)
        ResumeTemplates::Catalog.normalized_accent_color(
          accent_color,
          fallback: layout_config.fetch("accent_color")
        )
      end

      def build_sections(resume)
        ResumeBuilder::SectionRegistry.starter_sections.each_with_index do |section_attributes, section_index|
          section = resume.sections.build(
            section_type: section_attributes.fetch(:section_type),
            title: section_attributes.fetch(:title),
            position: section_index
          )

          Array(section_attributes.fetch(:entries)).each_with_index do |entry_content, entry_index|
            section.entries.build(content: entry_content, position: entry_index)
          end
        end
      end
  end
end
