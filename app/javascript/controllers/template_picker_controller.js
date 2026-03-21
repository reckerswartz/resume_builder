import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "card", "cardGrid", "eyebrow", "supporting", "indicator", "badge", "summary", "filterButton", "resultsLabel", "emptyState", "searchInput", "sortSelect"]
  static values = { accentFieldId: String }

  connect() {
    this.filters = this.defaultFilters()
    this.searchQuery = this.hasSearchInputTarget ? this.normalizedSearchValue(this.searchInputTarget.value) : ""
    this.sortValue = this.hasSortSelectTarget ? this.sortSelectTarget.value : this.defaultSortValue()
    this.selectedAccentColors = this.initialAccentSelections()

    if (!this.inputTargets.some((input) => input.checked) && this.hasInputTarget) {
      this.inputTargets[0].checked = true
    }

    this.updateFilterButtons()
    this.update()
  }

  setFilter(event) {
    event.preventDefault()

    const button = event.currentTarget
    this.filters[button.dataset.filterGroup] = button.dataset.filterValue
    this.updateFilterButtons()
    this.update()
  }

  updateSearch(event) {
    this.searchQuery = this.normalizedSearchValue(event.currentTarget.value)
    this.update()
  }

  updateSort(event) {
    this.sortValue = event.currentTarget.value || this.defaultSortValue()
    this.update()
  }

  selectAccentVariant(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const { templateId, accentColor } = button.dataset
    this.selectedAccentColors[templateId] = accentColor

    const card = this.cardTargets.find((candidate) => candidate.dataset.templateId === templateId)
    if (card) {
      card.dataset.selectedAccentColor = accentColor
    }

    this.applyAccentVariantState(templateId)

    if (templateId === this.selectedTemplateId) {
      this.updateAccentField(accentColor, { dispatchChange: true })
    }
  }

  update() {
    const selectedTemplateId = this.selectedTemplateId

    if (selectedTemplateId) {
      this.cardTargets.forEach((element) => this.applyState(element, selectedTemplateId))
      this.eyebrowTargets.forEach((element) => this.applyState(element, selectedTemplateId))
      this.supportingTargets.forEach((element) => this.applyState(element, selectedTemplateId))
      this.indicatorTargets.forEach((element) => this.applyState(element, selectedTemplateId, { updateText: true }))
      this.badgeTargets.forEach((element) => this.applyState(element, selectedTemplateId))
      this.summaryTargets.forEach((element) => {
        const selected = element.dataset.templateId === selectedTemplateId
        element.classList.toggle("hidden", !selected)
        element.setAttribute("aria-hidden", selected ? "false" : "true")
      })
    }

    this.cardTargets.forEach((card) => this.applyAccentVariantState(card.dataset.templateId))
    this.syncAccentFieldForSelectedTemplate(selectedTemplateId)

    this.applyFilters(selectedTemplateId)
  }

  applyState(element, selectedTemplateId, { updateText = false } = {}) {
    const selected = element.dataset.templateId === selectedTemplateId
    const selectedClasses = this.classTokens(element.dataset.selectedClasses)
    const unselectedClasses = this.classTokens(element.dataset.unselectedClasses)

    element.classList.remove(...selectedClasses, ...unselectedClasses)
    element.classList.add(...(selected ? selectedClasses : unselectedClasses))

    if (updateText) {
      const nextText = selected ? element.dataset.selectedText : element.dataset.unselectedText
      if (nextText !== undefined) {
        element.textContent = nextText
      }
    }
  }

  classTokens(value) {
    return (value || "").split(/\s+/).filter(Boolean)
  }

  initialAccentSelections() {
    return this.cardTargets.reduce((selections, card) => {
      if (card.dataset.templateId) {
        selections[card.dataset.templateId] = card.dataset.selectedAccentColor
      }

      return selections
    }, {})
  }

  defaultFilters() {
    return this.filterButtonTargets.reduce((filters, button) => {
      const group = button.dataset.filterGroup
      if (button.getAttribute("aria-pressed") === "true") {
        filters[group] = button.dataset.filterValue
      } else if (!(group in filters)) {
        filters[group] = "all"
      }

      return filters
    }, {})
  }

  defaultSortValue() {
    return this.hasSortSelectTarget ? this.sortSelectTarget.value : "name_asc"
  }

  updateFilterButtons() {
    this.filterButtonTargets.forEach((button) => {
      const active = this.filters[button.dataset.filterGroup] === button.dataset.filterValue
      const selectedClasses = this.classTokens(button.dataset.selectedClasses)
      const unselectedClasses = this.classTokens(button.dataset.unselectedClasses)

      button.classList.remove(...selectedClasses, ...unselectedClasses)
      button.classList.add(...(active ? selectedClasses : unselectedClasses))
      button.setAttribute("aria-pressed", active ? "true" : "false")
    })
  }

  applyFilters(selectedTemplateId) {
    const visibleCards = this.sortedCards(
      this.cardTargets.filter((card) => this.matchesFilters(card)),
      selectedTemplateId
    )

    this.cardTargets.forEach((card) => {
      card.classList.toggle("hidden", !visibleCards.includes(card))
    })

    if (this.hasCardGridTarget) {
      visibleCards.forEach((card) => this.cardGridTarget.appendChild(card))
    }

    if (this.hasResultsLabelTarget) {
      this.resultsLabelTarget.textContent = this.resultsLabelText(visibleCards.length)
    }

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle("hidden", visibleCards.length > 0)
    }
  }

  matchesFilters(card) {
    const matchesSearch = !this.searchQuery || (card.dataset.searchText || "").includes(this.searchQuery)

    if (!matchesSearch) return false

    return Object.entries(this.filters).every(([group, value]) => {
      return value === "all" || this.filterValueFor(card, group) === value
    })
  }

  sortedCards(cards, selectedTemplateId) {
    return [...cards].sort((leftCard, rightCard) => {
      if (this.sortValue === "selected_first" && selectedTemplateId) {
        const leftSelected = leftCard.dataset.templateId === selectedTemplateId
        const rightSelected = rightCard.dataset.templateId === selectedTemplateId

        if (leftSelected !== rightSelected) {
          return leftSelected ? -1 : 1
        }
      }

      if (this.sortValue === "recommended_first") {
        return this.compareNumbers(leftCard.dataset.sortRecommendationRank, rightCard.dataset.sortRecommendationRank) || this.compareValues(leftCard.dataset.sortName, rightCard.dataset.sortName)
      }

      if (this.sortValue === "family_asc") {
        return this.compareValues(leftCard.dataset.sortFamily, rightCard.dataset.sortFamily) || this.compareValues(leftCard.dataset.sortName, rightCard.dataset.sortName)
      }

      if (this.sortValue === "density_asc") {
        return this.compareNumbers(leftCard.dataset.sortDensityRank, rightCard.dataset.sortDensityRank) || this.compareValues(leftCard.dataset.sortName, rightCard.dataset.sortName)
      }

      return this.compareValues(leftCard.dataset.sortName, rightCard.dataset.sortName)
    })
  }

  compareValues(leftValue, rightValue) {
    return (leftValue || "").localeCompare(rightValue || "")
  }

  compareNumbers(leftValue, rightValue) {
    return Number(leftValue || 0) - Number(rightValue || 0)
  }

  filterValueFor(card, group) {
    const datasetKey = group.replace(/_([a-z])/g, (_match, character) => character.toUpperCase())
    return card.dataset[datasetKey]
  }

  normalizedSearchValue(value) {
    return (value || "").trim().toLowerCase()
  }

  resultsLabelText(count) {
    return count === 1 ? "1 template shown" : `${count} templates shown`
  }

  applyAccentVariantState(templateId) {
    const accentColor = this.accentColorFor(templateId)
    const selectedButton = this.variantButtonsFor(templateId).find((button) => button.dataset.accentColor === accentColor)
    if (!selectedButton) return

    this.variantButtonsFor(templateId).forEach((button) => {
      const selected = button.dataset.accentColor === accentColor
      const selectedClasses = this.classTokens(button.dataset.selectedClasses)
      const unselectedClasses = this.classTokens(button.dataset.unselectedClasses)

      button.classList.remove(...selectedClasses, ...unselectedClasses)
      button.classList.add(...(selected ? selectedClasses : unselectedClasses))
      button.setAttribute("aria-pressed", selected ? "true" : "false")
    })

    this.variantPreviewsFor(templateId).forEach((preview) => {
      preview.classList.toggle("hidden", preview.dataset.accentColor !== accentColor)
    })

    this.variantLabelsFor(templateId).forEach((label) => {
      label.textContent = selectedButton.dataset.accentLabel || selectedButton.dataset.variantLabel || label.textContent
    })

    this.variantSwatchesFor(templateId).forEach((swatch) => {
      swatch.style.backgroundColor = accentColor
    })

    this.variantPreviewLinksFor(templateId).forEach((link) => {
      if (selectedButton.dataset.previewTemplatePath) {
        link.href = selectedButton.dataset.previewTemplatePath
      }
    })
  }

  syncAccentFieldForSelectedTemplate(selectedTemplateId) {
    if (!selectedTemplateId) return

    this.updateAccentField(this.accentColorFor(selectedTemplateId))
  }

  updateAccentField(accentColor, { dispatchChange = false } = {}) {
    const accentField = this.accentFieldElement
    if (!accentField || !accentColor || accentField.value === accentColor) return

    accentField.value = accentColor

    if (dispatchChange) {
      accentField.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  accentColorFor(templateId) {
    return this.selectedAccentColors[templateId] || this.cardTargets.find((card) => card.dataset.templateId === templateId)?.dataset.selectedAccentColor || null
  }

  variantButtonsFor(templateId) {
    return Array.from(this.element.querySelectorAll(`[data-template-variant-button="true"][data-template-id="${templateId}"]`))
  }

  variantPreviewsFor(templateId) {
    return Array.from(this.element.querySelectorAll(`[data-template-variant-preview="true"][data-template-id="${templateId}"]`))
  }

  variantLabelsFor(templateId) {
    return Array.from(this.element.querySelectorAll(`[data-template-variant-label="true"][data-template-id="${templateId}"]`))
  }

  variantSwatchesFor(templateId) {
    return Array.from(this.element.querySelectorAll(`[data-template-variant-swatch="true"][data-template-id="${templateId}"]`))
  }

  variantPreviewLinksFor(templateId) {
    return Array.from(this.element.querySelectorAll(`[data-template-variant-preview-link="true"][data-template-id="${templateId}"]`))
  }

  get accentFieldElement() {
    if (!this.hasAccentFieldIdValue) return null

    return document.getElementById(this.accentFieldIdValue)
  }

  get selectedTemplateId() {
    return this.inputTargets.find((input) => input.checked)?.value || null
  }
}
