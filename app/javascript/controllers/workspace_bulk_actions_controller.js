import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectionSummary", "actionButton", "clearButton", "selectionFields", "pageLink"]
  static values = {
    selectedIds: Array,
    storageKey: { type: String, default: "workspace-resumes-bulk-selection" }
  }

  connect() {
    const initialIds = this.normalizeIds([...(this.hasSelectedIdsValue ? this.selectedIdsValue : []), ...this.readStoredIds()])

    this.selectedIds = new Set(initialIds)
    this.writeStoredIds(initialIds)
    this.sync()
  }

  update() {
    const selectedIds = new Set(this.readStoredIds())

    this.checkboxTargets.forEach((checkbox) => {
      const resumeId = this.checkboxValue(checkbox)

      if (checkbox.checked) {
        selectedIds.add(resumeId)
      } else {
        selectedIds.delete(resumeId)
      }
    })

    this.selectedIds = selectedIds
    this.writeStoredIds(Array.from(selectedIds))
    this.sync()
  }

  clearSelection(event) {
    event?.preventDefault()

    this.selectedIds = new Set()
    this.writeStoredIds([])
    this.sync()
  }

  submit() {
    this.syncSelectionFields()
    this.writeStoredIds([])
  }

  sync() {
    if (!(this.selectedIds instanceof Set)) {
      this.selectedIds = new Set(this.readStoredIds())
    }

    this.selectedIdsValue = Array.from(this.selectedIds)
    this.syncCheckboxes()
    this.syncSelectionFields()
    this.syncPageLinks()
    this.updateSummary()
    this.updateButtons()
  }

  syncCheckboxes() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = this.selectedIds.has(this.checkboxValue(checkbox))
    })
  }

  syncSelectionFields() {
    const selectedIds = Array.from(this.selectedIds)

    this.selectionFieldsTargets.forEach((container) => {
      container.replaceChildren(...selectedIds.map((resumeId) => this.buildHiddenField(resumeId)))
    })
  }

  syncPageLinks() {
    const selectedIds = Array.from(this.selectedIds)

    this.pageLinkTargets.forEach((link) => {
      const url = new URL(link.href, window.location.origin)
      url.searchParams.delete("resume_ids[]")

      selectedIds.forEach((resumeId) => {
        url.searchParams.append("resume_ids[]", resumeId)
      })

      link.href = url.toString()
    })
  }

  updateSummary() {
    if (!this.hasSelectionSummaryTarget) return

    const selectedCount = this.selectedIds.size
    const oneLabel = this.selectionSummaryTarget.dataset.one || "1 resume selected"
    const otherTemplate = this.selectionSummaryTarget.dataset.other || "%{count} resumes selected"

    this.selectionSummaryTarget.textContent = selectedCount === 1 ? oneLabel : otherTemplate.replace("%{count}", selectedCount)
  }

  updateButtons() {
    const hasSelection = this.selectedIds.size > 0

    this.actionButtonTargets.forEach((button) => {
      this.toggleButtonState(button, hasSelection)
    })

    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.hidden = false
      this.clearButtonTarget.disabled = !hasSelection
    }
  }

  checkboxValue(checkbox) {
    return String(checkbox.value)
  }

  buildHiddenField(resumeId) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "resume_ids[]"
    input.value = resumeId
    return input
  }

  toggleButtonState(button, enabled) {
    const enabledClasses = this.classTokens(button.dataset.enabledClasses)
    const disabledClasses = this.classTokens(button.dataset.disabledClasses)
    const nextClasses = enabled ? enabledClasses : disabledClasses

    button.disabled = !enabled
    button.classList.remove(...enabledClasses, ...disabledClasses)
    nextClasses.forEach((className) => {
      button.classList.add(className)
    })
  }

  classTokens(value) {
    return (value || "").split(/\s+/).filter(Boolean)
  }

  readStoredIds() {
    try {
      return this.normalizeIds(JSON.parse(window.sessionStorage.getItem(this.storageKeyValue) || "[]"))
    } catch (_error) {
      return []
    }
  }

  writeStoredIds(ids) {
    const normalizedIds = this.normalizeIds(ids)

    try {
      if (normalizedIds.length > 0) {
        window.sessionStorage.setItem(this.storageKeyValue, JSON.stringify(normalizedIds))
      } else {
        window.sessionStorage.removeItem(this.storageKeyValue)
      }
    } catch (_error) {
      return null
    }

    return normalizedIds
  }

  normalizeIds(ids) {
    return [...new Set(Array.isArray(ids) ? ids.map((id) => String(id)).filter(Boolean) : [])]
  }
}
