module ResumeTemplates
  class RenderProfileResolver
    def initialize(template:)
      @template = template
    end

    def call
      ResumeTemplates::Catalog.normalize_layout_config(
        source_profile,
        fallback_family: source_family
      )
    end

    def current_implementation
      @current_implementation ||= template.template_implementations.render_ready.most_recent_first.first
    end

    private
      attr_reader :template

      def source_profile
        current_implementation&.render_profile.presence || template.layout_config
      end

      def source_family
        current_implementation&.renderer_family.presence || template.slug
      end
  end
end
