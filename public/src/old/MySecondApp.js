(function(){
    var MySecondApp = cc.Layer.extend(
    {
        sprite: null,
        init:function()
        {	
            var animationCache = cc.AnimationCache.getInstance();

            var ControllableSprite = cc.Sprite.extend({
                velocity: 40,
                moveDelta: 0,
                addMoveDelta: .5,
                keyMap: null,
                animations: null,
                moving: false,
                ctor: function(){
                    
                    this.initWithFile(config.assetsFolder+"images/vanguard.png");
                    
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
            layer1.addChild(sprite);

            var windowSize = cc.Director.getInstance().getWinSize();
    		var spriteSize = sprite.getContentSize();
            sprite.setFlipX(true);
            
            sprite.setPosition(new cc.Point(
    			windowSize.width/2,
    			windowSize.height/2)
    		);

            sprite.scheduleUpdate();

            this.addChild(layer1);

            this.setTouchEnabled(true);
            this.setKeyboardEnabled(true);

            this.sprite = sprite;
            return true;
        },
        onKeyDown:function(e){
            this.sprite.handleKeyDown(e);
        },
        onKeyUp:function(e){
            this.sprite.handleKeyUp(e);
        }
    });


    MySecondAppScene = cc.Scene.extend({
        onEnter:function(){
            this._super();
            var layer = new MySecondApp();
            layer.init();
            this.addChild(layer);
        }
    })
}());