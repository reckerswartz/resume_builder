import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "toggle", "capsHint"]

  connect() {
    this.updateToggleLabel()
    this.hideCapsHint()
  }

  toggle() {
    if (!this.hasInputTarget) return

    this.inputTarget.type = this.inputTarget.type === "password" ? "text" : "password"
    this.updateToggleLabel()
  }

  updateCapsState(event) {
    if (!this.hasCapsHintTarget) return

    const capsLockOn = event.getModifierState && event.getModifierState("CapsLock")
    this.capsHintTarget.classList.toggle("hidden", !capsLockOn)
  }

  hideCapsHint() {
    if (!this.hasCapsHintTarget) return

    this.capsHintTarget.classList.add("hidden")
  }

  updateToggleLabel() {
    if (!this.hasToggleTarget || !this.hasInputTarget) return

    this.toggleTarget.textContent = this.inputTarget.type === "password" ? "Show" : "Hide"
  }
}
