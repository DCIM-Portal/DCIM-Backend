camera = null
controls = null
canvas = null
engine = null
scene = null
zone_grid = null
enclosure_racks = []
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
  min_x = Infinity
  min_y = Infinity
  max_x = -Infinity 
  max_y = -Infinity
  for rack in data
    min_x = rack.x if rack.x < min_x
    min_y = rack.y if rack.y < min_y
    max_x = rack.x if rack.x > max_x
    max_y = rack.y if rack.y > max_y
    enclosure_rack = new EnclosureRack(rack, scene)
    enclosure_racks.push(enclosure_rack)
  if Infinity in [min_x, min_y] || -Infinity in [max_x, max_y]
    console.log "Cannot render grid: Coordinate value error in EnclosureRacks list"
    return false
  zone_grid = new ZoneGrid(min_x, max_x, min_y, max_y, scene)
  resetCamera() if is_initial
  hud.hideBlockingLoading()
  return true

@resetCamera = ->
  xy = enclosureRacksMidpoint()
  x = xy[0] + 0.5
  y = xy[1] + 0.5
  camera.setPosition(new BABYLON.Vector3(-x, 15, y))
  camera.setTarget(new BABYLON.Vector3(-x, 0, y - 0.000000000000001))

@enclosureRacksMidpoint = ->
  x_total = 0
  y_total = 0
  for enclosure_rack in enclosure_racks
    x_total += enclosure_rack.x
    y_total += enclosure_rack.y
  return [x_total / enclosure_racks.length, y_total / enclosure_racks.length]
