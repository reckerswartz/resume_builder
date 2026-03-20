import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "card", "cardGrid", "eyebrow", "supporting", "indicator", "badge", "summary", "filterButton", "resultsLabel", "emptyState", "searchInput", "sortSelect"]

  connect() {
    this.filters = this.defaultFilters()
    this.searchQuery = this.hasSearchInputTarget ? this.normalizedSearchValue(this.searchInputTarget.value) : ""
    this.sortValue = this.hasSortSelectTarget ? this.sortSelectTarget.value : this.defaultSortValue()

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

  get selectedTemplateId() {
    return this.inputTargets.find((input) => input.checked)?.value || null
  }
}
