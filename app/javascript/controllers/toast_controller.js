import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  initialize() {
    this.timers = []
  }

  disconnect() {
    this.timers.forEach((id) => clearTimeout(id))
    this.timers = []
  }

  show({ detail: { message, type } }) {
    const toast = document.createElement("div")
    toast.className = this.#classesForType(type)
    toast.textContent = message
    this.containerTarget.appendChild(toast)

    this.timers.push(setTimeout(() => {
      toast.classList.add("opacity-0")
      toast.addEventListener("transitionend", () => toast.remove(), { once: true })
      // Fallback: transitionend が発火しない場合に備えて DOM から除去する
      this.timers.push(setTimeout(() => toast.remove(), 500))
    }, 3000))
  }

  #classesForType(type) {
    const base = "px-4 py-2 rounded-full shadow-lg text-sm transition-opacity duration-300"
    if (type === "error") {
      return `${base} bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-200`
    }
    return `${base} bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-200`
  }
}
