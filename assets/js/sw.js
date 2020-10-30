import { CacheableResponsePlugin } from 'workbox-cacheable-response'
import { CacheFirst } from 'workbox-strategies'
import { ExpirationPlugin } from 'workbox-expiration'
import { registerRoute } from 'workbox-routing'

registerRoute(
  ({ request }) => {
    if (request.destination !== 'image') return false

    const requestUrl = new URL(request.url)
    const referrerOrigin = (new URL(request.referrer)).origin

    if (requestUrl.origin !== referrerOrigin) return false

    return requestUrl.pathname === '/graph-proxy'
  },
  new CacheFirst({
    cacheName: 'graphs',
    plugins: [
      new CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new ExpirationPlugin({
        maxEntries: 200,
        maxAgeSeconds: 25 * 60 * 60, // 25 hours
      }),
    ],
  }),
)
