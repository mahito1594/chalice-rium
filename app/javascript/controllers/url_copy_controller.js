import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]
  static values = {
    text: String,
    url: String,
    copiedIcon: String,
    defaultIcon: String,
  }

  disconnect() {
    clearTimeout(this.resetTimer)
  }

  copy() {
    const plainText = `${this.textValue} ${this.urlValue}`
    const clipboardItem = new ClipboardItem({
      "text/plain": new Blob([plainText], { type: "text/plain" })
    })

    navigator.clipboard
      .write([clipboardItem])
      .then(() => {
        this.iconTarget.src = this.copiedIconValue
        this.#dispatchToast("コピーしました", "success")
        clearTimeout(this.resetTimer)
        this.resetTimer = setTimeout(() => {
          this.iconTarget.src = this.defaultIconValue
        }, 3000)
      })
      .catch(() => {
        this.#dispatchToast("コピーに失敗しました", "error")
      })
  }

  #dispatchToast(message, type) {
    window.dispatchEvent(
      new CustomEvent(`url-copy:${type}`, { detail: { message, type } })
    )
  }
}
