# ResumeBuilder.com Reference Guide

## Purpose

This document records a Playwright-based product and UI audit of `https://www.resumebuilder.com/` and related unauthenticated app routes.

It is intended as a **reference package** for our application work, not as documentation of our current Rails implementation.

The goal is to capture:

- The main information architecture
- The major user flows
- The important UI patterns
- The visible links and what they do
- The implementation ideas we may want to adapt in our own app
- Point-in-time screenshots saved inside this repository

## Audit Scope

- **Audit date**: 2026-03-19
- **Method**: Playwright navigation, snapshots, interactions, and screenshots
- **Scope**: Public marketing pages plus unauthenticated builder entry points
- **Not covered deeply**: Authenticated account area, checkout/subscription flow, and every individual example/detail page

## Saved Screenshots

The following screenshots were captured and saved in `docs/`:

- `../../resumebuilder_homepage.png`
- `../../resumebuilder_templates.png`
- `../../resumebuilder_examples.png`
- `../../resumebuilder_app_splash.png`
- `../../resumebuilder_editor_tips.png`
- `../../resumebuilder_cover_letter_experience.png`
- `../../resumebuilder_import_flow.png`
- `../../resumebuilder_signin.png`
- `../../resumebuilder_career_center.png`
- `../../resumebuilder_homepage_mobile.png`
- `../../resumebuilder_signin_mobile.png`

## Audited Pages

| Page | URL | Purpose | Screenshot |
| --- | --- | --- | --- |
| Marketing homepage | `https://www.resumebuilder.com/` | Main acquisition page with hero, templates, features, FAQs, and footer IA | `../../resumebuilder_homepage.png` |
| Resume templates hub | `https://www.resumebuilder.com/resume-templates/` | Template discovery, color variants, author trust, long-form SEO content | `../../resumebuilder_templates.png` |
| Resume examples hub | `https://www.resumebuilder.com/resume-examples/` | Searchable example library with category taxonomy and deep job links | `../../resumebuilder_examples.png` |
| Resume builder editor | `https://app.resumebuilder.com/build-resume/section/expr` | In-app resume wizard with stepper, completeness meter, form fields, preview/next flow | `../../resumebuilder_app_splash.png` |
| Resume editor tips state | `https://app.resumebuilder.com/build-resume/section/expr` | Same builder step with contextual help tooltip expanded | `../../resumebuilder_editor_tips.png` |
| Cover letter builder step | `https://app.resumebuilder.com/build-letter/experience` | Cover-letter wizard asking for experience level before template selection | `../../resumebuilder_cover_letter_experience.png` |
| Resume import flow | `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow` | Import-first upload flow with local and cloud options | `../../resumebuilder_import_flow.png` |
| Sign-in page | `https://app.resumebuilder.com/signin` | Auth gate reached from account-oriented entry points | `../../resumebuilder_signin.png` |
| Career Center hub | `https://www.resumebuilder.com/career-center/` | Editorial content hub that cross-links advice, templates, examples, and reports | `../../resumebuilder_career_center.png` |
| Mobile homepage | `https://www.resumebuilder.com/` | Narrow-viewport acquisition experience at `390x844` | `../../resumebuilder_homepage_mobile.png` |
| Mobile sign-in | `https://app.resumebuilder.com/signin` | Narrow-viewport auth screen at `390x844` | `../../resumebuilder_signin_mobile.png` |

## Screenshot Gallery

### Homepage

![ResumeBuilder homepage](../../resumebuilder_homepage.png)

### Templates Hub

![ResumeBuilder templates hub](../../resumebuilder_templates.png)

### Examples Hub

![ResumeBuilder examples hub](../../resumebuilder_examples.png)

### Resume Builder Editor

![ResumeBuilder resume editor](../../resumebuilder_app_splash.png)

### Resume Builder Tips State

![ResumeBuilder editor tips](../../resumebuilder_editor_tips.png)

### Cover Letter Experience Step

![ResumeBuilder cover letter experience step](../../resumebuilder_cover_letter_experience.png)

### Import Flow

![ResumeBuilder import flow](../../resumebuilder_import_flow.png)

### Sign-In Page

![ResumeBuilder sign-in](../../resumebuilder_signin.png)

### Career Center Hub

![ResumeBuilder Career Center](../../resumebuilder_career_center.png)

### Mobile Homepage

![ResumeBuilder homepage mobile](../../resumebuilder_homepage_mobile.png)

### Mobile Sign-In

![ResumeBuilder sign-in mobile](../../resumebuilder_signin_mobile.png)

## Phase-by-Phase Audit Log

### Phase 1: Marketing Homepage

#### Actions performed

1. Opened `https://www.resumebuilder.com/`
2. Reviewed the header navigation, hero CTAs, template strip, feature sections, FAQ block, and footer
3. Extracted the visible links on the page
4. Captured a full-page screenshot

#### What the page does

The homepage is a classic acquisition funnel.

It pushes users toward one of three actions:

- Start building a new resume
- Import an existing resume
- Browse templates/examples first and then enter the builder

It mixes:

- High-visibility CTAs
- SEO-oriented supporting content
- Social proof
- Template/example discovery
- FAQ content that answers pricing and workflow objections

#### Major homepage links and observed behavior

##### Global header

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Resume Builder App` | `https://app.resumebuilder.com/build-resume` | Sends the user directly into the resume builder flow |
| `Resume Examples` | `/resume-examples/` | Opens the example library |
| `Resume Templates` | `/resume-templates/` | Opens the template gallery |
| `Cover Letter Builder` | `https://app.resumebuilder.com/build-letter` | Sends the user into the cover-letter flow |
| `Career Center` | `/career-center/` | Opens editorial/career content |
| `My Account` | `https://app.resumebuilder.com/my-account/` | Entry point for account/authenticated area |
| `Build My Resume` | `https://app.resumebuilder.com/build-resume` | Primary CTA in header |

##### Hero and above-the-fold CTA links

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Create My Resume Now` | `https://app.resumebuilder.com/build-resume` | Starts a new resume |
| `Import Resume` | `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow` | Starts an import-first flow |
| `AI resume builder` | `/ai-resume-builder/` | Explains the AI-assisted builder feature |
| `Free users` | `/career-center/how-to-use-resume-builder-for-free/` | Explains the free usage/download model |

##### Template and example discovery links

| Link pattern | Destination pattern | Observed purpose |
| --- | --- | --- |
| `Use This Template` | `https://app.resumebuilder.com/build-resume/?skin=...&theme=...&templateflow=selectresume` | Starts the builder with a preselected template and color theme |
| `See All Resume Templates` | `/resume-templates/` | Opens the full template directory |
| `See This ... Resume Example` | `/resume-examples/.../` | Opens a specific example page |
| `See all Resume Examples` | `/resume-examples/` | Opens the example hub |

##### Additional CTA and content links

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Get Started Now` | `https://app.resumebuilder.com/build-resume` | Secondary CTA repeated lower on the page |
| `Try Out Our AI Resume Builder` | `https://app.resumebuilder.com/build-resume` | Routes users into the builder from AI feature content |
| `Create Resume from Phone` | `https://app.resumebuilder.com/build-resume` | Mobile-oriented CTA |
| `Get Expert Guidance` | `https://app.resumebuilder.com/build-resume` | CTA tied to advisory content |
| `Customize My Resume Now` | `https://app.resumebuilder.com/build-resume` | CTA tied to template customization content |
| `Import My Resume` | `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow` | Repeated import CTA |

##### Footer and trust links

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Trustpilot reviews` | Trustpilot profile | Social proof |
| `linkedin`, `twitter`, `instagram`, `tt`, `fb` | Social profiles | Brand/social presence |
| `AI Resume Builder` | `/ai-resume-builder/` | Footer shortcut to AI feature page |
| `Basic Resume Examples` | `/resume-examples/basic/` | Footer shortcut to a canonical example |
| `How To Write a Resume` | `/career-center/how-to-make-a-resume/` | Footer educational content |
| `About Us` | `/about-us/` | Company information |
| `Contact Us` | `/about-us/#contact` | Contact anchor |
| `Privacy Policy` | `/privacy-policy/` | Legal |
| `Terms of Service` | `/terms-and-conditions/` | Legal |
| `Accessibility` | `/accessibility/` | Accessibility statement |
| `Do Not Sell or Share` | `https://app.resumebuilder.com/donotsell_information` | Privacy/compliance page |

### Phase 2: Resume Templates Hub

#### Actions performed

1. Opened `https://www.resumebuilder.com/resume-templates/`
2. Reviewed the breadcrumb, author trust strip, CTA block, template gallery, color choices, FAQ content, and footer
3. Extracted visible links and repeated CTA patterns
4. Captured a full-page screenshot

#### What the page does

This page blends **template discovery** and **SEO content**.

Observed structure:

- Intro section with author/reviewer trust
- Primary builder/import CTAs
- Large template grid
- Color swatch controls
- Long-form content describing template categories and resume advice
- FAQ content
- Repeated CTA near the end of the page

#### Notable UI patterns

- The gallery looks visual-first, with each template card showing a preview and a short description
- Colors appear to be a separate control from the template card itself
- The page reuses the same global navigation and footer as the homepage
- Many `Use This Template` links share the same route shape and vary only by `skin` and `theme`

#### Important links and what they do

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Start Your Resume Now` | `https://app.resumebuilder.com/build-resume` | Sends the user straight into the builder |
| `Import Resume` | `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow` | Import-first entry |
| `Use This Template` | `https://app.resumebuilder.com/build-resume/?skin=...&theme=...&templateflow=selectresume` | Opens the builder with a specific template + theme |
| `Build My Resume Now` | `https://app.resumebuilder.com/build-resume` | Repeated CTA lower in the page |
| `Get Started Now` | `https://app.resumebuilder.com/build-resume` | CTA in sidebar/footer area |
| `Frank Hackett` | `/about-us/frank-hackett/` | Author profile page |
| `Jacob Meade` | `/about-us/jacob-meade/` | Reviewer profile page |
| `Google Docs` | `/resume-templates/google-docs/` | Specialized template subcategory |
| `Microsoft Word` | `/resume-templates/word/` | Specialized template subcategory |
| `basic, simple resume template` | `/resume-templates/basic-and-simple/` | FAQ/supporting content link |

#### Key takeaways

- Template selection is a first-class conversion surface
- Theme selection is encoded in URL params, not hidden behind a later step
- The page is doing double duty as both a content landing page and a conversion page

### Phase 3: Resume Examples Hub

#### Actions performed

1. Opened `https://www.resumebuilder.com/resume-examples/`
2. Reviewed the hero, carousel, search box, taxonomy list, FAQ content, and footer
3. Clicked `Accounting and Finance` to test whether taxonomy links route or filter in place
4. Captured a full-page screenshot
5. Extracted visible link patterns

#### What the page does

This page is a **large discovery directory** for example resumes.

Observed structure:

- A top trust/CTA section similar to templates
- A popular examples carousel
- A `Search by Job` field
- A long taxonomy of example categories with item counts
- Many deep example links for job titles and professions
- Supporting advice links and FAQ content

#### Observed interaction behavior

The category links such as `Accounting and Finance` use `javascript:void(0)` rather than a traditional route.

Observed implication:

- The examples hub is using JS-driven in-page interaction for taxonomy navigation, filtering, or anchored expansion
- Clicking the category did **not** change the URL
- The page remained on the same route during the interaction

#### Important links and what they do

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Start Your Resume Now` | `https://app.resumebuilder.com/build-resume` | Enter the builder from the examples library |
| `Import Resume` | `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow` | Import-first flow |
| `Go to example` | `/resume-examples/.../` | Opens a specific example detail page |
| `Search by Job` | In-page control | Text entry for narrowing examples |
| `Accounting and Finance`, `Business`, `Education`, etc. | `javascript:void(0)` | In-page category interaction rather than a conventional navigation link |
| `Choose a Resume Template` | `https://app.resumebuilder.com/build-resume` | CTA from advice content back into the builder |
| `How To Make a Resume` | `/career-center/how-to-make-a-resume/` | Editorial support content |
| `How Many Jobs Should You List on a Resume?` | `/career-center/how-many-jobs-should-you-list-on-a-resume/` | Related resume advice |
| `How to Include Personal and Academic Projects on Your Resume` | `/career-center/how-to-include-personal-and-academic-projects-on-your-resume/` | Related resume advice |

#### Key takeaways

- Resume examples are treated as an SEO-scaled library, not a small curated gallery
- The search + taxonomy combination is a major discovery surface
- The page is designed to capture users earlier in the funnel, before they are ready to commit to a template

### Phase 4: Resume Builder App

#### Actions performed

1. Opened `https://app.resumebuilder.com/build-resume`
2. Observed an intro screen with `Just three easy steps`
3. The app session later resolved into the actual wizard route: `https://app.resumebuilder.com/build-resume/section/expr`
4. Captured the default editor state
5. Clicked `Tips` to reveal the contextual help panel
6. Captured the tips-expanded state
7. Extracted visible links on the editor route

#### What the page does

The builder route is a **step-based editor** rather than a browse page.

Observed editor structure on the `Experience` step:

- Left sidebar stepper
- Completion percentage
- Step-specific form content in the main area
- Primary `Next` action
- Secondary `Preview` action
- Contextual `Tips` helper
- Legal/footer links inside the app shell

#### Observed stepper items

- `Heading`
- `Experience`
- `Education`
- `Skills`
- `Summary`
- `Finalize`

#### Observed form fields and actions on the experience step

| Element | Observed purpose |
| --- | --- |
| `Job Title *` | Required field |
| `Employer` | Optional or non-required employer field |
| Suggested experience chips | `Internships`, `Volunteering`, `Teacher’s Assistant (TA)`, `Babysitter or Nanny`, `Pet Sitter`, `Tutor` |
| `Location` | Text field |
| `Remote` | Boolean toggle |
| `Start Date` | Month + year controls |
| `End Date` | Month + year controls |
| `I currently work here` | Boolean toggle that likely affects end date requirements |
| `Preview` | View current resume rendering |
| `Next` | Move to the next step |

#### Tips panel behavior

Clicking `Tips` opened a floating helper panel titled `Expert Insights`.

The content focused on:

- Explaining what hiring managers look for in work history
- Advising against abbreviated job titles
- Encouraging start/end dates
- Allowing users to estimate details and refine later

This is a strong pattern because it provides guidance without forcing a separate help page.

#### Important links and what they do

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Heading` | `/build-resume/section/cntc` | Navigate to heading/contact step |
| `Experience` | `/build-resume/section/expr` | Current step |
| `Education`, `Skills`, `Summary`, `Finalize` | Same step URL was exposed in the captured state | Likely disabled or not yet available until progress rules are satisfied |
| `Terms of Use` | `https://app.resumebuilder.com/terms-conditions` | App-specific legal page |
| `Privacy Policy` | `https://app.resumebuilder.com/privacy-policy` | App-specific legal page |
| `Terms & Conditions` | `https://www.resumebuilder.com/terms-and-conditions` | Marketing-site legal page |
| `Privacy Policy` | `https://www.resumebuilder.com/privacy-policy` | Marketing-site legal page |
| `Accessibility` | `https://www.resumebuilder.com/accessibility` | Accessibility page |
| `Contact Us` | `https://www.resumebuilder.com/about-us/#contact` | Contact anchor |
| `Do Not Share or Sell My Personal Information` | `https://app.resumebuilder.com/donotsell_information` | Privacy/compliance page |

#### Important implementation observations

- The editor emphasizes **guided completion**, not open-ended editing
- Completeness is visible at all times
- The app uses a very narrow, form-focused layout with no in-page preview visible by default
- The stepper and helper content make the builder feel opinionated and hand-held

### Phase 5: Cover Letter Builder

#### Actions performed

1. Opened `https://app.resumebuilder.com/build-letter`
2. Observed an intro page with `Just three simple steps`
3. Triggered the primary CTA and accepted a `beforeunload` confirmation
4. Allowed the route to settle on `https://app.resumebuilder.com/build-letter/experience`
5. Captured the experience-level step screenshot and snapshot

#### What the flow does

The cover-letter flow appears to start with **qualification/experience segmentation** before the user reaches letter composition.

Observed experience choices:

- `No Experience`
- `Less Than 3 Years`
- `3-5 Years`
- `5-10 Years`
- `10+ Years`

This suggests the system likely personalizes templates or advice based on experience level before moving deeper into the builder.

#### Important links and actions

| Link or action | Destination / behavior | Observed purpose |
| --- | --- | --- |
| `Create my cover letter` | JS-triggered transition | Starts the cover-letter flow |
| `cover-letter-logo` | `javascript:void(0)` | App shell/logo element |
| `Contact Us` icon | `javascript:void(0)` in captured state | Likely opens support/contact interaction |
| `Terms & Conditions` | `https://www.resumebuilder.com/terms-and-conditions/` | Legal |
| `Privacy Policy` | `https://www.resumebuilder.com/privacy-policy/` | Legal |
| `Accessibility` | `https://www.resumebuilder.com/accessibility/` | Accessibility |
| `CONTACT US` | `https://www.resumebuilder.com/about-us/#contact` | Contact page |
| Experience buttons | In-app state transition | Selects user experience level |

### Phase 6: Resume Import Flow

#### Actions performed

1. Opened `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow`
2. Captured the visible upload options and action buttons
3. Saved a full-page screenshot of the import UI
4. Probed the route transitions to understand how import hands off to the builder

#### What the page does

This page is an **import-first intake surface** for users who already have a resume.

Observed structure:

- Large drag-and-drop upload target
- Local file picker button
- Cloud-provider buttons for `Google Drive` and `Dropbox`
- A `Build New Resume` branch for users who abandon import and start blank
- A visible `Next` continuation button
- Legal/footer links in the app shell

#### Important actions and what they do

| Action or link | Destination / behavior | Observed purpose |
| --- | --- | --- |
| `Browse` | Local file picker | Starts an import from the user’s device |
| `Google Drive` | In-app provider action | Starts cloud import from Google Drive |
| `Dropbox` | In-app provider action | Starts cloud import from Dropbox |
| `Build New Resume` | In-app start-from-scratch branch | Lets users exit the import path and begin a blank resume |
| `Next` | In-app continuation control | Likely advances after a file is selected or reviewed |
| `Terms & Conditions` | `https://www.resumebuilder.com/terms-and-conditions` | Legal |
| `Privacy Policy` | `https://www.resumebuilder.com/privacy-policy` | Legal |
| `Accessibility` | `https://www.resumebuilder.com/accessibility` | Accessibility |
| `Contact Us` | `https://www.resumebuilder.com/about-us/#contact` | Contact page |

#### Key takeaways

- Import is treated as a first-class alternative to starting from a blank resume
- Cloud import is surfaced immediately, not buried behind later steps
- The visual treatment uses background resume samples to reassure users that their imported file will map into a designed template

#### Handoff limitations observed in this pass

- Transition attempts out of the import route repeatedly triggered `beforeunload` prompts
- The builder handoff was not stable enough in this session to document file-review, parsing, or validation states confidently
- A follow-up pass with an actual uploaded file is still needed

### Phase 7: Preview, Finalize, and Download Probe

#### Actions performed

1. Attempted direct access to `https://app.resumebuilder.com/build-resume/section/expr`
2. Probed the page for a visible `Preview` action in a self-contained scripted run
3. Recorded the resulting URL, visible body text, and console behavior

#### What appears intended to happen

Based on the homepage copy, FAQ language, and the phase 1 stepper state, the intended flow appears to be:

`builder stepper` -> `preview` -> `finalize` -> `download or account-related completion`

#### What actually happened in this pass

- The direct builder-step route sometimes loaded only as `Resume Wizard Page Bootstrapping`
- The scripted probe did not find a reliable `Preview` control in that broken state
- The route logged front-end errors, including `lottieElement is not defined`
- The only obvious continuation control detected in that degraded state was `Next`

#### Assessment

The preview/finalize/download path was **not stable enough to document as confirmed behavior** in this pass.

The most defensible conclusion is:

- The product is designed around a guided builder that should eventually lead to preview and download
- The specific direct-route bootstrap path was unreliable during this audit and needs a dedicated re-check in a stable session

### Phase 8: Account and Sign-In Entry

#### Actions performed

1. Opened `https://app.resumebuilder.com/my-account/`
2. Confirmed the route redirected to `https://app.resumebuilder.com/signin`
3. Captured the sign-in page and extracted the visible actions

#### What the page does

The account entry is an **auth gate** rather than a public dashboard.

Observed sign-in structure:

- Brand/logo header back to the marketing site
- Social sign-in buttons
- Email/password form
- Password-reset entry point
- Legal consent copy below submit
- `Sign up for free` link that routes users back into the builder funnel

#### Important links and actions

| Action or link | Destination / behavior | Observed purpose |
| --- | --- | --- |
| `My Account` | Redirects to `/signin` | Account-oriented CTA resolves to authentication |
| `Sign in with Google` | `#` in captured state | Social auth entry point |
| `Sign in with Facebook` | `#` in captured state | Social auth entry point |
| `Email Address` + `Password` | Form fields | Standard credential sign-in |
| `Forgot your password?` | Reset flow entry | Password recovery |
| `Submit` | Form submission | Sign-in attempt |
| `Sign up for free` | `https://app.resumebuilder.com/build-resume` | New-account path routes users back into the product funnel |
| `Terms and Conditions` | `https://www.resumebuilder.com/terms-and-conditions/` | Legal |
| `Privacy Policy` | `https://www.resumebuilder.com/privacy-policy/` | Legal |
| Footer `Contact Us` | `https://www.resumebuilder.com/about-us/#contact` | Contact page |

#### Key takeaways

- `My Account` is a funnel entry into sign-in, not a partially accessible account page
- The sign-in screen is compact and conversion-focused
- The sign-up path deliberately returns users to resume creation instead of a separate marketing registration page

### Phase 9: Career Center Hub

#### Actions performed

1. Opened `https://www.resumebuilder.com/career-center/`
2. Reviewed the table of contents, article groupings, expert profiles, and footer IA
3. Captured a full-page screenshot
4. Extracted visible links from the page

#### What the page does

The Career Center is an **editorial content hub** that sits between pure marketing and pure product.

Observed structure:

- Breadcrumb and author trust area
- In-page table of contents with anchor links
- Sectioned article lists for advice and templates
- Job-market and special-report content
- Expert-team directory
- Repeated footer shortcuts into builder, examples, templates, and advice

#### Major content sections observed

- `Featured Advice`
- `Resume Templates`
- `Resume Advice`
- `Cover Letter Advice`
- `Interview Advice`
- `Jobs`
- `Careers`
- `Special Reports`
- `Meet Our Career Experts`

#### Important links and what they do

| Link | Destination | Observed purpose |
| --- | --- | --- |
| `Build My Resume` | `https://app.resumebuilder.com/build-resume` | Primary conversion CTA from the content hub |
| `Featured Advice`, `Resume Templates`, `Resume Advice`, etc. | `#...` anchor links | Jump users through the long page via table of contents |
| `How To Make a Resume With Examples and Guide` | `/career-center/how-to-make-a-resume/` | Canonical editorial entry point |
| `Basic and Simple Resume Templates and Examples for 2026` | `/resume-templates/basic-and-simple/` | Cross-link from editorial content to template discovery |
| `ATS Resume Checker` | `/career-center/ats-resume-checker/` | Tool- or utility-oriented advice page |
| `Special Reports` articles | `/...` report pages | Broader labor-market and workplace trend content |
| Expert profile links | `/about-us/.../` and LinkedIn | Trust and authority-building surface |

#### Key takeaways

- The Career Center is a large internal-link mesh that feeds both SEO and conversion
- Editorial advice is tightly interconnected with templates, examples, and the builder itself
- The in-page table of contents helps manage a very long hub page without fragmenting it into too many index screens

### Phase 10: Mobile Layout Check

#### Actions performed

1. Switched the viewport to `390x844`
2. Captured the homepage in a narrow viewport
3. Captured the sign-in screen in a narrow viewport
4. Probed the import route on mobile and recorded instability when it failed to settle cleanly

#### Mobile homepage observations

- The page remains CTA-forward at small widths
- The hero keeps both `Create My Resume Now` and `Import Resume`
- Template/gallery and FAQ content still appear, but in a more vertically stacked presentation
- The mobile header remains simplified around branding and primary action

#### Mobile sign-in observations

- The sign-in screen becomes a clean single-column form
- Social sign-in stays above the email/password form
- Reset-password and sign-up paths remain visible without additional navigation
- Footer/legal links stay present at the bottom of the page

#### Mobile caveat

- The mobile import route did not remain stable during this session and briefly jumped to an unrelated page, so it should be re-verified separately before treating mobile import behavior as authoritative

### Phase 11: Real File Upload Probe

#### Actions performed

1. Prepared a synthetic TXT resume fixture for the audit
2. Confirmed the import page exposes a hidden `input[type="file"]`
3. Switched to an available PDF fixture accessible to the Playwright runtime: `verification_resume.pdf`
4. Attempted direct file selection through the hidden input and then attempted to continue the flow
5. Captured the resulting state and reviewed the saved upload artifact

#### What was observed

- The import screen consistently exposed one hidden file input behind the drag-and-drop UI
- Direct file injection appeared to trigger a transition, but the UI did not settle into a stable parsing or review screen
- One saved upload artifact captured only a blank transition frame
- The final stable page state returned to the same import route and showed the original upload prompt again
- No reliable file-name echo, extraction progress, parse result, or validation error became visible during this pass

#### Assessment

The real-file upload probe produced **evidence that the import surface is wired for native file selection**, but it did **not** produce a stable, documentable parse/review state in this session.

The most defensible conclusion is:

- The import route supports a hidden file-input workflow behind the visible dropzone UI
- The automated upload path was not stable enough to confirm the next screen after a successful file selection
- A manual or browser-assisted re-check is still needed before documenting extraction behavior as confirmed product behavior

## Cross-Site Information Architecture

### Top-level structure

Observed product structure:

1. **Marketing site**
   - Homepage
   - Templates directory
   - Examples directory
   - Career content
   - Company/legal/footer pages

2. **App domain**
   - Resume builder
   - Cover-letter builder
   - Import flow
   - Account/auth-related routes
   - Privacy/legal support routes

### Primary funnel paths

#### Path A: Direct builder entry

`Homepage CTA` -> `build-resume` -> `step wizard` -> `preview/finalize` -> `download/account/upgrade`

#### Path B: Template-led entry

`Resume Templates` -> `Use This Template` -> `build-resume?skin=...&theme=...` -> `step wizard`

#### Path C: Example-led entry

`Resume Examples` -> `specific example` -> `build CTA` -> `builder`

#### Path D: Import-led entry

`Import Resume` -> `select-resume?mode=importflow` -> import path -> editor

#### Path E: Cover-letter entry

`Cover Letter Builder` -> `intro splash` -> `experience segmentation step` -> later letter-building steps

## UI Patterns Worth Reusing

### 1. CTA repetition without variety loss

The site repeats the same core actions frequently:

- Start a new resume
- Import a resume
- Browse templates/examples

This repetition is helpful because users can join the flow from almost any scroll position.

### 2. Separate browse surfaces for templates vs examples

The site distinguishes:

- **Templates** for visual/design-led entry
- **Examples** for content/job-led entry

That is a strong IA choice because it separates two different user intents.

### 3. Opinionated wizard shell

The editor uses:

- A left stepper
- A completeness meter
- Inline prompts
- Step-local helper content
- Progress-focused CTAs

This creates a more guided experience than a blank document editor.

### 4. Embedded instructional microcopy

The builder constantly tells users:

- What to enter
- Why it matters
- What counts as valid experience
- What hiring managers care about

This reduces anxiety and improves completion.

### 5. URL-driven template selection

The `skin` + `theme` pattern is simple and transparent.

It makes template selection easy to pass around from public pages into the actual builder.

### 6. SEO + product funnel integration

The marketing site is not just promotional.

It is also a giant discovery engine that routes users into the product through:

- Example pages
- Template pages
- Career advice pages
- AI-related content pages

## How It Works Today vs How We Should Adapt It

### How ResumeBuilder.com appears to work today

- The public website is content-heavy and conversion-oriented
- The actual builder lives on a separate app domain
- The builder is wizard-first, not canvas-first
- Template selection can happen from public pages before entering the editor
- Resume examples and editorial pages act as acquisition pages
- Cover-letter flow is separate and starts with a lightweight qualification step

### How we should adapt the useful parts in our app

We should adapt the **patterns**, not copy the product literally.

Given our Rails 8, HTML-first app direction, the best translation would be:

#### Public product surfaces

- Keep public marketing/discovery pages server-rendered
- Create separate entry points for `templates` and `examples`
- Reuse the same CTA language and action locations throughout the page
- Use clear browse paths for users who know their design preference vs users who need writing help

#### Builder shell

- Keep the builder as a multi-step guided flow
- Use a reusable stepper/sidebar component
- Keep a completeness indicator visible
- Keep inline helper content close to the form instead of hiding it in docs
- Preserve a `Preview` action before final export

#### Template selection

- Keep template choice explicit and early
- Allow template preview cards to launch the editor with a selected template
- Keep theme/color selection lightweight and understandable

#### Examples library

- Build an examples hub organized by category and search
- Treat examples as a content/reference surface, not only as a template gallery
- Route example pages back into the actual resume builder

#### Cover letter product direction

- If we build cover letters, use a separate workflow from resume editing
- Start with a small number of qualifying questions to personalize content
- Avoid forcing users into a full editor before the system understands experience level or target role

#### UX principles to keep

- Prefer guided prompts over empty textareas
- Prefer visible next steps over hidden navigation
- Keep legal/privacy links available in both public and app contexts
- Repeat primary CTAs consistently across long pages

## Recommended Implementation Notes for Our Rails App

These are **adaptation ideas**, not descriptions of current code.

### Marketing/discovery layer

- Use server-rendered Rails pages for homepage, templates, examples, and editorial hubs
- Use ViewComponents for repeated CTA bands, template cards, example cards, FAQ sections, and trust blocks
- Keep routes simple and crawlable

### Editing layer

- Keep our resume editor HTML-first with Turbo-driven partial updates
- Reuse the same resume data for both preview and export rendering
- Keep step transitions fast and predictable
- Add helper panels/popovers only where they materially reduce confusion

### Data model alignment

Useful concepts to mirror in our own domain without changing our architecture:

- A clear distinction between `template` selection and `resume` content
- A notion of completion/progress at the resume level
- Structured entry forms for experience, education, skills, and summary
- Optional import and AI-assist entry points layered onto the builder rather than replacing it

### Content strategy

- Seed a strong examples library and template library so discovery is not dependent on the editor alone
- Make every content surface route into an actionable builder step
- Keep examples and templates distinct because users arrive with different mental models

## Observed Caveats and Anomalies

### Builder route statefulness

When `build-resume` was first opened, an intro screen was visible. During the session, the builder later resolved into the `Experience` step route.

Observed implication:

- The app appears stateful
- Existing session/cookie state likely influences where a user lands

### Before-unload prompts

Leaving builder flows triggered `beforeunload` confirmations.

Observed implication:

- The app is protecting unsaved progress
- Route transitions across app/public boundaries may be intentionally guarded

### JS-driven taxonomy links

On the examples page, taxonomy links used `javascript:void(0)`.

Observed implication:

- Filtering/section changes are likely JS-driven rather than route-driven

### Direct builder bootstrap instability during phase 2

When the builder step route was probed directly during the phase 2 pass, it did not always hydrate into the full editor.

Observed implication:

- Route-level deep links may depend on client-side bootstrap state
- Console errors can prevent the UI from reaching the preview/finalize stage
- Preview/download behavior needs a stable follow-up audit

### Mobile import-route anomaly during phase 2

During the narrow-viewport pass, the import route did not settle reliably and briefly navigated to an unrelated external page.

Observed implication:

- The mobile import path should be re-verified separately
- That redirect should not be treated as confirmed product behavior without manual confirmation in a normal browser session

### Automated real-file upload instability during phase 3

During the phase 3 real-upload probe, direct file injection through the hidden import input triggered unstable behavior and never resolved into a stable review or extraction screen.

Observed implication:

- The upload path is present, but its post-selection state remains unconfirmed under the current automation setup
- A blank transition frame should not be treated as a confirmed product screen
- Import parsing and review behavior still require manual or more reliable browser-assisted verification

### Tool-session anomaly during cover-letter navigation

One cover-letter CTA transition briefly produced an unrelated external navigation before the app route settled back into the expected flow.

Observed interpretation:

- This may have been a browser-session artifact rather than a product behavior
- Do not treat that external redirect as a confirmed product rule without manual re-verification in a normal browser

### Console issues noticed during audit

Observed during browsing:

- Public pages logged a `Segment snippet included twice` error
- App pages showed some font/resource warnings
- One build-resume load showed an Akamai resource error

These were not investigated further in this audit.

## Recommended Next Audit Pass

For a phase 4 audit, the next high-value areas are:

- Manual or browser-assisted verification of a successful uploaded-file review/parsing state
- Stable preview, finalize, and download behavior after the builder successfully hydrates
- Authenticated account journey from sign-in to edit, preview, and export
- Payment or upgrade gating around PDF or premium download options
- Mobile import and mobile builder behavior after a clean, stable load

## Summary

ResumeBuilder.com combines:

- A content-heavy public website
- Strong, repeated conversion CTAs
- Separate visual and content discovery paths
- A guided step-based editor
- An import-first entry path with local and cloud-provider options
- A dedicated sign-in gate for account-oriented actions
- A large editorial Career Center that feeds the product funnel
- Lightweight contextual guidance inside the workflow
- Distinct resume and cover-letter product flows

The most reusable ideas for our app are:

- Separate `templates` and `examples` discovery surfaces
- A guided stepper-based editor
- A visible completeness meter
- An import path that is explicit and easy to discover
- Editorial content that cross-links back into builder actions
- Template selection that can happen before the editor opens
- Helpful instructional microcopy embedded directly inside the workflow
- Repeated CTA placement across all long-form public pages
