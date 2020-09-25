window.addEventListener('keydown', event => {
  if (event.target !== document.body) return

  if (event.key === '/' && !event.isComposing && !event.ctrlKey && !event.altKey) {
    const filterEl = document.getElementById('filter-goals')
    if (filterEl) {
      event.preventDefault()
      filterEl.focus()
    }
  }
})
