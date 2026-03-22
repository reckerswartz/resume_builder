import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel", "input"]
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

  navigate(event) {
    if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) {
      return
    }

    const currentIndex = this.tabTargets.indexOf(event.currentTarget)
    if (currentIndex === -1) {
      return
    }

    event.preventDefault()

    let nextIndex = currentIndex

    if (event.key === "ArrowRight") {
      nextIndex = (currentIndex + 1) % this.tabTargets.length
    } else if (event.key === "ArrowLeft") {
      nextIndex = (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length
    } else if (event.key === "Home") {
      nextIndex = 0
    } else if (event.key === "End") {
      nextIndex = this.tabTargets.length - 1
    }

    const nextTab = this.tabTargets[nextIndex]
    const key = nextTab?.dataset.tabKey

    if (!key) {
      return
    }

    this.activeValue = key
    this.#sync()
    nextTab.focus()
  }

  #sync() {
    const active = this.activeValue

    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabKey === active
      tab.setAttribute("aria-selected", isActive)
      tab.setAttribute("tabindex", isActive ? "0" : "-1")
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

    if (this.hasInputTarget) {
      this.inputTargets.forEach(input => {
        input.value = active
      })
    }
  }
}
