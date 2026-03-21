module ResumeTemplates
  class ComponentResolver
    def self.component_for(resume)
      component_class_for(resume).new(resume:)
    end

    def self.component_class_for(resume)
      ResumeTemplates::Catalog.component_class_for(resume.template.render_layout_config, fallback_family: resume.template.slug)
    end
  end
end
