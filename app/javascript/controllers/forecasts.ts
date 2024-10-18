import { Controller } from "@hotwired/stimulus"
import { ComponentInit } from "../shared/place_picker";


export default class ForecastsController extends Controller {
  connect() {
    ComponentInit();
    // this.element.textContent = "Hello World!"
  }
}
