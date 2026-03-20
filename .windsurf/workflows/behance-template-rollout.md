---
description: Repeatedly capture new Behance resume-template references, compare them with the current app, and implement only net-new templates or open improvement slices.
---
1. Treat any text supplied after `/behance-template-rollout` as optional Behance URLs, search terms, candidate limit, or mode (`capture-only`, `plan-only`, `implement-next`, or `re-review`).
2. Read `docs/template_rollouts/README.md`, `docs/template_rollouts/registry.yml`, and the latest run log before doing anything else.
3. Read the current renderer and reference docs that shape the work: `docs/template_rendering.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, and the relevant ResumeBuilder.com reference docs under `docs/references/resumebuilder/`.
4. Map the current implementation surface through `ResumeTemplates::Catalog`, `Template`, `ResumeTemplates::ComponentResolver`, `ResumeTemplates::PreviewResumeBuilder`, `db/seeds.rb`, and the relevant request/service specs before selecting a candidate.
5. Choose the next candidate only if the registry does not already mark its `source_url` or `capture_signature` as `implemented`, `duplicate`, `rejected`, or `superseded`.
6. If revisiting a known candidate, update the existing `docs/template_rollouts/templates/<reference_key>.md` file instead of creating a second track.
7. Use Playwright to capture the Behance reference and download raw artifacts into `tmp/reference_artifacts/behance/<reference_key>/`; treat those artifacts as internal reference material only and never reuse third-party assets in shipped UI.
8. Capture any relevant ResumeBuilder.com marketplace, template, or builder interaction patterns that should influence the implementation, then record those notes in the active run log.
9. Update the registry row, the per-template tracking doc, and a new run log under `docs/template_rollouts/runs/<timestamp>/` before and after implementation work so completed and pending states stay explicit.
10. If the mode includes implementation, implement only one net-new candidate or one open improvement slice unless the user explicitly asks for a batch.
11. When implementing, update the smallest complete set of files across catalog, renderer components, preview behavior, seeds, admin metadata, docs, and specs so the template is actually ready to use through the shared preview and export path.
12. Verify with the most targeted checks for the affected slice. At minimum consider `spec/services/resume_templates/catalog_spec.rb`, `spec/services/resume_templates/pdf_rendering_spec.rb`, `spec/services/resume_templates/preview_resume_builder_spec.rb`, `spec/requests/templates_spec.rb`, `spec/requests/admin/templates_spec.rb`, and any affected `spec/requests/resumes_spec.rb` coverage.
13. Only mark a candidate `implemented` when the shared renderer path, ready-to-use record path, documentation, and verification are complete; otherwise keep explicit `open_improvement_keys` and leave the candidate short of `implemented`.
14. Finish with changed files, verification results, registry/template status updates, and the next eligible candidate or open improvement slice.
