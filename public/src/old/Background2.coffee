textureCache = @cc.TextureCache.getInstance()

makeBuffer = (width, height, insertAfterSelector)->
	buffer = $('<canvas />')[0]
	buffer.width = width
	buffer.height = height
	if insertAfterSelector 
		$(buffer).insertAfter($(insertAfterSelector).css('display', 'inline-block')[0]).css({width:768, height:768, display:'inline-block', left: 1024})
	return buffer

@Background =
	create: (@options)->
		tileMap = @options.tileMap
		tileMapSize = @options.tileMapSize
		tileSize = @options.tileSize

		parentSprite = @options.parentSprite
		spatialHash = @options.spatialHash

		tileSpriteFrameFunction = @options.tileSpriteFrameFunction
		transitionSpriteFrameFunction = @options.transitionSpriteFrameFunction
		doodadsSpriteFrameFunction = @options.doodadsSpriteFrameFunction

		width = tileMapSize.width
		height = tileMapSize.height
		
		@buffer = makeBuffer(width * tileSize.width, height * tileSize.height, 'div')
		ctx = @buffer.getContext('2d')
		ctx.translate(0, @buffer.height)

		binSize = spatialHash.binSize

		modWidth 	= Math.floor(binSize.width/tileSize.width)
		modHeight = Math.floor(binSize.height/tileSize.height)
		chunkWidth = modWidth * tileSize.width
		chunkHeight = modHeight * tileSize.height

		ctxsArray = []

		for y in [0...height]
			for x in [0...width]
				chunkX = Math.floor(x/modWidth)
				if !ctxsArray[chunkX]
					ctxsArray[chunkX] = []
				chunkY = Math.floor(y/modHeight)
				ctxs = ctxsArray[chunkX][chunkY]
				if !ctxs
					bgBuffer = makeBuffer(chunkWidth, chunkHeight)
					fgBuffer = makeBuffer(chunkWidth + 2 * tileSize.width, chunkHeight)
					bgSprite = new Tile(
						buffer: bgBuffer
						spatialHash: spatialHash
						order: 0)
					fgSprite = new Tile(
						buffer: fgBuffer
						spatialHash: spatialHash
						order: 0)
					bgSprite.setAnchorPoint(new cc.Point(0, 1))
					fgSprite.setAnchorPoint(new cc.Point(0, 1))
					bgSprite.setPosition(new cc.Point(chunkX * chunkWidth, @buffer.height - chunkY * chunkHeight))
					fgSprite.setPosition(new cc.Point(chunkX * chunkWidth, chunkY * chunkHeight-@buffer.height))
					parentSprite.addChild(bgSprite, 0)
					parentSprite.addChild(fgSprite, 1)
					spatialHash.addNode(bgSprite)
					spatialHash.addNode(fgSprite)

					bgSprite = new Tile(
						buffer: bgBuffer
						spatialHash: spatialHash
						order: 0)
					fgSprite = new Tile(
						buffer: fgBuffer
						spatialHash: spatialHash
						order: 0)
					bgSprite.setAnchorPoint(new cc.Point(0, 1))
					fgSprite.setAnchorPoint(new cc.Point(0, 1))
					bgSprite.setPosition(new cc.Point(chunkX * chunkWidth + @buffer.width, @buffer.height - chunkY * chunkHeight))
					fgSprite.setPosition(new cc.Point(chunkX * chunkWidth + @buffer.width, chunkY * chunkHeight-@buffer.height))
					parentSprite.addChild(bgSprite, 0)
					parentSprite.addChild(fgSprite, 1)
					spatialHash.addNode(bgSprite)
					spatialHash.addNode(fgSprite)

					ctxs = ctxsArray[chunkX][chunkY] =
						bg: bgBuffer.getContext('2d')
						fg: fgBuffer.getContext('2d')

				spriteFrames = tileSpriteFrameFunction(x, y, tileMap)
				for spriteFrame in spriteFrames
					if spriteFrame?
						spriteFrameRect = spriteFrame.getRect()
						spriteFrameOffset = spriteFrame.getOffset()
						ctxs.bg.drawImage(
							spriteFrame.getTexture(), 
							spriteFrameRect.origin.x, 
							spriteFrameRect.origin.y, 
							spriteFrameRect.size.width, 
							spriteFrameRect.size.height,
							(x % modWidth) * tileSize.width + spriteFrameOffset.x,
							(y % modHeight) * tileSize.height + spriteFrameOffset.y,
							spriteFrameRect.size.width,
							spriteFrameRect.size.height)
						ctx.drawImage(
							spriteFrame.getTexture(), 
							spriteFrameRect.origin.x, 
							spriteFrameRect.origin.y, 
							spriteFrameRect.size.width, 
							spriteFrameRect.size.height,
							x * tileSize.width + spriteFrameOffset.x,
							y * tileSize.height - @buffer.height + spriteFrameOffset.y,
							spriteFrameRect.size.width,
							spriteFrameRect.size.height)