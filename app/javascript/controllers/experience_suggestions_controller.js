import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  insert(event) {
    event.preventDefault()

    if (!this.hasInputTarget) {
      return
    }

    const card = event.currentTarget.closest("[data-experience-suggestions-card]")
    const textElement = card?.querySelector("[data-experience-suggestions-text]")
    const text = textElement?.textContent?.trim() || ""

    const existingLines = this.inputTarget.value
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
    const suggestedLines = text
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
    const mergedLines = []

    ;[...existingLines, ...suggestedLines].forEach((line) => {
      if (!mergedLines.some((existingLine) => existingLine.toLowerCase() === line.toLowerCase())) {
        mergedLines.push(line)
      }
    })

    this.inputTarget.value = mergedLines.join("\n")
    this.inputTarget.focus()
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
