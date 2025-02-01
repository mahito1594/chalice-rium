import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]
  static values = {
    text: String,
    url: String,
    copiedIcon: String,
  }

  copy() {
    const plainText = `${this.textValue} | ${this.urlValue}`
    const htmlText = `<a href="${this.urlValue}">${this.textValue}</a>`
    const clipboardItem = new ClipboardItem({
      "text/plain": new Blob([plainText], { type: "text/plain" }),
      "text/html": new Blob([htmlText], { type: "text/html" })
    })

    navigator.clipboard
      .write([clipboardItem])
      .then(() => this.iconTarget.src = this.copiedIconValue)
      .catch((err) => console.error(err))
  }
}
