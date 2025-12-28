import { Controller } from "@hotwired/stimulus"

// Controls the collapsible filter form on the dungeons index page
export default class extends Controller {
  static targets = ["content", "expandIcon", "collapseIcon", "toggleButton", "form"]
  static values = { expanded: { type: Boolean, default: false } }

  connect() {
    this.updateVisibility()
  }

  toggle() {
    this.expandedValue = !this.expandedValue
    this.updateVisibility()
  }

  updateVisibility() {
    // Update aria-expanded for accessibility
    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.setAttribute("aria-expanded", this.expandedValue)
    }

    if (this.expandedValue) {
      this.contentTarget.classList.remove("hidden")
      if (this.hasExpandIconTarget) this.expandIconTarget.classList.add("hidden")
      if (this.hasCollapseIconTarget) this.collapseIconTarget.classList.remove("hidden")
    } else {
      this.contentTarget.classList.add("hidden")
      if (this.hasExpandIconTarget) this.expandIconTarget.classList.remove("hidden")
      if (this.hasCollapseIconTarget) this.collapseIconTarget.classList.add("hidden")
    }
  }

  reset(event) {
    event.preventDefault()

    // Clear all form inputs (selects, checkboxes, etc.)
    if (this.hasFormTarget) {
      this.formTarget.reset()
    }

    // Collapse the filter panel
    this.expandedValue = false
    this.updateVisibility()

    // Update the turbo frame directly to refresh dungeons list
    const frame = document.getElementById("dungeons-list")
    if (frame) {
      frame.src = event.currentTarget.href
    }
  }
}
