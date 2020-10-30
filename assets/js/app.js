import '../css/app.css'

import 'phoenix_html'
import 'alpinejs'

import './forms'
import './filter'
import './progress'

import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
const liveSocket = new LiveSocket('/live', Socket, {
  dom: {
    onBeforeElUpdated (from, to) {
      if (from.__x) { window.Alpine.clone(from.__x, to) }
    }
  },
  params: { _csrf_token: csrfToken }
})

liveSocket.connect()

window.liveSocket = liveSocket

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
}
