module TableHelper
  def current_table_params(*keys)
    request.query_parameters.slice(*keys.map(&:to_s)).compact_blank
  end

  def table_sort_params(column:, current_sort:, current_direction:, params: {})
    next_direction = current_sort == column && current_direction == "asc" ? "desc" : "asc"
    params.merge("sort" => column, "direction" => next_direction, "page" => nil).compact_blank
  end

  def table_sort_indicator(column, current_sort:, current_direction:)
    return unless current_sort == column

    content_tag(:span, current_direction == "asc" ? "↑" : "↓", aria: { hidden: true })
  end

  def table_page_window(current_page:, total_pages:, radius: 1)
    start_page = [ current_page - radius, 1 ].max
    end_page = [ current_page + radius, total_pages ].min

    (start_page..end_page).to_a
  end

  def table_query_path(base_path, params)
    query = params.compact_blank.to_query
    query.present? ? "#{base_path}?#{query}" : base_path
  end
end
