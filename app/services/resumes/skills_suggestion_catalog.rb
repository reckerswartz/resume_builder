module Resumes
  class SkillsSuggestionCatalog
    Suggestion = Data.define(:id, :category_key, :category_label, :skills, :experience_levels, :strength_order, :audience_key)
    State = Data.define(:query, :results)

    CATEGORY_CATALOG = [
      {
        key: "software_engineering",
        search_tags: %w[software engineer developer backend frontend rails javascript web python java],
        suggestions: [
          { key: "early_career", experience_levels: %w[no_experience less_than_3_years], audience_key: "early_career",
            skills: %w[JavaScript Python SQL Git HTML/CSS React REST\ APIs Testing Problem\ Solving Communication] },
          { key: "growth_stage", experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years], audience_key: "growth_stage",
            skills: %w[System\ Design Architecture Cloud\ Infrastructure CI/CD Mentoring Performance\ Optimization Security Cross-functional\ Leadership Technical\ Writing Strategic\ Planning] }
        ]
      },
      {
        key: "product_management",
        search_tags: %w[product manager roadmap prioritization strategy owner stakeholder],
        suggestions: [
          { key: "early_career", experience_levels: %w[no_experience less_than_3_years], audience_key: "early_career",
            skills: %w[User\ Research Data\ Analysis Roadmapping Agile/Scrum Wireframing Stakeholder\ Communication A/B\ Testing SQL Presentation Problem\ Solving] },
          { key: "growth_stage", experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years], audience_key: "growth_stage",
            skills: %w[Product\ Strategy Go-to-Market Revenue\ Optimization OKR\ Framework Cross-functional\ Leadership Market\ Analysis P&L\ Ownership Executive\ Communication Team\ Building Strategic\ Partnerships] }
        ]
      },
      {
        key: "design",
        search_tags: %w[designer ux ui product design figma prototype research visual],
        suggestions: [
          { key: "early_career", experience_levels: %w[no_experience less_than_3_years], audience_key: "early_career",
            skills: %w[Figma Wireframing User\ Research Prototyping Visual\ Design Typography Color\ Theory Responsive\ Design Usability\ Testing Collaboration] },
          { key: "growth_stage", experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years], audience_key: "growth_stage",
            skills: %w[Design\ Systems Information\ Architecture Accessibility Design\ Strategy User\ Psychology Workshop\ Facilitation Stakeholder\ Management Design\ Ops Team\ Mentoring Brand\ Strategy] }
        ]
      },
      {
        key: "data_analytics",
        search_tags: %w[data analyst analytics sql dashboard reporting bi insights science],
        suggestions: [
          { key: "early_career", experience_levels: %w[no_experience less_than_3_years], audience_key: "early_career",
            skills: %w[SQL Excel/Sheets Python Tableau Data\ Cleaning Statistical\ Analysis A/B\ Testing Visualization Communication Attention\ to\ Detail] },
          { key: "growth_stage", experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years], audience_key: "growth_stage",
            skills: %w[Machine\ Learning Data\ Pipeline\ Design Cloud\ Platforms Predictive\ Modeling Stakeholder\ Reporting Data\ Governance ETL\ Architecture Team\ Leadership Business\ Intelligence Strategic\ Insights] }
        ]
      },
      {
        key: "marketing",
        search_tags: %w[marketing content social media seo digital brand growth campaign],
        suggestions: [
          { key: "early_career", experience_levels: %w[no_experience less_than_3_years], audience_key: "early_career",
            skills: %w[Social\ Media Content\ Writing SEO Email\ Marketing Google\ Analytics Canva Copywriting Campaign\ Coordination Market\ Research Communication] },
          { key: "growth_stage", experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years], audience_key: "growth_stage",
            skills: %w[Brand\ Strategy Growth\ Marketing Marketing\ Automation Conversion\ Optimization Budget\ Management Team\ Leadership Demand\ Generation Partner\ Marketing Attribution\ Modeling Executive\ Storytelling] }
        ]
      },
      {
        key: "general",
        search_tags: %w[general business administration operations coordinator assistant],
        suggestions: [
          { key: "early_career", experience_levels: %w[no_experience less_than_3_years], audience_key: "early_career",
            skills: %w[Microsoft\ Office Communication Organization Time\ Management Customer\ Service Problem\ Solving Teamwork Adaptability Attention\ to\ Detail Research] },
          { key: "growth_stage", experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years], audience_key: "growth_stage",
            skills: %w[Project\ Management Process\ Improvement Stakeholder\ Management Budget\ Planning Strategic\ Thinking Leadership Negotiation Change\ Management Cross-functional\ Coordination Mentoring] }
        ]
      }
    ].freeze

    def initialize(resume:, query: nil)
      @resume = resume
      @query = query.to_s
    end

    def call
      result_suggestions = display_suggestions.first(3)

      State.new(
        query: display_query(result_suggestions),
        results: result_suggestions
      )
    end

    private

    attr_reader :query, :resume

    def suggestions
      @suggestions ||= CATEGORY_CATALOG.flat_map do |category|
        category.fetch(:suggestions).map do |suggestion|
          Suggestion.new(
            id: "#{category.fetch(:key)}-#{suggestion.fetch(:key)}",
            category_key: category.fetch(:key),
            category_label: I18n.t("resumes.skills_suggestion_catalog.category_labels.#{category.fetch(:key)}"),
            skills: suggestion.fetch(:skills),
            experience_levels: suggestion.fetch(:experience_levels),
            strength_order: suggestion.fetch(:skills).each_with_index.map { |skill, i| { skill: skill, rank: i + 1 } },
            audience_key: suggestion.fetch(:audience_key)
          )
        end
      end
    end

    def display_suggestions
      if effective_query.present?
        search_suggestions.presence || context_suggestions
      else
        context_suggestions
      end
    end

    def context_suggestions
      suggestions
        .select { |s| matches_experience?(s) }
        .sort_by { |s| featured_rank(s.category_key) }
    end

    def search_suggestions
      normalized = normalize(effective_query)
      return context_suggestions if normalized.blank?

      context_suggestions.select do |s|
        CATEGORY_CATALOG.find { |c| c[:key] == s.category_key }&.fetch(:search_tags, [])&.any? { |tag| normalize(tag).include?(normalized) || normalized.include?(normalize(tag)) }
      end
    end

    def matches_experience?(suggestion)
      level = normalize(resume.experience_level)
      level.blank? || suggestion.experience_levels.include?(level)
    end

    def featured_rank(category_key)
      if early_career?
        %w[general software_engineering marketing data_analytics design product_management].index(category_key) || 99
      else
        %w[software_engineering product_management design data_analytics marketing general].index(category_key) || 99
      end
    end

    def early_career?
      %w[no_experience less_than_3_years].include?(normalize(resume.experience_level))
    end

    def effective_query
      query.to_s.squish.presence || resume.headline.to_s.squish.presence
    end

    def display_query(results)
      results.first&.category_label || ""
    end

    def normalize(value)
      value.to_s.downcase.squish
    end
  end
end
