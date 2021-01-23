import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import csrfToken from '../csrf-token'

import hooks from './hooks'

const liveSocket = new LiveSocket('/live', Socket, {
  hooks,
  dom: {
    onBeforeElUpdated (from, to) {
      if (from.__x) { window.Alpine.clone(from.__x, to) }
    }
  },
  params: { _csrf_token: csrfToken }
})

liveSocket.connect()

window.liveSocket = liveSocket
