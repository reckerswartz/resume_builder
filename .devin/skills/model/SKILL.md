---
name: model
description: >-
  Creates well-structured ActiveRecord models with TDD approach - spec first, then
  migration, then model. Handles validations, associations, scopes, callbacks, enums,
  and FactoryBot factories. Use when creating models, adding validations, defining
  associations, or when working with ActiveRecord, model design, or database schema.
argument-hint: "[ModelName] [attributes: name:string, status:integer, ...]"
triggers:
  - user
  - model
---

# Rails Model Skill (TDD)

Creates models the TDD way: spec first, then migration, then implementation.

## Tech Stack

Ruby 3.3, Rails 8.1, PostgreSQL, RSpec, FactoryBot, Shoulda Matchers

## Architecture Context

| Directory | Role |
|-----------|------|
| `app/models/` | ActiveRecord Models (CREATE and MODIFY) |
| `app/validators/` | Custom Validators (READ and USE) |
| `app/services/` | Business Services (READ) |
| `app/queries/` | Query Objects (READ) |
| `spec/models/` | Model tests (CREATE and MODIFY) |
| `spec/factories/` | FactoryBot Factories (CREATE and MODIFY) |

## TDD Workflow

```
Model Creation Progress:
- [ ] Step 1: Define requirements (attributes, validations, associations)
- [ ] Step 2: Create model spec (RED)
- [ ] Step 3: Create factory
- [ ] Step 4: Run spec (should fail - no model/table)
- [ ] Step 5: Generate migration
- [ ] Step 6: Run migration
- [ ] Step 7: Create model file (empty)
- [ ] Step 8: Run spec (should fail - no validations)
- [ ] Step 9: Add validations and associations
- [ ] Step 10: Run spec (GREEN)
```

## Step 1: Requirements Template

Before writing code, define the model:

```markdown
## Model: [ModelName]

### Table: [table_name]

### Attributes
| Name | Type | Constraints | Default |
|------|------|-------------|---------|
| name | string | required, unique | - |
| email | string | required, unique, email format | - |
| status | integer | enum | 0 (pending) |
| organization_id | bigint | foreign key | - |

### Associations
- belongs_to :organization
- has_many :posts, dependent: :destroy
- has_one :profile, dependent: :destroy

### Validations
- name: presence, uniqueness, length(max: 100)
- email: presence, uniqueness, format(email)
- status: inclusion in enum values

### Scopes
- active: status = active
- recent: ordered by created_at desc

### Instance Methods
- full_name: combines first_name and last_name
- active?: checks if status is active

### Callbacks
- before_save :normalize_email
```

## Step 2: Create Model Spec

Location: `spec/models/[model_name]_spec.rb`

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelName, type: :model do
  subject { build(:model_name) }

  # === Associations ===
  describe 'associations' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:posts).dependent(:destroy) }
  end

  # === Validations ===
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
  end

  # === Scopes ===
  describe '.active' do
    let!(:active_record) { create(:model_name, status: :active) }
    let!(:inactive_record) { create(:model_name, status: :inactive) }

    it 'returns only active records' do
      expect(described_class.active).to include(active_record)
      expect(described_class.active).not_to include(inactive_record)
    end
  end

  # === Instance Methods ===
  describe '#full_name' do
    subject { build(:model_name, first_name: 'John', last_name: 'Doe') }

    it 'returns combined name' do
      expect(subject.full_name).to eq('John Doe')
    end
  end
end
```

## Step 3: Create Factory

Location: `spec/factories/[model_name_plural].rb`

```ruby
# frozen_string_literal: true

FactoryBot.define do
  factory :model_name do
    sequence(:name) { |n| "Name #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    status { :pending }
    association :organization

    trait :active do
      status { :active }
    end

    trait :with_posts do
      after(:create) do |record|
        create_list(:post, 3, model_name: record)
      end
    end
  end
end
```

## Step 4: Run Spec (Verify RED)

```bash
bundle exec rspec spec/models/model_name_spec.rb
```

Expected: Failure because model/table doesn't exist.

## Step 5: Generate Migration

```bash
bin/rails generate migration CreateModelNames \
  name:string \
  email:string:uniq \
  status:integer \
  organization:references
```

Review the generated migration and add constraints:

```ruby
# db/migrate/YYYYMMDDHHMMSS_create_model_names.rb
class CreateModelNames < ActiveRecord::Migration[8.0]
  def change
    create_table :model_names do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.integer :status, null: false, default: 0
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :model_names, :email, unique: true
    add_index :model_names, :status
  end
end
```

## Step 6: Run Migration

```bash
bin/rails db:migrate
bin/rails db:migrate:status  # Verify
```

## Step 7: Create Model File (Empty)

```ruby
# app/models/model_name.rb
# frozen_string_literal: true

class ModelName < ApplicationRecord
end
```

## Step 8: Run Spec (Still RED)

```bash
bundle exec rspec spec/models/model_name_spec.rb
```

Expected: Failures for missing validations/associations.

## Step 9: Add Validations & Associations

```ruby
# frozen_string_literal: true

class ModelName < ApplicationRecord
  # === Associations ===
  belongs_to :organization
  has_many :posts, dependent: :destroy

  # === Enums ===
  enum :status, { pending: 0, active: 1, suspended: 2 }

  # === Validations ===
  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: 100 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # === Scopes ===
  scope :active, -> { where(status: :active) }
  scope :recent, -> { order(created_at: :desc) }

  # === Instance Methods ===
  def full_name
    "#{first_name} #{last_name}".strip
  end
end
```

## Step 10: Run Spec (GREEN)

```bash
bundle exec rspec spec/models/model_name_spec.rb
```

## Model Design Principles

### Keep Models Thin

Models should focus on **data, validations, and associations** - not complex business logic.

**Good - Focused model:**
```ruby
class Entity < ApplicationRecord
  belongs_to :user
  has_many :submissions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :status, inclusion: { in: %w[draft published archived] }

  scope :published, -> { where(status: 'published') }
  scope :recent, -> { order(created_at: :desc) }

  def published?
    status == 'published'
  end
end
```

**Bad - Fat model with business logic:**
```ruby
class Entity < ApplicationRecord
  def publish!
    self.status = 'published'
    self.published_at = Time.current
    save!
    calculate_rating
    notify_followers
    update_search_index
    log_activity
    EntityMailer.published(self).deliver_later
  end
end
```

## Common Patterns

### Enum with Validation

```ruby
enum :status, { draft: 0, published: 1, archived: 2 }
validates :status, inclusion: { in: statuses.keys }
```

### Polymorphic Association

```ruby
belongs_to :commentable, polymorphic: true
```

### Counter Cache

```ruby
belongs_to :organization, counter_cache: true
# Add: organization.posts_count column
```

### Soft Delete

```ruby
scope :active, -> { where(deleted_at: nil) }
scope :deleted, -> { where.not(deleted_at: nil) }

def soft_delete
  update(deleted_at: Time.current)
end
```

## When to Use Callbacks vs Services

### Use Callbacks For:
- Data normalization (`before_validation`)
- Setting default values (`after_initialize`)
- Maintaining data integrity within the model

### Use Services For:
- Complex business logic
- Multi-model operations
- External API calls
- Sending emails/notifications
- Background job enqueueing

## Commands

### Tests

- **All models:** `bundle exec rspec spec/models/`
- **Specific model:** `bundle exec rspec spec/models/entity_spec.rb`
- **Specific line:** `bundle exec rspec spec/models/entity_spec.rb:25`
- **Detailed format:** `bundle exec rspec --format documentation spec/models/`

### Database

- **Rails console:** `bin/rails console`
- **Database console:** `bin/rails dbconsole`
- **Schema:** `cat db/schema.rb`

### Linting

- **Lint models:** `bundle exec rubocop -a app/models/`
- **Lint specs:** `bundle exec rubocop -a spec/models/`

### Factories

- **Validate factories:** `bundle exec rake factory_bot:lint`

## Model Best Practices

### Do This
- Keep models focused on data and persistence
- Use validations for data integrity
- Use scopes for reusable queries
- Write comprehensive tests for validations, associations, and scopes
- Use FactoryBot for test data
- Delegate business logic to service objects
- Use meaningful constant names
- Document complex validations

### Don't Do This
- Put complex business logic in models
- Use callbacks for side effects (emails, API calls)
- Create circular dependencies between models
- Skip validation tests
- Use `after_commit` callbacks excessively
- Create God objects (models with 1000+ lines)
- Query other models extensively in callbacks

## Boundaries

- **Always:** Write model specs, validate presence/format, define associations with `dependent:`
- **Ask first:** Before adding callbacks, changing existing validations
- **Never:** Add business logic to models (use services), skip tests, modify migrations after they've run
