import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import csrfToken from '../csrf-token'
import Alpine from '../alpine'
import topbar from 'topbar'
import hooks from './hooks'

const liveSocket = new LiveSocket('/live', Socket, {
  hooks,
  dom: {
    onBeforeElUpdated (from, to) {
      if (from._x_dataStack) { Alpine.clone(from, to) }
    }
  },
  params: { _csrf_token: csrfToken }
})

topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })

let topbarTimeout = null

window.addEventListener("phx:page-loading-start", info => {
  clearTimeout(topbarTimeout)
  topbarTimeout = setTimeout(() => topbar.show(), 800)
})

window.addEventListener("phx:page-loading-stop", info => {
  clearTimeout(topbarTimeout)
  topbar.hide()
})

liveSocket.connect()

window.liveSocket = liveSocket
