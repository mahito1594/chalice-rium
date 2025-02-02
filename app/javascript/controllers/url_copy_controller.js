import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]
  static values = {
    text: String,
    url: String,
    copiedIcon: String,
  }

  copy() {
    const plainText = `${this.textValue} ${this.urlValue}`
    const clipboardItem = new ClipboardItem({
      "text/plain": new Blob([plainText], { type: "text/plain" })
    })

    navigator.clipboard
      .write([clipboardItem])
      .then(() => this.iconTarget.src = this.copiedIconValue)
      .catch((err) => console.error(err))
  }
}
