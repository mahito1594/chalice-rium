import { Controller } from "@hotwired/stimulus"

// Controls the collapsible filter form on the dungeons index page
export default class extends Controller {
  static targets = ["content", "expandIcon", "collapseIcon", "toggleButton"]
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
}
