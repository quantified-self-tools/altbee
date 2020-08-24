document.addEventListener('submit', event => {
  if (event.target.getAttribute('data-prevent-submit') !== null) {
    event.preventDefault()
  }
})
