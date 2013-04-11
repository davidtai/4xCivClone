split = location.search.replace('?', '').split('&').map((val)->
  return val.split('=')
)

if split[0] && split[0].length > 0 && split[0][0] == "seed"
  seed = parseInt(split[0][1], 10)
else 
  seed = new Date().getTime()

$('body').append("<p>"+seed+"</p>")
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

size = 200
tileSize =  new cc.Size(40 * config.screen.scale, 40 * config.screen.scale)
worldSize = new cc.Size(tileSize.width * size, tileSize.height * size)

@Engine = class Engine extends cc.Layer
  init: ->
    @windowSize = cc.Director.getInstance().getWinSize()
    offset = cc.Node.create()
    offset.setPosition(new cc.Point(0, config.screen.height))#Math.floor((windowSize.width - config.screen.width)/2), Math.floor((windowSize.height - config.screen.height)/2))
    # for converting into conventional windowing system
    offset.setScaleY(-1)

    #@spatialHash = new SpatialHash(new cc.Size(80, 80), worldSize, 100)

    options = 
      tileSize: tileSize,
      worldSize: worldSize,
      landPlateCount: 96
      oceanPlateCount: 2
      fractionLand: .4
      fractionSubduction: .3
      rainfallReductionRate: 3
      maxTemperature: 100
      minTemperature: -50

    Async.series(
      ()=>
        @world = new World(options);
      ()=>
        @scroll = cc.Node.create();
        offset.addChild @scroll, 1
      ()=>
        binSize = new cc.Size(8000, 8000)
        @spatialHash = new SpatialHash(
          binSize: binSize
          spaceSize: new cc.Size(16000, 8000)
          border: 1024)
        @world.createSprites(@scroll, @spatialHash)

        @addChild offset
        @setTouchEnabled true
        @setKeyboardEnabled true

        lazyLayer = new cc.LazyLayer();
        lazyLayer.addChild(cc.LayerColor.create(new cc.Color4B(0, 0, 0, 255), @windowSize.width, @windowSize.height))
        @addChild lazyLayer
        
        @sprites = []

        @keyMap = {}
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
        position.x+=Math.floor(800*dt)
        if position.x > 0
          position.x -= worldSize.width
      if @keyMap[cc.KEY.right]
        position.x-=Math.floor(800*dt)
        if position.x < -2*worldSize.width + @windowSize.width
          position.x += worldSize.width
      if @keyMap[cc.KEY.down]
        position.y-=Math.floor(800*dt)
        if position.y < -worldSize.height + @windowSize.height
          position.y = -worldSize.height + @windowSize.height
      if @keyMap[cc.KEY.up]
        position.y+=Math.floor(800*dt)
        if position.y > 0
          position.y = 0
      @spatialHash.setActiveBins(new cc.Rect(-position.x, -position.y, config.screen.width, config.screen.height))
      for child in @scroll.getChildren()
        child.update(dt)
      @scroll.setPosition(position)
