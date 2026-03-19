// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
// import {hooks as colocatedHooks} from "phoenix-colocated/y_web"
import topbar from "../vendor/topbar"

const Hooks = {
  TakeComposer: {
    mounted() {
      const textarea = this.el.querySelector("textarea")
      const counter = this.el.querySelector("[data-counter]")
      const progressCircle = this.el.querySelector("[data-progress-circle]")
      const shareButton = this.el.querySelector("[data-share-button]")
      const limit = 250

      const updateUI = () => {
        const count = textarea.value.length
        const remaining = limit - count
        const percent = Math.min((count / limit) * 100, 100)
        
        // Update counter text
        if (counter) {
          if (remaining <= 20) {
            counter.innerText = remaining
            counter.classList.remove("hidden")
            counter.classList.toggle("text-red-500", remaining < 0)
            counter.classList.toggle("text-white/60", remaining >= 0)
          } else {
            counter.innerText = ""
            counter.classList.add("hidden")
          }
        }

        // Update progress ring
        if (progressCircle) {
          const radius = progressCircle.r.baseVal.value
          const circumference = 2 * Math.PI * radius
          const offset = circumference - (percent / 100) * circumference
          progressCircle.style.strokeDasharray = `${circumference} ${circumference}`
          progressCircle.style.strokeDashoffset = offset
          
          if (count >= limit) {
            progressCircle.style.stroke = "#ef4444" // red
          } else if (count >= limit * 0.9) {
            progressCircle.style.stroke = "#f59e0b" // orange/yellow
          } else {
            progressCircle.style.stroke = "#F5F5F5" // accent color (near-white)
          }

          // Hide circle if over limit (replaced by red counter)
          progressCircle.parentElement.classList.toggle("opacity-0", count > limit)
        }

        // Toggle button state
        if (shareButton) {
          shareButton.disabled = count === 0 || count > limit
          shareButton.classList.toggle("opacity-50", shareButton.disabled)
          shareButton.classList.toggle("cursor-not-allowed", shareButton.disabled)
        }
      }

      textarea.addEventListener("input", updateUI)
      // Initial check
      updateUI()
    }
  },
  NotificationObserver: {
    mounted() {
      this.observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const id = entry.target.dataset.id;
            const unread = entry.target.dataset.unread === "true";
            if (unread) {
              this.pushEvent("mark_read", { id: id });
              // Optimization: update local state so we don't spam
              entry.target.dataset.unread = "false"; 
            }
          }
        });
      }, { threshold: 0.1 });

      this.observeItems();
    },
    updated() {
      this.observeItems();
    },
    destroyed() {
      if (this.observer) this.observer.disconnect();
    },
    observeItems() {
      this.el.querySelectorAll('[data-id]').forEach(item => {
        this.observer.observe(item);
      });
    }
  },
  EmojiPicker: {
    mounted() {
      this.handleOutsideClick = (e) => {
        if (!this.el.contains(e.target)) {
          const closeEvent = this.el.dataset.closeEvent || "close_emoji_picker"
          this.pushEvent(closeEvent, {})
        }
      }
      // Delay so the toggle click doesn't immediately close
      setTimeout(() => {
        document.addEventListener("click", this.handleOutsideClick)
      }, 10)
    },
    destroyed() {
      document.removeEventListener("click", this.handleOutsideClick)
    }
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

