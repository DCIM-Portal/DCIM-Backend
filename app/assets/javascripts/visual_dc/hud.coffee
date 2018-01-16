class @HUD
  constructor: (context) ->
    @context = context
    @scene = @context.scene
    @ui = BABYLON.GUI.AdvancedDynamicTexture.CreateFullscreenUI("Visual DC HUD")

    cameraModeToggle = BABYLON.GUI.Button.CreateSimpleButton("cameraModeToggle", "Toggle camera mode")
    cameraModeToggle.width = '180px'
    cameraModeToggle.height = '32px'
    cameraModeToggle.background = 'gray'
    @ui.addControl(cameraModeToggle)
    cameraModeToggle.horizontalAlignment = BABYLON.GUI.Control.HORIZONTAL_ALIGNMENT_RIGHT
    cameraModeToggle.verticalAlignment = BABYLON.GUI.Control.VERTICAL_ALIGNMENT_TOP
    cameraModeToggle.onPointerDownObservable.add =>
      camera = @scene.activeCamera
      if camera.mode == BABYLON.Camera.ORTHOGRAPHIC_CAMERA
        context.setCameraMode(BABYLON.Camera.PERSPECTIVE_CAMERA)
      else
        context.setCameraMode(BABYLON.Camera.ORTHOGRAPHIC_CAMERA)

    @compass = new BABYLON.GUI.TextBlock()
    @compass.text = "↑"
    @compass.width = '24px'
    @compass.height = '24px'
    @compass.color = "black"
    @ui.addControl(@compass)
    @compass.horizontalAlignment = BABYLON.GUI.Control.HORIZONTAL_ALIGNMENT_RIGHT
    @compass.verticalAlignment = BABYLON.GUI.Control.VERTICAL_ALIGNMENT_BOTTOM
    @scene.registerBeforeRender(@updateCompass)

  updateCompass: =>
    return unless @compass && @scene
    camera = @scene.activeCamera
    position = camera.position
    target = camera.target
    rotation = Math.atan2(-(position.x - target.x), (position.z - target.z))
    @compass.rotation = rotation

  showBlockingLoading: (text="Loading…") ->
    @loadingIndicator = new BABYLON.GUI.TextBlock()
    @loadingIndicator.text = text
    @loadingIndicator.color = "black"
    @ui.addControl(@loadingIndicator)

  hideBlockingLoading: ->
    @ui.removeControl(@loadingIndicator)
