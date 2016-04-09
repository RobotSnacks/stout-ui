###*
# @overview Defines the generic Pane object which can be used for application
# window "panes" or modal windows, etc.
#
# @module stout-ui/pane/Pane
###

ComponentView         = require '../component/ComponentView'
defaults              = require 'lodash/defaults'
Pane                  = require './Pane'
template              = require './pane.template'
vars                  = require '../vars'
Promise               = require 'stout-core/promise/Promise'
transitions           = require './transitions'
TransitionCanceledExc = require('stout-client/exc').TransitionCanceledExc

# Load shared variables.
require '../vars/pane'


###*
# The class to add to the root pane container.
# @const
# @type string
# @private
###
PANE_CLS = vars.read 'pane/pane-class'


###*
# Default pane transition-in time.
# @const
# @type number
# @private
###
TRANS_IN_TIME = vars.readTime 'pane/pane-trans-in-time'


###*
# Default pane transition-out time.
# @const
# @type number
# @private
###
TRANS_OUT_TIME = vars.readTime 'pane/pane-trans-out-time'


###*
# The pane custom tag name.
# @type string
# @const
# @private
###
TAG_NAME = vars.readPrefixed 'pane/pane-tag'



###*
# Pane class which represents a generic pane for displaying content within
# the viewport.
#
# @param {Object} [init] - Initiation object.
#
# @exports stout-ui/pane/Pane
# @extends stout-ui/container/Container
# @constructor
###
module.exports = class PaneView extends ComponentView

  constructor: (init, events) ->
    defaults init, {template, tagName: TAG_NAME}
    super init, events
    @prefixedClasses.add PANE_CLS
    @syncProperty @context, 'transition start end width height'

    @on 'transition:in', ->
      transitions[@transition].in?.call @
      @setDisplaySize()

    @on 'transition:out', ->
      transitions[@transition].out?.call @

  # Clone shared view-model properties.
  @cloneProperty Pane, 'transition start end width height'


  ###*
  # Window resize event handler. It simply repositions the modal window and
  # its contents.
  #
  # @method _resizeHandler
  # @memberof stout-ui/modal/Modal#
  # @protected
  ###
  _resizeHandler: =>
    @setDisplaySize()


  ###*
  # Resets the pane's size and position.
  #
  # @method resetSizeAndPosition
  # @memberof stout-ui/pane/Pane#
  # @public
  ###
  resetSizeAndPosition: ->
    @root.style.width = "auto"
    @root.style.height = "auto"
    @root.style.transform = "none"



  ###*
  # Sets the final-size of the pane.
  #
  # @method setDisplaySize
  # @memberof stout-ui/pane/Pane#
  # @public
  ###
  setDisplaySize: ->
    W = window.innerWidth
    H = window.innerHeight

    setWH = (w, h) =>
      @root.style.width = "#{w}px"
      @root.style.height = "#{h}px"

    if @width is 'auto' or @height is 'auto'
      @contents.getRenderedDimensions().then ({width, height}) =>
        switch @width
          when 'full' then w = W
          when 'auto' then w = width
          else w = @width
        switch @height
          when 'full' then h = H
          when 'auto' then h = height
          else h = @height
        setWH w, h

    else
      w = if @width is 'full' then W else @width
      h = if @height is 'full' then H else @height
      setWH w, h



  ###*
  # Sets pane transformation parameters.
  #
  # @param {Array<number>} params Array of `matrix3d` CSS transformation
  # parameters.
  #
  # @method setTransform
  # @memberof stout-ui/pane/Pane#
  # @public
  ###
  setTransform: (params) ->
    @root.style.transform = "matrix3d(#{params.join(',')})"
    if @transition is 'zoom'
      @root.style.transform += " translate3d(-50%, -50%, 0)"


  ###*
  # Transitions-in this pane.
  #
  # @method transitionIn
  # @memberof stout-ui/pane/Pane#
  # @public
  ###
  transitionIn: (time = TRANS_IN_TIME) ->
    if @visible
      Promise.rejected new TransitionCanceledExc "Transition Canceled
      because the pane is already visible."
    else
      @setPaneTransitionClasses()
      @resetSizeAndPosition()
      transitions[@transition].setupIn.call(@).then =>
        super(time).then =>
          window.addEventListener 'resize', @_resizeHandler


  ###*
  # Transitions-out this pane.
  #
  # @method transitionOut
  # @memberof stout-ui/pane/Pane#
  ###
  transitionOut: (time = TRANS_OUT_TIME) ->
    if @hidden
      Promise.rejected new TransitionCanceledExc "Transition Canceled
      because the pane is already hidden."
    else
      @setPaneTransitionClasses()
      transitions[@transition].setupOut.call(@).then =>
        super(time).then =>
          window.removeEventListener 'resize', @_resizeHandler


  ###*
  # Sets the transition classes on the pane element.
  #
  # @method setPaneTransitionClasses
  # @memberof stout-ui/pane/Pane#
  ###
  setPaneTransitionClasses: ->
    @prefixedClasses.remove 'zoom overlay fade'
    @prefixedClasses.add @transition