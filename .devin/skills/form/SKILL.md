---
name: form
description: >-
  Creates form objects for complex multi-model forms, search/filter forms, wizard
  forms, and contact forms with TDD approach. Handles validations, type coercion,
  nested attributes, and Turbo integration. Use when building multi-model forms,
  search forms, wizard forms, or when working with form objects or virtual models.
argument-hint: "[FormName] [type: multi-model|search|wizard|contact]"
triggers:
  - user
  - model
---

# Rails Form Object Skill (TDD)

Creates form objects that encapsulate complex form logic decoupled from ActiveRecord.

## Tech Stack

Ruby 3.3, Rails 8.1, Hotwire (Turbo + Stimulus), ActiveModel, RSpec

## Architecture Context

| Directory | Role |
|-----------|------|
| `app/forms/` | Form Objects (CREATE and MODIFY) |
| `app/models/` | ActiveRecord Models (READ) |
| `app/validators/` | Custom Validators (READ and USE) |
| `app/controllers/` | Controllers (READ and MODIFY) |
| `app/views/` | ERB Views (READ and MODIFY) |
| `spec/forms/` | Form tests (CREATE and MODIFY) |

## When to Use Form Objects

| Scenario | Use Form Object? |
|----------|-----------------|
| Single model CRUD | No (use model) |
| Multi-model creation | Yes |
| Complex validations across models | Yes |
| Search/filter forms | Yes |
| Wizard/multi-step forms | Yes |
| API params transformation | Yes |
| Contact forms (no persistence) | Yes |
| `accepts_nested_attributes_for` is sufficient | No |

## TDD Workflow

```
Form Object Progress:
- [ ] Step 1: Define form requirements
- [ ] Step 2: Write form object spec (RED)
- [ ] Step 3: Run spec (fails)
- [ ] Step 4: Create form object
- [ ] Step 5: Run spec (GREEN)
- [ ] Step 6: Wire up controller
- [ ] Step 7: Create view form
```

## Directory Structure

```
app/forms/
├── application_form.rb               # Base class
├── entity_registration_form.rb       # Multi-model
├── search_form.rb                    # Non-persisted
├── content_submission_form.rb        # Complex validations
├── user_profile_form.rb              # Edit with pre-population
└── wizard/
    ├── base_form.rb
    ├── step_one_form.rb
    └── step_two_form.rb

spec/forms/
├── entity_registration_form_spec.rb
├── search_form_spec.rb
└── content_submission_form_spec.rb
```

## Base Form Class

```ruby
# app/forms/application_form.rb
class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  def self.model_name
    ActiveModel::Name.new(self, nil, name.chomp("Form"))
  end

  def persisted?
    false
  end

  def save
    return false unless valid?
    persist!
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  private

  def persist!
    raise NotImplementedError
  end
end
```

## Form Patterns

### Pattern 1: Multi-Model Registration Form

Creates multiple records in a transaction.

```ruby
# app/forms/entity_registration_form.rb
class EntityRegistrationForm < ApplicationForm
  attribute :name, :string
  attribute :email, :string
  attribute :phone, :string
  attribute :address, :string
  attribute :account_id, :integer

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true

  private

  def persist!
    ActiveRecord::Base.transaction do
      entity = Entity.create!(name: name, account_id: account_id)
      ContactInfo.create!(entity: entity, email: email, phone: phone, address: address)
      EntityMailer.welcome(entity).deliver_later
    end
  end
end
```

### Pattern 2: Search/Filter Form (Non-Persisted)

```ruby
# app/forms/search_form.rb
class SearchForm < ApplicationForm
  attribute :query, :string
  attribute :status, :string
  attribute :date_from, :date
  attribute :date_to, :date

  def results
    scope = Entity.all
    scope = scope.where("name ILIKE ?", "%#{query}%") if query.present?
    scope = scope.where(status: status) if status.present?
    scope = scope.where("created_at >= ?", date_from) if date_from.present?
    scope = scope.where("created_at <= ?", date_to) if date_to.present?
    scope
  end

  def any_filters?
    [query, status, date_from, date_to].any?(&:present?)
  end

  # Override - search forms don't persist
  def save
    valid?
  end
end
```

### Pattern 3: Wizard/Multi-Step Form

```ruby
# app/forms/wizard/base_form.rb
module Wizard
  class BaseForm < ApplicationForm
    STEPS = %w[step_one step_two step_three].freeze

    attribute :current_step, :string, default: "step_one"

    def next_step
      idx = STEPS.index(current_step)
      STEPS[idx + 1] if idx && idx < STEPS.length - 1
    end

    def previous_step
      idx = STEPS.index(current_step)
      STEPS[idx - 1] if idx && idx > 0
    end

    def first_step? = current_step == STEPS.first
    def last_step?  = current_step == STEPS.last

    def progress_percentage
      ((STEPS.index(current_step).to_f + 1) / STEPS.length * 100).round
    end
  end
end
```

### Pattern 4: Edit Form with Pre-Population

```ruby
# app/forms/user_profile_form.rb
class UserProfileForm < ApplicationForm
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :bio, :string
  attribute :avatar  # Active Storage

  validates :first_name, presence: true
  validates :last_name, presence: true

  def initialize(user:, **attributes)
    @user = user
    super(
      first_name: user.first_name,
      last_name: user.last_name,
      bio: user.bio,
      **attributes
    )
  end

  def persisted?
    true  # Edit form
  end

  private

  def persist!
    @user.update!(
      first_name: first_name,
      last_name: last_name,
      bio: bio
    )
    @user.avatar.attach(avatar) if avatar.present?
  end
end
```

### Pattern 5: Contact Form (No Persistence)

```ruby
class ContactForm < ApplicationForm
  attribute :name, :string
  attribute :email, :string
  attribute :message, :string

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { minimum: 10 }

  def save
    return false unless valid?
    ContactMailer.inquiry(name: name, email: email, message: message).deliver_later
    true
  end
end
```

## Form Spec Template

```ruby
# spec/forms/entity_registration_form_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntityRegistrationForm, type: :form do
  subject(:form) { described_class.new(attributes) }

  let(:account) { create(:account) }
  let(:attributes) do
    {
      name: "Test Entity",
      email: "test@example.com",
      phone: "555-1234",
      address: "123 Main St",
      account_id: account.id
    }
  end

  describe "#save" do
    context "with valid attributes" do
      it "returns true" do
        expect(form.save).to be true
      end

      it "creates an entity" do
        expect { form.save }.to change(Entity, :count).by(1)
      end

      it "creates contact info" do
        expect { form.save }.to change(ContactInfo, :count).by(1)
      end

      it "sends welcome email" do
        expect { form.save }
          .to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context "with missing name" do
      let(:attributes) { super().merge(name: "") }

      it "returns false" do
        expect(form.save).to be false
      end

      it "has error on name" do
        form.save
        expect(form.errors[:name]).to include("can't be blank")
      end
    end

    context "with invalid email" do
      let(:attributes) { super().merge(email: "not-an-email") }

      it "returns false" do
        expect(form.save).to be false
      end

      it "has error on email" do
        form.save
        expect(form.errors[:email]).to be_present
      end
    end
  end
end
```

## Controller Integration

```ruby
class RegistrationsController < ApplicationController
  def new
    @form = EntityRegistrationForm.new
  end

  def create
    @form = EntityRegistrationForm.new(registration_params)

    if @form.save
      redirect_to entities_path, notice: "Registration successful"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:entity_registration).permit(:name, :email, :phone, :address)
          .merge(account_id: current_account.id)
  end
end
```

## View Integration

```erb
<%# app/views/registrations/new.html.erb %>
<%= form_with model: @form, url: registrations_path do |f| %>
  <% if @form.errors.any? %>
    <div class="errors">
      <% @form.errors.full_messages.each do |msg| %>
        <p><%= msg %></p>
      <% end %>
    </div>
  <% end %>

  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :email %>
  <%= f.email_field :email %>

  <%= f.label :phone %>
  <%= f.tel_field :phone %>

  <%= f.submit "Register" %>
<% end %>
```

Key view conventions:
- Use `form_with model: @form, url: explicit_path` (form object is not ActiveRecord)
- Permit params with snake-case class name without "Form" suffix
- Always `render :new, status: :unprocessable_entity` on failure (Turbo compatibility)

## Rails 8 / Turbo Considerations

- Forms submit via Turbo by default (no full page reload)
- Use `turbo_stream` responses for inline validation errors
- File uploads work with Active Storage direct uploads
- Always return `status: :unprocessable_entity` on validation failure

## Commands

### Tests

- **All forms:** `bundle exec rspec spec/forms/`
- **Specific form:** `bundle exec rspec spec/forms/entity_registration_form_spec.rb`
- **Specific line:** `bundle exec rspec spec/forms/entity_registration_form_spec.rb:45`
- **Detailed format:** `bundle exec rspec --format documentation spec/forms/`

### Linting

- **Lint forms:** `bundle exec rubocop -a app/forms/`
- **Lint specs:** `bundle exec rubocop -a spec/forms/`

### Console

- **Test manually:** `bin/rails console`

## Checklist

- [ ] Spec written first (RED)
- [ ] Extends `ApplicationForm` or includes `ActiveModel::Model`
- [ ] Attributes declared with types
- [ ] Validations defined
- [ ] `#save` method with transaction (if multi-model)
- [ ] Controller uses form object
- [ ] View uses `form_with model: @form`
- [ ] Error handling in place
- [ ] All specs GREEN

## Boundaries

- **Always:** Write form specs, validate all inputs, wrap multi-model persistence in transactions
- **Ask first:** Before adding database writes to multiple tables, modifying a form used by multiple controllers
- **Never:** Skip validations, bypass model validations, put business logic in forms, create forms without tests
