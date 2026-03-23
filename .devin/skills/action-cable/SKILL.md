---
name: action-cable
description: >-
  Implements real-time features with Action Cable and WebSockets. Use when
  adding live updates, chat features, notifications, real-time dashboards,
  or working with Action Cable, WebSockets, channels, or real-time features.
triggers:
  - model
---

# Action Cable Patterns for Rails 8

## Overview

Action Cable integrates WebSockets with Rails:
- Real-time updates without polling
- Server-to-client push notifications
- Chat and messaging features
- Live dashboards and feeds
- Collaborative editing

## Quick Start

Action Cable is included in Rails by default. Configure it:

```ruby
# config/cable.yml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: solid_cable  # Rails 8 default
  # OR
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") %>
```

## Project Structure

```
app/
├── channels/
│   ├── application_cable/
│   │   ├── connection.rb      # Authentication
│   │   └── channel.rb         # Base channel
│   ├── notifications_channel.rb
│   ├── events_channel.rb
│   └── chat_channel.rb
├── javascript/
│   └── channels/
│       ├── consumer.js
│       ├── notifications_channel.js
│       └── events_channel.js
spec/channels/
├── notifications_channel_spec.rb
└── events_channel_spec.rb
```

## Connection Authentication

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Using Rails 8 authentication
      if session_token = cookies.signed[:session_token]
        if session = Session.find_by(token: session_token)
          session.user
        else
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    end
  end
end
```

## Channel Patterns

Four core patterns are available:

- **Pattern 1: Notifications Channel** — streams per-user notifications via `stream_for current_user`
- **Pattern 2: Resource Updates Channel** — streams updates for a specific resource with authorization via `reject`
- **Pattern 3: Chat Channel** — bidirectional messaging with `speak` and `typing` actions, presence tracking
- **Pattern 4: Dashboard Live Updates** — broadcasts stats and activity feed to all account members

Each pattern follows the same structure:
1. `subscribed` — find the resource, check authorization, call `stream_for`
2. Class-level `broadcast_*` methods — render partials via `ApplicationController.renderer`
3. A matching JavaScript subscription handler with a `received(data)` switch

## Broadcasting

Broadcasting can be triggered from services, models, or callbacks:

- **From a service object** — call `EventsChannel.broadcast_update(event)` after persistence
- **From model callbacks** — use `after_create_commit` to trigger channel broadcasts
- **Turbo Streams integration** — use `broadcast_append_to` / `broadcast_remove_to` helpers directly on models
- **Stimulus controller** — wrap the Action Cable subscription lifecycle inside a Stimulus controller for clean connect/disconnect management
- **Performance patterns** — connection limits, selective broadcasting, debounced broadcasts

## Testing Channels

Key conventions:

```ruby
# Stub connection identity
stub_connection(current_user: user)

# Assert subscription confirmed and streaming
subscribe(event_id: event.id)
expect(subscription).to be_confirmed
expect(subscription).to have_stream_for(event)

# Assert rejection for unauthorized access
expect(subscription).to be_rejected

# Assert broadcast payload
expect {
  described_class.notify(user, notification)
}.to have_broadcasted_to(user).with(hash_including(type: "notification"))
```

## Checklist

- [ ] Connection authentication configured
- [ ] Channel authorization implemented
- [ ] Client-side subscription set up
- [ ] Broadcasting from services/models
- [ ] Channel specs written
- [ ] Error handling in place
- [ ] Reconnection logic on client
- [ ] Performance limits configured
