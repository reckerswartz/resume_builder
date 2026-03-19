import { application } from "./application"

import AutosaveController from "./autosave_controller"
import HelloController from "./hello_controller"

application.register("autosave", AutosaveController)
application.register("hello", HelloController)
