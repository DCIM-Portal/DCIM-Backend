class @EnclosureRack
  constructor: (data) ->
    @scale = 0.8
    for key, value of data
      this[key] = value

    geometry = new THREE.BoxGeometry(1 * @scale, @relativeHeight(), 1 * @scale)
    material = new THREE.MeshLambertMaterial({ color: 0x455a64 })
    rack = new THREE.Mesh(geometry, material)
    rack.position.x = @x + 0.5
    rack.position.y = @relativeHeight() / 2
    rack.position.z = @y + 0.5
    rack.rotation.y = Math.PI / 180 * @orientation
    @object3d = rack

  relativeHeight: ->
    return 1991/600/42*@height*@scale
