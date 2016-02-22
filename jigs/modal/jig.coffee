Button = require '../../button/Button'
backdrop = require '../../modal/backdrop'
Modal = require '../../modal/Modal'
Alert = require '../../modal/Alert'


document.addEventListener 'DOMContentLoaded', ->
  m = new Modal
    parentEl: document.body
    id: 'basic-modal'
    contents: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis placerat commodo nunc sit amet feugiat. Fusce imperdiet at lacus feugiat lobortis. Sed facilisis urna purus, vitae lacinia augue tincidunt eget. Praesent molestie augue ligula, at sagittis ipsum ullamcorper at. Sed lobortis elit vel scelerisque bibendum. Praesent enim velit, viverra ac lorem ultrices, bibendum accumsan sem. Morbi ut dolor condimentum felis sagittis interdum. Fusce convallis lectus a turpis fermentum tempor.</p><p>Pellentesque ornare viverra neque non finibus. Pellentesque vel urna scelerisque orci dictum tristique vitae ut sapien. In mollis tellus nec leo blandit aliquet. Etiam quis vulputate arcu. Quisque tellus eros, commodo ultrices varius quis, blandit a risus. Aliquam ut sollicitudin ex. Maecenas eu hendrerit ligula, a eleifend augue. Quisque rutrum pellentesque consequat. Cras in sem vel purus mollis aliquam. Donec faucibus vel nisl suscipit accumsan. Aliquam erat volutpat. Donec convallis nunc dolor, at auctor neque finibus quis. Praesent vitae lectus eu felis tincidunt semper. Quisque tortor turpis, aliquam eleifend sem eu, bibendum vehicula quam. Nam mollis pulvinar elementum. Nullam condimentum facilisis efficitur.</p>'
    static: false

  alert = new Alert
    parentEl: document.body
    title: 'Something great is happening!'
    content: 'You just won the lottery! I hope you\'re happy!'
    ok: 'Yes, I am!'
    buttonStyle: 'danger-flat'

  new Button
    label: 'Show Backdrop'
    parentEl: '.ex.basic .controls'
    click: ->
      backdrop().static = false
      backdrop().transitionIn()
  .render()

  new Button
    label: 'Show Modal Window'
    parentEl: '.ex.modal-window .controls'
    click: m.open
  .render()

  new Button
    label: 'Show with Promise'
    parentEl: '.ex.modal-window .controls'
    click: (e) ->
      m.open().then ->
        console.log 'it is open now!'
      , ->
        console.log 'open canceled!'
      .then ->
        console.log 'seriously, it\'s really open!'
  .render()

  new Button
    label: 'Show Alert'
    parentEl: '.ex.alert .controls'
    click: alert.open
  .render()
