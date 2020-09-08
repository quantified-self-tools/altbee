import NProgress from 'nprogress'

let pendingLoad = null

window.addEventListener('phx:page-loading-start', () => {
  cancelPendingLoad()
  pendingLoad = setTimeout(() => {
    NProgress.start()
  }, 250)
})

window.addEventListener('phx:page-loading-stop', () => {
  NProgress.done()
  cancelPendingLoad()
})

function cancelPendingLoad () {
  if (pendingLoad) {
    clearTimeout(pendingLoad)
    pendingLoad = null
  }
}
