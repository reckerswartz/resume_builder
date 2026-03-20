module Photos
  class TemplatePromptBuilder
    def initialize(resume:, template:, source_asset:)
      @resume = resume
      @template = template
      @source_asset = source_asset
    end

    def call
      <<~PROMPT.squish
        Create a polished, professional resume portrait variation that preserves the same person's identity.
        Use the attached photo as the only identity reference.
        Resume name: #{resume.contact_field("full_name").presence || resume.user.display_name}.
        Headline: #{resume.headline.presence || "Professional profile"}.
        Template family: #{layout_config.fetch("family")}.
        Headshot supported: #{layout_config.fetch("supports_headshot")}.
        Target slot: headshot.
        Portrait shape hint: #{photo_slot_config.fetch("portrait_shape", "rounded_square")}.
        Crop style hint: #{photo_slot_config.fetch("crop_style", "cover") }.
        Background style hint: #{photo_slot_config.fetch("background_style", "studio_clean") }.
        Keep the framing suitable for a resume header, use clean professional lighting, avoid props, avoid text overlays,
        and return an edited image that remains realistic and presentation-ready.
      PROMPT
    end

    private
      attr_reader :resume, :source_asset, :template

      def layout_config
        @layout_config ||= template.normalized_layout_config
      end

      def photo_slot_config
        @photo_slot_config ||= layout_config.fetch("photo_slots", {}).fetch("headshot", {})
      end
  end
end
