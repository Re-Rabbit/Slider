import $ from 'jquery'

export default function(ports) {
  ports.getSize.subscribe(uuid => {
    let $el = $(`[data-uuid=${uuid}]`)

    const getSliderSize = uuid => _ => {
      let $el = $(`[data-uuid=${uuid}]`).find('.slider__line')
      return {
        left:  $el.offset().left,
        width: $el.width()
      }
    }

    let fx = getSliderSize(uuid)

    setTimeout(_ => ports.setSize.send(fx()), 0)
  })
}

