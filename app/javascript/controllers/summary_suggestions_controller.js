import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  insert(event) {
    event.preventDefault()

    if (!this.hasInputTarget) {
      return
    }

    const card = event.currentTarget.closest("[data-summary-suggestions-card]")
    const textElement = card?.querySelector("[data-summary-suggestions-text]")
    const text = textElement?.textContent?.trim() || ""

    this.inputTarget.value = text
    this.inputTarget.focus()
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
