// run callback once dom is loaded
const runOnReady = (cb: () => any): any => {
  document.readyState === "loading" ? document.addEventListener("DOMContentLoaded", cb) : cb();
}

export { runOnReady }