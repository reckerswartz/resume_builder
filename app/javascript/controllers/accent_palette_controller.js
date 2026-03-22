import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "swatch", "customInput", "resetButton", "customIndicator"]

  select(event) {
    const hex = event.currentTarget.dataset.accentColor
    if (!hex) return

    this.inputTarget.value = hex
    this.updateSelection(hex)
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  customChange() {
    const hex = this.customInputTarget.value
    this.inputTarget.value = hex
    this.updateSelection(hex)
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  reset() {
    const defaultColor = this.element.dataset.accentPaletteDefaultValue
    if (!defaultColor) return

    this.inputTarget.value = defaultColor
    this.customInputTarget.value = defaultColor
    this.updateSelection(defaultColor)
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  updateSelection(hex) {
    const normalizedHex = hex.toUpperCase()

    this.swatchTargets.forEach((swatch) => {
      const swatchColor = (swatch.dataset.accentColor || "").toUpperCase()
      const isSelected = swatchColor === normalizedHex

      swatch.setAttribute("aria-pressed", isSelected)
      if (isSelected) {
        swatch.classList.add("ring-2", "ring-aqua-200", "ring-offset-2")
        swatch.classList.remove("ring-0")
      } else {
        swatch.classList.remove("ring-2", "ring-aqua-200", "ring-offset-2")
        swatch.classList.add("ring-0")
      }
    })

    const paletteMatch = this.swatchTargets.some((swatch) => {
      return (swatch.dataset.accentColor || "").toUpperCase() === normalizedHex
    })

    if (this.hasCustomIndicatorTarget) {
      this.customIndicatorTarget.classList.toggle("hidden", paletteMatch)
    }

    this.customInputTarget.value = hex

    const defaultColor = (this.element.dataset.accentPaletteDefaultValue || "").toUpperCase()
    if (this.hasResetButtonTarget) {
      this.resetButtonTarget.disabled = normalizedHex === defaultColor
      this.resetButtonTarget.classList.toggle("opacity-40", normalizedHex === defaultColor)
    }
  }
}
