import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "body", "arrow"]

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }

  show() {
    if (!this.hasBodyTarget) return
    this.position()
    this.bodyTarget.classList.remove("opacity-0", "invisible")
    this.bodyTarget.classList.add("opacity-100", "visible")
  }

  hide() {
    if (!this.hasBodyTarget) return
    this.bodyTarget.classList.add("opacity-0", "invisible")
    this.bodyTarget.classList.remove("opacity-100", "visible")
  }

  position() {
    if (!this.hasArrowTarget || !this.hasTriggerTarget || !this.hasBodyTarget) return

    const wrapperRect = this.element.getBoundingClientRect()
    const triggerRect = this.triggerTarget.getBoundingClientRect()
    const bodyRect = this.bodyTarget.getBoundingClientRect()

    const triggerCenter = triggerRect.left + triggerRect.width / 2
    let bodyLeft = triggerCenter - bodyRect.width / 2 - wrapperRect.left

    // Clamp to stay within the wrapper
    const maxLeft = wrapperRect.width - bodyRect.width
    bodyLeft = Math.max(0, Math.min(bodyLeft, maxLeft))
    this.bodyTarget.style.left = `${bodyLeft}px`

    // Position arrow at trigger center
    const arrowLeft = triggerCenter - wrapperRect.left - bodyLeft - 4
    this.arrowTarget.style.left = `${arrowLeft}px`
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.triggerTarget.blur()
      this.hide()
    }
  }
}
