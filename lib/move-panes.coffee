module.exports =
  config:
    toggles:
      type: 'object'
      order: 1
      properties:
        autoCreate:
          title: 'Create a new pane'
          description: 'Create a new pane if cannot move'
          type: 'boolean'
          default: true

  activate: (state) ->
    atom.commands.add "atom-workspace", "move-panes-cabaret:move-right": => @moveRight()
    atom.commands.add "atom-workspace", "move-panes-cabaret:move-left", => @moveLeft()
    atom.commands.add "atom-workspace", "move-panes-cabaret:move-down", => @moveDown()
    atom.commands.add "atom-workspace", "move-panes-cabaret:move-up", => @moveUp()
    atom.commands.add "atom-workspace", "move-panes-cabaret:move-next", => @moveNext()
    atom.commands.add "atom-workspace", "move-panes-cabaret:move-previous", => @movePrevious()

  moveRight: -> @move 'horizontal', +1
  moveLeft: -> @move 'horizontal', -1
  moveUp: -> @move 'vertical', -1
  moveDown: -> @move 'vertical', +1
  moveNext: -> @moveOrder @nextMethod
  movePrevious: -> @moveOrder @previousMethod

  nextMethod: 'activateNextPane'
  previousMethod: 'activatePreviousPane'

  active: -> atom.workspace.getActivePane()

  moveOrder: (method) ->
    source = @active()
    atom.workspace[method]()
    target = @active()
    @swapEditor source, target

  newPane: (pane, orientation, delta)->
    if orientation == 'horizontal' && delta == +1
      return pane.splitRight()
    else if orientation == 'horizontal' && delta == -1
      return pane.splitLeft()
    else if orientation == 'vertical' && delta == -1
      return pane.splitUp()
    else if orientation == 'vertical' && delta == +1
      return pane.splitDown()
    else
      return null

  move: (orientation, delta) ->
    pane = atom.workspace.getActivePane()
    [axis,child] = @getAxis pane, orientation
    if axis?
      target = @getRelativePane axis, child, delta
    if !target? && atom.config.get('move-panes-cabaret.toggles.autoCreate')
      target = @newPane pane, orientation, delta
    if target?
      @swapEditor pane, target

  swapEditor: (source, target) ->
    editor = source.getActiveItem()
    source.removeItem editor
    target.addItem editor
    target.activateItem editor
    target.activate()

  getAxis: (pane, orientation) ->
    axis = pane.parent
    child = pane
    while true
      return [] unless axis.constructor.name == 'PaneAxis'
      break if axis.orientation == orientation
      child = axis
      axis = axis.parent
    return [axis,child]

  getRelativePane: (axis, source, delta) ->
    position = axis.children.indexOf source
    target = position + delta
    return unless target < axis.children.length
    return axis.children[target].getPanes()[0] if axis.children[target]

  deactivate: ->

  serialize: ->
