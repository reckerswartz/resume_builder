---
name: service
description: >-
  Creates well-structured Rails service objects following SOLID principles with
  callable interface, Result objects, and comprehensive specs. Use when extracting
  business logic, creating complex operations, implementing interactors, or when
  working with service objects, POROs, or multi-model operations.
argument-hint: "[Namespace::ActionService] [purpose description]"
triggers:
  - user
  - model
---

# Rails Service Object Skill (TDD)

Creates service objects that encapsulate business logic with consistent Result object returns.

## Tech Stack

Ruby 3.3, Rails 8.1, RSpec, FactoryBot

## Architecture Context

| Directory | Role |
|-----------|------|
| `app/services/` | Business Services (CREATE and MODIFY) |
| `app/models/` | ActiveRecord Models (READ) |
| `app/queries/` | Query Objects (READ and CALL) |
| `app/validators/` | Custom Validators (READ) |
| `app/jobs/` | Background Jobs (READ and ENQUEUE) |
| `app/mailers/` | Mailers (READ and CALL) |
| `spec/services/` | Service tests (CREATE and MODIFY) |
| `spec/factories/` | FactoryBot Factories (READ and MODIFY) |

## When to Use Service Objects

| Scenario | Use Service Object? |
|----------|---------------------|
| Complex business logic | Yes |
| Multiple model interactions | Yes |
| External API calls | Yes |
| Logic shared across controllers | Yes |
| Action requires a transaction | Yes |
| Side effects (emails, notifications) | Yes |
| Simple CRUD operations | No (use model) |
| Single model validation | No (use model) |
| Wrapper without added value | No |

## TDD Workflow

```
Service Object Progress:
- [ ] Step 1: Define input/output contract
- [ ] Step 2: Create service spec (RED)
- [ ] Step 3: Run spec (fails - no service)
- [ ] Step 4: Create service file with empty #call
- [ ] Step 5: Run spec (fails - wrong return)
- [ ] Step 6: Implement #call method
- [ ] Step 7: Run spec (GREEN)
- [ ] Step 8: Add error case specs
- [ ] Step 9: Implement error handling
- [ ] Step 10: Final spec run
```

## Step 1: Define Contract

```markdown
## Service: Orders::CreateService

### Purpose
Creates a new order with inventory validation and payment processing.

### Input
- user: User (required) - The user placing the order
- items: Array<Hash> (required) - Items to order [{product_id:, quantity:}]
- payment_method_id: Integer (optional) - Saved payment method

### Output (Result object)
Success: { success?: true, data: Order }
Failure: { success?: false, error: String }

### Side Effects
- Creates Order and OrderItem records
- Decrements inventory
- Sends confirmation email (async)
```

## Directory Structure & Naming

```
app/services/
├── application_service.rb          # Base class
├── result.rb                       # Shared Result class
├── entities/
│   ├── create_service.rb           # Entities::CreateService
│   ├── update_service.rb           # Entities::UpdateService
│   └── calculate_rating_service.rb # Entities::CalculateRatingService
└── submissions/
    ├── create_service.rb           # Submissions::CreateService
    └── moderate_service.rb         # Submissions::ModerateService
```

**Naming convention:** `Namespace::VerbNounService` (e.g., `Orders::CreateService`)

## ApplicationService Base Class

```ruby
# app/services/application_service.rb
class ApplicationService
  def self.call(...)
    new(...).call
  end

  private

  def success(data = nil)
    Result.new(success: true, data: data, error: nil)
  end

  def failure(error)
    Result.new(success: false, data: nil, error: error)
  end

  # Ruby 3.2+ Data.define for immutable result objects
  Result = Data.define(:success, :data, :error) do
    def success? = success
    def failure? = !success
  end
end
```

## Step 2: Create Service Spec

Location: `spec/services/[namespace]/[name]_service_spec.rb`

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entities::CreateService do
  subject(:result) { described_class.call(user: user, params: params) }

  let(:user) { create(:user) }
  let(:params) { { name: "Test Entity", description: "A test" } }

  describe '#call' do
    context 'with valid inputs' do
      it 'returns success' do
        expect(result).to be_success
      end

      it 'creates an entity' do
        expect { result }.to change(Entity, :count).by(1)
      end

      it 'returns the entity' do
        expect(result.data).to be_a(Entity)
      end
    end

    context 'with invalid params' do
      let(:params) { { name: "" } }

      it 'returns failure' do
        expect(result).to be_failure
      end

      it 'returns error message' do
        expect(result.error).to include("Name")
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'returns failure' do
        expect(result).to be_failure
      end

      it 'returns authorization error' do
        expect(result.error).to eq('User not authorized')
      end
    end
  end
end
```

## Step 3-6: Implement Service

```ruby
# app/services/entities/create_service.rb
module Entities
  class CreateService < ApplicationService
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      return failure("User not authorized") unless authorized?

      entity = build_entity

      if entity.save
        notify_owner(entity)
        success(entity)
      else
        failure(entity.errors.full_messages.join(", "))
      end
    end

    private

    attr_reader :user, :params

    def authorized?
      user.present?
    end

    def build_entity
      user.entities.build(permitted_params)
    end

    def permitted_params
      params.slice(:name, :description, :address, :phone)
    end

    def notify_owner(entity)
      EntityMailer.created(entity).deliver_later
    end
  end
end
```

## Service Patterns

### 1. Simple CRUD Service
Guard clauses, save, side effects. Used for standard create/update operations.

### 2. Service with Transaction
```ruby
def call
  ActiveRecord::Base.transaction do
    order = Order.create!(user: user, status: :pending)
    items.each { |item| order.order_items.create!(item) }
    success(order)
  end
rescue ActiveRecord::RecordInvalid => e
  failure(e.message)
end
```

### 3. Service with Injected Dependencies
```ruby
def initialize(inventory_service: InventoryService.new,
               payment_gateway: PaymentGateway.new)
  @inventory_service = inventory_service
  @payment_gateway = payment_gateway
end
```

Testing with mocks:
```ruby
let(:inventory_service) { instance_double(InventoryService) }
let(:service) { described_class.new(inventory_service: inventory_service) }

before do
  allow(inventory_service).to receive(:available?).and_return(true)
end
```

### 4. Calculation/Query Service
Memoization, aggregate queries, `update_columns` for performance.

## Usage in Controllers

```ruby
class EntitiesController < ApplicationController
  def create
    result = Entities::CreateService.call(
      user: current_user,
      params: entity_params
    )

    if result.success?
      redirect_to result.data, notice: "Entity created successfully"
    else
      @entity = Entity.new(entity_params)
      flash.now[:alert] = result.error
      render :new, status: :unprocessable_entity
    end
  end
end
```

## Usage in Jobs

```ruby
class ProcessOrderJob < ApplicationJob
  def perform(user_id, items)
    user = User.find(user_id)
    result = Orders::CreateService.new.call(user: user, items: items)

    unless result.success?
      Rails.logger.error("Order failed: #{result.error}")
    end
  end
end
```

## Commands

### Tests

- **All services:** `bundle exec rspec spec/services/`
- **Specific service:** `bundle exec rspec spec/services/entities/create_service_spec.rb`
- **Specific line:** `bundle exec rspec spec/services/entities/create_service_spec.rb:25`
- **Detailed format:** `bundle exec rspec --format documentation spec/services/`

### Linting

- **Lint services:** `bundle exec rubocop -a app/services/`
- **Lint specs:** `bundle exec rubocop -a spec/services/`

### Console

- **Test manually:** `bin/rails console`

## Conventions

1. **Naming**: `VerbNounService` (e.g., `CreateOrderService`)
2. **Location**: `app/services/[namespace]/[name]_service.rb`
3. **Interface**: Single public method `#call`
4. **Return**: Always return Result object
5. **Dependencies**: Inject via constructor
6. **Errors**: Catch and wrap in Result, don't raise

## Anti-Patterns to Avoid

1. **God service**: Too many responsibilities - split into smaller services
2. **Hidden dependencies**: Using globals instead of injection
3. **No return contract**: Returning different types
4. **Raising exceptions**: Use Result objects instead
5. **Business logic in controller**: Extract to service

## Boundaries

- **Always:** Write service specs, use Result objects, follow SRP
- **Ask first:** Before modifying existing services used by multiple controllers, adding external API calls
- **Never:** Skip tests, put service logic in controllers/models, silently ignore errors
