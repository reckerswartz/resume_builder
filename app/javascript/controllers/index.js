import { application } from "./application"

import AutosaveController from "./autosave_controller"
import DisclosureController from "./disclosure_controller"
import ExperienceSuggestionsController from "./experience_suggestions_controller"
import HelloController from "./hello_controller"
import PasswordFieldController from "./password_field_controller"
import SourceUploadController from "./source_upload_controller"
import SummarySuggestionsController from "./summary_suggestions_controller"
import SortableController from "./sortable_controller"
import TemplateGalleryController from "./template_gallery_controller"
import TemplatePickerController from "./template_picker_controller"
import WorkspaceBulkActionsController from "./workspace_bulk_actions_controller"
import WorkspaceTabsController from "./workspace_tabs_controller"

application.register("autosave", AutosaveController)
application.register("disclosure", DisclosureController)
application.register("experience-suggestions", ExperienceSuggestionsController)
application.register("hello", HelloController)
application.register("password-field", PasswordFieldController)
application.register("source-upload", SourceUploadController)
application.register("summary-suggestions", SummarySuggestionsController)
application.register("sortable", SortableController)
application.register("template-gallery", TemplateGalleryController)
application.register("template-picker", TemplatePickerController)
application.register("workspace-bulk-actions", WorkspaceBulkActionsController)
application.register("workspace-tabs", WorkspaceTabsController)
