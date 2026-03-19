class Admin::TemplatesController < Admin::BaseController
  before_action :set_template, only: %i[ show edit update destroy ]

  def index
    @templates = policy_scope(Template).order(:name)
  end

  def show
    authorize @template
  end

  def new
    @template = Template.new(active: true, layout_config: { "variant" => "modern", "accent_color" => "#0F172A", "font_scale" => "base" })
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

    def template_params
      permitted = params.require(:template).permit(:name, :slug, :description, :active, layout_config: {})
      permitted[:layout_config] = permitted[:layout_config]&.to_h || {}
      permitted.to_h
    end
end
