---
name: rails-architecture
description: >-
  Guides modern Rails 8 architecture decisions and code organization. Use when
  deciding where to put code, choosing between patterns (service vs concern vs
  query object), designing feature architecture, refactoring for better organization,
  or when asking "where should this code go?"
argument-hint: "[description of code to place or feature to design]"
triggers:
  - user
  - model
---

# Rails 8 Architecture Decision Guide

Guides where code should live and which patterns to use for clean, maintainable architecture.

## Tech Stack

Ruby 3.3, Rails 8.1, Hotwire (Turbo + Stimulus), PostgreSQL, Pundit, Solid Queue, ViewComponent

## Architecture Decision Tree

```
Where should this code go?
│
├─ Is it view/display formatting?
│   └─ → Presenter (app/presenters/)
│
├─ Is it complex business logic?
│   └─ → Service Object (invoke /service)
│
├─ Is it a complex database query?
│   └─ → Query Object (app/queries/)
│
├─ Is it shared behavior across models?
│   └─ → Concern (app/models/concerns/)
│
├─ Is it authorization logic?
│   └─ → Policy (invoke /policy)
│
├─ Is it reusable UI with logic?
│   └─ → ViewComponent (app/components/)
│
├─ Is it async/background work?
│   └─ → Job (app/jobs/, Solid Queue)
│
├─ Is it a complex form (multi-model, wizard)?
│   └─ → Form Object (invoke /form)
│
├─ Is it a transactional email?
│   └─ → Mailer (app/mailers/)
│
├─ Is it real-time/WebSocket communication?
│   └─ → Channel (app/channels/)
│
├─ Is it data validation only?
│   └─ → Model (invoke /model)
│
└─ Is it HTTP request/response handling only?
    └─ → Controller (invoke /controller)
```

## Layer Interaction Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        REQUEST                               │
└─────────────────────────┬───────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     CONTROLLER                               │
│  • Authenticate (Authentication concern)                     │
│  • Authorize (Policy)                                        │
│  • Parse params                                              │
│  • Delegate to Service/Query                                 │
└──────────┬─────────────────────────────────────┬────────────┘
           │                                     │
           ▼                                     ▼
┌─────────────────────┐               ┌─────────────────────┐
│      SERVICE        │               │       QUERY         │
│  • Business logic   │               │  • Complex queries  │
│  • Orchestration    │               │  • Aggregations     │
│  • Transactions     │               │  • Reports          │
└──────────┬──────────┘               └──────────┬──────────┘
           │                                     │
           ▼                                     ▼
┌─────────────────────────────────────────────────────────────┐
│                        MODEL                                 │
│  • Validations  • Associations  • Scopes  • Callbacks       │
└─────────────────────────┬───────────────────────────────────┘
                          │
           ┌──────────────┴──────────────┐
           ▼                             ▼
┌─────────────────────┐       ┌─────────────────────┐
│     PRESENTER       │       │    VIEW COMPONENT   │
│  • Formatting       │       │  • Reusable UI      │
│  • Display logic    │       │  • Encapsulated     │
└──────────┬──────────┘       └──────────┬──────────┘
           │                             │
           └──────────────┬──────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                       RESPONSE                               │
└─────────────────────────────────────────────────────────────┘

ASYNC:  Job (Solid Queue)  │  Channel (Action Cable + Solid Cable)
EMAIL:  Mailer (Action Mailer)
```

## Layer Responsibilities

| Layer | Responsibility | Should NOT contain |
|-------|---------------|-------------------|
| **Controller** | HTTP, params, response | Business logic, queries |
| **Model** | Data, validations, relations | Display logic, HTTP |
| **Service** | Business logic, orchestration | HTTP, display logic |
| **Query** | Complex database queries | Business logic |
| **Presenter** | View formatting, badges | Business logic, queries |
| **Policy** | Authorization rules | Business logic |
| **Component** | Reusable UI encapsulation | Business logic |
| **Job** | Async processing | HTTP, display logic |
| **Form** | Complex form handling | Persistence logic |
| **Mailer** | Email composition | Business logic |
| **Channel** | WebSocket communication | Business logic |

## Project Directory Structure

```
app/
├── channels/            # Action Cable channels
├── components/          # ViewComponents (UI + logic)
├── controllers/
│   └── concerns/        # Shared controller behavior
├── forms/               # Form objects
├── helpers/             # Simple view helpers (avoid)
├── jobs/                # Background jobs (Solid Queue)
├── mailers/             # Action Mailer classes
├── models/
│   └── concerns/        # Shared model behavior
├── policies/            # Pundit authorization
├── presenters/          # View formatting
├── queries/             # Complex queries
├── services/            # Business logic
│   └── result.rb        # Shared Result class
└── views/
    └── layouts/
```

## Core Principles

### 1. Skinny Controllers

Controllers should only: authenticate/authorize, parse params, call service/query, render response.

```ruby
# GOOD: Thin controller
class OrdersController < ApplicationController
  def create
    result = Orders::CreateService.new.call(
      user: current_user,
      params: order_params
    )

    if result.success?
      redirect_to result.data, notice: t(".success")
    else
      flash.now[:alert] = result.error
      render :new, status: :unprocessable_entity
    end
  end
end
```

### 2. Rich Models, Smart Services

**Models handle:** Validations, associations, scopes, simple derived attributes
**Services handle:** Multi-model operations, external API calls, complex business rules, transactions

### 3. Result Objects for Services

All services return a consistent Result object:

```ruby
Result = Data.define(:success, :data, :error) do
  def success? = success
  def failure? = !success
end
```

### 4. Multi-Tenancy by Default

All queries scoped through account:

```ruby
# GOOD: Scoped through account
def index
  @events = current_account.events.recent
end

# BAD: Unscoped query
def index
  @events = Event.where(user_id: current_user.id)
end
```

## When NOT to Abstract (Avoid Over-Engineering)

| Situation | Keep It Simple | Don't Create |
|-----------|----------------|--------------|
| Simple CRUD (< 10 lines) | Keep in controller | Service object |
| Used only once | Inline the code | Abstraction |
| Simple query with 1-2 conditions | Model scope | Query object |
| Basic text formatting | Helper method | Presenter |
| Single model form | `form_with model:` | Form object |
| Simple partial without logic | Partial | ViewComponent |

### Signs of Over-Engineering

```ruby
# OVER-ENGINEERED: Service for simple save
class Users::UpdateEmailService
  def call(user, email)
    user.update(email: email)  # Just do this in controller!
  end
end

# KEEP IT SIMPLE
class UsersController < ApplicationController
  def update
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end
end
```

## When TO Abstract

| Signal | Action |
|--------|--------|
| Same code in 3+ places | Extract to concern/service |
| Controller action > 15 lines | Extract to service |
| Model > 300 lines | Extract concerns |
| Complex conditionals | Extract to policy/service |
| Query joins 3+ tables | Extract to query object |
| Form spans multiple models | Extract to form object |

## Pattern Selection Guide

### Service Objects
- Logic spans multiple models
- External API calls needed
- Complex business rules
- Need consistent error handling
- Logic reused across controllers/jobs
→ Use `invoke /service`

### Query Objects
- Complex SQL/ActiveRecord queries
- Aggregations and statistics
- Dashboard data and reports

### Presenters
- Formatting data for display
- Status badges with colors
- Currency/date formatting
- Conditional display logic

### Concerns
- Shared validations across models
- Common scopes (e.g., `Searchable`)
- Shared callbacks (e.g., `HasUuid`)
- Keep single-purpose!

### ViewComponents
- Reusable UI with logic
- Complex partials
- Need testable views
- Cards, tables, badges

### Form Objects
- Multi-model forms
- Wizard/multi-step forms
- Search/filter forms
- Contact forms (no persistence)
→ Use `invoke /form`

### Policies
- Resource authorization
- Role-based access
- Action permissions
- Scoped collections
→ Use `invoke /policy`

## Rails 8 Specific Features

| Feature | Purpose |
|---------|---------|
| **Authentication Generator** | `bin/rails generate authentication` - built-in auth |
| **Solid Queue** | Database-backed job processing (no Redis) |
| **Solid Cable** | Database-backed WebSocket adapter |
| **Solid Cache** | Database-backed caching |
| **Propshaft** | Asset pipeline (replaces Sprockets) |
| **Importmap** | JavaScript without bundling |
| **Kamal** | Docker deployment |
| **Thruster** | HTTP/2 proxy with caching |

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| God Model | Model > 500 lines | Extract services/concerns |
| Fat Controller | Logic in controllers | Move to services |
| Callback Hell | Complex model callbacks | Use services |
| Helper Soup | Massive helper modules | Use presenters/components |
| N+1 Queries | Unoptimized queries | Use `.includes()`, query objects |
| Stringly Typed | Magic strings everywhere | Use constants, enums |
| Premature Abstraction | Service for 3 lines | Keep in controller |

## Testing Strategy by Layer

| Layer | Test Type | Focus |
|-------|-----------|-------|
| Model | Unit | Validations, scopes, methods |
| Service | Unit | Business logic, edge cases |
| Query | Unit | Query results, tenant isolation |
| Presenter | Unit | Formatting, HTML output |
| Controller | Request | Integration, HTTP flow |
| Component | Component | Rendering, variants |
| Policy | Unit | Authorization rules |
| Form | Unit | Validations, persistence |
| System | E2E | Critical user paths |

## New Feature Checklist

1. **Model** - Define data structure (invoke /model)
2. **Migration** - Create database tables (invoke /migration)
3. **Policy** - Add authorization rules (invoke /policy)
4. **Service** - Create for complex logic if needed (invoke /service)
5. **Query** - Add for complex queries if needed
6. **Controller** - Keep it thin! (invoke /controller)
7. **Form** - Use for multi-model forms if needed (invoke /form)
8. **Presenter** - Format for display
9. **Component** - Build reusable UI
10. **Mailer** - Add transactional emails if needed
11. **Job** - Add background processing if needed

## Refactoring Signals

| Signal | Action |
|--------|--------|
| Model > 300 lines | Extract concern or service |
| Controller action > 15 lines | Extract service |
| View logic in helpers | Use presenter |
| Repeated query patterns | Extract query object |
| Complex partial with logic | Use ViewComponent |
| Form with multiple models | Use form object |
| Same code in 3+ places | Extract to shared module |
