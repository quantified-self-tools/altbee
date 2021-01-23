import Sortable from 'sortablejs'

export default {
  Sortable: {
    mounted () {
      const pushSortEvent = list =>
        this.pushEvent('sort', list)

      // eslint-disable-next-line no-new
      new Sortable(this.el, {
        handle: '[data-drag-handle]',
        ghostClass: 'drag-ghost',
        onSort () {
          const sortedList = [...document.querySelectorAll('[data-group-id]')]
            .map(el => el.dataset.groupId)
          pushSortEvent(sortedList)
        }
      })
    }
  }
}
