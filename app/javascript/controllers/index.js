import { application } from "./application"

import AutosaveController from "./autosave_controller"
import DisclosureController from "./disclosure_controller"
import HelloController from "./hello_controller"
import PasswordFieldController from "./password_field_controller"
import SourceUploadController from "./source_upload_controller"
import SummarySuggestionsController from "./summary_suggestions_controller"
import SortableController from "./sortable_controller"
import TemplateGalleryController from "./template_gallery_controller"
import TemplatePickerController from "./template_picker_controller"

application.register("autosave", AutosaveController)
application.register("disclosure", DisclosureController)
application.register("hello", HelloController)
application.register("password-field", PasswordFieldController)
application.register("source-upload", SourceUploadController)
application.register("summary-suggestions", SummarySuggestionsController)
application.register("sortable", SortableController)
application.register("template-gallery", TemplateGalleryController)
application.register("template-picker", TemplatePickerController)
