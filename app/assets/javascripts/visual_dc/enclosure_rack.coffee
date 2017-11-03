class @EnclosureRack
  constructor: (data, scene) ->
    @scale = 0.8
    @scene = scene
    for key, value of data
      this[key] = value

    color = new BABYLON.Color3(121/256, 145/256, 157/256)
    #faceColors = []
    #for i in [0..5]
    #  faceColors.push(color)
    rack = new BABYLON.MeshBuilder.CreateBox("EnclosureRack: " + @name, { width: 1 * @scale, height: @relativeHeight(), depth: 1 * @scale}, @scene)

    material = new BABYLON.StandardMaterial("EnclosureRack " + @name + " material", @scene)
    material.diffuseColor = color
    #material.ambientColor = new BABYLON.Color3(1, 1, 1)
    material.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1)
    material.emissiveColor = new BABYLON.Color3(0, 0, 0)
    rack.material = material
    rack.position = new BABYLON.Vector3(-(@x + 0.5), @relativeHeight() / 2, @y + 0.5)
    rack.rotation.y = Math.PI / 180 * @orientation

    indices = rack.getIndices()
    indices[25] = 0
    indices[26] = 0
    indices[27] = 0
    rack.setIndices(indices, rack.getTotalVertices())

    @roof = new BABYLON.MeshBuilder.CreatePlane("EnclosureRack Roof: " + @name, { width: 1 * @scale, height: 1 * @scale}, @scene)
    @roof.parent = rack
    @roof.position = new BABYLON.Vector3(0, @relativeHeight() / 2, 0)
    @roof.rotation = new BABYLON.Vector3(Math.PI / 180 * 90, 0, 0)
    @roof.material = new BABYLON.StandardMaterial("EnclosureRack Roof Material: " + @name, @scene)
    @roof.material.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1)
    @updateRoof()


    rack.actionManager = new BABYLON.ActionManager(scene)
    _this = @
    rack.actionManager.registerAction(new BABYLON.ExecuteCodeAction(BABYLON.ActionManager.OnPointerOverTrigger, (ev) ->
      rack.material.diffuseColor = new BABYLON.Color3(140/256, 164/256, 176/256)
      _this.updateRoof(true)
    ))
    rack.actionManager.registerAction(new BABYLON.ExecuteCodeAction(BABYLON.ActionManager.OnPointerOutTrigger, (ev) ->
      rack.material.diffuseColor = color
      _this.updateRoof()
    ))

    @object3d = rack

  relativeHeight: ->
    return 1991/600/42*@height*@scale

  updateRoof: (highlight=false) ->
    texture = new BABYLON.DynamicTexture("EnclosureRack Roof Texture: " + @name, 512, @scene, true)
    displayName = @name
    displayName = displayName.substring(0, 4) + "…" if displayName.length > 4
    noHighlightColor = "#78909C"
    yesHighlightColor = "#8ba3af"
    highlightColor = if highlight then yesHighlightColor else noHighlightColor
    texture.drawText(displayName, null, null, "160px 'Roboto Condensed'", "white", highlightColor)
    @roof.material.diffuseTexture = texture
