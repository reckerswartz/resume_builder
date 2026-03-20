# Resume workspace pages

## Resumes index (`resumes#index`)

### Inherited now

- `Ui::HeroHeaderComponent` supplies the dark product-summary shell.
- Resume cards and side-rail panels inherit the new white-canvas / dark-shell contrast.
- Shared buttons and badges now align the workspace entry point with the new system.
- Resume cards now group preview context, metadata, and actions inside one white-canvas surface so the workspace list reads more like a product dashboard than a plain CRUD index.
- The side rail now stays advisory through lighter panels, quick-action buttons, and momentum copy instead of competing with the primary resume list.

### Still update / verify

- If workspace filters, search, or bulk actions are added later, keep them subordinate to the card grid rather than replacing the resume list with a dense control surface.

### Where to apply style

- Hero summary
- Resume list cards
- Side-rail momentum panels

## New resume (`resumes#new`)

### Inherited now

- `Ui::PageHeaderComponent` now supplies the white-canvas entry header.
- Shared form tokens and template picker tokens inherit the updated class system.
- The compact setup picker now uses `atelier-pill` discovery cues, stronger selected-summary framing, and a richer recommendation callout instead of reading like a plain radio list.
- The experience and student gates now use lighter step cues and advisory rails so the start flow feels product-led without turning into wizard chrome.
- The setup form now keeps experience carry-through, optional import, and next-step guidance inside the named `ink/canvas` palette while leaving template selection as the primary decision.

### Still update / verify

- Validation messaging should stay inside white-canvas surfaces.
- If more intake questions are added later, keep them in the current light advisory rhythm instead of introducing denser step chrome.

### Where to apply style

- Page header
- Resume creation form
- Template picker

## Edit resume (`resumes#edit`)

### Inherited now

- Builder chrome, step headers, widget cards, badges, and inputs all inherit the updated shared token layer.
- The dark shell and white-canvas contrast now better supports the split between navigation, editing, and supporting guidance.
- The shared finalize-step template picker now uses the same atelier discovery shell, live-sample framing, and selected-summary treatment as the setup flow.
- The live preview rail now uses the shared-renderer header language plus white-canvas glow framing so the builder preview feels closer to the public preview/export surfaces.
- Section and entry editors now use restrained white-canvas card framing, atelier-pill guidance labels, and named palette copy so the editing stack feels dense without turning into another dark-shell surface.
- The finalize-step additional sections area and add-section panel now share the same light product-editor vocabulary as the guided section steps.
- Builder progress and next-step guidance now sit inside lighter advisory cards, while the dark shell stays focused on the primary step frame and navigation context.
- Source import and finalize guidance now use white-canvas advisory panels plus named palette copy, with stronger emphasis reserved for actionable AI-import-ready or export-ready states.
- Heading, personal-details, and summary steps now keep autosave guidance, optional-field framing, and curated helper copy on the same lighter product-editor rhythm.

### Still update / verify

- If more import or export states are added later, reserve dark-shell emphasis for blocking or high-priority status changes instead of default guidance copy.
- If more intro-step guidance or summary tooling is added later, keep it inside grouped white canvases and preserve the current terse footer guidance.

### Where to apply style

- `_editor_chrome`
- `_workspace_overview`
- `_preview`
- `_template_picker`
- `_editor_source_step`, `_editor_finalize_step`

## Resume show (`resumes#show`)

### Inherited now

- Shared page header and export controls inherit the updated system.
- Preview/export-adjacent surfaces now sit naturally inside the dark-shell outer frame.
- The preview area now uses a product-artifact review shell with shared-renderer framing, atelier-pill cues, and a dedicated white-canvas render stage.
- Export and download actions now sit in an advisory side rail, while status remains a separate white-canvas summary instead of competing with the preview artifact.

### Still update / verify

- If additional post-export status UI is added later, prefer stacked white canvases rather than new hero variants.

### Where to apply style

- Page header
- Export action area
- Preview/status surfaces
