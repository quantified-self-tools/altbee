import '../css/app.css'

import 'phoenix_html'

import './forms'

import { Socket } from 'phoenix'
import NProgress from 'nprogress'
import { LiveSocket } from 'phoenix_live_view'

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
const liveSocket = new LiveSocket('/live', Socket, { params: { _csrf_token: csrfToken } })

window.addEventListener('phx:page-loading-start', info => NProgress.start())
window.addEventListener('phx:page-loading-stop', info => NProgress.done())

liveSocket.connect()

window.liveSocket = liveSocket
