module ResumeTemplates
  class BaseComponent < ApplicationComponent
    attr_reader :resume, :template

    def initialize(resume:)
      @resume = resume
      @template = resume.template
    end

    def accent_color
      template.layout_config.fetch("accent_color", "#0F172A")
    end

    def contact_items
      [
        ["Email", contact_value("email")],
        ["Phone", contact_value("phone")],
        ["Location", contact_value("location")],
        ["Website", contact_value("website")],
        ["LinkedIn", contact_value("linkedin")]
      ].reject { |_label, value| value.blank? }
    end

    def full_name
      contact_value("full_name").presence || resume.user.display_name
    end

    def section_entries(section)
      section.ordered_entries
    end

    def date_range_for(entry)
      start_date = value_for(entry, "start_date")
      end_date = value_for(entry, "end_date")
      [start_date, end_date].reject(&:blank?).join(" - ")
    end

    def value_for(entry, key)
      entry.content.fetch(key, "")
    end

    def list_values_for(entry, key)
      Array(entry.content[key])
    end

    private
      def contact_value(key)
        resume.contact_field(key)
      end
  end
end
