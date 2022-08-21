import 'phoenix_html'

import './filter'
import './live-view'

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
}
