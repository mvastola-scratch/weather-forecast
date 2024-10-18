import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = true
// @ts-ignore
window.Stimulus   = application

export { application }
