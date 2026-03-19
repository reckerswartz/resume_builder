# Vikinger Pattern Catalog

## Purpose

This reference captures the major UI families observed through Playwright on the Vikinger demo site and translates them into Rails-first implementation guidance for this workspace.

## Capture Sources

The following pages were reviewed with Playwright while building this skill:

- `https://odindesignthemes.com/vikinger-landing/#demos`
- `https://odindesignthemes.com/vikinger/profile-timeline.html`
- `https://odindesignthemes.com/vikinger/overview.html`
- `https://odindesignthemes.com/vikinger/marketplace-product.html`
- `https://odindesignthemes.com/vikinger/hub-account-info.html`
- `https://odindesignthemes.com/vikinger/logged-out-and-icons.html`

## Demo Families Found on the Landing Page

The landing page grouped the template into these UI families:

- Landing
- Profile timeline and profile subpages
- Newsfeed
- Overview and statistics
- Groups
- Members
- Badges and quests
- Streams and events
- Forums
- Marketplace
- Account hub
- Logged-out pages and icons

This is useful because it shows the theme is not one page template. It is a small design system covering multiple product surfaces.

## Pattern 1: Signed-Out Header and Auth Entry

### Observed on

- `logged-out-and-icons.html`

### What was captured

- Branded top bar with a logo and sparse navigation
- Search input in the header
- Compact email/password login panel in the header area
- Clear register CTA

### Rails translation

Use this as inspiration for:

- Marketing or template-gallery headers
- Compact sign-in forms
- Auth entry points that do not require a full-page modal
- Public template browsing with quick search

### Good component split

- `PublicHeaderComponent`
- `HeaderSearchComponent`
- `InlineSignInFormComponent`

### Notes

Keep this lighter than the source theme. Resume Builder likely needs cleaner marketing pages than a game-community product.

## Pattern 2: Dense Signed-In App Shell

### Observed on

- `profile-timeline.html`
- `overview.html`
- `marketplace-product.html`
- `hub-account-info.html`

### What was captured

- Narrow icon-led primary navigation rail
- Branded top header with search and quick utilities
- Secondary contextual navigation tied to the signed-in user
- Main content area with optional right-column widgets

### Rails translation

Use this for:

- Admin dashboards
- Resume management back office
- AI suggestion workspace
- Export/reporting surfaces

### Recommended layout recipe

```erb
<div class="min-h-screen bg-slate-50">
  <%= render AppShellComponent.new do |shell| %>
    <% shell.with_primary_nav do %>
      <%= render SidebarNavComponent.new(items: primary_items) %>
    <% end %>

    <% shell.with_header do %>
      <%= render DashboardHeaderComponent.new(title: page_title, actions: header_actions) %>
    <% end %>

    <% shell.with_main do %>
      <div class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_20rem]">
        <section class="space-y-6">
          <%= yield %>
        </section>

        <aside class="space-y-6">
          <%= render WidgetCardComponent.new(title: "Recent exports") %>
          <%= render WidgetCardComponent.new(title: "Completion tips") %>
        </aside>
      </div>
    <% end %>
  <% end %>
</div>
```

### Guardrails

- Keep the shell optional for public pages
- Do not force three columns when the content density does not justify it
- Use semantic `nav`, `header`, `main`, and `aside`

## Pattern 3: Profile Hero / Resume Summary Hero

### Observed on

- `profile-timeline.html`
- `overview.html`

### What was captured

- Large identity block with avatar/brand area
- Summary metrics under the name
- Section tabs beneath the hero
- Compact badges and supporting actions

### Rails translation

Map this pattern to:

- Resume header in the editor
- Candidate overview panel
- Template detail hero
- Admin user overview

### Example structure

```erb
<section class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
  <div class="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
    <div class="space-y-3">
      <p class="text-sm font-medium uppercase tracking-wide text-slate-500">Resume</p>
      <h1 class="text-3xl font-semibold text-slate-900"><%= @resume.title %></h1>
      <p class="text-sm text-slate-600"><%= @resume.tagline %></p>
    </div>

    <div class="flex flex-wrap gap-3">
      <%= link_to "Preview", preview_resume_path(@resume), class: primary_button_classes %>
      <%= link_to "Export PDF", export_resume_path(@resume), class: secondary_button_classes %>
    </div>
  </div>

  <div class="mt-6 grid gap-4 sm:grid-cols-3">
    <%= render MetricCardComponent.new(label: "Sections complete", value: @completion.sections_complete) %>
    <%= render MetricCardComponent.new(label: "Strength score", value: @completion.score) %>
    <%= render MetricCardComponent.new(label: "Exports", value: @resume.exports_count) %>
  </div>
</section>
```

## Pattern 4: Feed Cards and Activity Stack

### Observed on

- `profile-timeline.html`

### What was captured

- Repeated stacked cards
- A compact header with author/time context
- Rich content blocks inside cards
- Bottom action row for reaction/comment/share
- Supporting widgets in the side column

### Rails translation

Turn this into:

- Resume activity history
- Suggestion cards from the LLM pipeline
- Collaboration notes
- Export job history and outcomes

### Recommended components

- `ActivityCardComponent`
- `ActivityActionBarComponent`
- `SuggestionCardComponent`
- `JobStatusCardComponent`

### Interaction notes

- Turbo Streams are a better fit than client-side feed frameworks
- Use small Stimulus controllers for expanding content and dismissing notices

## Pattern 5: Dashboard Metrics and Reporting

### Observed on

- `overview.html`

### What was captured

- KPI cards with trend deltas
- Time-range filters
- Leaderboard or table-like sections
- Geographic and report widgets
- Sectioned analytics cards within a unified page

### Rails translation

Use this for:

- Resume completion analytics
- Template usage metrics
- Export/report pages
- Admin reporting dashboards

### Implementation recipe

- Top row: 3-6 `MetricCardComponent` instances
- Mid page: chart or trend cards inside `ReportPanelComponent`
- Lower page: ranked table or audit list inside `DataTableComponent`
- Filters: use GET forms plus Turbo Frames where partial refresh helps

## Pattern 6: Marketplace Detail Page

### Observed on

- `marketplace-product.html`

### What was captured

- Product title and breadcrumb context
- Large preview gallery
- Tabbed details area
- Sticky or emphasized sidebar with pricing and CTA
- Metadata and author cards

### Rails translation

Map this to:

- Resume template detail pages
- Premium add-on pages
- Theme/package merchandising
- Template preview purchase or selection flow

### Recommended components

- `TemplateGalleryComponent`
- `TemplatePurchaseCardComponent`
- `TemplateMetadataComponent`
- `AuthorCardComponent`

### Good data hierarchy

- Main column: preview and narrative
- Right column: price, CTA, support details, metadata
- Below: comparisons, included features, screenshots, FAQ

## Pattern 7: Account Hub and Settings Center

### Observed on

- `hub-account-info.html`

### What was captured

- Grouped navigation by area
- Large but organized forms
- Strong section headings
- Persistent save/discard action area

### Rails translation

Use this for:

- Account settings
- Billing preferences
- AI provider settings
- Export preferences
- Template management settings

### Recommended components

- `SettingsHubNavComponent`
- `SettingsSectionComponent`
- `StickyActionBarComponent`
- `FieldGroupComponent`

### Example shell

```erb
<div class="grid gap-6 xl:grid-cols-[18rem_minmax(0,1fr)]">
  <aside>
    <%= render SettingsHubNavComponent.new(sections: settings_sections, current_key: @section_key) %>
  </aside>

  <section class="space-y-6">
    <%= render SettingsSectionComponent.new(title: "Account Info", description: "Manage your primary account details") do %>
      <%= render "form", user: @user %>
    <% end %>
  </section>
</div>
```

## Pattern 8: Icon Language and Compact Utility Actions

### Observed on

- `logged-out-and-icons.html`

### What was captured

- An explicit icon catalog for product concepts
- Consistent utility-oriented action names
- Small action affordances across the UI

### Rails translation

Do not copy the proprietary icon set directly.

Instead:

- Define a local icon language using permitted assets
- Keep icon meaning stable across editor, preview, export, and settings flows
- Pair icon-only controls with labels or `aria-label`

## Conversion Rules for This Workspace

When adapting these patterns to Resume Builder, prefer:

- **Resume terminology over community terminology**
- **ViewComponents over giant partials**
- **Tailwind utilities over imported vendor CSS**
- **Stimulus controllers over generic jQuery plugins**
- **Turbo frames/streams over full SPA state**
- **Shared preview/export presentation paths over duplicated template markup**

## Legal and Maintenance Guidance

Because Vikinger is a commercial theme, treat it as a reference library, not a copy target.

- Do not paste source HTML, CSS bundles, JavaScript bundles, SVG packs, or illustrations into the app unless licensing is explicitly confirmed
- Prefer recreating layout ideas with the app's own structure, classes, and assets
- Keep the resulting system consistent with the repo's existing Tailwind, Hotwire, and ViewComponent patterns

## Best Use Cases in This Repo

These patterns are especially relevant for:

- Resume editor chrome
- Template gallery and template detail pages
- Export history dashboards
- AI suggestion panels and activity cards
- Admin reporting screens
- Account and platform settings
