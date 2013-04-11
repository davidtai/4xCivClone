var sharedSpriteFrameCache = cc.SpriteFrameCache.getInstance();

var tileMap = [
    [1,0,0,0,1,1,2,2,2,1],
    [1,2,2,2,1,1,0,0,0,1],
    [1,1,1,1,1,2,2,2,2,2]
];

tileMap.reverse();

var tileDim = {
    w: 40,
    h: 40
};

var loadTile = function(layer, tileId, x, y){
    var tile;
    switch(tileId)
    {
    case 0:
        tile = cc.Sprite.createWithSpriteFrameName("TempBackground");
        break;
    case 1:
        tile = cc.Sprite.createWithSpriteFrameName("TempBox");
        break;
    case 2:
        tile = cc.Sprite.createWithSpriteFrameName("TempDirt");
        break;
    default:
        return;
    }
    tile.setAnchorPoint(new cc.Point(0,0));
    tile.setPosition(new cc.Point(tileDim.w*x, tileDim.h*y));
    layer.addChild(tile);
};

var loadTiles = function(layer, tileMap){
    tileMap.map(function(tiles, y){
        tiles.map(function(tile, x){
            loadTile(layer, tile, x, y);
        });
    });
};

var Engine = cc.Layer.extend(
{
    sprite: null,
    init:function(){	
        var animationCache = cc.AnimationCache.getInstance();

        var ControllableSprite = cc.Sprite.extend({
            velocity: 40,
            moveDelta: 0,
            addMoveDelta: .5,
            keyMap: null,
            animations: null,
            moving: false,
            ctor: function(){
                
                this.init();
                
                var stillAnimation = animationCache.getAnimation("VanguardStill");
                var readyAnimation = animationCache.getAnimation("VanguardReady");
                var walkAnimation = animationCache.getAnimation("VanguardWalk");

                var animations = {};
                this.animations = animations;
                animations.still = cc.Animate.create(stillAnimation);
                animations.ready = cc.Animate.create(readyAnimation);
                animations.walk = cc.RepeatForever.create(cc.Animate.create(walkAnimation));  

                this.runAction(animations.still);

                this.keyMap = {};
            },
            update:function(dt)
            {
                if(this.keyMap[cc.KEY.left]){
                    this.setFlipX(false);
                    this.moveDelta = this.addMoveDelta;
                } else if(this.keyMap[cc.KEY.right]){
                    this.setFlipX(true);
                    this.moveDelta = this.addMoveDelta;
                } else if(this.moving){
                    this.stopAllActions();
                    this.runAction(this.animations.still);
                    this.moving = false;
                }

                if(this.moveDelta > 0)
                {
                    this.handleMove(dt);
                }
            },
            handleMove:function(dt){    
                var velocity = this.velocity;
                if(!this.isFlippedX()){
                    velocity = -velocity;
                }
                if(dt >= this.moveDelta){
                    this._position.x += this.moveDelta * velocity;
                    this.moveDelta = 0;
                }
                else{
                    this._position.x += dt * velocity;
                    this.moveDelta -= dt;
                }
            },
            handleKeyUp:function(e){
                this.keyMap[e] = false;
                if(e === cc.KEY.left || e === cc.KEY.right){
                    this.moveDelta = 0;
                }
            },
            handleKeyDown:function(e)
            {
                if(e === cc.KEY.left && !this.keyMap[e]){
                    this.stopAllActions();
                    this.runAction(this.animations.walk);
                    this.keyMap[e] = true;
                    this.moving = true;
                }
                else if(e === cc.KEY.right&& !this.keyMap[e]){
                    this.stopAllActions();
                    this.runAction(this.animations.walk);
                    this.keyMap[e] = true;
                    this.moving = true;
                }
            },
        });

        var layer1 = cc.LayerColor.create(new cc.Color4B(0, 0, 0, 255), 600, 600),
            sprite = new ControllableSprite();
        layer1.addChild(sprite, 1);

        var windowSize = cc.Director.getInstance().getWinSize();
		var spriteSize = sprite.getContentSize();

        sprite.setPosition(new cc.Point(
			windowSize.width/2,
			38)
		);

        sprite.scheduleUpdate();

        this.addChild(layer1);

        this.setTouchEnabled(true);
        this.setKeyboardEnabled(true);

        this.sprite = sprite;

        loadTiles(layer1, tileMap);

        return true;
    },
    onKeyDown:function(e){
        this.sprite.handleKeyDown(e);
    },
    onKeyUp:function(e){
        this.sprite.handleKeyUp(e);
    }
});

var engine = cc.Scene.extend({
    onEnter:function(){
        this._super();
        var layer = new Engine();
        layer.init();
        this.addChild(layer);
    }
});