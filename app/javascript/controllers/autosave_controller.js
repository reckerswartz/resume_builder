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

  queue() {
    this.clear()
    this.timeout = window.setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue)
  }

  clear() {
    if (this.timeout) {
      window.clearTimeout(this.timeout)
      this.timeout = null
    }
  }
}
