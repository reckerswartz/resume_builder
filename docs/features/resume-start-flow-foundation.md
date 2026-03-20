# Feature Specification

## General Information

**Feature name:** `Resume Start Flow Foundation`

**Ticket/Issue:** `TBD`

**Priority:** `High`

**Estimate:** `Large (3-5 days across multiple small PRs)`

---

## Objective

**Problem to solve:**

The current `new_resume_path` flow asks the user to choose a title and template immediately, then drops them into the editor. That works, but it misses a lightweight qualification step that can make the start of the experience feel more guided. The hosted comparison flow shows a clear advantage here: it captures experience level before heavier resume setup begins.

This feature adds a small, server-rendered start flow before resume creation. It captures `experience_level`, conditionally asks whether the user is a student for the early-career path, and persists those answers onto the created `Resume` so later recommendation and guidance work can build on a stable foundation.

**Value delivered:**

- adds a guided start without replacing the existing Rails-first creation flow
- creates a durable, low-risk persona signal for later template recommendation and summary guidance work
- improves onboarding clarity for early-career users while keeping the flow lightweight for everyone else

**Success criteria:**
 - [ ] Authenticated users see an experience-level step before the existing resume setup form.
 - [ ] Choosing `Less than 3 years` shows a conditional student follow-up step.
 - [ ] Choosing any other experience option skips the student follow-up and proceeds to resume setup.
 - [ ] When a resume is created, `intake_details` persists the chosen flow answers using string keys.
 - [ ] Existing `template_id` deep links still carry through the start flow and apply to the created resume.
 - [ ] If the final resume setup submission fails validation, the setup form re-renders with selected intake answers and template selection preserved.

---

## Personas Impacted

- [ ] Visitor (unauthenticated)
- [x] Signed-in User
- [x] Resource Owner
- [x] Admin

### Authorization Matrix

| Action | Visitor | User | Owner | Admin |
|--------|---------|------|-------|-------|
| View start flow | ❌ | ✅ | ✅ | ✅ |
| Create resume through start flow | ❌ | ✅ | ✅ | ✅ |
| Edit created draft after creation | ❌ | ❌ | ✅ | ✅ |
| Delete created draft after creation | ❌ | ❌ | ✅ | ✅ |

**Authorization notes:**

- Visitors are blocked by `Authentication` and redirected to `new_session_path`.
- Resume creation continues to rely on `ResumePolicy#create?`, which already allows authenticated users.
- No new roles or policy branches are introduced in v1.

---

## User Stories

### Primary story

```text
As a signed-in resume creator,
I want to answer a short experience question before creating a draft,
So that the app can guide my start and persist lightweight intake context for later personalization.
```

**Acceptance criteria:**

- [ ] The first step at `new_resume_path` presents exactly five experience choices.
- [ ] Selecting `Less than 3 years` leads to a student follow-up step before the setup form.
- [ ] Selecting any other experience option leads directly to the setup form.
- [ ] The student follow-up is optional when shown.
- [ ] On successful creation, the created resume stores the selected intake answers in `intake_details`.
- [ ] A valid `template_id` deep link remains selected on the setup form and on the created resume.
- [ ] If the final setup submission fails validation, the setup form re-renders with intake state and template selection preserved.

### Gherkin Scenarios

```gherkin
Feature: Resume Start Flow Foundation

  Background:
    Given I am signed in
    And at least one user-visible template exists

  Scenario: User chooses a non-junior experience level
    Given I visit the new resume path
    When I choose "3-5 Years"
    Then I should see the resume setup step
    And I should not see "Are you a student?"
    And the flow should retain "experience_level" as "three_to_five_years"

  Scenario: User chooses the junior path and answers the student follow-up
    Given I visit the new resume path
    When I choose "Less than 3 years"
    Then I should see "Are you a student?"
    When I choose "Yes"
    Then I should see the resume setup step
    And the flow should retain "experience_level" as "less_than_3_years"
    And the flow should retain "student_status" as "student"

  Scenario: User skips the optional student follow-up
    Given I selected "Less than 3 years"
    When I continue without choosing a student status
    Then I should see the resume setup step
    And the flow should retain a blank "student_status"

  Scenario: User creates a resume after completing the start flow
    Given I reached the resume setup step with "No Experience"
    When I submit valid resume details
    Then a resume should be created for me
    And the resume intake_details should include "experience_level" => "no_experience"
    And the resume intake_details should include "student_status" => ""
    And I should be redirected to the source step of the editor

  Scenario: Template deep link is preserved through the start flow
    Given I visit the new resume path with a valid template_id
    When I complete the start flow
    Then the setup step should keep that template selected
    When I submit valid resume details
    Then the created resume should use that template

  Scenario: Final setup validation failure preserves intake state
    Given I reached the resume setup step with "3-5 Years"
    And I have a valid template selected
    When I submit invalid resume details
    Then I should remain on the resume setup step
    And the flow should retain "experience_level" as "three_to_five_years"
    And the selected template should remain selected
    And I should see the resume validation errors

  Scenario: Visitor tries to access the start flow
    Given I am not signed in
    When I visit the new resume path
    Then I should be redirected to the sign in page
```

### Secondary story

```text
As an early-career user,
I want the app to optionally ask whether I am a student,
So that future guidance can better fit internships, coursework, and academic projects without forcing every user through that question.
```

---

## Edge Cases and Error Handling

### Identified Edge Cases

| # | Type | Scenario | Expected behavior | Error message |
|---|------|----------|-------------------|---------------|
| 1 | Invalid input | A request submits an unsupported `experience_level` value | Stay on the experience step, preserve safe params, do not advance | `Choose your experience level to continue.` |
| 2 | Unauthorized access | A visitor requests `new_resume_path` | Redirect to sign in and preserve return path | none; existing auth redirect |
| 3 | Guarded flow state | A user attempts to load the student step without first selecting `Less than 3 years` | Redirect or reset back to the experience step | `Choose your experience level first.` |
| 4 | Invalid follow-up value | A request submits an unsupported `student_status` value | Ignore invalid transition, stay on or return to a valid step, do not persist invalid data | `Choose a valid student response or skip this question.` |
| 5 | Deep-link mismatch | `template_id` is present but no longer matches a user-visible template | Continue with default template selection and surface the current unavailable-template alert | `Template is not available.` |
| 6 | Empty optional value | The student follow-up is shown but skipped | Continue to setup with blank `student_status` | none |
| 7 | Validation failure | The final resume setup submission fails because required resume fields are missing | Stay on the setup step, preserve intake answers and template selection, and show resume validation errors | `Show existing inline resume validation errors.` |

### Gherkin Scenarios for Edge Cases

```gherkin
  Scenario: User submits an invalid experience level
    Given I am signed in
    When I submit the experience step with an invalid experience_level
    Then I should remain on the experience step
    And I should see "Choose your experience level to continue."

  Scenario: User tries to open the student step without the junior path
    Given I am signed in
    When I request the student step without selecting "Less than 3 years"
    Then I should be sent back to the experience step
    And I should see "Choose your experience level first."

  Scenario: Invalid template deep link falls back safely
    Given I am signed in
    When I visit the new resume path with an unavailable template_id
    Then I should see "Template is not available."
    And the setup flow should use the default user-visible template

  Scenario: Visitor attempts to create a resume through the start flow
    Given I am not signed in
    When I submit the create action
    Then I should be redirected to the sign in page
    And no resume should be created
```

---

## Incremental PR Breakdown

### Integration branch

**Branch name:** `feature/resume-start-flow-foundation`

### Step 1: Intake persistence on `Resume` (Completed)

**Branch:** `feature/resume-start-flow-foundation-step-1-intake-persistence`

**Status:** `Completed 2026-03-20`

**Objective:**

Add durable storage for start-flow answers without changing existing create behavior when no intake answers are present.

**Content:**

- [x] Migration to add `resumes.intake_details` as `jsonb`, `null: false`, `default: {}`
- [x] `Resume` normalization for string-key JSON persistence
- [x] Lightweight readers/helpers for `experience_level` and `student_status`
- [x] Model specs for normalization and safe defaults

**Estimate:** `45-60 min dev + 30 min review`

**Tests included:**

- [x] Migration is reversible
- [x] `Resume` stores string-key JSON payloads
- [x] Blank intake defaults remain safe
- [x] Unsupported values do not leak into normalized state

---

### Step 2: Controller and parameter plumbing (Completed)

**Branch:** `feature/resume-start-flow-foundation-step-2-param-plumbing`

**Status:** `Completed 2026-03-20`

**Objective:**

Allow the existing create path to accept and persist valid intake data while preserving current template-selection behavior.

**Content:**

- [x] Permit `intake_details` in `ResumesController`
- [x] Pass intake data through `create_resume_params`, `update_resume_params`, and `build_new_resume_from_params` as needed
- [x] Keep `template_id` validation/fallback behavior intact
- [x] Request specs for create with and without intake details

**Estimate:** `60-90 min dev + 30 min review`

**Tests included:**

- [x] Valid intake data persists on create
- [x] Invalid deep-linked template falls back safely
- [x] Existing create success path still redirects to `step=source`
- [x] Existing create failure preserves form state

---

### Step 3: Experience-step start flow (Completed)

**Branch:** `feature/resume-start-flow-foundation-step-3-experience-step`

**Status:** `Completed 2026-03-20`

**Objective:**

Introduce a lightweight server-rendered first step before the existing resume setup form.

**Content:**

- [x] Add `Resumes::StartFlowState` presenter or equivalent state object
- [x] Modify `ResumesController#new` to render the start flow using step-aware state
- [x] Add an experience-step partial with the five hosted-inspired options
- [x] Preserve valid `template_id` through the transition into the setup form
- [x] Presenter/request specs for default rendering and non-junior transitions

**Estimate:** `90-120 min dev + 45 min review`

**Tests included:**

- [x] Default `GET /resumes/new` shows experience step
- [x] Non-junior selection advances directly to setup
- [x] Selected experience level remains visible in flow state
- [x] Unauthenticated access still redirects to sign in

---

### Step 4: Conditional student follow-up (Completed)

**Branch:** `feature/resume-start-flow-foundation-step-4-student-follow-up`

**Status:** `Completed 2026-03-20`

**Objective:**

Add the optional student follow-up for the `Less than 3 years` path and protect the flow from invalid direct access.

**Content:**

- [x] Add a student-step partial with `Yes`, `No`, and skip/continue behavior
- [x] Guard direct access to the student step when prerequisites are missing
- [x] Persist blank student status safely when skipped
- [x] Request specs for junior path, skip path, and guarded transitions

**Estimate:** `90-120 min dev + 45 min review`

**Tests included:**

- [x] Junior path shows the student follow-up
- [x] Skip path reaches setup with blank `student_status`
- [x] Invalid student values do not persist
- [x] Direct student-step access without junior selection is rejected safely

---

### Step 5: Documentation and regression hardening

**Branch:** `feature/resume-start-flow-foundation-step-5-docs-regression`

**Objective:**

Finish the feature with updated docs and regression coverage around the new start path.

**Content:**

- [ ] Update `docs/resume_editing_flow.md` to mention the pre-create start flow
- [ ] Add or refine request/presenter regression coverage for deep links and flash messaging
- [ ] Capture UI screenshots/GIFs for PR review if the team expects visual review artifacts

**Estimate:** `45-60 min dev + 30 min review`

**Tests included:**

- [ ] Deep-link template preservation regression coverage
- [ ] Validation/error-message regression coverage
- [ ] Documentation reflects the new creation path

---

### Merge strategy checklist

- [x] The feature is split into 3-10 steps
- [x] Each step is intended to stay below 400 lines
- [x] Each step has a single, testable objective
- [x] Dependency order is explicit
- [x] Each step includes its own tests

---

## Technical Framing

### Impacted models

#### Existing model: `Resume`

**Changes:**

- [ ] Add attribute: `intake_details:jsonb`
- [ ] Normalize stored JSON to string keys
- [ ] Add helper readers for start-flow answers
- [ ] Keep current behavior unchanged when `intake_details` is blank

**Expected keys in `intake_details` (v1):**

- `experience_level`
- `student_status`

**Allowed values (v1):**

- `experience_level`
  - `no_experience`
  - `less_than_3_years`
  - `three_to_five_years`
  - `five_to_ten_years`
  - `ten_plus_years`
- `student_status`
  - `student`
  - `not_student`
  - blank when skipped

### Validation rules

Only new or behaviorally changed fields are listed here.

| Field | Type | Required | Validation rules | Error message |
|-------|------|----------|------------------|---------------|
| `intake_details[experience_level]` | string | Yes for progressing past step 1 and for final create in this flow | inclusion in the five allowed values | `Choose your experience level to continue.` |
| `intake_details[student_status]` | string | No | blank allowed; otherwise inclusion in `student` / `not_student`; accepted only when `experience_level = less_than_3_years` | `Choose a valid student response or skip this question.` |
| `resume[title]` | string | Yes on final create step | existing `Resume` presence validation remains authoritative | existing model error |
| `resume[template_id]` | string/integer | No | if present, it must resolve within `Template.user_visible`; otherwise fall back safely and surface the existing unavailable-template alert | `Template is not available.` |

### Migration

```ruby
# db/migrate/*_add_intake_details_to_resumes.rb
class AddIntakeDetailsToResumes < ActiveRecord::Migration[8.1]
  def change
    add_column :resumes, :intake_details, :jsonb, null: false, default: {}
  end
end
```

**Migration attention points:**

- [x] Reversible with `change`
- [x] Safe default for existing rows
- [x] No index required in v1 because the field is not queried in user-facing lists yet
- [x] Persisted shape should remain consistent with the app rule of string-key JSON payloads

### Controllers

#### Existing controller: `ResumesController`

**Changes:**

- [ ] `new` renders a step-aware pre-create flow before the existing setup form
- [ ] `create` accepts and persists valid `intake_details`
- [ ] failed `create` re-renders the setup form with preserved intake state and template selection
- [ ] `build_new_resume_from_params` preserves entered values on validation failure
- [ ] Existing template-selection fallback behavior remains intact

**Strong parameters:**

```ruby
params.require(:resume).permit(
  :title,
  :headline,
  :summary,
  :slug,
  :template_id,
  :source_mode,
  :source_text,
  :source_document,
  contact_details: {},
  settings: {},
  intake_details: [:experience_level, :student_status]
)
```

**Controller notes:**

- The implementation may use query params, hidden fields, or session-backed transient state before `Resume` exists.
- The persisted source of truth after creation must be `Resume#intake_details`.
- The controller must re-check prerequisites server-side instead of trusting client navigation alone.

### Routes

```ruby
# config/routes.rb
resources :resumes
```

**Routing note:**

- No new top-level route is required in v1.
- Step progression may be expressed via `GET /resumes/new?step=...` and standard `POST /resumes`.

### Services / Presenters

**Presenter:** `Resumes::StartFlowState`

**Responsibility:**

Encapsulate which pre-create step should render, which transitions are valid, which previous answers are available, and whether the existing setup form should be displayed.

**Expected responsibilities:**

- derive the current step from safe params/transient state
- expose the five experience options
- determine whether the student follow-up is reachable
- expose back/continue destinations
- preserve the selected `template_id` into the setup step

**Service note:**

- No separate business service is required in v1 unless flow branching grows beyond presenter/controller collaboration.

### Policies (Pundit)

**Policy:** `ResumePolicy`

**New rules:**

- none

**Existing rules relied on:**

- `create?` remains available to authenticated users
- ownership/admin checks remain unchanged for post-create resume actions

### Views and components

#### Views likely to change

- `app/views/resumes/new.html.erb`
- `app/views/resumes/_form.html.erb`
- new partial: `app/views/resumes/_start_flow_experience_step.html.erb`
- new partial: `app/views/resumes/_start_flow_student_step.html.erb`

#### New non-component object likely to add

- `app/presenters/resumes/start_flow_state.rb`

#### UI notes

- reuse existing UI components and Tailwind helpers where possible
- do not introduce a new custom component unless repetition clearly justifies it
- keep the flow server-rendered and HTML-first

### JavaScript (Stimulus)

- none required in v1
- if a later implementation adds progressive enhancement, the server-rendered flow must still work without JavaScript

### Jobs / async work

- none

---

## Test Strategy

### Model tests

**File:** `spec/models/resume_spec.rb`

**Tests to add or extend:**

- [ ] `intake_details` defaults to `{}`
- [ ] stored JSON is normalized to string keys
- [ ] allowed values remain accessible via helper readers
- [ ] blank values remain safe for existing resumes that predate the feature

### Request specs

**File:** `spec/requests/resumes_spec.rb`

**Tests to add or extend:**

- [ ] `GET /resumes/new` requires authentication
- [ ] default new page shows the experience step
- [ ] selecting a non-junior experience path reaches setup directly
- [ ] selecting `Less than 3 years` reaches the student step
- [ ] skipping the student step reaches setup with blank `student_status`
- [ ] invalid experience values do not advance
- [ ] direct student-step access without a junior selection is blocked safely
- [ ] successful create persists `intake_details` with string keys
- [ ] invalid final create preserves intake state and selected template
- [ ] valid `template_id` deep links remain selected on setup and create
- [ ] unavailable template deep links show the existing alert and fall back safely

### Presenter tests

**File:** `spec/presenters/resumes/start_flow_state_spec.rb`

**Tests to add:**

- [ ] current step resolution
- [ ] student-step reachability rules
- [ ] preserved values for experience and student answers
- [ ] deep-link template carry-through state

### Integration / feature tests

**File:** optional `spec/features/resume_start_flow_foundation_spec.rb`

**Recommended scenarios if added:**

- [ ] complete happy path for junior user
- [ ] complete happy path for non-junior user
- [ ] validation failure preserves flow state and visible selections

**Note:**

Request specs are sufficient for the first implementation if the flow remains fully server-rendered and the UI interactions stay simple.

### Policy tests

- no new policy spec required unless implementation adds a new custom action or changes authorization behavior

### Component tests

- not required unless a new reusable component is extracted during implementation

---

## Security Considerations

- [x] **Strong parameters** must explicitly whitelist `intake_details`
- [x] **Authentication** must continue to protect `new` and `create`
- [x] **Pundit authorization** remains in force through existing `ResumePolicy`
- [x] **Validation** must reject unsupported flow values server-side
- [x] **Template safety** must keep selection scoped to `Template.user_visible`
- [x] **Mass assignment** must stay limited to allowed intake keys
- [x] **XSS** risk stays low because inputs are plain text / choice values rendered with Rails escaping
- [x] **Data minimization**: only store the minimal persona fields needed for later guidance; do not expand to sensitive personal details in this feature
- [x] **Flow guardrails**: never trust direct access to later start-flow steps without prerequisite answers

---

## Performance Considerations

- [x] No background jobs are needed
- [x] No extra query-heavy lists are introduced
- [x] No `intake_details` index is needed until product requirements include querying/filtering by intake answers
- [x] The feature should avoid extra database writes before the final resume creation
- [x] Existing template loading behavior should remain memoized/scoped as it is today

---

## UI / UX Considerations

### UI/UX checklist

- [x] **Responsive**: the step layout must work on mobile, tablet, and desktop
- [x] **Accessibility**: each option must have clear button text, semantic headings, and visible focus states
- [x] **Feedback**: validation and unavailable-template alerts must be user-safe and actionable
- [x] **HTML-first**: no JavaScript is required for core step progression
- [x] **Error handling**: invalid transitions must preserve the user’s safe inputs and show a clear next action

### Interactive states

| State | Description | Implementation |
|------|-------------|----------------|
| **Loading** | Standard full-page render | normal request/response cycle; no spinner requirement in v1 |
| **Success** | Resume created successfully | existing create success redirect to `edit_resume_path(@resume, step: "source")` with notice |
| **Error** | Invalid start-flow submission or unavailable template | inline or flash alert; stay on valid step; preserve safe inputs |
| **Empty** | Optional student answer intentionally skipped | continue to setup with blank `student_status` | none |
| **Disabled** | Later steps without prerequisites | do not render as accessible destinations; server guards invalid access |

### User-facing messages

| Context | Type | Message |
|---------|------|---------|
| Missing experience selection | error | `Choose your experience level to continue.` |
| Invalid student follow-up value | error | `Choose a valid student response or skip this question.` |
| Student step requested too early | error | `Choose your experience level first.` |
| Unavailable template deep link | error | `Template is not available.` |
| Final create validation failure | error | `Show existing inline resume validation errors.` |
| Successful create | success | `Resume created successfully.` |

### Product decisions locked for v1

- show exactly five experience choices
- show the student follow-up **only** for `Less than 3 years`
- keep the student follow-up optional when shown
- keep the existing resume setup form and template picker as the final pre-create step
- do not add source fork or template recommendation behavior in this feature

---

## Deployment Plan

### Prerequisites

- [ ] Migration tested up and down
- [ ] Request/model/presenter specs pass
- [ ] No new environment variables required
- [ ] Visual review assets prepared if the team wants screenshots for the changed `new` flow

### Deployment steps

1. Deploy the code
2. Run `rails db:migrate`
3. Verify authenticated access to `new_resume_path`
4. Create one resume through the non-junior path
5. Create one resume through the junior path with skipped student status
6. Confirm the created rows persist `intake_details` as expected

### Rollback plan

```bash
rails db:rollback STEP=1
# then redeploy the previous release
```

---

## Documentation to update

- [ ] `docs/resume_editing_flow.md`
- [ ] This feature spec if scope changes during review
- [ ] PR description/screenshots for the updated `new` flow
- [ ] Review whether `db/seeds.rb` needs a sample `intake_details` payload for demo data after implementation

---

## Notes and Open Questions

**Open questions:**

- None blocking for the draft spec.
- If product later wants recommendations, they should be specified in a follow-up feature spec instead of being folded into this one.

**Technical decisions:**

- Persist final answers on `Resume#intake_details`
- Keep transient pre-create state lightweight and server-rendered
- Preserve JSON string-key consistency with the rest of the app

**Points of attention:**

- Do not accidentally broaden the student follow-up to `No Experience` unless product explicitly asks for it later
- Do not allow invalid step params to bypass prerequisite checks
- Keep existing template fallback behavior intact

**External dependencies:**

- none

---

**Date created:** `2026-03-20`

**Author:** `Cascade`

**Reviewers:** `TBD`

**Status:** `Draft`

---

## Review Readiness Checklist

### Must have

- [x] Objective and user value are clear
- [x] Personas are identified
- [x] Primary user story is documented
- [x] Acceptance criteria are testable
- [x] Gherkin scenarios are included
- [x] At least 3 edge cases are documented
- [x] Authorization matrix is complete

### Should have

- [x] Validation rules are documented
- [x] Technical touchpoints are listed
- [x] Database changes are specified
- [x] Policy expectations are documented
- [x] Test strategy is defined

### UI-specific

- [x] Success/error/empty states are documented
- [x] User messages are defined
- [x] Responsive and accessibility expectations are stated

### Medium/Large feature

- [x] Incremental PR breakdown is included
- [x] Each PR is scoped small
- [x] Dependencies between PRs are clear
- [x] Tests are included in each step
