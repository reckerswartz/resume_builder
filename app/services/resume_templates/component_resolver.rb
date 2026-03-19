module ResumeTemplates
  class ComponentResolver
    COMPONENTS = {
      "classic" => ResumeTemplates::ClassicComponent,
      "modern" => ResumeTemplates::ModernComponent
    }.freeze

    def self.component_for(resume)
      component_class_for(resume).new(resume:)
    end

    def self.component_class_for(resume)
      COMPONENTS.fetch(resume.template.slug, ResumeTemplates::ModernComponent)
    end
  end
end
