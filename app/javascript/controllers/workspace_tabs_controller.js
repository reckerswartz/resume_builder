import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: { type: String, default: "" } }

  connect() {
    if (!this.activeValue && this.tabTargets.length > 0) {
      this.activeValue = this.tabTargets[0].dataset.tabKey
    }
    this.#sync()
  }

  select(event) {
    event.preventDefault()
    const key = event.currentTarget.dataset.tabKey
    if (key) {
      this.activeValue = key
      this.#sync()
    }
  }

  #sync() {
    const active = this.activeValue

    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabKey === active
      tab.setAttribute("aria-selected", isActive)
      tab.classList.toggle("border-b-2", isActive)
      tab.classList.toggle("border-ink-950", isActive)
      tab.classList.toggle("text-ink-950", isActive)
      tab.classList.toggle("font-semibold", isActive)
      tab.classList.toggle("text-ink-700/70", !isActive)
    })

    this.panelTargets.forEach(panel => {
      const isActive = panel.dataset.tabKey === active
      panel.hidden = !isActive
    })
  }
}
