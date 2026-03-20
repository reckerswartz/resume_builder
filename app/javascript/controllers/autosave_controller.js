import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 500 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    this.clear()
  }

  queue(event) {
    if (this.ignoredTarget(event?.target)) {
      return
    }

    if (this.immediateSubmitTarget(event?.target)) {
      this.submitNow()
      return
    }

    this.clear()
    this.timeout = window.setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue)
  }

  submitNow() {
    this.clear()
    this.element.requestSubmit()
  }

  clear() {
    if (this.timeout) {
      window.clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  immediateSubmitTarget(target) {
    return target?.name === "resume[template_id]"
  }

  ignoredTarget(target) {
    return target?.closest("[data-autosave-ignore='true']") !== null
  }
}
