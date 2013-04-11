@Math.cbrt = (x)->
  if x is 0 
    0 
  else 
    sign = if x > 0 then 1 else -1
    sign * Math.pow(Math.abs(x), 1 / 3)

animationCache = cc.AnimationCache.getInstance()   
sharedSpriteFrameCache = cc.SpriteFrameCache.getInstance()
sharedSpriteSheetCache = cc.SpriteSheetJson.getInstance()

tileMap = []
  #[1, 0, 0, 0, 1, 1, 2, 2, 2, 1] 
  #[1, 2, 2, 2, 1, 1, 0, 0, 0, 1]
  #[1, 1, 1, 1, 1, 2, 2, 2, 2, 2]
  #]

for x in [0...100]
  tileMap[y] = []
  for y in [0...100]
    tileMap[x][y] = Math.floor(Math.random()*4)

counts = []
for i in [1...6]
  for x in [1...99]
    counts[x] = []
    for y in [1...99]
      counts[x][y] = 0
      for w in [-1...2]
        for h in [-1...2]
          counts[x][y]++ if tileMap[x+w][y+h] == 1 || tileMap[x+w][y+h] == 2
  for x in [1...99]
    for y in [1...99]
      tileMap[x][y] = if counts[x][y] >= 5 then 2 else if counts[x][y] >= 4  then 3 else 0

tileMap.reverse()
tileDim = new cc.Size(40, 40)

class SmartTile
  constructor: (@tile, @x, @y, left, up, right, down) ->
    @actors = {}
    @setLeft(left)
    @setUp(up)
    @setRight(right)
    @setDown(down)
  setLeft: (tile)->
    if tile?
      @left = tile
      tile.right = @
  setUp: (tile)->
    if tile?
      @up = tile
      tile.down = @
  setRight: (tile)->
    if tile?
      @right = tile
      tile.left = @
  setDown: (tile)->
    if tile?
      @down = tile
      tile.up = @

class SmartTileLayer extends cc.SpriteBatchNode
  ctor: (fileImage, @w, @h, @tileMap)->
    @size = new cc.Size(@tileMap.length, if @tileMap[0]? then @tileMap[0].length else 1)
    @.init(fileImage, @size.x * @size.y)
    @loadTiles(tileMap)

  loadTiles: () ->
    @smartTiles = []
    @visibleSmartTiles = []
    that =@
    @tileMap.map (tileIds, y) ->
      that.smartTiles[y] = []
      tileIds.map (tileId, x) ->
        tile = that.getTile x, y
        if tile?
          that.addChild tile
          #tiles.push(tile)
          smartTileForYMinus1 = that.smartTiles[y-1];
          smartTile = new SmartTile(tile, x, y, that.smartTiles[y][x-1], if smartTileForYMinus1? then smartTileForYMinus1[x] else null)
          that.smartTiles[y][x] = smartTile
          if tile.isVisible()
            that.visibleSmartTiles.push(smartTile) 
            smartTile.marked = true

  getTile: (x, y) ->
    tileId = @tileMap[y][x]
    # it is plus one because we are drawing form bottom left.
    tileIdAbove = if @tileMap[y+1]? then @tileMap[y+1][x] else tileId
    switch tileId
      when 0
        tile = cc.Sprite.createWithSpriteFrameName("TempBackground")
      when 1
            tile = cc.Sprite.createWithSpriteFrameName("TempBox")
      when 2
        switch tileIdAbove
          when 2
            tile = cc.Sprite.createWithSpriteFrameName("TempDirt")
          else
            tile = cc.Sprite.createWithSpriteFrameName("TempDirtWalkable")
      when 3
        switch tileIdAbove
          when 0, 1
            tile = cc.Sprite.createWithSpriteFrameName("TempBackDirtWalkable")
          else            
            tile = cc.Sprite.createWithSpriteFrameName("TempBackDirt")
            
      else
        return null
    tile.setAnchorPoint new cc.Point(0, 0)
    position = new cc.Point(tileDim.w * x, tileDim.h * y)
    tile.setPosition position
    if position.x > config.screen.width + tileDim.w || position.x < -tileDim.w || position.y > config.screen.height + tileDim.h || position.y < -tileDim.h
      tile.setVisible(false)
    tile

  getOverlappedSmartTiles: (x, y, w, h)->
    overlappedSmartTiles = []
    for j in [y...(y+h)]
      smartTiles = @smartTiles[j]
      if smartTiles?
        for i in [x...(x+w)]
          overlappedSmartTiles.push(smartTiles[i]) if smartTiles[i]?
    return overlappedSmartTiles

  update:(dt, scrollPos)->  
    if @visibleSmartTiles && scrollPos
      for visibleSmartTile in @visibleSmartTiles
        tile = visibleSmartTile.tile
        actors = visibleSmartTile.actors
        tile.setVisible(false)

      @visibleSmartTiles = @getOverlappedSmartTiles(Math.round(scrollPos.x/40)-1, Math.round(scrollPos.y/40)-1, Math.round(config.screen.width/40)+1, Math.round(config.screen.height/40)+1)

      for visibleSmartTile in @visibleSmartTiles
        tile = visibleSmartTile.tile
        actors = visibleSmartTile.actors
        tile.setVisible(true)

actorId = 0;
class Actor extends cc.Sprite
  velocity: 80
  moveDelta: 0
  addMoveDelta: .5
  keyMap: null
  animations: null
  moving: false
  deltaPos: null
  currentSmartTile = null
  ctor: (@smartTileLayer) ->
    @id = actorId++
    @init()

    y = Math.floor(@_position.y/ 40)
    smartTiles = @smartTileLayer.smartTiles[y]
    if smartTiles?
      x = Math.floor(@_position.x / 40)
      @currentSmartTile = smartTiles[x]
      @currentSmartTile.actors[@id] = @
      @setVisible(@currentSmartTile.tile.isVisible())

  update: (dt) ->
    @myUpdate(dt) if @myUpdate?
    position = @_position

    y = Math.floor(position.y/ 40)
    smartTiles = @smartTileLayer.smartTiles[y]
    if smartTiles?
      x = Math.floor(position.x / 40)
      smartTile = smartTiles[x]
      if smartTile? && smartTile != @currentSmartTile
        delete @currentSmartTile.actors[@id] if @currentSmartTile
        @currentSmartTile = smartTile
        @currentSmartTile.actors[@id] = @
    @setVisible(@currentSmartTile.tile.isVisible()) if @currentSmartTile
  handleMove: (dt) ->
    velocity = @velocity
    velocity = -velocity  unless @isFlippedX()
    if dt >= @moveDelta
      @deltaPos.x += @moveDelta * velocity
      deltaX = Math.floor(@deltaPos.x)
      @_position.x += deltaX
      @deltaPos.x -= deltaX
      @moveDelta = 0
    else
      @deltaPos.x += dt * velocity
      deltaX = Math.floor(@deltaPos.x)
      @_position.x += deltaX
      @deltaPos.x -= deltaX
      @moveDelta -= dt

class ControllableSprite extends Actor
  ctor: (smartTileLayer) ->
    super(smartTileLayer)
    stillAnimation = animationCache.getAnimation("VanguardStill")
    readyAnimation = animationCache.getAnimation("VanguardReady")
    walkAnimation = animationCache.getAnimation("VanguardWalk")
    animations = {}
    @animations = animations
    animations.still = cc.Animate.create(stillAnimation)
    animations.ready = cc.Animate.create(readyAnimation)
    animations.walk = cc.RepeatForever.create(cc.Animate.create(walkAnimation))
    @runAction animations.still
    @keyMap = {}
    @deltaPos = new cc.Point(0, 0)
    @setAnchorPoint(new cc.Point(0.5, 0))

  myUpdate: (dt) ->
    if @keyMap[cc.KEY.left]
      @setFlipX false
      @moveDelta = @addMoveDelta
    else if @keyMap[cc.KEY.right]
      @setFlipX true
      @moveDelta = @addMoveDelta
    else if @moving
      @stopAllActions()
      @runAction @animations.still
      @moving = false
    @handleMove dt  if @moveDelta > 0

  handleKeyUp: (e) ->
    @keyMap[e] = false
    @moveDelta = 0  if e is cc.KEY.left or e is cc.KEY.right

  handleKeyDown: (e) ->
    if e is cc.KEY.left and not @keyMap[e]
      @stopAllActions()
      @runAction @animations.walk
      @keyMap[e] = true
      @moving = true
    else if e is cc.KEY.right and not @keyMap[e]
      @stopAllActions()
      @runAction @animations.walk
      @keyMap[e] = true
      @moving = true

class Engine extends cc.Layer
  sprite: null
  sprites: null
  scroll: null
  init: ->
    windowSize = cc.Director.getInstance().getWinSize()
    windowSize.width = windowSize.width / config.screen.scale
    windowSize.height = windowSize.height / config.screen.scale
    layer1 = cc.LayerColor.create(new cc.Color4B(0, 0, 0, 255), config.screen.width, config.screen.height)
    layer1.setPosition(Math.floor((windowSize.width - config.screen.width)/2), Math.floor((windowSize.height - config.screen.height)/2))

    @scroll = cc.Node.create();
    layer1.addChild @scroll, 1

    @smartTileLayer = new SmartTileLayer(sharedSpriteSheetCache.getSpriteSheet("MapTiles").Source, tileDim.w, tileDim.h, tileMap)
    @scroll.addChild @smartTileLayer

    @sprite = new ControllableSprite(@smartTileLayer)
    @scroll.addChild @sprite

    spriteSize = @sprite.getContentSize()
    @sprite.setPosition(new cc.Point(160, 160))

    @addChild layer1
    @setTouchEnabled true
    @setKeyboardEnabled true

    lazyLayer = new cc.LazyLayer();
    lazyLayer.addChild(cc.LayerColor.create(new cc.Color4B(0, 0, 0, 255), windowSize.width, windowSize.height))
    @addChild lazyLayer
    
    @sprites = []
    for i in [0...99]
      bug = new Actor(@smartTileLayer)
      bugWalk = cc.RepeatForever.create(cc.Animate.create(animationCache.getAnimation("WorkerBugWalk")))
      bug.runAction(bugWalk)
      bug.setPosition(new cc.Point(Math.floor(Math.random()*4000), Math.floor(Math.random()*4000)))
      bug.setAnchorPoint(new cc.Point(0.5,0))
      @scroll.addChild(bug)
      @sprites.push(bug)
    true

  onKeyDown: (e) ->
    @sprite.handleKeyDown e

  onKeyUp: (e) ->
    @sprite.handleKeyUp e

  update: (dt) ->
    if @sprite.moving
      @sprite.update(dt)  
      @updateSprite(@sprite) 

      scrollPos = @scroll.getPosition()
      spritePos = @sprite.getPosition()
      spritePos.x += if @sprite.isFlippedX() then config.screen.cameraOffset else -config.screen.cameraOffset
      spritePos.x += scrollPos.x - config.screen.centerX
      spritePos.y += scrollPos.y - config.screen.centerY

      if spritePos.x != 0 || spritePos.y != 0
        scrollPos.x -= Math.floor(Math.cbrt(spritePos.x))
        scrollPos.y -= Math.floor(Math.cbrt(spritePos.y))
        @scroll.setPosition(scrollPos)

        #Invert these they are relative to the world instead of camera
        scrollPos.x = -scrollPos.x
        scrollPos.y = -scrollPos.y
        @smartTileLayer.update(dt, scrollPos)
        
    for sprite in @sprites
      sprite.update(dt)
      z = sprite.getPosition()
      z.x -=.3
      sprite.setPosition(z)
      @updateSprite(sprite)   
  
  updateSprite: (sprite) ->
    scrollPos = @scroll.getPosition()
    spritePos = sprite.getPosition()
    y = Math.floor(spritePos.y / tileDim.h)

    tileIds = tileMap[y]
    if tileIds?
      x = Math.floor(spritePos.x / tileDim.w)
      tileId = tileIds[x]
      if tileId == 1 || tileId == 2
        spritePos.y = (y + 1) * tileDim.h
        sprite.setPosition(spritePos)
      else if (tileId == 0 || tileId == 3) && tileMap[y-1] && tileMap[y-1][x] == 0
        spritePos.y = (y - 1) * tileDim.h
        sprite.setPosition(spritePos)

@engine = cc.Scene.extend(
  onEnter: ->
    @_super()
    layer = new Engine()
    $(document).keydown((e)->layer.onKeyDown(e.which))
    $(document).keyup((e)->layer.onKeyUp(e.which))
    layer.init()
    layer.scheduleUpdate()
    layer.setScale(config.screen.scale,config.screen.scale)
    @addChild layer
)
