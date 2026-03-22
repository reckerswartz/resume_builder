import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameInput"]

  add(event) {
    event.preventDefault()

    if (!this.hasNameInputTarget) {
      return
    }

    const skillName = event.currentTarget
      .closest("[data-skills-suggestions-card]")
      ?.querySelector("[data-skills-suggestions-skill-name]")
      ?.textContent?.trim()

    if (!skillName) {
      return
    }

    const currentValue = this.nameInputTarget.value.trim()

    if (currentValue.toLowerCase() === skillName.toLowerCase()) {
      return
    }

    this.nameInputTarget.value = skillName
    this.nameInputTarget.focus()
    this.nameInputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.nameInputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
