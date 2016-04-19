###*
# @overview Defines the MaxLength validator.
#
# @module stout-ui/validator/MaxLength
###
Validator = require 'stout-core/validator/Validator'



###*
# The `MaxLength` validator can be used for giving user feedback on
# length-restricted text fields.
#
#
# @exports stout-ui/validator/MaxLength
# @extends stout-core/validator/Validator
# @constructor
###
module.exports = class MaxLength extends Validator

  constructor: (max, warn, @removeTime = 3000) ->
    super()
    this.max = max
    this.warn = warn
    @messages.warning = 'The :name field can be at most :max characters.'
    @messages.error = 'The maximum length of :max characters has been reached.'


  @property 'max'


  @property 'warn'


  ###*
  # Timeout for removing the error after @removeTime.
  #
  # @member _errorTimeout
  # @memberof stout-ui/validator/MaxLength
  ###


  ###*
  # Validates the length of the passed value.
  #
  # @param {mixed} v - The value to validate.
  #
  # @method softValidate
  # @memberof stout-ui/validator/MaxLength#
  ###
  softValidate: (v) ->
    if v.length >= @max
      @_error()
      if @_errorTimeout then clearTimeout @_errorTimeout
      @_errorTimeout = setTimeout =>
        console.log 'okaying...', @
        @_ok()
      , @removeTime
    else if v.length >= @warn
      @_warning()
    else
      @_ok()
    super()


  ###*
  # Hard validation for max length.
  #
  # @param {mixed} v - The value to validate.
  #
  # @method validate
  # @memberof stout-ui/validator/MaxLength#
  ###
  validate: ->