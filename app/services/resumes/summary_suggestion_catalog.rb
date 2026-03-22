module Resumes
  class SummarySuggestionCatalog
    Entry = Data.define(:id, :role_key, :role_label, :experience_levels, :related_roles, :expert_recommended, :badge_label, :summary) do
      def search_text
        [ role_label, *related_roles, summary ].join(" ").downcase
      end
    end

    State = Data.define(:query, :results, :related_roles)

    ROLE_CATALOG = [
      {
        key: "software_engineer",
        label: "Software Engineer",
        related_roles: [ "Backend Engineer", "Full Stack Developer", "Platform Engineer" ],
        suggestions: [
          {
            experience_levels: %w[no_experience less_than_3_years three_to_five_years],
            expert_recommended: true,
            badge_label: "Recommended for early career",
            summary: "An early-career software engineer building Rails and JavaScript features with a focus on product quality, maintainable systems, and clear collaboration across design, support, and operations teams."
          },
          {
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            summary: "Senior software engineer leading end-to-end delivery across web platforms, mentoring teammates, and improving reliability, developer experience, and customer-facing workflows at scale."
          }
        ]
      },
      {
        key: "product_manager",
        label: "Product Manager",
        related_roles: [ "Project Manager", "Customer Success Manager", "Product Owner" ],
        suggestions: [
          {
            experience_levels: %w[less_than_3_years three_to_five_years],
            expert_recommended: true,
            summary: "Product manager translating customer needs into clear priorities, making cross-functional product decisions with design and engineering partners, and using product signals to guide iteration and adoption."
          },
          {
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            summary: "Strategic product manager aligning roadmap bets to business goals, leading cross-functional product decisions, and turning ambiguous operational or customer problems into measurable product outcomes."
          }
        ]
      },
      {
        key: "product_designer",
        label: "Product Designer",
        related_roles: [ "UX Designer", "UI Designer", "Design Systems Designer" ],
        suggestions: [
          {
            experience_levels: %w[no_experience less_than_3_years three_to_five_years],
            expert_recommended: true,
            summary: "Product designer crafting intuitive user journeys, translating research insights into polished interface decisions, and collaborating closely with product and engineering to improve usability."
          },
          {
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            summary: "Senior product designer shaping end-to-end experiences, driving design systems consistency, and balancing customer insight, visual clarity, and implementation constraints across complex workflows."
          }
        ]
      },
      {
        key: "data_analyst",
        label: "Data Analyst",
        related_roles: [ "Business Analyst", "Analytics Engineer", "Data Scientist" ],
        suggestions: [
          {
            experience_levels: %w[no_experience less_than_3_years three_to_five_years],
            expert_recommended: true,
            summary: "Data analyst turning raw operational and product data into clear reporting, actionable insights, and decision-ready dashboards that help teams improve performance and spot trends quickly."
          },
          {
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            summary: "Analytical problem solver combining SQL, BI tooling, and stakeholder partnership to build trusted reporting layers, explain business performance, and guide operational prioritization."
          }
        ]
      },
      {
        key: "customer_success_manager",
        label: "Customer Success Manager",
        related_roles: [ "Account Manager", "Implementation Specialist", "Client Success Lead" ],
        suggestions: [
          {
            experience_levels: %w[less_than_3_years three_to_five_years],
            expert_recommended: true,
            summary: "Customer success manager focused on onboarding, adoption, and retention, known for building trusted client relationships, resolving issues quickly, and turning feedback into better account outcomes."
          },
          {
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            summary: "Client success leader partnering with strategic accounts to grow product adoption, coordinate cross-functional escalations, and strengthen renewal confidence through proactive planning and communication."
          }
        ]
      },
      {
        key: "project_manager",
        label: "Project Manager",
        related_roles: [ "Program Manager", "Operations Manager", "Delivery Manager" ],
        suggestions: [
          {
            experience_levels: %w[less_than_3_years three_to_five_years],
            expert_recommended: false,
            summary: "Project manager improving planning, reporting, and team coordination by tightening execution, clarifying responsibilities, and removing friction across cross-functional delivery workflows."
          },
          {
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: true,
            summary: "Project leader streamlining complex programs, building scalable team processes, and aligning cross-functional execution so business priorities move faster with better visibility and accountability."
          }
        ]
      }
    ].freeze

    def initialize(resume: nil, query: nil)
      @resume = resume
      @query = query
    end

    def call
      result_entries = display_entries.first(4)

      State.new(
        query: display_query(result_entries),
        results: result_entries.map { |entry| presented_result(entry) },
        related_roles: related_role_chips(result_entries.first)
      )
    end

    def suggestions(experience_level: nil, prioritize_query: nil)
      filtered_entries = entries.select { |entry| experience_match?(entry, experience_level) }
      return filtered_entries if normalize(prioritize_query).blank?

      filtered_entries.sort_by do |entry|
        [ entry_rank(entry, prioritize_query), entry.role_label, entry.id ]
      end
    end

    def search(query:, experience_level: nil)
      normalized_query = normalize(query)
      return suggestions(experience_level:) if normalized_query.blank?

      suggestions(experience_level:)
        .filter_map do |entry|
          score = entry_rank(entry, normalized_query)
          next if score == 4

          [ score, entry ]
        end
        .sort_by { |score, entry| [ score, entry.role_label, entry.id ] }
        .map(&:last)
    end

    def related_roles(query:, experience_level: nil, limit: 4)
      matched_role = roles_matching_query(query).find { |role| role_supported_for_experience?(role, experience_level) }
      return featured_roles(experience_level:, limit:) if matched_role.blank?

      [ matched_role.fetch(:label), *matched_role.fetch(:related_roles) ].uniq.first(limit)
    end

    def featured_roles(experience_level: nil, limit: 4)
      ROLE_CATALOG
        .select { |role| role_supported_for_experience?(role, experience_level) }
        .first(limit)
        .map { |role| role.fetch(:label) }
    end

    private
      attr_reader :query, :resume

      def entries
        @entries ||= ROLE_CATALOG.flat_map do |role|
          role.fetch(:suggestions).each_with_index.map do |suggestion, index|
            Entry.new(
              id: "#{role.fetch(:key)}-#{index}",
              role_key: role.fetch(:key),
              role_label: role.fetch(:label),
              experience_levels: suggestion.fetch(:experience_levels),
              related_roles: role.fetch(:related_roles),
              expert_recommended: suggestion.fetch(:expert_recommended),
              badge_label: suggestion.fetch(:badge_label, "Curated"),
              summary: suggestion.fetch(:summary)
            )
          end
        end
      end

      def display_entries
        source_entries = if effective_query.present?
          search(query: effective_query, experience_level: resume.experience_level)
        else
          suggestions(experience_level: resume.experience_level)
        end

        source_entries.uniq(&:role_key)
      end

      def effective_query
        query.to_s.squish.presence || resume.headline.to_s.squish.presence
      end

      def display_query(result_entries)
        return result_entries.first.role_label if result_entries.first.present?
        return effective_query.to_s.titleize if effective_query.present?

        ""
      end

      def presented_result(entry)
        {
          role_key: entry.role_key,
          role_title: entry.role_label,
          badge_label: entry.badge_label,
          summary: entry.summary
        }
      end

      def related_role_chips(entry)
        role_labels = if entry.present?
          entry.related_roles
        else
          featured_roles(experience_level: resume.experience_level)
        end

        role_labels.first(4).map { |role_label| related_role_chip(role_label) }
      end

      def related_role_chip(role_label)
        role = role_for_label(role_label)
        title = role&.fetch(:label) || role_label

        {
          role_key: role&.fetch(:key) || title.parameterize(separator: "_"),
          title: title,
          query: title
        }
      end

      def role_for_label(role_label)
        ROLE_CATALOG.find { |role| normalize(role.fetch(:label)) == normalize(role_label) }
      end

      def experience_match?(entry, experience_level)
        normalized_level = normalize(experience_level)
        normalized_level.blank? || entry.experience_levels.include?(normalized_level)
      end

      def role_supported_for_experience?(role, experience_level)
        normalized_level = normalize(experience_level)
        return true if normalized_level.blank?

        role.fetch(:suggestions).any? do |suggestion|
          suggestion.fetch(:experience_levels).include?(normalized_level)
        end
      end

      def roles_matching_query(query)
        normalized_query = normalize(query)
        return [] if normalized_query.blank?

        ROLE_CATALOG
          .select { |role| role_search_text(role).include?(normalized_query) }
          .sort_by { |role| [ role_rank(role, normalized_query), role.fetch(:label) ] }
      end

      def entry_rank(entry, query)
        normalized_query = normalize(query)
        return 99 if normalized_query.blank?

        searchable_terms = [ entry.role_label, *entry.related_roles ].map { |value| normalize(value) }

        return 0 if searchable_terms.any? { |term| term == normalized_query }
        return 1 if searchable_terms.any? { |term| term.start_with?(normalized_query) || normalized_query.start_with?(term) }
        return 2 if searchable_terms.any? { |term| term.include?(normalized_query) || normalized_query.include?(term) }
        return 3 if normalize(entry.summary).include?(normalized_query)

        4
      end

      def role_rank(role, query)
        normalized_query = normalize(query)
        searchable_terms = [ role.fetch(:label), *role.fetch(:related_roles) ].map { |value| normalize(value) }

        return 0 if searchable_terms.any? { |term| term == normalized_query }
        return 1 if searchable_terms.any? { |term| term.start_with?(normalized_query) || normalized_query.start_with?(term) }
        return 2 if searchable_terms.any? { |term| term.include?(normalized_query) || normalized_query.include?(term) }

        3
      end

      def role_search_text(role)
        [ role.fetch(:label), *role.fetch(:related_roles) ].join(" ").downcase
      end

      def normalize(value)
        value.to_s.squish.downcase
      end
  end
end
