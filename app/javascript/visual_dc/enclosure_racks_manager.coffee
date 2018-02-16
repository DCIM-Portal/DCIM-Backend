import EnclosureRack from './enclosure_rack'
import ZoneGrid from './zone_grid'

export default class EnclosureRacksManager
  constructor: (context) ->
    @context = context

    @racks = {
      # Committed to server
      solid: {},
      # To be sent to server
      pending: {},
      # Mouse down, not sure if dragging camera
      uncertain: {},
      # Awaiting placement under cursor
      ghost: {},
      # Not on ZoneGrid
      drawer: {}
    }

    $(".enclosure-rack-drawer-item").on "click", (event) =>
      enclosure_rack_id = $(event.currentTarget).data('enclosure-rack-id')
      Object.keys(@racks.ghost).forEach (id) =>
        @stopGhostEnclosureRack(id)
      @startGhostEnclosureRack(enclosure_rack_id)

  populate: ->
    @context.hud.showBlockingLoading("Retreiving racks…")
    @loadEnclosureRacks()
    
  loadEnclosureRacks: ->
    canvas = @context.getCanvas()
    $.ajax
      url: '/admin/visual_dc/zone/' + canvas.data('zone-id') + '.json'
      method: 'get'
      success: (data) =>
        @_callbackGotEnclosureRacks(data)
      error: (xhr, status, exception) ->
        console.log "Visual DC error: AJAX received " + exception + " with XHR:"
        console.log xhr

  _callbackGotEnclosureRacks: (data) =>
    is_initial = $.isEmptyObject(@racks.solid)
    for rack in data
      enclosure_rack = new EnclosureRack(rack, @context.scene)
      if (enclosure_rack.x != null && enclosure_rack.y != null)
        @racks.solid[enclosure_rack.id] = enclosure_rack
      else
        enclosure_rack.hide()
        @racks.drawer[enclosure_rack.id] = enclosure_rack
    @context.zone_grid = new ZoneGrid(0, 0, 0, 0, @context.scene)
    @redrawGrid()
    @resetCamera() if is_initial
    @context.hud.hideBlockingLoading()

  calculateGrid: (objects) ->
    min_x = Infinity
    min_y = Infinity
    max_x = -Infinity
    max_y = -Infinity
    unless Object.keys(objects).length
      [min_x, min_y, max_x, max_y] = [0, 0, 0, 0]
    Object.keys(objects).forEach (id) =>
      rack = objects[id]
      min_x = rack.x if rack.x < min_x
      min_y = rack.y if rack.y < min_y
      max_x = rack.x if rack.x > max_x
      max_y = rack.y if rack.y > max_y
    if Infinity in [min_x, min_y] || -Infinity in [max_x, max_y]
      console.log "Cannot render grid: Coordinate value error in EnclosureRacks list"
      return false
    return [min_x, max_x, min_y, max_y]

  redrawGrid: (objects=$.extend({}, @racks.solid, @racks.pending)) ->
    [min_x, max_x, min_y, max_y] = @calculateGrid(objects)
    @context.zone_grid.setBounds(min_x, max_x, min_y, max_y)
    @context.zone_grid.redraw()

  resetCamera: ->
    xy = @enclosureRacksMidpoint()
    x = xy[0] + 0.5
    y = xy[1] + 0.5
    if isNaN(x) || isNaN(y)
      [x, y] = [0, 0]
    @context.camera.setPosition(new BABYLON.Vector3(-x, 15, y))
    @context.camera.setTarget(new BABYLON.Vector3(-x, 0, y - 0.000000000000001))

  enclosureRacksMidpoint: ->
    x_total = 0
    y_total = 0
    num_of_enclosure_racks = Object.keys(@racks.solid).length
    Object.keys(@racks.solid).forEach (enclosure_rack_id) =>
      enclosure_rack = @racks.solid[enclosure_rack_id]
      x_total += enclosure_rack.x
      y_total += enclosure_rack.y
    return [x_total / num_of_enclosure_racks, y_total / num_of_enclosure_racks]

  startGhostEnclosureRack: (enclosure_rack_id) ->
    ghost_cursor_enclosure_rack = @racks.drawer[enclosure_rack_id]
    ghost_cursor_enclosure_rack.hide()
    @racks.ghost[ghost_cursor_enclosure_rack.id] = ghost_cursor_enclosure_rack

    clickObserver = @context.scene.onPointerObservable.add (eventData, eventState) =>
      return unless @context.zone_grid
      # Point identifiable
      if (pickedPoint = eventData.pickInfo.pickedPoint) != null
        # Mouse down (placement uncertain)
        if (eventData.type == BABYLON.PointerEventTypes.POINTERDOWN)
          @racks.uncertain[enclosure_rack_id] = ghost_cursor_enclosure_rack
        # Mouse up (flush uncertain to pending or cancel)
        else if (eventData.type == BABYLON.PointerEventTypes.POINTERUP)
          # Left-mouse click (flush uncertain to pending)
          if (eventData.event.button == 0)
            Object.keys(@racks.uncertain).forEach (enclosure_rack) =>
              @racks.pending[enclosure_rack_id] = @racks.uncertain[enclosure_rack_id]
              # Remove from drawer when promoting to pending
              delete @racks.drawer[enclosure_rack_id]
              @stopGhostEnclosureRack(enclosure_rack_id)
              @racks.pending[enclosure_rack_id].show(EnclosureRack::STATE_PENDING)
            @racks.uncertain = {}
          # Right-mouse click (cancel)
          else if (eventData.event.button == 2)
            delete @racks.uncertain[enclosure_rack_id]
            @stopGhostEnclosureRack(enclosure_rack_id)
        # Mouse move (flush uncertain to black hole)
        else if (eventData.type == BABYLON.PointerEventTypes.POINTERMOVE)
          @racks.uncertain = {}
          x = Math.floor(-pickedPoint.x)
          y = Math.floor(pickedPoint.z)
          ghost_cursor_enclosure_rack.show(EnclosureRack::STATE_GHOST)
          ghost_cursor_enclosure_rack.setGridPosition(x, y)
          @redrawGrid($.extend({}, @racks.solid, @racks.pending, @racks.ghost))
      else
        ghost_cursor_enclosure_rack.hide()
        @redrawGrid()

    @racks.ghost[ghost_cursor_enclosure_rack.id].clickObserver = clickObserver

  stopGhostEnclosureRack: (enclosure_rack_id) ->
    return unless @racks.ghost[enclosure_rack_id]
    @context.scene.onPointerObservable.remove(@racks.ghost[enclosure_rack_id].clickObserver)
    @racks.ghost[enclosure_rack_id].hide()
    delete @racks.ghost[enclosure_rack_id]
    @redrawGrid()
