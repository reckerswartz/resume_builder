module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice
      "border border-emerald-200/80 bg-canvas-50/95 text-emerald-800 shadow-[0_18px_40px_rgba(16,185,129,0.12)] backdrop-blur-sm"
    when :alert
      "border border-rose-200/80 bg-canvas-50/95 text-rose-700 shadow-[0_18px_40px_rgba(244,63,94,0.12)] backdrop-blur-sm"
    else
      "border border-canvas-200/80 bg-canvas-50/92 text-ink-700 shadow-[0_18px_40px_rgba(15,23,42,0.08)] backdrop-blur-sm"
    end
  end

  def nav_link_classes(active)
    base = "inline-flex items-center rounded-full border px-4 py-2 text-sm font-medium transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-aqua-200/70 focus-visible:ring-offset-2 focus-visible:ring-offset-transparent"
    active ? "#{base} border-ink-950 bg-ink-950 text-white shadow-[0_14px_30px_rgba(2,6,23,0.16)]" : "#{base} border-canvas-200/80 bg-canvas-50/90 text-ink-700 hover:border-aqua-200/80 hover:bg-canvas-50 hover:text-ink-950"
  end

  def ui_button_classes(style = :secondary, size: :md)
    base = "inline-flex items-center justify-center gap-2 rounded-full font-medium transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-aqua-200/70 focus-visible:ring-offset-2 focus-visible:ring-offset-transparent"
    size_classes = case size.to_sym
    when :sm
      "px-4 py-2.5 text-sm"
    when :lg
      "px-6 py-3.5 text-base"
    else
      "px-5 py-3 text-sm"
    end

    style_classes = case style.to_sym
    when :primary
      "border border-ink-950 bg-ink-950 text-white shadow-[0_18px_38px_rgba(2,6,23,0.18)] hover:-translate-y-0.5 hover:bg-ink-900"
    when :secondary
      "border border-canvas-200/80 bg-canvas-50/92 text-ink-900 shadow-[0_14px_32px_rgba(15,23,42,0.08)] hover:-translate-y-0.5 hover:border-aqua-200/80 hover:bg-canvas-50 hover:text-ink-950"
    when :warning
      "border border-amber-200/80 bg-canvas-50/95 text-amber-700 shadow-[0_14px_32px_rgba(245,158,11,0.1)] hover:-translate-y-0.5 hover:bg-amber-50"
    when :disabled
      "cursor-not-allowed border border-canvas-200/80 bg-canvas-100/70 text-slate-400 shadow-none"
    when :ghost
      "text-ink-700 underline decoration-canvas-300 underline-offset-4 hover:text-ink-950"
    when :danger
      "border border-rose-200/80 bg-canvas-50/95 text-rose-700 shadow-[0_14px_32px_rgba(244,63,94,0.08)] hover:-translate-y-0.5 hover:bg-rose-50"
    when :hero_primary
      "border border-white/70 bg-canvas-50 text-ink-950 shadow-[0_18px_38px_rgba(255,255,255,0.14)] hover:-translate-y-0.5 hover:bg-aqua-100/70"
    when :hero_secondary
      "border border-white/14 bg-white/8 text-white backdrop-blur-sm hover:-translate-y-0.5 hover:bg-white/12"
    else
      "border border-canvas-200/80 bg-canvas-50/92 text-ink-900 shadow-[0_14px_32px_rgba(15,23,42,0.08)] hover:-translate-y-0.5 hover:border-aqua-200/80 hover:bg-canvas-50 hover:text-ink-950"
    end

    "#{base} #{size_classes} #{style_classes}"
  end

  def ui_surface_classes(tone: :default, padding: :md, extra: nil)
    padding_classes = case padding.to_sym
    when :none
      nil
    when :sm
      "p-5"
    when :lg
      "p-8"
    else
      "p-6"
    end

    tone_classes = case tone.to_sym
    when :brand
      "atelier-panel-dark"
    when :subtle
      "atelier-panel-subtle"
    when :danger
      "relative overflow-hidden rounded-[2rem] border border-rose-200/80 bg-canvas-50/95 text-rose-900 shadow-[0_22px_60px_rgba(244,63,94,0.08)] backdrop-blur-sm"
    when :dark
      "atelier-panel-dark"
    else
      "atelier-panel"
    end

    [ padding_classes, tone_classes, extra ].compact.join(" ")
  end

  def ui_badge_classes(tone = :neutral)
    base = "inline-flex items-center rounded-full border px-3 py-1.5 text-[0.72rem] font-semibold uppercase tracking-[0.18em] backdrop-blur-sm"

    "#{base} #{ui_badge_tone_classes(tone)}"
  end

  def ui_badge_tone_classes(tone = :neutral)
    case tone.to_sym
    when :success
      "border-emerald-200/80 bg-canvas-50/95 text-emerald-700 shadow-[0_12px_28px_rgba(16,185,129,0.08)]"
    when :warning
      "border-amber-200/80 bg-canvas-50/95 text-amber-700 shadow-[0_12px_28px_rgba(245,158,11,0.08)]"
    when :danger
      "border-rose-200/80 bg-canvas-50/95 text-rose-700 shadow-[0_12px_28px_rgba(244,63,94,0.08)]"
    when :info
      "border-aqua-200/80 bg-canvas-50/95 text-ink-800 shadow-[0_12px_28px_rgba(125,211,252,0.12)]"
    when :hero
      "border-white/14 bg-white/8 text-white/80"
    when :hero_success
      "border-emerald-400/30 bg-emerald-400/10 text-emerald-100"
    else
      "border-canvas-200/80 bg-canvas-50/88 text-ink-700 shadow-[0_10px_24px_rgba(15,23,42,0.06)]"
    end
  end

  def ui_inset_panel_classes(tone: :default, padding: :md)
    padding_classes = case padding.to_sym
    when :lg
      "px-5 py-5"
    else
      "px-4 py-4"
    end

    tone_classes = case tone.to_sym
    when :success
      "border border-emerald-200/70 bg-canvas-50/90"
    when :subtle
      "border border-mist-200/80 bg-canvas-100/84"
    when :danger
      "border border-rose-200/80 bg-canvas-50/92"
    else
      "border border-canvas-200/80 bg-canvas-50/92"
    end

    [ "rounded-[1.75rem] shadow-[0_16px_36px_rgba(15,23,42,0.06)] backdrop-blur-sm", padding_classes, tone_classes ].join(" ")
  end

  def ui_selectable_card_classes(selected:, tone: :default, size: :md)
    base = "block cursor-pointer border transition shadow-[0_18px_40px_rgba(15,23,42,0.08)]"
    size_classes = case size.to_sym
    when :lg
      "rounded-[1.75rem] px-5 py-5"
    else
      "rounded-[1.5rem] p-4"
    end

    unselected_classes = case tone.to_sym
    when :subtle
      "border-mist-200/80 bg-canvas-100/88 text-ink-950 hover:-translate-y-0.5 hover:border-aqua-200/80 hover:bg-canvas-50"
    else
      "border-canvas-200/80 bg-canvas-50/92 text-ink-950 hover:-translate-y-0.5 hover:border-aqua-200/80 hover:bg-canvas-50"
    end

    selected_classes = "border-aqua-200/35 bg-ink-950 text-white shadow-[0_24px_50px_rgba(2,6,23,0.32)]"

    "#{base} #{size_classes} #{selected ? selected_classes : unselected_classes}"
  end

  def ui_selectable_eyebrow_classes(selected:)
    selected ? "text-white/55" : "text-ink-700/70"
  end

  def ui_selectable_supporting_text_classes(selected:)
    selected ? "text-white/72" : "text-ink-700/80"
  end

  def ui_selectable_indicator_classes(selected:)
    selected ? "border-white/10 bg-white/8 text-white shadow-inner shadow-white/10" : "border-canvas-200/80 bg-canvas-50/92 text-ink-700/55"
  end

  def ui_filter_chip_classes(active:)
    base = "inline-flex items-center rounded-full border px-3 py-1.5 text-[0.72rem] font-semibold uppercase tracking-[0.18em] transition backdrop-blur-sm"
    tone_classes = active ? "border-ink-950 bg-ink-950 text-white shadow-[0_14px_30px_rgba(2,6,23,0.16)]" : "border-canvas-200/80 bg-canvas-50/90 text-ink-700 hover:border-aqua-200/80 hover:bg-canvas-50 hover:text-ink-950"

    "#{base} #{tone_classes}"
  end

  def ui_label_classes
    "text-[0.72rem] font-semibold uppercase tracking-[0.18em] text-ink-700/70"
  end

  def ui_input_classes
    "mt-2 block w-full rounded-[1.5rem] border border-canvas-200/80 bg-canvas-50/92 px-4 py-3 text-sm text-ink-950 shadow-[0_14px_32px_rgba(15,23,42,0.08)] transition placeholder:text-slate-400 focus:border-aqua-200 focus:outline-none focus:ring-2 focus:ring-aqua-100/80"
  end

  def ui_checkbox_classes
    "h-5 w-5 rounded border-canvas-300 bg-canvas-50 text-ink-950 shadow-sm focus:ring-aqua-200"
  end

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
