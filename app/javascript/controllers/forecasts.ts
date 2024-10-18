import { Controller } from "@hotwired/stimulus"

export default class ForecastsController extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
