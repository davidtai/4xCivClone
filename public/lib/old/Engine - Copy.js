// Generated by CoffeeScript 1.10.0
(function() {
  var Actor, ControllableSprite, Engine, SmartTile, SmartTileLayer, actorId, animationCache, counts, h, i, k, l, m, n, o, p, q, r, s, sharedSpriteFrameCache, sharedSpriteSheetCache, tileDim, tileMap, w, x, y,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  this.Math.cbrt = function(x) {
    var sign;
    if (x === 0) {
      return 0;
    } else {
      sign = x > 0 ? 1 : -1;
      return sign * Math.pow(Math.abs(x), 1 / 3);
    }
  };

  animationCache = cc.AnimationCache.getInstance();

  sharedSpriteFrameCache = cc.SpriteFrameCache.getInstance();

  sharedSpriteSheetCache = cc.SpriteSheetJson.getInstance();

  tileMap = [];

  for (x = k = 0; k < 100; x = ++k) {
    tileMap[y] = [];
    for (y = l = 0; l < 100; y = ++l) {
      tileMap[x][y] = Math.floor(Math.random() * 4);
    }
  }

  counts = [];

  for (i = m = 1; m < 6; i = ++m) {
    for (x = n = 1; n < 99; x = ++n) {
      counts[x] = [];
      for (y = o = 1; o < 99; y = ++o) {
        counts[x][y] = 0;
        for (w = p = -1; p < 2; w = ++p) {
          for (h = q = -1; q < 2; h = ++q) {
            if (tileMap[x + w][y + h] === 1 || tileMap[x + w][y + h] === 2) {
              counts[x][y]++;
            }
          }
        }
      }
    }
    for (x = r = 1; r < 99; x = ++r) {
      for (y = s = 1; s < 99; y = ++s) {
        tileMap[x][y] = counts[x][y] >= 5 ? 2 : counts[x][y] >= 4 ? 3 : 0;
      }
    }
  }

  tileMap.reverse();

  tileDim = new cc.Size(40, 40);

  SmartTile = (function() {
    function SmartTile(tile1, x1, y1, left, up, right, down) {
      this.tile = tile1;
      this.x = x1;
      this.y = y1;
      this.actors = {};
      this.setLeft(left);
      this.setUp(up);
      this.setRight(right);
      this.setDown(down);
    }

    SmartTile.prototype.setLeft = function(tile) {
      if (tile != null) {
        this.left = tile;
        return tile.right = this;
      }
    };

    SmartTile.prototype.setUp = function(tile) {
      if (tile != null) {
        this.up = tile;
        return tile.down = this;
      }
    };

    SmartTile.prototype.setRight = function(tile) {
      if (tile != null) {
        this.right = tile;
        return tile.left = this;
      }
    };

    SmartTile.prototype.setDown = function(tile) {
      if (tile != null) {
        this.down = tile;
        return tile.up = this;
      }
    };

    return SmartTile;

  })();

  SmartTileLayer = (function(superClass) {
    extend(SmartTileLayer, superClass);

    function SmartTileLayer() {
      return SmartTileLayer.__super__.constructor.apply(this, arguments);
    }

    SmartTileLayer.prototype.ctor = function(fileImage, w1, h1, tileMap1) {
      this.w = w1;
      this.h = h1;
      this.tileMap = tileMap1;
      this.size = new cc.Size(this.tileMap.length, this.tileMap[0] != null ? this.tileMap[0].length : 1);
      this.init(fileImage, this.size.x * this.size.y);
      return this.loadTiles(tileMap);
    };

    SmartTileLayer.prototype.loadTiles = function() {
      var that;
      this.smartTiles = [];
      this.visibleSmartTiles = [];
      that = this;
      return this.tileMap.map(function(tileIds, y) {
        that.smartTiles[y] = [];
        return tileIds.map(function(tileId, x) {
          var smartTile, smartTileForYMinus1, tile;
          tile = that.getTile(x, y);
          if (tile != null) {
            that.addChild(tile);
            smartTileForYMinus1 = that.smartTiles[y - 1];
            smartTile = new SmartTile(tile, x, y, that.smartTiles[y][x - 1], smartTileForYMinus1 != null ? smartTileForYMinus1[x] : null);
            that.smartTiles[y][x] = smartTile;
            if (tile.isVisible()) {
              that.visibleSmartTiles.push(smartTile);
              return smartTile.marked = true;
            }
          }
        });
      });
    };

    SmartTileLayer.prototype.getTile = function(x, y) {
      var position, tile, tileId, tileIdAbove;
      tileId = this.tileMap[y][x];
      tileIdAbove = this.tileMap[y + 1] != null ? this.tileMap[y + 1][x] : tileId;
      switch (tileId) {
        case 0:
          tile = cc.Sprite.createWithSpriteFrameName("TempBackground");
          break;
        case 1:
          tile = cc.Sprite.createWithSpriteFrameName("TempBox");
          break;
        case 2:
          switch (tileIdAbove) {
            case 2:
              tile = cc.Sprite.createWithSpriteFrameName("TempDirt");
              break;
            default:
              tile = cc.Sprite.createWithSpriteFrameName("TempDirtWalkable");
          }
          break;
        case 3:
          switch (tileIdAbove) {
            case 0:
            case 1:
              tile = cc.Sprite.createWithSpriteFrameName("TempBackDirtWalkable");
              break;
            default:
              tile = cc.Sprite.createWithSpriteFrameName("TempBackDirt");
          }
          break;
        default:
          return null;
      }
      tile.setAnchorPoint(new cc.Point(0, 0));
      position = new cc.Point(tileDim.w * x, tileDim.h * y);
      tile.setPosition(position);
      if (position.x > config.screen.width + tileDim.w || position.x < -tileDim.w || position.y > config.screen.height + tileDim.h || position.y < -tileDim.h) {
        tile.setVisible(false);
      }
      return tile;
    };

    SmartTileLayer.prototype.getOverlappedSmartTiles = function(x, y, w, h) {
      var j, overlappedSmartTiles, ref, ref1, ref2, ref3, smartTiles, t, u;
      overlappedSmartTiles = [];
      for (j = t = ref = y, ref1 = y + h; ref <= ref1 ? t < ref1 : t > ref1; j = ref <= ref1 ? ++t : --t) {
        smartTiles = this.smartTiles[j];
        if (smartTiles != null) {
          for (i = u = ref2 = x, ref3 = x + w; ref2 <= ref3 ? u < ref3 : u > ref3; i = ref2 <= ref3 ? ++u : --u) {
            if (smartTiles[i] != null) {
              overlappedSmartTiles.push(smartTiles[i]);
            }
          }
        }
      }
      return overlappedSmartTiles;
    };

    SmartTileLayer.prototype.update = function(dt, scrollPos) {
      var actors, len, len1, ref, ref1, results, t, tile, u, visibleSmartTile;
      if (this.visibleSmartTiles && scrollPos) {
        ref = this.visibleSmartTiles;
        for (t = 0, len = ref.length; t < len; t++) {
          visibleSmartTile = ref[t];
          tile = visibleSmartTile.tile;
          actors = visibleSmartTile.actors;
          tile.setVisible(false);
        }
        this.visibleSmartTiles = this.getOverlappedSmartTiles(Math.round(scrollPos.x / 40) - 1, Math.round(scrollPos.y / 40) - 1, Math.round(config.screen.width / 40) + 1, Math.round(config.screen.height / 40) + 1);
        ref1 = this.visibleSmartTiles;
        results = [];
        for (u = 0, len1 = ref1.length; u < len1; u++) {
          visibleSmartTile = ref1[u];
          tile = visibleSmartTile.tile;
          actors = visibleSmartTile.actors;
          results.push(tile.setVisible(true));
        }
        return results;
      }
    };

    return SmartTileLayer;

  })(cc.SpriteBatchNode);

  actorId = 0;

  Actor = (function(superClass) {
    var currentSmartTile;

    extend(Actor, superClass);

    function Actor() {
      return Actor.__super__.constructor.apply(this, arguments);
    }

    Actor.prototype.velocity = 80;

    Actor.prototype.moveDelta = 0;

    Actor.prototype.addMoveDelta = .5;

    Actor.prototype.keyMap = null;

    Actor.prototype.animations = null;

    Actor.prototype.moving = false;

    Actor.prototype.deltaPos = null;

    currentSmartTile = null;

    Actor.prototype.ctor = function(smartTileLayer1) {
      var smartTiles;
      this.smartTileLayer = smartTileLayer1;
      this.id = actorId++;
      this.init();
      y = Math.floor(this._position.y / 40);
      smartTiles = this.smartTileLayer.smartTiles[y];
      if (smartTiles != null) {
        x = Math.floor(this._position.x / 40);
        this.currentSmartTile = smartTiles[x];
        this.currentSmartTile.actors[this.id] = this;
        return this.setVisible(this.currentSmartTile.tile.isVisible());
      }
    };

    Actor.prototype.update = function(dt) {
      var position, smartTile, smartTiles;
      if (this.myUpdate != null) {
        this.myUpdate(dt);
      }
      position = this._position;
      y = Math.floor(position.y / 40);
      smartTiles = this.smartTileLayer.smartTiles[y];
      if (smartTiles != null) {
        x = Math.floor(position.x / 40);
        smartTile = smartTiles[x];
        if ((smartTile != null) && smartTile !== this.currentSmartTile) {
          if (this.currentSmartTile) {
            delete this.currentSmartTile.actors[this.id];
          }
          this.currentSmartTile = smartTile;
          this.currentSmartTile.actors[this.id] = this;
        }
      }
      if (this.currentSmartTile) {
        return this.setVisible(this.currentSmartTile.tile.isVisible());
      }
    };

    Actor.prototype.handleMove = function(dt) {
      var deltaX, velocity;
      velocity = this.velocity;
      if (!this.isFlippedX()) {
        velocity = -velocity;
      }
      if (dt >= this.moveDelta) {
        this.deltaPos.x += this.moveDelta * velocity;
        deltaX = Math.floor(this.deltaPos.x);
        this._position.x += deltaX;
        this.deltaPos.x -= deltaX;
        return this.moveDelta = 0;
      } else {
        this.deltaPos.x += dt * velocity;
        deltaX = Math.floor(this.deltaPos.x);
        this._position.x += deltaX;
        this.deltaPos.x -= deltaX;
        return this.moveDelta -= dt;
      }
    };

    return Actor;

  })(cc.Sprite);

  ControllableSprite = (function(superClass) {
    extend(ControllableSprite, superClass);

    function ControllableSprite() {
      return ControllableSprite.__super__.constructor.apply(this, arguments);
    }

    ControllableSprite.prototype.ctor = function(smartTileLayer) {
      var animations, readyAnimation, stillAnimation, walkAnimation;
      ControllableSprite.__super__.ctor.call(this, smartTileLayer);
      stillAnimation = animationCache.getAnimation("VanguardStill");
      readyAnimation = animationCache.getAnimation("VanguardReady");
      walkAnimation = animationCache.getAnimation("VanguardWalk");
      animations = {};
      this.animations = animations;
      animations.still = cc.Animate.create(stillAnimation);
      animations.ready = cc.Animate.create(readyAnimation);
      animations.walk = cc.RepeatForever.create(cc.Animate.create(walkAnimation));
      this.runAction(animations.still);
      this.keyMap = {};
      this.deltaPos = new cc.Point(0, 0);
      return this.setAnchorPoint(new cc.Point(0.5, 0));
    };

    ControllableSprite.prototype.myUpdate = function(dt) {
      if (this.keyMap[cc.KEY.left]) {
        this.setFlipX(false);
        this.moveDelta = this.addMoveDelta;
      } else if (this.keyMap[cc.KEY.right]) {
        this.setFlipX(true);
        this.moveDelta = this.addMoveDelta;
      } else if (this.moving) {
        this.stopAllActions();
        this.runAction(this.animations.still);
        this.moving = false;
      }
      if (this.moveDelta > 0) {
        return this.handleMove(dt);
      }
    };

    ControllableSprite.prototype.handleKeyUp = function(e) {
      this.keyMap[e] = false;
      if (e === cc.KEY.left || e === cc.KEY.right) {
        return this.moveDelta = 0;
      }
    };

    ControllableSprite.prototype.handleKeyDown = function(e) {
      if (e === cc.KEY.left && !this.keyMap[e]) {
        this.stopAllActions();
        this.runAction(this.animations.walk);
        this.keyMap[e] = true;
        return this.moving = true;
      } else if (e === cc.KEY.right && !this.keyMap[e]) {
        this.stopAllActions();
        this.runAction(this.animations.walk);
        this.keyMap[e] = true;
        return this.moving = true;
      }
    };

    return ControllableSprite;

  })(Actor);

  Engine = (function(superClass) {
    extend(Engine, superClass);

    function Engine() {
      return Engine.__super__.constructor.apply(this, arguments);
    }

    Engine.prototype.sprite = null;

    Engine.prototype.sprites = null;

    Engine.prototype.scroll = null;

    Engine.prototype.init = function() {
      var bug, bugWalk, layer1, lazyLayer, spriteSize, t, windowSize;
      windowSize = cc.Director.getInstance().getWinSize();
      windowSize.width = windowSize.width / config.screen.scale;
      windowSize.height = windowSize.height / config.screen.scale;
      layer1 = cc.LayerColor.create(new cc.Color4B(0, 0, 0, 255), config.screen.width, config.screen.height);
      layer1.setPosition(Math.floor((windowSize.width - config.screen.width) / 2), Math.floor((windowSize.height - config.screen.height) / 2));
      this.scroll = cc.Node.create();
      layer1.addChild(this.scroll, 1);
      this.smartTileLayer = new SmartTileLayer(sharedSpriteSheetCache.getSpriteSheet("MapTiles").Source, tileDim.w, tileDim.h, tileMap);
      this.scroll.addChild(this.smartTileLayer);
      this.sprite = new ControllableSprite(this.smartTileLayer);
      this.scroll.addChild(this.sprite);
      spriteSize = this.sprite.getContentSize();
      this.sprite.setPosition(new cc.Point(160, 160));
      this.addChild(layer1);
      this.setTouchEnabled(true);
      this.setKeyboardEnabled(true);
      lazyLayer = new cc.LazyLayer();
      lazyLayer.addChild(cc.LayerColor.create(new cc.Color4B(0, 0, 0, 255), windowSize.width, windowSize.height));
      this.addChild(lazyLayer);
      this.sprites = [];
      for (i = t = 0; t < 99; i = ++t) {
        bug = new Actor(this.smartTileLayer);
        bugWalk = cc.RepeatForever.create(cc.Animate.create(animationCache.getAnimation("WorkerBugWalk")));
        bug.runAction(bugWalk);
        bug.setPosition(new cc.Point(Math.floor(Math.random() * 4000), Math.floor(Math.random() * 4000)));
        bug.setAnchorPoint(new cc.Point(0.5, 0));
        this.scroll.addChild(bug);
        this.sprites.push(bug);
      }
      return true;
    };

    Engine.prototype.onKeyDown = function(e) {
      return this.sprite.handleKeyDown(e);
    };

    Engine.prototype.onKeyUp = function(e) {
      return this.sprite.handleKeyUp(e);
    };

    Engine.prototype.update = function(dt) {
      var len, ref, results, scrollPos, sprite, spritePos, t, z;
      if (this.sprite.moving) {
        this.sprite.update(dt);
        this.updateSprite(this.sprite);
        scrollPos = this.scroll.getPosition();
        spritePos = this.sprite.getPosition();
        spritePos.x += this.sprite.isFlippedX() ? config.screen.cameraOffset : -config.screen.cameraOffset;
        spritePos.x += scrollPos.x - config.screen.centerX;
        spritePos.y += scrollPos.y - config.screen.centerY;
        if (spritePos.x !== 0 || spritePos.y !== 0) {
          scrollPos.x -= Math.floor(Math.cbrt(spritePos.x));
          scrollPos.y -= Math.floor(Math.cbrt(spritePos.y));
          this.scroll.setPosition(scrollPos);
          scrollPos.x = -scrollPos.x;
          scrollPos.y = -scrollPos.y;
          this.smartTileLayer.update(dt, scrollPos);
        }
      }
      ref = this.sprites;
      results = [];
      for (t = 0, len = ref.length; t < len; t++) {
        sprite = ref[t];
        sprite.update(dt);
        z = sprite.getPosition();
        z.x -= .3;
        sprite.setPosition(z);
        results.push(this.updateSprite(sprite));
      }
      return results;
    };

    Engine.prototype.updateSprite = function(sprite) {
      var scrollPos, spritePos, tileId, tileIds;
      scrollPos = this.scroll.getPosition();
      spritePos = sprite.getPosition();
      y = Math.floor(spritePos.y / tileDim.h);
      tileIds = tileMap[y];
      if (tileIds != null) {
        x = Math.floor(spritePos.x / tileDim.w);
        tileId = tileIds[x];
        if (tileId === 1 || tileId === 2) {
          spritePos.y = (y + 1) * tileDim.h;
          return sprite.setPosition(spritePos);
        } else if ((tileId === 0 || tileId === 3) && tileMap[y - 1] && tileMap[y - 1][x] === 0) {
          spritePos.y = (y - 1) * tileDim.h;
          return sprite.setPosition(spritePos);
        }
      }
    };

    return Engine;

  })(cc.Layer);

  this.engine = cc.Scene.extend({
    onEnter: function() {
      var layer;
      this._super();
      layer = new Engine();
      $(document).keydown(function(e) {
        return layer.onKeyDown(e.which);
      });
      $(document).keyup(function(e) {
        return layer.onKeyUp(e.which);
      });
      layer.init();
      layer.scheduleUpdate();
      layer.setScale(config.screen.scale, config.screen.scale);
      return this.addChild(layer);
    }
  });

}).call(this);
