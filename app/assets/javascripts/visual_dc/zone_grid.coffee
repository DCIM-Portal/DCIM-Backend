class @ZoneGrid
  constructor: (min_x, max_x, min_y, max_y) ->
    @min_x = min_x - 1
    @max_x = max_x + 2
    @min_y = min_y - 1
    @max_y = max_y + 2
    @object3d = new THREE.Object3D

    material = new THREE.LineBasicMaterial({ color: 0x000000 })
    for x in [@min_x..@max_x]
      geometry = new THREE.Geometry
      geometry.vertices.push(new THREE.Vector3(x, 0, @min_y))
      geometry.vertices.push(new THREE.Vector3(x, 0, @max_y))
      line = new THREE.Line(geometry, material)
      @object3d.add(line)
    for z in [@min_y..@max_y]
      geometry = new THREE.Geometry
      geometry.vertices.push(new THREE.Vector3(@min_x, 0, z))
      geometry.vertices.push(new THREE.Vector3(@max_x, 0, z))
      line = new THREE.Line(geometry, material)
      @object3d.add(line)
