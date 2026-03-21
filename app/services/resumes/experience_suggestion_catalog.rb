module Resumes
  class ExperienceSuggestionCatalog
    Entry = Data.define(
      :id,
      :role_key,
      :role_title,
      :experience_levels,
      :student_statuses,
      :search_tags,
      :expert_recommended,
      :audience_key,
      :highlights
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
        key: "internship",
        search_tags: %w[intern internship trainee apprentice fellowship campus student],
        suggestions: [
          {
            key: "early_career",
            experience_levels: %w[no_experience less_than_3_years],
            expert_recommended: true,
            audience_key: "early_career"
          }
        ]
      },
      {
        key: "teaching_assistant",
        search_tags: %w[teaching assistant ta instructor classroom course university student],
        suggestions: [
          {
            key: "student_support",
            experience_levels: %w[no_experience less_than_3_years three_to_five_years],
            student_statuses: %w[student],
            expert_recommended: true,
            audience_key: "student_friendly"
          }
        ]
      },
      {
        key: "tutor",
        search_tags: %w[tutor tutoring mentor peer academic coach student],
        suggestions: [
          {
            key: "student_support",
            experience_levels: %w[no_experience less_than_3_years three_to_five_years],
            student_statuses: %w[student],
            expert_recommended: false,
            audience_key: "student_friendly"
          }
        ]
      },
      {
        key: "volunteer_experience",
        search_tags: %w[volunteer volunteering nonprofit outreach community program coordinator],
        suggestions: [
          {
            key: "community",
            experience_levels: %w[no_experience less_than_3_years three_to_five_years],
            expert_recommended: false,
            audience_key: "community"
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
              student_statuses: suggestion.fetch(:student_statuses, []),
              search_tags: role.fetch(:search_tags),
              expert_recommended: suggestion.fetch(:expert_recommended),
              audience_key: suggestion.fetch(:audience_key),
              highlights: highlight_list(role.fetch(:key), suggestion.fetch(:key))
            )
          end
        end
      end

      def display_entries
        source_entries = if effective_query.present?
          search(query: effective_query, experience_level: resume.experience_level, student_status: resume.student_status).presence || suggestions(experience_level: resume.experience_level, student_status: resume.student_status)
        else
          suggestions(experience_level: resume.experience_level, student_status: resume.student_status)
        end

        source_entries.uniq(&:role_key)
      end

      def suggestions(experience_level:, student_status:)
        entries
          .select { |entry| matches_context?(entry, experience_level, student_status) }
          .sort_by do |entry|
            [
              featured_rank(entry.role_key, experience_level:, student_status:),
              entry.expert_recommended ? 0 : 1,
              entry.role_title
            ]
          end
      end

      def search(query:, experience_level:, student_status:)
        normalized_query = normalize(query)
        return suggestions(experience_level:, student_status:) if normalized_query.blank?

        suggestions(experience_level:, student_status:)
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

      def matches_context?(entry, experience_level, student_status)
        matches_experience?(entry, experience_level) && matches_student_status?(entry, student_status)
      end

      def matches_experience?(entry, experience_level)
        normalized_level = normalize(experience_level)
        normalized_level.blank? || entry.experience_levels.include?(normalized_level)
      end

      def matches_student_status?(entry, student_status)
        return true if entry.student_statuses.empty?

        entry.student_statuses.include?(normalize(student_status))
      end

      def featured_rank(role_key, experience_level:, student_status:)
        featured_role_keys(experience_level:, student_status:).index(role_key) || 99
      end

      def featured_role_keys(experience_level:, student_status:)
        normalized_level = normalize(experience_level)
        normalized_student_status = normalize(student_status)

        if %w[no_experience less_than_3_years].include?(normalized_level)
          return %w[teaching_assistant tutor internship volunteer_experience] if normalized_student_status == "student"

          return %w[internship volunteer_experience customer_success_manager project_manager]
        end

        %w[software_engineer product_manager product_designer data_analyst]
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
        I18n.t("resumes.experience_suggestion_catalog.role_labels.#{role_key}")
      end

      def highlight_list(role_key, suggestion_key)
        Array(I18n.t("resumes.experience_suggestion_catalog.roles.#{role_key}.variants.#{suggestion_key}.highlights"))
      end

      def presented_result(entry)
        {
          role_key: entry.role_key,
          role_title: entry.role_title,
          expert_recommended: entry.expert_recommended,
          audience_key: entry.audience_key,
          highlights: entry.highlights
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
