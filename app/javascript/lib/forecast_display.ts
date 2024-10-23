import { runOnReady } from "./utils";
import { Carousel, Tooltip } from 'bootstrap/dist/js/bootstrap.esm.js';


const activateBootstrap = () => {
  const carousels = Array.from(document.querySelectorAll('.carousel'))
    .map(node => new Carousel(node));
  const tooltips = Array.from(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    .map(node => new Tooltip(node));
}

runOnReady(activateBootstrap)