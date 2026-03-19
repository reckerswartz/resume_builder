module Admin::TemplatesHelper
  def template_badge_classes(template)
    template.active? ? "bg-emerald-50 text-emerald-700 border border-emerald-200" : "bg-slate-100 text-slate-600 border border-slate-200"
  end
end
