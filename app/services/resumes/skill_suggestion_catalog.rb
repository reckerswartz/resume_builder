module Resumes
  class SkillSuggestionCatalog
    Entry = Data.define(
      :id,
      :role_key,
      :role_title,
      :experience_levels,
      :search_tags,
      :expert_recommended,
      :audience_key,
      :skills
    )

    State = Data.define(:query, :results)

    ROLE_CATALOG = [
      {
        key: "software_engineer",
        search_tags: %w[software engineer developer backend frontend platform rails javascript web],
        suggestions: [
          {
            key: "early_career",
            experience_levels: %w[no_experience less_than_3_years],
            expert_recommended: true,
            audience_key: "early_career"
          },
          {
            key: "growth_stage",
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "product_manager",
        search_tags: %w[product manager roadmap prioritization customer strategy owner],
        suggestions: [
          {
            key: "early_career",
            experience_levels: %w[less_than_3_years],
            expert_recommended: true,
            audience_key: "early_career"
          },
          {
            key: "growth_stage",
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "product_designer",
        search_tags: %w[product designer ux ui design prototype research figma],
        suggestions: [
          {
            key: "early_career",
            experience_levels: %w[no_experience less_than_3_years],
            expert_recommended: true,
            audience_key: "early_career"
          },
          {
            key: "growth_stage",
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "data_analyst",
        search_tags: %w[data analyst analytics sql dashboard reporting bi insights],
        suggestions: [
          {
            key: "early_career",
            experience_levels: %w[no_experience less_than_3_years],
            expert_recommended: true,
            audience_key: "early_career"
          },
          {
            key: "growth_stage",
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "marketing_strategist",
        search_tags: %w[marketing strategist content seo brand digital campaign growth],
        suggestions: [
          {
            key: "growth_stage",
            experience_levels: %w[less_than_3_years three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "customer_success_manager",
        search_tags: %w[customer success onboarding retention account client implementation support],
        suggestions: [
          {
            key: "early_career",
            experience_levels: %w[less_than_3_years three_to_five_years],
            expert_recommended: true,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "project_manager",
        search_tags: %w[project manager delivery operations coordination planning program],
        suggestions: [
          {
            key: "growth_stage",
            experience_levels: %w[less_than_3_years three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "healthcare_administrator",
        search_tags: %w[healthcare administrator medical clinical operations compliance nursing],
        suggestions: [
          {
            key: "growth_stage",
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      },
      {
        key: "finance_analyst",
        search_tags: %w[finance analyst accounting financial modeling budgeting forecasting treasury],
        suggestions: [
          {
            key: "early_career",
            experience_levels: %w[no_experience less_than_3_years],
            expert_recommended: true,
            audience_key: "early_career"
          },
          {
            key: "growth_stage",
            experience_levels: %w[three_to_five_years five_to_ten_years ten_plus_years],
            expert_recommended: false,
            audience_key: "growth_stage"
          }
        ]
      }
    ].freeze

    def initialize(resume:, query: nil)
      @resume = resume
      @query = query.to_s
    end

    def call
      result_entries = display_entries.first(4)

      State.new(
        query: display_query(result_entries),
        results: result_entries.map { |entry| presented_result(entry) }
      )
    end

    private
      attr_reader :query, :resume

      def entries
        @entries ||= ROLE_CATALOG.flat_map do |role|
          role.fetch(:suggestions).map do |suggestion|
            Entry.new(
              id: "#{role.fetch(:key)}-#{suggestion.fetch(:key)}",
              role_key: role.fetch(:key),
              role_title: role_label(role.fetch(:key)),
              experience_levels: suggestion.fetch(:experience_levels),
              search_tags: role.fetch(:search_tags),
              expert_recommended: suggestion.fetch(:expert_recommended),
              audience_key: suggestion.fetch(:audience_key),
              skills: skill_list(role.fetch(:key), suggestion.fetch(:key))
            )
          end
        end
      end

      def display_entries
        source_entries = if effective_query.present?
          search(query: effective_query, experience_level: resume.experience_level).presence || suggestions(experience_level: resume.experience_level)
        else
          suggestions(experience_level: resume.experience_level)
        end

        source_entries.uniq(&:role_key)
      end

      def suggestions(experience_level:)
        entries
          .select { |entry| matches_experience?(entry, experience_level) }
          .sort_by do |entry|
            [
              featured_rank(entry.role_key, experience_level:),
              entry.expert_recommended ? 0 : 1,
              entry.role_title
            ]
          end
      end

      def search(query:, experience_level:)
        normalized_query = normalize(query)
        return suggestions(experience_level:) if normalized_query.blank?

        suggestions(experience_level:)
          .filter_map do |entry|
            score = entry_rank(entry, normalized_query)
            next if score == 99

            [ score, entry ]
          end
          .sort_by { |score, entry| [ score, entry.expert_recommended ? 0 : 1, entry.role_title ] }
          .map(&:last)
      end

      def effective_query
        query.to_s.squish.presence
      end

      def display_query(result_entries)
        return result_entries.first.role_title if result_entries.first.present?
        return effective_query.to_s.titleize if effective_query.present?

        ""
      end

      def matches_experience?(entry, experience_level)
        normalized_level = normalize(experience_level)
        normalized_level.blank? || entry.experience_levels.include?(normalized_level)
      end

      def featured_rank(role_key, experience_level:)
        featured_role_keys(experience_level:).index(role_key) || 99
      end

      def featured_role_keys(experience_level:)
        normalized_level = normalize(experience_level)

        if %w[no_experience less_than_3_years].include?(normalized_level)
          %w[software_engineer data_analyst product_designer finance_analyst]
        else
          %w[software_engineer product_manager product_designer data_analyst]
        end
      end

      def entry_rank(entry, normalized_query)
        query_tokens = normalize_tokens(normalized_query)
        searchable_tokens = normalize_tokens([ entry.role_title, *entry.search_tags ].join(" "))

        return 0 if normalize(entry.role_title) == normalized_query
        return 1 if entry.search_tags.any? { |tag| normalize(tag) == normalized_query }

        overlap_count = (searchable_tokens & query_tokens).size
        return 2 if overlap_count >= 2
        return 3 if overlap_count == 1
        return 4 if normalize(entry.role_title).include?(normalized_query) || normalized_query.include?(normalize(entry.role_title))

        99
      end

      def role_label(role_key)
        I18n.t("resumes.skill_suggestion_catalog.role_labels.#{role_key}")
      end

      def skill_list(role_key, suggestion_key)
        Array(I18n.t("resumes.skill_suggestion_catalog.roles.#{role_key}.variants.#{suggestion_key}.skills"))
      end

      def presented_result(entry)
        {
          role_key: entry.role_key,
          role_title: entry.role_title,
          expert_recommended: entry.expert_recommended,
          audience_key: entry.audience_key,
          skills: entry.skills
        }
      end

      def normalize(value)
        value.to_s.downcase.squish
      end

      def normalize_tokens(value)
        normalize(value).split(/[^a-z0-9]+/).filter_map do |token|
          token if token.length >= 2
        end
      end
  end
end
