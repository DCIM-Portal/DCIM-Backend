class @ArcRotateCameraOrthographicMouseWheelInput
  wheel = null
  observer = null
  wheelPrecision = 0.2

  getClassName: ->
    "ArcRotateCameraOrthographicMouseWheelInput"

  getTypeName: ->
    @getClassName()

  getSimpleName: ->
    "mousewheel"

  attachControl: (element, noPreventDefault=false) ->
    camera = @camera
    wheel = (p, s) ->
      return if p.type != BABYLON.PointerEventTypes.POINTERWHEEL
      event = p.event
      delta = 0

      if event.wheelDelta
        delta = event.wheelDelta / (wheelPrecision * 40)
      else if event.detail
        delta = -event.detail / wheelPrecision

      if delta
        engine = camera.getScene().getEngine()
        scale = camera.getScene().getEngine().getRenderHeight() / camera.orthoTop
        scale += delta
        camera.orthoLeft = -engine.getRenderWidth() / scale
        camera.orthoRight = engine.getRenderWidth() / scale
        camera.orthoBottom = -engine.getRenderHeight() / scale
        camera.orthoTop = engine.getRenderHeight() / scale

      event.preventDefault() if event.preventDefault && !noPreventDefault

    observer = camera.getScene().onPointerObservable.add(wheel, BABYLON.PointerEventTypes.POINTERWHEEL)
  
  detachControl: (element) ->
    if element && observer
      @camera.getScene().onPointerObservable.remove(observer)
      wheel = null
      observer = null
