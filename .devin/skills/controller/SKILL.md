---
name: controller
description: >-
  Creates thin, RESTful Rails controllers with TDD approach - request spec first,
  then implementation. Handles strong parameters, Pundit authorization, Turbo Stream
  responses, and proper error handling. Use when creating controllers, adding actions,
  implementing CRUD, or when working with routes, endpoints, or request handling.
argument-hint: "[ResourceName] [actions: index,show,create,...]"
triggers:
  - user
  - model
---

# Rails Controller Skill (TDD)

Creates RESTful controllers following project conventions with request specs first.

## Tech Stack

Ruby 3.3, Rails 8.1, Hotwire (Turbo + Stimulus), PostgreSQL, Pundit, RSpec, Pagy

## Architecture Context

| Directory | Role |
|-----------|------|
| `app/controllers/` | Controllers (CREATE and MODIFY) |
| `app/services/` | Business Services (READ and CALL) |
| `app/queries/` | Query Objects (READ and CALL) |
| `app/presenters/` | Presenters (READ and USE) |
| `app/models/` | ActiveRecord Models (READ) |
| `app/policies/` | Pundit Policies (READ and VERIFY) |
| `spec/requests/` | Request specs (CREATE and MODIFY) |
| `spec/factories/` | FactoryBot Factories (READ and MODIFY) |

## TDD Workflow

### Step 1: Write Failing Request Spec (RED)

```ruby
# spec/requests/[resources]_spec.rb
RSpec.describe "[Resources]", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user, scope: :user }

  describe "GET /[resources]" do
    let!(:resource) { create(:[resource], account: user.account) }
    let!(:other_resource) { create(:[resource], account: other_user.account) }

    it "returns http success" do
      get [resources]_path
      expect(response).to have_http_status(:success)
    end

    it "shows only current_user's resources (multi-tenant)" do
      get [resources]_path
      expect(response.body).to include(resource.name)
      expect(response.body).not_to include(other_resource.name)
    end
  end

  describe "GET /[resources]/:id" do
    let!(:resource) { create(:[resource], account: user.account) }

    it "returns http success" do
      get [resource]_path(resource)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /[resources]" do
    let(:valid_params) { { [resource]: attributes_for(:[resource]) } }

    it "creates a new resource" do
      expect {
        post [resources]_path, params: valid_params
      }.to change([Resource], :count).by(1)
    end

    it "assigns to current_account" do
      post [resources]_path, params: valid_params
      expect([Resource].last.account).to eq(user.account)
    end
  end

  describe "authorization" do
    let!(:other_resource) { create(:[resource], account: other_user.account) }

    it "returns 404 for unauthorized access" do
      get [resource]_path(other_resource)
      expect(response).to have_http_status(:not_found)
    end
  end
end
```

### Step 2: Run Spec (Confirm RED)

```bash
bundle exec rspec spec/requests/[resources]_spec.rb
```

### Step 3: Implement Controller (GREEN)

```ruby
# app/controllers/[resources]_controller.rb
class [Resources]Controller < ApplicationController
  before_action :set_[resource], only: [:show, :edit, :update, :destroy]

  def index
    authorize [Resource], :index?
    @pagy, resources = pagy(policy_scope([Resource]).order(created_at: :desc))
    @[resources] = resources.map { |r| [Resource]Presenter.new(r) }
  end

  def show
    authorize @[resource]
    @[resource] = [Resource]Presenter.new(@[resource])
  end

  def new
    @[resource] = current_account.[resources].build
    authorize @[resource]
  end

  def create
    @[resource] = current_account.[resources].build([resource]_params)
    authorize @[resource]

    if @[resource].save
      redirect_to [resources]_path, notice: "[Resource] created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @[resource]
  end

  def update
    authorize @[resource]

    if @[resource].update([resource]_params)
      redirect_to @[resource], notice: "[Resource] updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @[resource]
    @[resource].destroy
    redirect_to [resources]_path, notice: "[Resource] deleted successfully"
  end

  private

  def set_[resource]
    @[resource] = policy_scope([Resource]).find(params[:id])
  end

  def [resource]_params
    params.require(:[resource]).permit(:name, :field1, :field2)
  end
end
```

### Step 4: Run Spec (Confirm GREEN)

```bash
bundle exec rspec spec/requests/[resources]_spec.rb
```

## Controller Design Principles

### Thin Controllers

Controllers should be **thin** - they orchestrate, they don't implement business logic. Delegate to services for anything complex.

**Good - Thin controller with service delegation:**
```ruby
class EntitiesController < ApplicationController
  def create
    authorize Entity

    result = Entities::CreateService.call(
      user: current_user,
      params: entity_params
    )

    if result.success?
      redirect_to result.data, notice: "Entity created successfully."
    else
      @entity = Entity.new(entity_params)
      @entity.errors.merge!(result.error)
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Bad - Fat controller with business logic:**
```ruby
class EntitiesController < ApplicationController
  def create
    @entity = Entity.new(entity_params)
    @entity.user = current_user
    @entity.status = 'pending'

    # Business logic in controller - BAD!
    if @entity.save
      @entity.calculate_metrics
      @entity.notify_stakeholders
      ActivityLog.create!(action: 'entity_created', user: current_user)
      EntityMailer.created(@entity).deliver_later
      redirect_to @entity, notice: "Entity created."
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

### RESTful Actions

Follow Rails REST conventions:

```ruby
def index   # GET    /resources
def show    # GET    /resources/:id
def new     # GET    /resources/new
def create  # POST   /resources
def edit    # GET    /resources/:id/edit
def update  # PATCH  /resources/:id
def destroy # DELETE /resources/:id
```

### Authorization First

**ALWAYS** authorize before any action:

```ruby
class RestaurantsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_restaurant, only: [:show, :edit, :update, :destroy]

  def show
    authorize @restaurant  # Pundit authorization
  end

  def create
    authorize Restaurant  # Authorize class for new records
  end
end
```

## Rails 8 Features

- **Authentication:** Use built-in `has_secure_password` or `authenticate_by`
- **Rate Limiting:** Use `rate_limit` for API endpoints
- **Solid Queue:** Background jobs are database-backed
- **Turbo 8:** Morphing and view transitions built-in

## Namespaced Controllers

For nested routes like `settings/accounts`:

```ruby
# app/controllers/settings/accounts_controller.rb
module Settings
  class AccountsController < ApplicationController
    before_action :set_account

    def show
      authorize @account
    end

    private

    def set_account
      @account = current_account
    end
  end
end
```

## Turbo Stream Response Pattern

```ruby
def create
  @resource = current_account.resources.build(resource_params)
  authorize @resource

  if @resource.save
    respond_to do |format|
      format.html { redirect_to resources_path, notice: "Created" }
      format.turbo_stream do
        flash.now[:notice] = "Created"
        @pagy, @resources = pagy(policy_scope(Resource).order(created_at: :desc))
        render turbo_stream: [
          turbo_stream.replace("resources-list", partial: "resources/list"),
          turbo_stream.update("modal", "")
        ]
      end
    end
  else
    render :new, status: :unprocessable_entity
  end
end
```

## Commands

### Tests

- **All requests:** `bundle exec rspec spec/requests/`
- **Specific controller:** `bundle exec rspec spec/requests/entities_spec.rb`
- **Specific line:** `bundle exec rspec spec/requests/entities_spec.rb:25`
- **Detailed format:** `bundle exec rspec --format documentation spec/requests/`

### Development

- **Rails console:** `bin/rails console`
- **Routes:** `bin/rails routes`
- **Routes grep:** `bin/rails routes | grep entity`

### Linting

- **Lint controllers:** `bundle exec rubocop -a app/controllers/`
- **Lint specs:** `bundle exec rubocop -a spec/requests/`

### Security

- **Security scan:** `bin/brakeman --only-files app/controllers/`

## Controller Testing Checklist

- [ ] Request spec written first (RED)
- [ ] Multi-tenant isolation tested
- [ ] Test all RESTful actions (index, show, new, create, edit, update, destroy)
- [ ] Test authentication (authenticated vs unauthenticated)
- [ ] Test authorization (authorized vs unauthorized - 404 for unauthorized)
- [ ] Test with valid parameters (success case)
- [ ] Test with invalid parameters (validation errors)
- [ ] Test edge cases (empty lists, missing resources)
- [ ] Test response status codes
- [ ] Test redirects and renders
- [ ] Test flash messages
- [ ] Test Turbo Stream responses (if applicable)
- [ ] Controller uses `authorize` on every action
- [ ] Controller uses `policy_scope` for queries
- [ ] Presenter wraps models for views
- [ ] Strong parameters defined
- [ ] All specs GREEN

## Boundaries

- **Always do:**
  - Create thin controllers that delegate to services
  - Follow REST conventions
  - Authorize every action with Pundit
  - Write request specs for all actions
  - Use appropriate HTTP status codes
  - Handle errors gracefully
  - Use strong parameters
  - Test authentication and authorization

- **Ask first:**
  - Adding non-RESTful actions (consider if REST can work)
  - Creating API endpoints (follow API conventions)
  - Modifying ApplicationController
  - Adding custom rescue_from handlers

- **Never do:**
  - Put business logic in controllers (use services)
  - Skip authorization checks
  - Skip authentication on sensitive actions
  - Use `params` directly without strong parameters
  - Render without status codes on errors
  - Create controllers without request specs
  - Modify controller tests to make them pass
  - Skip error handling
