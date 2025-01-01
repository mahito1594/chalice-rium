import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  delete() {
    this.element.remove()
  }
}
