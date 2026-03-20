module Ui
  class SurfaceCardComponent < ApplicationComponent
    attr_reader :tone, :padding, :tag_name, :extra_classes, :html_options

    def initialize(tone: :default, padding: :md, tag: :section, extra_classes: nil, html_options: {})
      @tone = tone
      @padding = padding
      @tag_name = tag
      @extra_classes = extra_classes
      @html_options = html_options
    end

    def call
      resolved_html_options = html_options.deep_dup
      resolved_html_options[:class] = [ helpers.ui_surface_classes(tone:, padding:, extra: extra_classes), resolved_html_options[:class] ].compact.join(" ")

      helpers.content_tag(tag_name, content, **resolved_html_options)
    end
  end
end
