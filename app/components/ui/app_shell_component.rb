module Ui
  class AppShellComponent < ApplicationComponent
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

    attr_reader :current_user, :authenticated, :controller_path, :controller_name

    def initialize(current_user:, authenticated:, controller_path:, controller_name:)
      @current_user = current_user
      @authenticated = authenticated
      @controller_path = controller_path.to_s
      @controller_name = controller_name.to_s
    end

    def authenticated?
      BOOLEAN_TYPE.cast(authenticated)
    end

    def admin?
      current_user&.admin?
    end

    def brand_destination
      authenticated? ? helpers.resumes_path : helpers.root_path
    end

    def header_items
      if authenticated?
        [
          nav_item("Resumes", helpers.resumes_path, controller_name == "resumes" && !controller_path.start_with?("admin/")),
          nav_item("Templates", helpers.templates_path, controller_name == "templates" && !controller_path.start_with?("admin/")),
          nav_item("New resume", helpers.new_resume_path, current_page?(helpers.new_resume_path)),
          (nav_item("Admin", helpers.admin_root_path, controller_path.start_with?("admin/")) if admin?)
        ].compact
      else
        [
          nav_item("Home", helpers.root_path, current_page?(helpers.root_path)),
          nav_item("Sign in", helpers.new_session_path, controller_name == "sessions")
        ]
      end
    end

    def sidebar_items
      return [] unless authenticated?

      items = [
        nav_item("Workspace", helpers.resumes_path, controller_name == "resumes" && !controller_path.start_with?("admin/"), "Manage drafts, previews, and exports"),
        nav_item("Templates", helpers.templates_path, controller_name == "templates" && !controller_path.start_with?("admin/"), "Compare layouts and open live previews"),
        nav_item("Create resume", helpers.new_resume_path, current_page?(helpers.new_resume_path), "Start a new draft in a few steps")
      ]

      if admin?
        items.concat(
          [
            nav_item("Admin overview", helpers.admin_root_path, controller_path == "admin/dashboard", "Platform health and operational triage"),
            nav_item("Templates", helpers.admin_templates_path, controller_path.start_with?("admin/templates"), "Template records and visibility"),
            nav_item("LLM providers", helpers.admin_llm_providers_path, controller_path.start_with?("admin/llm_providers"), "Provider readiness and sync state"),
            nav_item("LLM models", helpers.admin_llm_models_path, controller_path.start_with?("admin/llm_models"), "Model availability and assignment"),
            nav_item("Settings", helpers.admin_settings_path, controller_path == "admin/settings", "Feature flags and workflow defaults"),
            nav_item("Job logs", helpers.admin_job_logs_path, controller_path.start_with?("admin/job_logs"), "Background execution history"),
            nav_item("Error logs", helpers.admin_error_logs_path, controller_path.start_with?("admin/error_logs"), "Captured incidents and related jobs")
          ]
        )
      end

      items.compact
    end

    def current_area_label
      return "Admin hub" if controller_path.start_with?("admin/")
      return "Template gallery" if controller_name == "templates" && !controller_path.start_with?("admin/")

      if controller_name == "resumes"
        return "New resume" if current_page?(helpers.new_resume_path)

        return "Resume workspace"
      end

      "Signed-in workspace"
    end

    def current_area_description
      return "Track platform health, review templates, and keep background work moving from one control hub." if controller_path.start_with?("admin/")
      return "Compare layout options, open live previews, and choose a strong starting point for the next draft." if controller_name == "templates" && !controller_path.start_with?("admin/")

      if controller_name == "resumes"
        return "Start with a draft, choose a layout, and move into guided editing with fewer setup decisions." if current_page?(helpers.new_resume_path)

        return "Move between drafting, previewing, and exporting without losing track of your next step."
      end

      "Move between resumes, templates, and admin tools from one shared shell."
    end

    def brand_supporting_text
      authenticated? ? "Guided resumes and admin tools" : "Build polished resumes faster"
    end

    def current_area_badges
      [
        (admin? ? "Admin access" : "Signed in"),
        (controller_path.start_with?("admin/") ? "Reporting shell" : "Guided workspace")
      ]
    end

    def wrapper_classes
      authenticated? ? "relative z-10 mx-auto flex w-full max-w-[100rem] gap-5 px-4 py-5 sm:px-6 lg:px-8" : "relative z-10 mx-auto flex w-full max-w-7xl flex-1 flex-col px-4 py-10 sm:px-6 lg:px-8"
    end

    def main_classes
      authenticated? ? "min-w-0 flex-1 space-y-5 pb-8" : "w-full"
    end

    def header_link_classes(active)
      base = "inline-flex items-center rounded-full border px-4 py-2 text-sm font-medium transition backdrop-blur-sm"

      if active
        "#{base} border-white/70 bg-canvas-50 text-ink-950 shadow-[0_16px_34px_rgba(255,255,255,0.12)]"
      else
        "#{base} border-white/10 bg-white/4 text-white/72 hover:border-white/16 hover:bg-white/8 hover:text-white"
      end
    end

    def sidebar_link_classes(active)
      base = "block rounded-[1.35rem] border px-4 py-3.5 transition backdrop-blur-sm"
      active ? "#{base} border-aqua-200/35 bg-ink-950 text-white shadow-[0_24px_50px_rgba(2,6,23,0.28)]" : "#{base} border-canvas-200/80 bg-canvas-50/92 text-ink-700 hover:-translate-y-0.5 hover:border-aqua-200/80 hover:bg-canvas-50 hover:text-ink-950"
    end

    private
      def nav_item(label, path, active, caption = nil)
        { label: label, path: path, active: active, caption: caption }
      end

      def current_page?(path)
        helpers.current_page?(path)
      rescue StandardError
        false
      end
  end
end
