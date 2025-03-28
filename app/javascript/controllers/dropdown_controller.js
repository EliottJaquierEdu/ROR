import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() {
    this.dropdown = new bootstrap.Dropdown(this.element.querySelector('.dropdown-toggle'))
  }

  disconnect() {
    if (this.dropdown) {
      this.dropdown.dispose()
    }
  }
} 