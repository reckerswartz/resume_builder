class Admin::TemplatesController < Admin::BaseController
  PAGE_SIZE = 10

  before_action :set_template, only: %i[ show edit update destroy ]

  def index
    @query = params[:query].to_s.strip
    @status_filter = params[:status].presence_in(%w[active inactive]).to_s
    @sort = Template.admin_sort_column(params[:sort])
    @direction = table_direction(default: "asc")

    scope = policy_scope(Template).matching_query(@query).with_active_filter(@status_filter)
    @total_count = scope.count
    @template_summary = build_template_summary(scope)
    @total_pages = table_total_pages(total_count: @total_count, per_page: PAGE_SIZE)
    @current_page = table_current_page(total_pages: @total_pages)
    @templates = scope.sorted_for_admin(@sort, @direction).offset((@current_page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
  end

  def show
    authorize @template
  end

  def new
    @template = Template.new(active: true, layout_config: ResumeTemplates::Catalog.default_layout_config)
    authorize @template
  end

  def edit
    authorize @template
  end

  def create
    @template = Template.new(template_params)
    authorize @template

    if @template.save
      redirect_to admin_template_path(@template), notice: "Template created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @template

    if @template.update(template_params)
      redirect_to admin_template_path(@template), notice: "Template updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @template

    @template.destroy!
    redirect_to admin_templates_path, notice: "Template deleted.", status: :see_other
  end

  private
    def set_template
      @template = policy_scope(Template).find(params[:id])
    end

    def build_template_summary(scope)
      summary_templates = scope.select(:id, :active, :layout_config, :name, :slug).to_a
      normalized_layouts = summary_templates.map(&:normalized_layout_config)

      {
        active_count: summary_templates.count(&:active?),
        family_count: normalized_layouts.map { |layout_config| layout_config.fetch("family") }.uniq.count,
        card_shell_count: normalized_layouts.count { |layout_config| layout_config.fetch("shell_style") == "card" },
        sidebar_layout_count: normalized_layouts.count { |layout_config| Array(layout_config["sidebar_section_types"]).any? }
      }
    end

    def template_params
      permitted = params.require(:template).permit(:name, :slug, :description, :active, layout_config: {})
      permitted[:layout_config] = permitted[:layout_config]&.to_h || {}
      permitted.to_h
    end
end
