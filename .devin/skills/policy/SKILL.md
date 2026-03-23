---
name: policy
description: >-
  Creates secure Pundit authorization policies with TDD approach, scope restrictions,
  and comprehensive RSpec tests. Handles role-based access, state conditions, headless
  policies, and permitted attributes. Use when adding authorization, restricting access,
  defining permissions, or when working with Pundit, policies, or role-based access.
argument-hint: "[ModelName] [roles: owner,admin,member]"
triggers:
  - user
  - model
---

# Rails Pundit Policy Skill (TDD)

Creates secure Pundit authorization policies with deny-by-default and comprehensive testing.

## Tech Stack

Ruby 3.3, Rails 8.1, Pundit, RSpec

## Architecture Context

| Directory | Role |
|-----------|------|
| `app/policies/` | Pundit Policies (CREATE and MODIFY) |
| `app/controllers/` | Controllers (READ and AUDIT for authorize calls) |
| `app/models/` | Models (READ) |
| `spec/policies/` | Policy tests (CREATE and MODIFY) |
| `spec/support/pundit_matchers.rb` | RSpec matchers for Pundit |

## TDD Workflow

```
Authorization Progress:
- [ ] Step 1: Write policy spec (RED)
- [ ] Step 2: Run spec (fails)
- [ ] Step 3: Implement policy
- [ ] Step 4: Run spec (GREEN)
- [ ] Step 5: Add policy to controller
- [ ] Step 6: Test integration
```

## Naming Convention

```
app/policies/
├── application_policy.rb    # Base policy (deny all by default)
├── entity_policy.rb
├── submission_policy.rb
└── user_policy.rb

spec/policies/
├── entity_policy_spec.rb
├── submission_policy_spec.rb
└── user_policy_spec.rb
```

## Base Policy (Deny All by Default)

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Default: deny all
  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "Define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
```

## Policy Patterns

### 1. Basic CRUD Policy (Owner-based)

```ruby
class EntityPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner?
  end

  def create?
    user.present?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def permitted_attributes
    [:name, :description, :status]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(account_id: user.account_id)
    end
  end

  private

  def owner?
    record.account_id == user.account_id
  end
end
```

### 2. Role-Based Policy

```ruby
class SubmissionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner? || admin?
  end

  def create?
    user.present?
  end

  def update?
    owner? || admin?
  end

  def destroy?
    admin?
  end

  # Custom action
  def publish?
    owner? && record.draft?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(account_id: user.account_id)
      end
    end
  end

  private

  def owner?
    record.account_id == user.account_id
  end

  def admin?
    user.admin?
  end
end
```

### 3. Policy with State Conditions

```ruby
class OrderPolicy < ApplicationPolicy
  def update?
    owner? && !record.locked?
  end

  def cancel?
    owner? && record.can_cancel?
  end

  def destroy?
    owner? && record.destroyable?
  end
end
```

### 4. Headless Policy (No Record)

For dashboards, admin panels, non-model actions:

```ruby
# Usage: authorize :dashboard, :show?
class DashboardPolicy < ApplicationPolicy
  def show?
    user.present?
  end

  def admin?
    user.admin?
  end
end
```

### 5. Permitted Attributes by Role

```ruby
def permitted_attributes
  if user.admin?
    [:name, :description, :status, :featured, :admin_notes]
  else
    [:name, :description]
  end
end
```

## Policy Spec Template

```ruby
# spec/policies/entity_policy_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntityPolicy, type: :policy do
  subject(:policy) { described_class.new(user, entity) }

  let(:account) { create(:account) }
  let(:entity) { create(:entity, account: account) }

  context "unauthenticated visitor" do
    let(:user) { nil }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context "authenticated user (non-owner)" do
    let(:user) { create(:user) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context "entity owner" do
    let(:user) { create(:user, account: account) }

    it { is_expected.to permit_actions(:index, :show, :create, :update, :destroy) }
  end

  context "admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_actions(:index, :show, :update, :destroy) }
  end

  describe "Scope" do
    let(:user) { create(:user, account: account) }
    let!(:own_entity) { create(:entity, account: account) }
    let!(:other_entity) { create(:entity) }

    it "returns only entities for user's account" do
      scope = described_class::Scope.new(user, Entity.all).resolve
      expect(scope).to include(own_entity)
      expect(scope).not_to include(other_entity)
    end
  end
end
```

## Controller Integration

Every controller action **must** call `authorize` or `policy_scope`:

```ruby
class EntitiesController < ApplicationController
  before_action :set_entity, only: [:show, :edit, :update, :destroy]

  def index
    @entities = policy_scope(Entity)  # Scoped collection
  end

  def show
    authorize @entity  # Checks show?
  end

  def create
    @entity = current_account.entities.build(entity_params)
    authorize @entity
    # ...
  end

  def update
    authorize @entity
    @entity.update(permitted_attributes(@entity))  # Uses policy's permitted_attributes
  end

  private

  def set_entity
    @entity = policy_scope(Entity).find(params[:id])
  end
end
```

### ApplicationController Setup

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
```

### View Integration

```erb
<% if policy(@entity).edit? %>
  <%= link_to "Edit", edit_entity_path(@entity) %>
<% end %>

<% if policy(@entity).destroy? %>
  <%= button_to "Delete", entity_path(@entity), method: :delete %>
<% end %>
```

## Commands

### Tests

- **All policies:** `bundle exec rspec spec/policies/`
- **Specific policy:** `bundle exec rspec spec/policies/entity_policy_spec.rb`
- **Specific line:** `bundle exec rspec spec/policies/entity_policy_spec.rb:25`
- **Detailed format:** `bundle exec rspec --format documentation spec/policies/`

### Generation

- **Generate policy:** `bin/rails generate pundit:policy Entity`

### Linting

- **Lint policies:** `bundle exec rubocop -a app/policies/`
- **Lint specs:** `bundle exec rubocop -a spec/policies/`

### Audit

- **Find missing authorize:** `grep -r "def " app/controllers/ | grep -v "authorize"`

## Security Checklist

- [ ] Policy spec written first (RED)
- [ ] Policy inherits from ApplicationPolicy
- [ ] Deny by default - only explicitly allow
- [ ] Scope defined for collections (multi-tenancy enforced)
- [ ] Each controller action has `authorize` or `policy_scope`
- [ ] `verify_authorized` after_action enabled
- [ ] `permitted_attributes` defined for updates
- [ ] Views use `policy(@record).action?`
- [ ] Error handling configured (`rescue_from Pundit::NotAuthorizedError`)
- [ ] Unauthenticated visitor (`user: nil`) tested
- [ ] Regular authenticated user tested
- [ ] Resource owner/author tested
- [ ] Admin (if applicable) tested
- [ ] Custom actions tested
- [ ] All specs GREEN

## Boundaries

- **Always:** Write policy specs, deny by default, verify every controller action has `authorize`, use `policy_scope` for index
- **Ask first:** Before granting admin-level permissions, modifying existing policies
- **Never:** Allow access by default, skip policy tests, hardcode user IDs, forget to test nil user
