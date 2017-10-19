camera = null
controls = null
viewport = null
renderer = null
scene = null
zone_grid = null
enclosure_racks = []

@resizeVisualDC = ->
  return unless getViewport().length
  hRatio = viewport.width() / viewport.height()
  scale = 3.5
  hRatioScale = hRatio * scale
  # Perspective
  if camera instanceof THREE.PerspectiveCamera
    camera.aspect = hRatio
    camera.fov = 90
  # Orthographic
  else if camera instanceof THREE.OrthographicCamera
    camera.left = -hRatioScale
    camera.right = hRatioScale
    camera.top = scale
    camera.bottom = -scale
  # All
  camera.near = 0.1
  camera.far  = 1000
  camera.updateProjectionMatrix()
  renderer.setSize(viewport.width(), viewport.height())

@setCameraType = (type) ->
  camera = new type()
  controls = new THREE.OrbitControls(camera, renderer.domElement)
  resizeVisualDC()
  animate()

window.addEventListener('resize', resizeVisualDC, false)

@getViewport = ->
  return $('#visual_dc')

@initializeVisualDC = ->
  viewport = getViewport()
  return unless viewport.length
  scene = new THREE.Scene()
#  camera = new THREE.PerspectiveCamera(75, viewport.width() / viewport.height(), 0.1, 1000)
#  camera = new THREE.OrthographicCamera(viewport.width()/-2, viewport.width()/2, viewport.height()/2, viewport.height()/-2, 0.1, 1000)
  
  renderer = new THREE.WebGLRenderer({ antialias: true })
#  renderer.setClearColor(0xfcfcfc, 1)
  renderer.setClearColor(0xE4E5E6, 1)
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  renderer.setSize(viewport.width(), viewport.height())
  renderer.domElement.id = "zone_canvas"
  viewport.append(renderer.domElement)

  loadEnclosureRacks(true)
  setCameraType(THREE.PerspectiveCamera)
#  setCameraType(THREE.OrthographicCamera)
  resizeVisualDC()

#  for x in [0..2]
#    for y in [0..2]
#      geometry = new (THREE.BoxGeometry)(1 * 0.9, 1991/600 * 0.9, 1 * 0.9)
#      material = new (THREE.MeshLambertMaterial)({ color: 0x455a64 })
#      data = {"id":1,"name":"A01","height":42,"x":x,"y":y,"orientation":180,"created_at":"2017-10-16T14:53:11.000-05:00","updated_at":"2017-10-16T16:11:12.000-05:00","zone_id":1}
#      rack = new EnclosureRack(data)
#      scene.add(rack.object3d)

  ambientLight = new (THREE.AmbientLight)(0x404040)
  scene.add(ambientLight)

  frontDirectionalLight = new THREE.DirectionalLight(0xffffff, 1)
  frontDirectionalLight.position.x = 0.5
  frontDirectionalLight.position.y = 0.75
  frontDirectionalLight.position.z = 1
  scene.add(frontDirectionalLight)

  backDirectionalLight = new THREE.DirectionalLight(0xffffff, 1)
  backDirectionalLight.position.x = -0.5
  backDirectionalLight.position.y = 0.75
  backDirectionalLight.position.z = -1
  scene.add(backDirectionalLight)

#  grid = new THREE.GridHelper(5, 5)
#  scene.add(grid)

#  planeGeometry = new (THREE.PlaneBufferGeometry)(5, 5, 5, 5)
#  planeMaterial = new (THREE.MeshStandardMaterial)( { color: 0xffffff, wireframe: true } )
#  plane = new (THREE.Mesh)(planeGeometry, planeMaterial)
#  plane.rotation.x = 3 * Math.PI / 2
#  plane.rotation.y = 0
#  plane.rotation.z = 0
#  plane.receiveShadow = true
#  scene.add(plane)

#  zone_grid = new ZoneGrid(-1, 3, -1, 5)
#  scene.add(zone_grid.object3d)

#  camera.position.x = 0
#  camera.position.y = 7
#  camera.position.z = 0
#  camera.lookAt(new THREE.Vector3(0, 0, 0))

  helper = new THREE.CameraHelper(camera)
  scene.add(helper)

#  renderer.render(scene, camera)

#  controls.target = new THREE.Vector3(0, 0, 0)

#  animate = ->
#    requestAnimationFrame(animate)
#    rack.rotation.x += 0.1
#    rack.rotation.y += 0.1
#    rack.rotation.z += 0.1
#    renderer.render(scene, camera)

animate = ->
  renderer.render(scene, camera)
  requestAnimationFrame(animate)
  controls.update()

@destroyVisualDC = ->
  getViewport().html('')

$(document).on 'turbolinks:load', ->
  initializeVisualDC()

$(document).on 'turbolinks:before-cache', ->
  destroyVisualDC()

@loadEnclosureRacks = (is_initial=false) ->
  viewport = getViewport()
  $.ajax
    url: '/admin/datacenter_zones/' + viewport.data('zone-id') + '/racks.json'
    method: 'get'
    success: (data) ->
      presentEnclosureRacks(data, is_initial)
    error: (xhr, status, exception) ->
      console.log "Visual DC error: AJAX received " + exception + " with XHR:"
      console.log xhr

@presentEnclosureRacks = (data, is_initial=false) ->
  min_x = Number.MAX_SAFE_INTEGER
  min_y = Number.MAX_SAFE_INTEGER
  max_x = Number.MIN_SAFE_INTEGER
  max_y = Number.MIN_SAFE_INTEGER
  for rack in data
    min_x = rack.x if rack.x < min_x
    min_y = rack.y if rack.y < min_y
    max_x = rack.x if rack.x > max_x
    max_y = rack.y if rack.y > max_y
    enclosure_rack = new EnclosureRack(rack)
    enclosure_racks.push(enclosure_rack)
    scene.add(enclosure_rack.object3d)
  if Number.MAX_SAFE_INTEGER in [min_x, min_y] || Number.MIN_SAFE_INTEGER in [max_x, max_y]
    console.log "Cannot render grid: Coordinate value error in EnclosureRacks list"
    return false
  zone_grid = new ZoneGrid(min_x, max_x, min_y, max_y)
  scene.add(zone_grid.object3d)
  resetCamera() if is_initial
  return true

@resetCamera = ->
  xy = enclosureRacksMidpoint()
  x = xy[0] + 0.5
  y = xy[1] + 0.5
  camera.position.x = x
  camera.position.y = 5
  camera.position.z = y
  midpoint = new THREE.Vector3(x, 0, y)
  camera.lookAt(midpoint)
  controls.target = midpoint

@enclosureRacksMidpoint = ->
  x_total = 0
  y_total = 0
  for enclosure_rack in enclosure_racks
    x_total += enclosure_rack.x
    y_total += enclosure_rack.y
  return [x_total / enclosure_racks.length, y_total / enclosure_racks.length]
