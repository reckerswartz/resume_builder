# Homepage Entry

## Hosted page

- **URL**: `https://www.resumebuilder.com/`
- **Confidence**: High
- **Purpose**: Public acquisition page that routes users into resume creation, import, templates, examples, and account entry.

## Observed options, fields, and interactions

- **Header navigation**
  - `Resume Builder App`
  - `Resume Examples`
  - `Resume Templates`
  - `Cover Letter Builder`
  - `Career Center`
  - `My Account`
- **Hero CTAs**
  - `Create My Resume Now`
  - `Import Resume`
- **Discovery surfaces**
  - Template strip/carousel
  - Repeated CTA buttons deeper on the page
  - FAQ block answering workflow and pricing objections
- **Support/trust elements**
  - Social proof
  - Brand/trust footer
  - Legal links and social links

## Closest equivalent in our app

- **Route**: `root_path` via `HomeController#index`
- **Files**
  - `app/controllers/home_controller.rb`
  - `app/views/home/index.html.erb`
- **Current behavior**
  - Signed-out users see a branded hero with `Create account` and `Sign in`
  - Signed-in users are redirected to `resumes_path`
  - The page previews the workspace concept but does not act as a broad discovery funnel

## Missing or weaker capabilities in our app

- **No direct public import CTA**
- **No public template-gallery CTA from the home hero**
- **No public examples/editorial discovery layer**
- **No FAQ or objection-handling content on the landing page**
- **No clear multi-path funnel choice** between start, import, browse templates, and sign in

## Suggested enhancements

- **Add a three-path public CTA cluster**
  - `Start a resume`
  - `Import an existing resume`
  - `Browse templates`
- **Link the signed-out homepage to discovery surfaces**
  - public template marketplace
  - a future examples/advice library if we decide to build one
- **Add lightweight trust and FAQ blocks**
  - keep them concise and product-focused rather than SEO-heavy
- **Preserve Rails simplicity**
  - we do not need to replicate ResumeBuilder.com’s long-form marketing page verbatim
  - we do need clearer entry points into the product funnel

## Recommended priority

- **Medium**
- This is valuable for funnel clarity, but it is less urgent than import flow, summary suggestions, and persona-driven template recommendations.
