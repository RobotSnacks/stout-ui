###*
# @overview Defines the Backdrop class and its singleton interface.
#
# @module stout-ui/modal/backdrop
# @requires stout-ui/common/Interactive
# @requires stout-ui/vars/modal
# @requires stout-ui/vars
###
defaults = require 'lodash/defaults'
Interactive = require '../interactive/Interactive'
InteractiveView = require '../interactive/InteractiveView'
vars        = require '../vars'


# Load modal variables.
require '../vars/modal'



###*
# The backdrop classname postfix.
# @const
# @type string
# @private
###
BACKDROP_CLASS = vars.read 'modal/backdrop-class'


###*
# The backdrop transition-in time in milliseconds.
# @const
# @type number
# @private
###
TRANS_IN_TIME = vars.readTime 'modal/backdrop-trans-in-time'


###*
# The backdrop transition-out time in milliseconds.
# @const
# @type number
# @private
###
TRANS_OUT_TIME = vars.readTime 'modal/backdrop-trans-out-time'


###*
# Internal reference to backdrop singleton instance.
# @private
# @type modal/backdrop.Backdrop
###
instance = null



module.exports.Backdrop = class Backdrop extends InteractiveView

  ###*
  # Backdrop element which overlays the application's main window and prevents
  # user interaction with the main application window until the backdrop is
  # removed.
  #
  # @class Backdrop
  # @extends stout-ui/common/Interactive
  # @memberof stout-ui/modal/backdrop
  ###
  constructor: (init = {}, events) ->
    defaults init, {template: '', context: new Interactive}
    super init, events
    @prefixedClasses.add BACKDROP_CLASS, 'hidden'
    @parentEl = document.body
    @render()
    @static = true


  ###*
  # If this property is `false`, then the backdrop can be cleared if the
  # user clicks on it. Otherwise, the backdrop can only be cleared
  # programmatically using `#hide()` or `#transitionOut()`.
  #
  # @member static
  # @memberof stout-ui/modal/backdrop.Backdrop#
  # @type boolean
  # @default true
  ###
  @property 'static',
    default: true
    set: (s) ->
      @_static = !!s
      if @_static
        @off 'click', @_clickHandler
      else
        @on 'click', @_clickHandler, @
    get: -> @_static


  ###*
  # Internal click handler which is called when the user clicks on the
  # backdrop *and* the backdrop is configured as *not static*.
  #
  # @method _clickHandler
  # @memberof stout-ui/modal/backdrop.Backdrop#
  # @private
  ###
  _clickHandler: -> @transitionOut()


  ###*
  # Transitions-in the backdrop.
  #
  # @param {function} [cb] - Callback function called when the backdrop is
  # fully visible.
  #
  # @method transitionIn
  # @memberof stout-ui/modal/backdrop.Backdrop#
  ###
  transitionIn: (cb) -> super TRANS_IN_TIME, cb


  ###*
  # Transitions-out the backdrop.
  #
  # @param {function} [cb] - Callback function called when the backdrop has
  # fully transitioned out of user view.
  #
  # @method transitionOut
  # @memberof stout-ui/modal/backdrop.Backdrop#
  ###
  transitionOut: (cb) -> super TRANS_OUT_TIME, cb



###*
# Returns singleton instance of the Backdrop class.
#
# @returns {modal/backdrop.Backdrop}
#
# @function
###
module.exports = ->
  if instance is null then instance = new Backdrop()
  instance
