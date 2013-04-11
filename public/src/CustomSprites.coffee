animationCache = cc.AnimationCache.getInstance()   

@Tile = class Tile extends cc.Sprite
  ctor: (@options) ->
    @spatialHash = options.spatialHash
    @spatialHash.addNode(@)
    @initWithTexture(@options.buffer)
  update: (dt) ->
    bin = @spatialHash.getBinFromNode(@)
    @setVisible(bin? && bin.active)