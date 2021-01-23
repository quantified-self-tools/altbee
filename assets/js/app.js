import '../css/app.css'

import 'phoenix_html'
import 'alpinejs'

import './filter'
import './forms'
import './live-view'
import './progress'

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
}
