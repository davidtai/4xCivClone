class SpatialHashBin
	constructor: (active, @nodes)->
		@nodes = {} if !nodes?
		@active = active != false && active?

	add: (id, node)->
		@nodes[id] = node
		return @

	remove: (id)->
		@nodes[id] = null

spatialId = 0
@SpatialHash = class SpatialHash
	constructor: (@options)->
		@binSize = @options.binSize
		@spaceSize = @options.spaceSize
		@border = @options.border
		@border = if @border > 0 then @border else 0
		@gridSize = new cc.Size(Math.ceil(@spaceSize.width / @binSize.width), Math.ceil(@spaceSize.height / @binSize.height))
		@grid = []
		@activeBins = []
		for x in [0...@gridSize.width]
			@grid[x] = []
			for y in [0...@gridSize.height]
				@grid[x][y] = new SpatialHashBin()

	worldToGrid: (position)->
		return new cc.Point(Math.floor(position.x / @binSize.width), Math.floor(position.y / @binSize.height))

	isGridPositionInGrid: (position)->
		position.x >= 0 && position.y >= 0 && position.x < @gridSize.width && position.y < @gridSize.height
	
	# mostly use internally
	getBinInGrid: (x, y)->
		bins = @grid[x]
		return if bins then bins[y] else null

	getBin: (position)->
		binPosition = @worldToGrid(position)
		return @getBinInGrid(binPosition.x, binPosition.y) if @isGridPositionInGrid(binPosition)

	addNode: (node)->
		node.__spatialId = spatialId++ if !node.__spatialId?
		bin = @getBin(node.getPosition())
		return @insertNode(node, bin)

	# internal
	insertNode: (node, bin) ->
		node.__spatialBin = bin
		if bin?
			bin.add(node.__spatialId, node)
		return bin

	updateNode: (node)->
		if node.__spatialId? && node.__spatialBin?
			node.__spatialBin.remove(node.__spatialId)
		return @addNode(node)

	getBinFromNode: (node)->
		return node.__spatialBin;

	setActiveBins: (boundingRect)->
		for bin in @activeBins
			bin.active = false
		@activeBins.length = 0
			
		x1 = Math.max(Math.floor((boundingRect.origin.x - @border) / @binSize.width), 0)
		y1 = Math.max(Math.floor((boundingRect.origin.y - @border) / @binSize.height), 0)
		x2 = Math.min(Math.ceil((boundingRect.size.width + boundingRect.origin.x + @border) / @binSize.width), @gridSize.width)
		y2 = Math.min(Math.ceil((boundingRect.size.height + boundingRect.origin.y + @border)  / @binSize.height), @gridSize.height)

		for x in [x1...x2]
			for y in [y1...y2]
				bin = @getBinInGrid(x, y)
				if bin?
					@activeBins.push bin
					bin.active = true 
		console.log("ActiveBins:" + @activeBins.length);