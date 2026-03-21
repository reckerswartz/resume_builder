module Resumes
  class DraftBuilder
    def initialize(user:, template:, attributes: {})
      @user = user
      @template = template
      @attributes = attributes.to_h.symbolize_keys
    end

    def call
      user.resumes.build(
        title: attributes[:title].presence || I18n.t("resumes.controller.untitled_resume_title"),
        headline: attributes[:headline],
        summary: attributes[:summary],
        source_mode: attributes[:source_mode].presence || "scratch",
        source_text: attributes[:source_text].to_s,
        source_document: attributes[:source_document],
        headshot: attributes[:headshot],
        template: template,
        contact_details: {
          "full_name" => user.display_name,
          "email" => user.email_address
        },
        intake_details: attributes[:intake_details] || {},
        personal_details: attributes[:personal_details] || {},
        settings: default_settings.merge(attributes.fetch(:settings, {}).to_h.deep_stringify_keys)
      )
    end

    private
      attr_reader :attributes, :template, :user

      def default_settings
        {
          "accent_color" => template.render_layout_config.fetch("accent_color"),
          "show_contact_icons" => true,
          "page_size" => Resume::DEFAULT_PAGE_SIZE
        }
      end
  end
end
