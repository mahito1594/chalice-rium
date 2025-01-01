import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "closedIcon", "openIcon"]
  static values = { isOpen: Boolean }

  connect() {
    // Close the menu when window is resized to a smaller size
    this.resizeObserver = new ResizeObserver(() => {
      const BREAKPOINT = 1024 // lg breakpoint
      if (window.innerWidth < BREAKPOINT) {
        this.hideMenu()
      }
    })
    this.resizeObserver.observe(document.body)
  }

  disconnect() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }
  }

  /**
   * Toggle the menu when the menu icon is clicked
   */
  toggle() {
    const isOpen = this.isOpenValue
    if (isOpen) {
      this.hideMenu()
    } else {
      this.showMenu()
    }
  }

  showMenu() {
    this.menuTarget.classList.remove("-translate-x-full")
    this.menuTarget.classList.remove("opacity-0")
    this.closedIconTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.isOpenValue = true
  }

  hideMenu() {
    this.menuTarget.classList.add("-translate-x-full")
    this.menuTarget.classList.add("opacity-0")
    this.closedIconTarget.classList.remove("hidden")
    this.openIconTarget.classList.add("hidden")
    this.isOpenValue = false
  }
}
