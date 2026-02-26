// AutoSave hook — debounces pushEvent("auto-save") at 2 seconds.
//
// Attach to a container element. Any `input` or `change` event within
// the element starts/resets a 2-second timer. When the timer fires, it
// pushes an "auto-save" event to the LiveView.

const AutoSave = {
  mounted() {
    this.timer = null
    this.saving = false

    this.el.addEventListener("input", () => this.scheduleSave())
    this.el.addEventListener("change", () => this.scheduleSave())

    this.handleEvent("auto-save-done", () => {
      this.saving = false
    })
  },

  scheduleSave() {
    if (this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      if (!this.saving) {
        this.saving = true
        this.pushEvent("auto-save", {})
      }
    }, 2000)
  },

  destroyed() {
    if (this.timer) clearTimeout(this.timer)
  }
}

export default AutoSave
