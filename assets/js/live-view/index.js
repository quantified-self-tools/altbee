import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import csrfToken from '../csrf-token'
import Alpine from '../alpine'

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

liveSocket.connect()

window.liveSocket = liveSocket
