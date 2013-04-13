if disabledSmoothing then scale = 1 else scale = config.screen.scale

split = location.search.replace('?', '').split('&').map((val)->
  return val.split('=')
)

if split[0] && split[0].length > 0 && split[0][0] == "seed"
  seed = parseInt(split[0][1], 10)
else 
  seed = new Date().getTime()

$('body').append("<p>Seed: "+seed+"</p>")
#seed = 1365818253446
#seed = 1365327125203 
#seed = 1365322763369
#seed = 1365319545109
#seed = 1365318773422
#seed = 1365313131633
#seed = 1365312678822 
#seed = 1365237459362
#seed = 1365234196266
#seed = 1365223191317

#seed = 1365222851243
#seed = 1365159982305
#seed = 1361054058269 
#seed = 1361065761458
#seed = 1364980842667
#seed = 1364980912183

console.log("SEED:" + seed)

MT = new MersenneTwister(seed)
Math.random = ()->
  return MT.random.apply(MT, arguments)

global = @

@Math.cbrt = (x)->
  if x is 0 
    0 
  else 
    sign = if x > 0 then 1 else -1
    sign * Math.pow(Math.abs(x), 1 / 3)

animationCache = cc.AnimationCache.getInstance()   
sharedSpriteFrameCache = cc.SpriteFrameCache.getInstance()
sharedSpriteSheetCache = cc.SpriteSheetJson.getInstance()

size = 128
tileSize =  new cc.Size(40 * scale, 40 * scale)
worldSize = new cc.Size(tileSize.width * size, tileSize.height * size)

@Engine = class Engine extends cc.Layer
  init: ->
    cc.renderContext.webkitImageSmoothingEnabled = false
    cc.renderContext.mozImageSmoothingEnabled = false
    cc.renderContext.imageSmoothingEnabled = false
    cc.renderContext.oImageSmoothingEnabled = false

    @windowSize = cc.Director.getInstance().getWinSize()
    offset = cc.Node.create()
    offset.setPosition(new cc.Point(0, config.screen.height * config.screen.scale if disabledSmoothing))#Math.floor((windowSize.width - config.screen.width)/2), Math.floor((windowSize.height - config.screen.height)/2))
    # for converting into conventional windowing system
    offset.setScaleX(config.screen.scale)
    offset.setScaleY(-config.screen.scale)

    #@spatialHash = new SpatialHash(new cc.Size(80, 80), worldSize, 100)

    options = 
      tileSize: tileSize,
      worldSize: worldSize,
      landPlateCount: 96
      oceanPlateCount: 2
      fractionLand: .6
      fractionSubduction: .3
      rainfallReductionRate: 3
      maxTemperature: 100
      minTemperature: -50

    @sprites = []

    @keyMap = {}

    Async.series(
      ()=>
        @world = new World(options);
      ()=>
        @scroll = cc.Node.create();
        offset.addChild(@scroll, 1)
      ()=>
        #binSize = new cc.Size(8000, 8000)
        #@spatialHash = new SpatialHash(
        #  binSize: binSize
        #  spaceSize: new cc.Size(16000, 8000)
        #  border: 0)
        @world.createSprites(@scroll, @spatialHash)
        
        @overlay = new Overlay(
          tileSize: tileSize,
          screenSize: @windowSize,
          parentSprite: @scroll)

        @addChild offset
        @setTouchEnabled true
        @setKeyboardEnabled true

        lazyLayer = new cc.LazyLayer();
        lazyLayer.addChild(cc.LayerColor.create(new cc.Color4B(0, 0, 0, 255), @windowSize.width, @windowSize.height))
        @addChild lazyLayer
        
        @ready = true
      )

  onKeyDown: (e)->
    @keyMap[e] = true;
  onKeyUp: (e)->
    @keyMap[e] = false;

  onTouchesEnded: (pTouch, pEvent)->

  update: (dt)->
    if @ready
      position = @scroll.getPosition()
      if @keyMap[cc.KEY.left]
        move = true
        position.x+=Math.floor(400*dt)
        if position.x > 0
          position.x -= worldSize.width
      if @keyMap[cc.KEY.right]
        move = true
        position.x-=Math.floor(400*dt)
        if position.x < -2*worldSize.width + config.screen.width
          position.x += worldSize.width
      if @keyMap[cc.KEY.down]
        move = true
        position.y-=Math.floor(400*dt)
        if position.y < -worldSize.height + config.screen.height
          position.y = -worldSize.height + config.screen.height
      if @keyMap[cc.KEY.up]
        move = true
        position.y+=Math.floor(400*dt)
        if position.y > 0
          position.y = 0

      if move
        if @spatialHash?
          @spatialHash.setActiveBins(new cc.Rect(-position.x, -position.y, config.screen.width, config.screen.height))
          for child in @scroll.getChildren()
            child.update(dt)
        else 
          children = @scroll.getChildren()
          if -position.x < worldSize.width && !children[0].isVisible()
              children[0].setVisible(true)
              children[3].setVisible(true)
          else if -position.x >= worldSize.width && children[0].isVisible()
              children[0].setVisible(false)
              children[3].setVisible(false)

          if -position.x >= worldSize.width - config.screen.width && children[1].isVisible()
              children[1].setVisible(true)
              children[4].setVisible(true)
          else if -position.x < worldSize.width - config.screen.width && !children[1].isVisible()
              children[1].setVisible(false)
              children[4].setVisible(false)

        @scroll.setPosition(position)
        @overlay.update(dt)