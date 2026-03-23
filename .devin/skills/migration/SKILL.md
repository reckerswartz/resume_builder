---
name: migration
description: >-
  Creates safe, reversible database migrations with proper indexes, constraints,
  and zero-downtime strategies. Handles table creation, column additions, index
  management, foreign keys, and data migrations. Use when creating tables, adding
  columns, modifying schema, or when working with migrations, database changes,
  or schema updates.
argument-hint: "[AddColumnToTable column:type] or [CreateTableName]"
triggers:
  - user
  - model
---

# Rails Migration Skill

Creates safe, reversible, and production-optimized database migrations.

## Tech Stack

Ruby 3.3, Rails 8.1, PostgreSQL

## Architecture Context

| Directory | Role |
|-----------|------|
| `db/migrate/` | Migration files (CREATE, NEVER MODIFY existing) |
| `db/schema.rb` | Current schema (Rails auto-generates) |
| `app/models/` | ActiveRecord Models (READ) |

## Safety Checklist

```
Migration Safety:
- [ ] Migration is reversible (has down or uses change)
- [ ] Large tables use batching for updates
- [ ] Indexes added concurrently (if needed)
- [ ] Foreign keys have indexes
- [ ] NOT NULL added in two steps (for existing columns)
- [ ] Default values don't lock table
- [ ] Tested rollback locally
```

## Commands

### Generation

- **Create migration:** `bin/rails generate migration AddColumnToTable column:type`
- **Create model:** `bin/rails generate model ModelName column:type`
- **Empty migration:** `bin/rails generate migration MigrationName`

### Execution

- **Migrate:** `bin/rails db:migrate`
- **Rollback:** `bin/rails db:rollback`
- **Rollback N steps:** `bin/rails db:rollback STEP=3`
- **Status:** `bin/rails db:migrate:status`
- **Specific version:** `bin/rails db:migrate:up VERSION=20231201120000`
- **Redo (rollback + migrate):** `bin/rails db:migrate:redo`

### Verification

- **Dump schema:** `bin/rails db:schema:dump`
- **Check structure:** `bin/rails dbconsole` then `\d table_name`
- **Pending migrations:** `bin/rails db:abort_if_pending_migrations`
- **Prepare test DB:** `bin/rails db:test:prepare`

## Rails 8 Migration Features

- **`create_virtual`:** For computed/generated columns
- **`add_check_constraint`:** For data integrity
- **Deferred constraints:** Use `deferrable: :deferred` for FK constraints

## Safe Migration Patterns

### Pattern 1: Create Table

```ruby
class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.date :event_date
      t.references :account, null: false, foreign_key: true
      t.timestamps
    end

    add_index :events, [:account_id, :event_date]
  end
end
```

### Pattern 2: Add Column (Safe)

```ruby
class AddStatusToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :status, :integer, default: 0, null: false
  end
end
```

### Pattern 3: Add Column with NOT NULL (Two-Step for Existing Tables)

```ruby
# Step 1: Add column with default (allows NULL temporarily)
class AddPriorityToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :priority, :integer, default: 0
  end
end

# Step 2: Add NOT NULL constraint after backfill
class AddNotNullToTasksPriority < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tasks, :priority, false
  end
end
```

### Pattern 4: Add Index (Production Safe - Concurrent)

```ruby
class AddIndexToEventsStatus < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :events, :status, algorithm: :concurrently, if_not_exists: true
  end
end
```

### Pattern 5: Add Foreign Key with Index

```ruby
class AddAccountToEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :events, :account, null: false, foreign_key: true, index: true
  end
end
```

### Pattern 6: Add Enum Column

```ruby
class AddStatusEnumToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :status, :integer, default: 0, null: false
    add_index :orders, :status
  end
end
```

### Pattern 7: Reversible with up/down

```ruby
class ChangeColumnType < ActiveRecord::Migration[8.1]
  def up
    change_column :items, :price, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :items, :price, :integer
  end
end
```

## Production-Safe Patterns

### Column Removal (Always 2 Steps)

```ruby
# Step 1: Ignore the column in the model (deploy first)
class User < ApplicationRecord
  self.ignored_columns += ["old_column"]
end

# Step 2: Remove the column (deploy after)
class RemoveOldColumnFromUsers < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :users, :old_column, :string }
  end
end
```

### Column Renaming (Multiple Deployments)

```
1. Add the new column
2. Synchronize data (background job)
3. Update code to use the new column
4. Remove the old column
```

**Never** use `rename_column` in production - it breaks running code.

### Change Column Type (Safe Way)

```ruby
# Step 1: Add new column
class AddBudgetDecimalToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :budget_decimal, :decimal, precision: 10, scale: 2
  end
end

# Step 2: Backfill data (in a rake task or job)
Event.in_batches.update_all("budget_decimal = budget")

# Step 3: Remove old column (after code updated)
class RemoveOldBudgetFromEvents < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :events, :budget, :integer }
    rename_column :events, :budget_decimal, :budget
  end
end
```

## Data Migrations

### Safe Backfill Pattern

```ruby
class BackfillEventStatus < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    Event.unscoped.in_batches(of: 1000) do |batch|
      batch.where(status: nil).update_all(status: 0)
      sleep(0.1) # Reduce database load
    end
  end

  def down
    # No rollback for data migration
  end
end
```

### Background Job for Large Tables

```ruby
class BackfillProcessedAtJob < ApplicationJob
  def perform(start_id, end_id)
    Event.where(id: start_id..end_id, processed_at: nil)
         .update_all(processed_at: Time.current)
  end
end

# Enqueue in rake task
Event.in_batches(of: 10_000) do |batch|
  BackfillProcessedAtJob.perform_later(batch.minimum(:id), batch.maximum(:id))
end
```

## Recommended Column Types (PostgreSQL)

```ruby
# Text
t.string :name              # varchar(255)
t.text :description         # unlimited text
t.citext :email             # case-insensitive text (extension)

# Numbers
t.integer :count            # integer
t.bigint :external_id       # bigint (external IDs)
t.decimal :price, precision: 10, scale: 2  # exact decimal

# Dates
t.date :birth_date          # date only
t.datetime :published_at    # timestamp with time zone
t.timestamps                # created_at, updated_at

# Booleans
t.boolean :active, null: false, default: false

# JSON
t.jsonb :metadata           # Binary JSON (indexable)

# UUID
t.uuid :external_id, default: "gen_random_uuid()"

# Enum (prefer Rails integer enums)
t.integer :status, null: false, default: 0
```

## Index Strategies

```ruby
# Simple index
add_index :users, :email

# Unique index
add_index :users, :email, unique: true

# Composite index (order matters!)
add_index :submissions, [:entity_id, :created_at]

# Partial index (PostgreSQL)
add_index :users, :email, where: "deleted_at IS NULL", name: "index_active_users_on_email"

# Concurrent index (doesn't block reads)
add_index :users, :email, algorithm: :concurrently

# GIN index for JSONB
add_index :items, :metadata, using: :gin
```

## Foreign Keys

```ruby
# Add reference with FK
add_reference :submissions, :entity, null: false, foreign_key: true

# FK with cascade delete
add_foreign_key :submissions, :entities, on_delete: :cascade

# FK with nullify
add_foreign_key :posts, :users, column: :author_id, on_delete: :nullify

# FK with restrict
add_foreign_key :orders, :users, on_delete: :restrict

# Check constraint
add_check_constraint :items, "price >= 0", name: "price_positive"
```

## Verification Checklist

### Before Creating

- [ ] Is the migration reversible?
- [ ] Are there appropriate NOT NULL constraints?
- [ ] Are necessary indexes created?
- [ ] Are foreign keys defined?
- [ ] Is the migration safe for a large table?

### After Creation

- [ ] `bin/rails db:migrate` succeeds
- [ ] `bin/rails db:rollback` succeeds
- [ ] `bin/rails db:migrate` succeeds again
- [ ] Tests pass: `bundle exec rspec`
- [ ] Schema is consistent: `git diff db/schema.rb`

### For Production

- [ ] No long locks on important tables
- [ ] Indexes added with `algorithm: :concurrently` if necessary
- [ ] Column removal in 2 steps (ignored_columns first)
- [ ] Data backfill done in a job, not in the migration

## Boundaries

- **Always:** Make migrations reversible, use `algorithm: :concurrently` for indexes on large tables, add NOT NULL and FK constraints
- **Ask first:** Before dropping columns/tables, changing column types
- **Never:** Modify migrations that have already run, run destructive migrations in production without backup, use `rename_column` in production
