###*
# @overview Defines the `TreeItemView` view class, the view portion of a Table of
# Contents item component.
#
# @module stout-ui/tree/TreeItemView
###
defaults        = require 'lodash/defaults'
InteractiveView = require '../interactive/InteractiveView'
Promise         = require 'stout-core/promise/Promise'
template        = require './tree-item.template'
vars            = require '../vars'

# Require shared input variables.
require '../vars/tree'


###*
# The table-of-contents custom tag name.
#
# @type string
# @const
# @private
###
TAG_NAME = vars.readPrefixed 'tree/tree-item-tag'


###*
# The tree custom tag name.
#
# @type string
# @const
# @private
###
TREE_TAG_NAME = vars.readPrefixed 'tree/tree-tag'


###*
# The tree-item class name.
#
# @type string
# @const
# @private
###
TREE_ITEM_CLS = vars.read 'tree/tree-item-class'


###*
# Collapsible class added to items which should be rendered as "collapsible."
#
# @type {string}
# @const
###
COL_CLS = vars.read 'tree/tree-collapsible-class'


###*
# Class indicating that the item is currently collapsed.
#
# @type {string}
# @const
###
COLLAPSED_CLS = vars.read 'tree/tree-collapsed-class'


###*
# The time (in millseconds) a collapse operation should take.
#
# @type {number}
# @const
###
COLLAPSE_T = vars.readTime 'tree/tree-item-collapse-time'


###*
# The time (in millseconds) an expand operation should take.
#
# @type {number}
# @const
###
EXPAND_T = vars.readTime 'tree/tree-item-expand-time'


###*
# Class added to the tree during a collapsing transition.
#
# @type {string}
# @const
###
COLLAPSING_CLS = vars.read 'tree/tree-collapsing-class'


###*
# Class added to the tree during an expand transition.
#
# @type {string}
# @const
###
EXPANDING_CLS = vars.read 'tree/tree-expanding-class'



###*
# Helper function sets then schedules the clearing of the collapse transition
# flag.
#
# @function
# @inner
###
transitionHelper = (dir, target) ->
  t = if dir is 'expand' then EXPAND_T else COLLAPSE_T
  target._collapseTimer = setTimeout ->
    target._collapseTransitioning = false
    target._targetTree = false
    target.prefixedClasses.remove EXPANDING_CLS, COLLAPSING_CLS
    if dir is 'collapse' then target.prefixedClasses.add COLLAPSED_CLS
  , t


###*
# Helper function to set the collapse-prevention flag.
#
#
#
###
setCollapseFlag = (target) ->
  if target._collapseTimer then clearTimeout target._collapseTimer
  target._collapseTransitioning = true



###*
# The `TreeItemView` class represents the view part of a table of contents
# item component.
#
# @exports stout-ui/tree/TreeItemView
# @extends stout-ui/interactive/InteractiveView
# @constructor
###
module.exports = class TreeItemView extends InteractiveView

  constructor: (init, events) ->
    defaults init, {template, tagName: TAG_NAME}
    super init, events

    @prefixedClasses.add TREE_ITEM_CLS

    @root.setAttribute 'role', 'listitem'

    @_collapseTransitioning = false
    @_targetTree = false

    @on 'ready', @_onTreeReady, @

    # Listen for touchstart/mouseup events to toggle the tree.
    @on 'mouseup', (e) =>
      e.data.stopPropagation()
      @_targetTree = true
      @toggle()


  ###*
  # Property indicating if this item's children can be collapsed. This property
  # has no meaning if this item has no children.
  #
  # @member {boolean} collapsible
  # @memberof stout-ui/tree/TreeItemView#
  ###
  @property 'collapsible',
    type: 'boolean'
    default: true


  ###*
  # The current collapsed state of this tree item. This property has no meaning
  # if it has no children.
  #
  # @member {boolean} collapsible
  # @memberof stout-ui/tree/TreeItemView#
  ###
  @property 'collapsed',
    type: 'boolean'
    default: true


  ###*
  # Timer for updating `_collapseTransitioning` flag.
  #
  # @member _collapseTimer
  # @memberof stout-ui/tree/TreeItemView#
  ###


  ###*
  # Flag indicating if the tree is currently expanding or collapsing. A `true`
  # state indicates that transition is currently occurring.
  #
  # @member _collapseTransitioning
  # @memberof stout-ui/tree/TreeItemView#
  ###


  ###*
  # Flag indicating if this tree-item was the source of the collapse or expand.
  #
  # @member _targetTree
  # @memberof stout-ui/tree/TreeItemView#
  ###


  ###*
  # Collapses child trees and their descendants. This method doesn't do any
  # checking to determine if a collpase should be "allowed" or not.
  #
  # @method _collapse
  # @memberof stout-ui/tree/TreeItemView#
  # @private
  ###
  _collapse: ->
    @collapsed = true
    setCollapseFlag @
    @prefixedClasses.remove EXPANDING_CLS
    @prefixedClasses.add COLLAPSING_CLS

    reduceParentTreeHeight = (tree, h) ->
      if not tree then return
      tree.reduceHeight h
      if tree.parent.parent and tree.parent.parent.collapsible
        reduceParentTreeHeight tree.parent.parent, h

    @_getDescendantsHeight().then (h) =>
      promises = []
      @children.get(TREE_TAG_NAME).every (tree) ->
        promises.push tree.collapse()
      Promise.all(promises).then =>
        transitionHelper 'collapse', @
        if @_targetTree then reduceParentTreeHeight(@parent, h)


  ###*
  # Expands child trees and their descendants. This method doesn't do any
  # checking to determine if an expand should be "allowed" or not.
  #
  # @method _expand
  # @memberof stout-ui/tree/TreeItemView#
  ###
  _expand: ->
    @collapsed = false
    setCollapseFlag @
    @prefixedClasses.remove COLLAPSED_CLS
    @prefixedClasses.add EXPANDING_CLS

    increaseParentTreeHeight = (tree, h) ->
      if not tree then return
      tree.increaseHeight h
      if tree.parent.parent and tree.parent.parent.collapsible
        increaseParentTreeHeight tree.parent.parent, h

    @_getDescendantsHeight().then (h) =>
      promises = []
      @children.get(TREE_TAG_NAME).every (tree) ->
        promises.push tree.expand()
      Promise.all(promises).then =>
        transitionHelper 'expand', @
        if @_targetTree then increaseParentTreeHeight(@parent, h)


  ###*
  # Opens the child tree of this tree item, if it is currently collapsed and
  # is collapsible.
  #
  # @method expand
  # @memberof stout-ui/tree/TreeItemView#
  ###
  expand: ->
    if @collapsible and @collapsed and not @_collapseTransitioning
      @_expand()
    else
      Promise.fulfilled()


  ###*
  # Closes the child tree of this tree item, if it is currently expand and
  # is collapsible.
  #
  # @method collapse
  # @memberof stout-ui/tree/TreeItemView#
  ###
  collapse: ->
    if not @_collapseTransitioning and @collapsible and not @collapsed
      @_collapse()
    else
      Promise.fulfilled()


  ###*
  # Toggles the expanded/collapsed state of this tree view item.
  #
  # @method toggle
  # @memberof stout-ui/tree/TreeItemView#
  ###
  toggle: ->
    if @collapsed then @expand() else @collapse()


  ###*
  # Calculates and returns (as a promise) the height of this tree including
  # any subtrees.
  #
  # @returns {module:stout-core/promise/Promise} Promise resolved to the height
  # of the descendants in pixels.
  #
  # @member _getDescendantsHeight
  # @memberof stout-ui/tree/TreeItemView#
  ###
  _getDescendantsHeight: ->
    promises = []

    @children.get(TREE_TAG_NAME).every (tree) ->
      promises.push tree.getRenderedDimensions(null, ['height'])

      tree.children.get(TAG_NAME).every (item) ->
        promises.push item._getDescendantsHeight()

    Promise.all(promises).then (a) ->
      if not a or a.length is 0
        0
      else
        a.reduce ((p, v) -> p + (+v?.height or 0)), 0


  ###*
  # Updates the "collapsible" display state of this item on-ready.
  #
  # @method _onTreeReady
  # @memberof stout-ui/tree/TreeItemView#
  # @private
  ###
  _onTreeReady: ->

    # Update collapsed and collapsable classes based on child trees.
    @prefixedClasses.remove COL_CLS, COLLAPSED_CLS

    if @children.get(TREE_TAG_NAME).length > 0 and @collapsible
      if @collapsed then @_collapse() else @_expand()
      @prefixedClasses.add COL_CLS

    if @collapsed and @collapsible
      @prefixedClasses.add COLLAPSED_CLS
