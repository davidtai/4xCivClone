upscale = (img, zoom)->
  # Create an offscreen canvas, draw an image to it, and fetch the pixels
  ref = document.createElement('canvas').getContext('2d')
  buffer = document.createElement('canvas')
  buffer.width = img.width * zoom
  buffer.height = img.height * zoom
  bufferCtx = buffer.getContext('2d')
  ref.drawImage(img, 0, 0)
  imgData = ref.getImageData(0, 0, img.width, img.height).data

  # Draw the zoomed-up pixels to a different canvas context
  for x in [0...img.width]
    for y in [0...img.height]
      # Find the starting index in the one-dimensional image data
      i = (y*img.width + x) * 4
      r = imgData[i  ]
      g = imgData[i+1]
      b = imgData[i+2]
      a = imgData[i+3]
      bufferCtx.fillStyle = "rgba("+r+","+g+","+b+","+(a/255)+")"
      bufferCtx.fillRect(x*zoom,y*zoom,zoom,zoom)

  return buffer
# -------------------------
# Custom Helpers
# -------------------------
sharedTextureCache = @cc.TextureCache.getInstance()
sharedSpriteFrameCache = @cc.SpriteFrameCache.getInstance()
sharedAnimationCache = @cc.AnimationCache.getInstance()
cacheSpriteFrame = (json, name, texture) ->
  rect = json.Rect
  frameRect = new cc.Rect(rect.x * config.screen.scale, rect.y * config.screen.scale, rect.w * config.screen.scale, rect.h * config.screen.scale)
  hotspot = json.Hotspot
  spriteFrame = cc.SpriteFrame.createWithTexture(texture, frameRect, false, new cc.Point(hotspot.x * config.screen.scale, hotspot.y * config.screen.scale), frameRect.size)
  sharedSpriteFrameCache.addSpriteFrame spriteFrame, name
  spriteFrame

cacheAnimation = (json, texture) ->
  id = json.Id
  if id and json.Sprites
    spriteFrames = json.Sprites.map((json, i) ->
      cacheSpriteFrame json, id + parseInt(i, 10), texture
    )
    animation = cc.Animation.create()
    animation.initWithSpriteFrames spriteFrames, (if json.Rate? then json.Rate else 1)
    sharedAnimationCache.addAnimation animation, json.Id

cacheChildren = ->
  texture = sharedTextureCache.addImage(@Source)
  if config.screen.scale != 1
    texture = upscale(texture, config.screen.scale)
    sharedTextureCache.cacheImage(@Source, texture)
  if @Animations
    animations = @Animations.map((json) ->
      cacheAnimation json, texture
    )
  if @Statics
    statics = @Statics.map((json) ->
      cacheSpriteFrame json, json.Id, texture
    )

# Passing json as context for cacheAnimations is a hack to get things to pass the json
cacheImage = (json, callback) ->
  sharedTextureCache.addImageAsync json.Source, json, callback

# -------------------------
# Emulate Singleton
# -------------------------

# -------------------------
# SpriteSheet
# -------------------------
spriteSheets = {}
setSpriteSheet = (json) ->
  if json.Id and json.Source
    spriteSheets[json.Id] = json
    json.Source = config.assetsFolder + json.Source
    cacheImage json, cacheChildren

actualSpriteSheetJson =
  preloadSpriteJson: (url) ->
    $.getJSON url, setSpriteSheet

  getSpriteSheet: (id) ->
    spriteSheets[id]

spriteSheetJson = getInstance: ->
  actualSpriteSheetJson

# -------------------------
# Add Custom Stores
# -------------------------
@cc.SpriteSheetJson = spriteSheetJson

# -------------------------
# Patch the Preloader
# -------------------------
@cc.Loader::preload = (resources) ->
  sharedEngine = cc.AudioEngine.getInstance()
  sharedParser = cc.SAXParser.getInstance()
  sharedFileUtils = cc.FileUtils.getInstance()
  sharedSpriteSheetJson = cc.SpriteSheetJson.getInstance()
  @loadedResourceCount = 0
  @resourceCount = 0
  
  for key, res of resources
    switch res.type
      when "image"
        sharedTextureCache.addImage res.src
      when "sound"
        sharedEngine.preloadSound res.src
      when "plist", "tmx", "fnt"
        sharedParser.preloadPlist res.src
      
      #cc.log("cocos2d:not implemented yet")
      when "tga", "ccbi", "binary"
        sharedFileUtils.preloadBinaryFileData res.src
      when "face-font"
        @_registerFaceFont res[i]
      when "sprite-json"
        sharedSpriteSheetJson.preloadSpriteJson res.src
      else
        throw "cocos2d:unknown type : " + res.type
    @resourceCount++
  @isLoadedComplete()

@cc.Loader::isLoadedComplete = ->
  loaderCache = cc.Loader.getInstance()
  if loaderCache.loadedResourceCount >= loaderCache.resourceCount
    if loaderCache.onload
      loaderCache.timer = setTimeout(loaderCache.onload, 16)
    else
      cc.Assert 0, "cocos2d:no load callback defined"
  else
    if loaderCache.onloading
      loaderCache.timer = setTimeout(loaderCache.onloading, 16)
    else
      cc.LoaderScene.getInstance().draw()
    loaderCache.timer = setTimeout(loaderCache.isLoadedComplete, 16)