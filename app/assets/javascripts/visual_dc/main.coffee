camera = null
controls = null
canvas = null
engine = null
scene = null
zone_grid = null
enclosure_racks = {}
hud = null

@resizeVisualDC = ->
  return unless getCanvas().length
  canvasDom = getCanvas().get(0)
  engine.resize()
  if camera instanceof Object
    scale = 100
    camera.orthoLeft = -canvasDom.width / scale
    camera.orthoRight = canvasDom.width / scale
    camera.orthoBottom = -canvasDom.height / scale
    camera.orthoTop = canvasDom.height / scale

document.resizeVisualDC = ->
  resizeVisualDC()

@setCameraMode = (mode) ->
  camera.mode = mode
  if mode == BABYLON.Camera.ORTHOGRAPHIC_CAMERA
    camera.inputs.removeByType("ArcRotateCameraMouseWheelInput")
    camera.inputs.add(new ArcRotateCameraOrthographicMouseWheelInput())
  else
    camera.inputs.removeByType("ArcRotateCameraOrthographicMouseWheelInput")
    camera.inputs.add(new BABYLON.ArcRotateCameraMouseWheelInput())

window.addEventListener('resize', resizeVisualDC, false)

@getCanvas = ->
  return $('#visual_dc_canvas')

@initializeVisualDC = ->
  canvasDom = getCanvas().get(0)
  return unless $(canvasDom).length
  engine = new BABYLON.Engine(canvasDom, true)
  scene = new BABYLON.Scene(engine)
  scene.clearColor = new BABYLON.Color3(229/256, 230/256, 231/256)
  BABYLON.Tools.GetClassName = BABYLON.Tools.getClassName
  scene.debugLayer.show()

  canvasDom.setAttribute("oncontextmenu", "return false")
  
  loadEnclosureRacks(true)
  camera = new BABYLON.ArcRotateCamera("Camera", Math.PI / 2, 15 * Math.PI / 32, 25, BABYLON.Vector3.Zero(), scene)
  camera.panningSensibility = 500
  camera.attachControl(canvasDom, true, false)
  resizeVisualDC()
  #setCameraMode(BABYLON.Camera.PERSPECTIVE_CAMERA)
  setCameraMode(BABYLON.Camera.ORTHOGRAPHIC_CAMERA)

#  ambientLight = new BABYLON.HemisphericLight('ambientLight', new BABYLON.Vector3.Zero(), scene)
  frontDirectionalLight = new BABYLON.DirectionalLight('frontDirectionalLight', new BABYLON.Vector3(0.5, -0.75, 1), scene)
  backDirectionalLight = new BABYLON.DirectionalLight('backDirectionalLight', new BABYLON.Vector3(-0.5, -0.75, -1), scene)

  hud = new HUD(@, scene)
  hud.showBlockingLoading("Retreiving racks…")

  # Ghost EnclosureRack under cursor
  ghost_data = {}
  ghost_data.x = -Infinity
  ghost_data.y = -Infinity
  ghost_data.height = 42
  ghost_data.name = "GHOST"
  ghost_data.orientation = 0
  ghost_cursor_enclosure_rack = new EnclosureRack(ghost_data, scene)
  ghost_cursor_enclosure_rack.setOpacity(0.0)
  # Clicky stuff
  _ = @
  clickObserver = scene.onPointerObservable.add (eventData, eventState) ->
    #return if eventData.type != 1 && eventData.type != 2
    return unless zone_grid
    if (pickedPoint = eventData.pickInfo.pickedPoint) != null
      x = Math.floor(-pickedPoint.x)
      y = Math.floor(pickedPoint.z)
      ghost_cursor_enclosure_rack.setGridPosition(x, y)
      ghost_cursor_enclosure_rack.setOpacity(0.5)
      enclosure_racks["ghost"] = ghost_cursor_enclosure_rack
    else
      ghost_cursor_enclosure_rack.setOpacity(0.0)
      delete enclosure_racks["ghost"]
    [min_x, max_x, min_y, max_y] = _.calculateGrid()
    zone_grid.setBounds(min_x, max_x, min_y, max_y)
    zone_grid.redraw()

  engine.runRenderLoop ->
    scene.render()

@destroyVisualDC = ->
  getCanvas().html('')

$(document).on 'turbolinks:load', ->
  initializeVisualDC()

$(document).on 'turbolinks:before-cache', ->
  destroyVisualDC()

@loadEnclosureRacks = (is_initial=false) ->
  canvas = getCanvas()
  $.ajax
    url: '/admin/datacenter_zones/' + canvas.data('zone-id') + '/racks.json'
    method: 'get'
    success: (data) ->
      presentEnclosureRacks(data, is_initial)
    error: (xhr, status, exception) ->
      console.log "Visual DC error: AJAX received " + exception + " with XHR:"
      console.log xhr

@presentEnclosureRacks = (data, is_initial=false) ->
  for rack in data
    enclosure_rack = new EnclosureRack(rack, scene)
    enclosure_racks[enclosure_rack.id] = enclosure_rack
  [min_x, max_x, min_y, max_y] = @calculateGrid()
  zone_grid = new ZoneGrid(min_x, max_x, min_y, max_y, scene)
  resetCamera() if is_initial
  hud.hideBlockingLoading()
  return true

@calculateGrid = ->
  min_x = Infinity
  min_y = Infinity
  max_x = -Infinity 
  max_y = -Infinity
  unless Object.keys(enclosure_racks).length
    [min_x, min_y, max_x, max_y] = [0, 0, 0, 0]
  Object.keys(enclosure_racks).forEach (id) ->
    rack = enclosure_racks[id]
    min_x = rack.x if rack.x < min_x
    min_y = rack.y if rack.y < min_y
    max_x = rack.x if rack.x > max_x
    max_y = rack.y if rack.y > max_y
  if Infinity in [min_x, min_y] || -Infinity in [max_x, max_y]
    console.log "Cannot render grid: Coordinate value error in EnclosureRacks list"
    return false
  return [min_x, max_x, min_y, max_y]


@resetCamera = ->
  xy = enclosureRacksMidpoint()
  x = xy[0] + 0.5
  y = xy[1] + 0.5
  if isNaN(x) || isNaN(y)
    [x, y] = [0, 0]
  camera.setPosition(new BABYLON.Vector3(-x, 15, y))
  camera.setTarget(new BABYLON.Vector3(-x, 0, y - 0.000000000000001))

@enclosureRacksMidpoint = ->
  x_total = 0
  y_total = 0
  num_of_enclosure_racks = Object.keys(enclosure_racks).length
  Object.keys(enclosure_racks).forEach (enclosure_rack_id) ->
    enclosure_rack = enclosure_racks[enclosure_rack_id]
    x_total += enclosure_rack.x
    y_total += enclosure_rack.y
  return [x_total / num_of_enclosure_racks, y_total / num_of_enclosure_racks]
