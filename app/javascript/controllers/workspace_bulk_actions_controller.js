import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectionSummary", "actionButton"]

  connect() {
    this.update()
  }

  update() {
    const selectedCount = this.checkboxTargets.filter((checkbox) => checkbox.checked).length

    if (this.hasSelectionSummaryTarget) {
      const oneLabel = this.selectionSummaryTarget.dataset.one || "1 resume selected"
      const otherTemplate = this.selectionSummaryTarget.dataset.other || "%{count} resumes selected"

      this.selectionSummaryTarget.textContent = selectedCount === 1 ? oneLabel : otherTemplate.replace("%{count}", selectedCount)
    }

    this.actionButtonTargets.forEach((button) => {
      const enabled = selectedCount > 0
      const enabledClasses = this.classTokens(button.dataset.enabledClasses)
      const disabledClasses = this.classTokens(button.dataset.disabledClasses)

      button.disabled = !enabled
      button.classList.remove(...enabledClasses, ...disabledClasses)
      button.classList.add(...(enabled ? enabledClasses : disabledClasses))
    })
  }

  classTokens(value) {
    return (value || "").split(/\s+/).filter(Boolean)
  }
}
