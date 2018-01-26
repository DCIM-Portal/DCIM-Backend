export default class EnclosureRack
  constructor: (data, scene) ->
    @scale = 0.8
    @scene = scene
    for key, value of data
      this[key] = value

    faceUV = new Array(6)
    for i of [0,1,2,3,4,5]
      faceUV[i] = new BABYLON.Vector4(0, 0, 0, 0)
    faceUV[4] = new BABYLON.Vector4(0, 0, 1, 1)
    rack = new BABYLON.MeshBuilder.CreateBox("EnclosureRack: " + @name, { width: 1 * @scale, height: @relativeHeight(), faceUV: faceUV, depth: 1 * @scale}, @scene)
    @object3d = rack

    material = new BABYLON.StandardMaterial("EnclosureRack " + @name + " material", @scene)
    material.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1)
    material.emissiveColor = new BABYLON.Color3(0, 0, 0)
    rack.material = material
    @setGridPosition(@x, @y)
    rack.rotation.y = Math.PI / 180 * @orientation

    @updateTexture()

    rack.actionManager = new BABYLON.ActionManager(@scene)
    rack.actionManager.registerAction(new BABYLON.ExecuteCodeAction(BABYLON.ActionManager.OnPointerOverTrigger, (ev) =>
      @updateTexture(true)
      @showHover(ev)
    ))
    rack.actionManager.registerAction(new BABYLON.ExecuteCodeAction(BABYLON.ActionManager.OnPointerOutTrigger, (ev) =>
      @updateTexture()
      @hideHover(ev)
    ))

  relativeHeight: ->
    return 1991/600/42*@height*@scale

  setGridPosition: (x, y) ->
    @x = x
    @y = y
    @object3d.setAbsolutePosition(new BABYLON.Vector3(-(@x + 0.5), @relativeHeight() / 2, @y + 0.5))

  hide: ->
    @object3d.setAbsolutePosition(new BABYLON.Vector3(-Infinity, @relativeHeight() / 2, -Infinity))

  updateTexture: (highlight=false) ->
    @texture ||= new BABYLON.DynamicTexture("EnclosureRack Roof Texture: " + @name, 512, @scene, true)
    if @name
      displayName = @name
      displayName = displayName.substring(0, 4) + "…" if displayName.length > 4
    noHighlightColor = "#78909C"
    yesHighlightColor = "#8ba3af"
    highlightColor = if highlight then yesHighlightColor else noHighlightColor
    @texture.drawText(displayName, null, null, "160px 'Roboto Condensed'", "white", highlightColor)
    @texture.wAng = Math.PI / 180 * 90
    @object3d.material.diffuseTexture = @texture

  setOpacity: (alpha) ->
    @object3d.material.alpha = alpha

  showHover: (ev) ->
    text = document.createElement("span")
    text.setAttribute("id", "enclosure_rack-hover")
    style = text.style
    style.position = "absolute"
    style.display = 'none'
    window.onmousemove = (e) ->
      x = e.clientX + 20
      y = e.clientY + 20
      style.display = 'inherit'
      style.top = y + 'px'
      style.left = x  + 'px'
    text.textContent = "Wes Miser"
    document.body.appendChild(text)

  hideHover: (ev) ->
    document.getElementById("enclosure_rack-hover").parentNode.removeChild(document.getElementById("enclosure_rack-hover"))
