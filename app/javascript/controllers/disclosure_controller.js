import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    storageKey: String,
    defaultOpen: { type: Boolean, default: false }
  }

  connect() {
    const storedState = this.readState()
    this.element.open = storedState === null ? this.defaultOpenValue : storedState === "true"
  }

  remember() {
    this.writeState(this.element.open)
  }

  readState() {
    if (!this.hasStorageKeyValue) return null

    try {
      return window.sessionStorage.getItem(this.storageKeyValue)
    } catch (_error) {
      return null
    }
  }

  writeState(value) {
    if (!this.hasStorageKeyValue) return

    try {
      window.sessionStorage.setItem(this.storageKeyValue, String(value))
    } catch (_error) {
      return null
    }
  }
}
