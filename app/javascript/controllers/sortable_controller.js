import { Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.draggedItem = null
    this.originalIndex = null
    this.originalParent = null
    this.originalNextSibling = null
    this.dropHandled = false
  }

  dragstart(event) {
    const item = this.itemFromEvent(event)
    if (!item) return

    this.draggedItem = item
    this.originalIndex = this.itemTargets.indexOf(item)
    this.originalParent = item.parentElement
    this.originalNextSibling = item.nextElementSibling
    this.dropHandled = false

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", item.id || item.dataset.sortableMoveUrl)

    requestAnimationFrame(() => {
      item.classList.add("opacity-60", "ring-2", "ring-slate-300")
    })
  }

  dragover(event) {
    if (!this.draggedItem) return

    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const item = this.itemFromEvent(event)
    if (!item || item === this.draggedItem) return

    const rect = item.getBoundingClientRect()
    const insertBefore = event.clientY < rect.top + (rect.height / 2)

    if (insertBefore) {
      item.before(this.draggedItem)
    } else {
      item.after(this.draggedItem)
    }
  }

  async drop(event) {
    if (!this.draggedItem) return

    event.preventDefault()
    this.dropHandled = true
    await this.persist()
  }

  dragend() {
    if (!this.draggedItem) return

    if (!this.dropHandled) {
      this.restoreOriginalPosition()
      this.cleanup()
    }
  }

  async persist() {
    const newIndex = this.itemTargets.indexOf(this.draggedItem)

    if (newIndex === -1 || newIndex === this.originalIndex) {
      this.cleanup()
      return
    }

    try {
      const response = await fetch(this.draggedItem.dataset.sortableMoveUrl, {
        method: "PATCH",
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          "X-CSRF-Token": this.csrfToken
        },
        body: new URLSearchParams({ position: newIndex }).toString(),
        credentials: "same-origin"
      })

      if (!response.ok) throw new Error("Failed to persist reordered item")

      Turbo.renderStreamMessage(await response.text())
    } catch (_error) {
      this.restoreOriginalPosition()
    } finally {
      this.cleanup()
    }
  }

  itemFromEvent(event) {
    const item = event.target.closest("[data-sortable-target='item']")
    return this.itemTargets.find((target) => target === item) || null
  }

  restoreOriginalPosition() {
    if (!this.draggedItem || !this.originalParent) return

    if (this.originalNextSibling && this.originalNextSibling.parentElement === this.originalParent) {
      this.originalParent.insertBefore(this.draggedItem, this.originalNextSibling)
    } else {
      this.originalParent.appendChild(this.draggedItem)
    }
  }

  cleanup() {
    if (this.draggedItem) {
      this.draggedItem.classList.remove("opacity-60", "ring-2", "ring-slate-300")
    }

    this.draggedItem = null
    this.originalIndex = null
    this.originalParent = null
    this.originalNextSibling = null
    this.dropHandled = false
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content.toString() || ""
  }
}
