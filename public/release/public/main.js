var cocos2dApp=cc.Application.extend({config:document.ccConfig,ctor:function(){this._super();var that=this;cc.COCOS2D_DEBUG=this.config.COCOS2D_DEBUG;cc.initDebugSetting();cc.setup(this.config.tag);cc.Loader.getInstance().onloading=function(){cc.LoaderScene.getInstance().draw()};cc.Loader.getInstance().onload=function(){that.startScene=engine=cc.Scene.extend({onEnter:function(){this._super();var layer=new Engine;$(document).keydown(function(e){layer.onKeyDown(e.which)});$(document).keyup(function(e){layer.onKeyUp(e.which)});layer.init();layer.scheduleUpdate();this.addChild(layer)}});cc.AppController.shareAppController().didFinishLaunchingWithOptions()};cc.Loader.getInstance().preload(resources)},applicationDidFinishLaunching:function(){var director=cc.Director.getInstance();director.setDisplayStats(this.config.showFPS);director.setAnimationInterval(1/this.config.frameRate);director.runWithScene(new this.startScene);return true}});var myApp=new cocos2dApp;