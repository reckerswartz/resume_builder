module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice
      "border border-emerald-200 bg-emerald-50 text-emerald-800"
    when :alert
      "border border-rose-200 bg-rose-50 text-rose-800"
    else
      "border border-slate-200 bg-white text-slate-700"
    end
  end

  def nav_link_classes(active)
    base = "rounded-full px-4 py-2 text-sm font-medium transition"
    active ? "#{base} bg-slate-900 text-white" : "#{base} text-slate-600 hover:bg-slate-100 hover:text-slate-900"
  end
end
