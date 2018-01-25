class @ZoneGrid
  constructor: (min_x, max_x, min_y, max_y, scene) ->
    @setBounds(min_x, max_x, min_y, max_y)
    @scene = scene

    @ground_material = new BABYLON.StandardMaterial("zone_ground-material", @scene)
    @ground_material.alpha = 0.0

    @redraw()

    line = []
    line.push(new BABYLON.Vector3(0, 0, 1))
    line.push(new BABYLON.Vector3(0, 0, 0))
    origin = BABYLON.MeshBuilder.CreateTube("zone_grid_origin_indicator", {path: line, radius: 0.01}, @scene)
    origin.color = new BABYLON.Color3.Red()

    @object3d = @grid

  setBounds: (min_x, max_x, min_y, max_y) ->
    @min_x = -(min_x - 1)
    @max_x = -(max_x + 2)
    @min_y = min_y - 1
    @max_y = max_y + 2

  createLinesArrayFromBounds: (min_x, max_x, min_y, max_y) ->
    lines = []
    for x in [min_x..max_x]
      path = []
      path.push(new BABYLON.Vector3(x, 0, min_y))
      path.push(new BABYLON.Vector3(x, 0, max_y))
      lines.push(path)
    for z in [min_y..max_y]
      path = []
      path.push(new BABYLON.Vector3(min_x, 0, z))
      path.push(new BABYLON.Vector3(max_x, 0, z))
      lines.push(path)
    return lines

  redraw: ->
    lines = @createLinesArrayFromBounds(@min_x, @max_x, @min_y, @max_y)
    if @grid
      @grid.dispose()
      delete @grid
    if @ground
      @ground.dispose()
      delete @ground

    @grid = BABYLON.MeshBuilder.CreateLineSystem("zone_grid", {lines: lines}, @scene)
    @grid.color = new BABYLON.Color3(0, 0, 0)

    @ground = BABYLON.MeshBuilder.CreateTiledGround("zone_ground", {xmax: @min_x+4, xmin: @max_x-4, zmin: @min_y-4, zmax: @max_y+4}, @scene)
    @ground.material = @ground_material
    @ground.actionManager = new BABYLON.ActionManager(@scene)
