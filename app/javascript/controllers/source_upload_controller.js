import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cloudPanel", "dropzone", "input", "modeInput", "pastePanel", "pendingReview", "pendingFilename", "pendingContentType", "pendingFileSize", "pendingStatusBadge", "pendingMessage", "uploadPanel"]

  connect() {
    this.dragDepth = 0
    this.syncMode()
  }

  syncMode() {
    const selectedMode = this.selectedMode()
    const uploadModeSelected = selectedMode === "upload"

    if (this.hasPastePanelTarget) {
      this.pastePanelTarget.classList.toggle("hidden", selectedMode !== "paste")
    }

    if (this.hasUploadPanelTarget) {
      this.uploadPanelTarget.classList.toggle("hidden", !uploadModeSelected)
    }

    if (this.hasCloudPanelTarget) {
      this.cloudPanelTarget.classList.toggle("hidden", !uploadModeSelected)
    }
  }

  openPicker(event) {
    if (event) {
      event.preventDefault()
    }

    if (this.hasInputTarget) {
      this.inputTarget.click()
    }
  }

  dragEnter(event) {
    event.preventDefault()
    this.dragDepth += 1
    this.highlightDropzone(true)
  }

  dragLeave(event) {
    event.preventDefault()
    this.dragDepth = Math.max(this.dragDepth - 1, 0)
    this.highlightDropzone(this.dragDepth > 0)
  }

  dragOver(event) {
    event.preventDefault()
    this.highlightDropzone(true)
  }

  drop(event) {
    event.preventDefault()
    this.dragDepth = 0

    if (!this.hasInputTarget) {
      return
    }

    const files = event.dataTransfer?.files
    if (!files || files.length === 0) {
      this.highlightDropzone(false)
      return
    }

    const transfer = new DataTransfer()
    Array.from(files).forEach((file) => transfer.items.add(file))
    this.inputTarget.files = transfer.files
    this.selectUploadMode()
    this.updatePendingReview(transfer.files[0])
    this.highlightDropzone(false)
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  selectFromInput() {
    this.selectUploadMode()
    this.updatePendingReview(this.inputTarget.files?.[0])
    this.highlightDropzone(false)
  }

  updatePendingReview(file) {
    if (!this.hasPendingReviewTarget) {
      return
    }

    if (!file) {
      this.pendingReviewTarget.classList.add("hidden")
      return
    }

    const supported = this.autofillSupported(file)
    const contentType = file.type || this.fallbackContentType(file)

    this.pendingFilenameTarget.textContent = file.name
    this.pendingContentTypeTarget.textContent = contentType
    this.pendingFileSizeTarget.textContent = this.formatFileSize(file.size)
    this.pendingStatusBadgeTarget.textContent = supported ? "Autofill supported" : "Reference only"
    this.pendingStatusBadgeTarget.className = supported ? this.pendingStatusBadgeTarget.dataset.supportedClasses : this.pendingStatusBadgeTarget.dataset.referenceClasses
    this.pendingMessageTarget.textContent = supported ? "This file can be converted into source text during autofill while the original file stays attached to the draft." : `This file will stay attached for reference. AI autofill currently reads ${this.supportedFormatsLabelValue} uploads.`
    this.pendingReviewTarget.classList.remove("hidden")
  }

  highlightDropzone(active) {
    if (!this.hasDropzoneTarget) {
      return
    }

    this.dropzoneTarget.classList.toggle("border-slate-900", active)
    this.dropzoneTarget.classList.toggle("bg-white", active)
    this.dropzoneTarget.classList.toggle("shadow-[0_18px_44px_rgba(15,23,42,0.08)]", active)
  }

  selectUploadMode() {
    const uploadModeInput = document.getElementById("resume_source_mode_upload")
    if (uploadModeInput) {
      uploadModeInput.checked = true
    }
    this.syncMode()
  }

  selectedMode() {
    return this.modeInputTargets.find((input) => input.checked)?.value || "scratch"
  }

  autofillSupported(file) {
    const extension = file.name.split(".").pop()?.toLowerCase() || ""
    const supportedExtensions = this.supportedExtensionsValue.split(",").filter(Boolean)
    const supportedContentTypes = this.supportedContentTypesValue.split(",").filter(Boolean)

    return supportedExtensions.includes(extension) || supportedContentTypes.includes(file.type)
  }

  fallbackContentType(file) {
    const extension = file.name.split(".").pop()?.toLowerCase() || ""

    if (["md", "markdown"].includes(extension)) return "text/markdown"
    if (["html", "htm"].includes(extension)) return "text/html"
    if (extension === "rtf") return "text/rtf"
    if (["txt", "text"].includes(extension)) return "text/plain"
    if (extension === "pdf") return "application/pdf"
    if (extension === "doc") return "application/msword"
    if (extension === "docx") return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

    return "Unknown type"
  }

  formatFileSize(size) {
    if (size < 1024) return `${size} Bytes`

    const units = ["KB", "MB", "GB"]
    let value = size / 1024

    for (const unit of units) {
      if (value < 1024 || unit === units[units.length - 1]) {
        return `${value.toFixed(value >= 10 ? 0 : 1)} ${unit}`
      }

      value /= 1024
    }

    return `${size} Bytes`
  }

  get supportedExtensionsValue() {
    return this.element.dataset.sourceUploadSupportedExtensionsValue || ""
  }

  get supportedContentTypesValue() {
    return this.element.dataset.sourceUploadSupportedContentTypesValue || ""
  }

  get supportedFormatsLabelValue() {
    return this.element.dataset.sourceUploadSupportedFormatsLabelValue || "supported"
  }
}
