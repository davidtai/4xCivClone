var cocos2dApp = cc.Application.extend({
    config: document.ccConfig,
    ctor: function () {
        this._super();
        var that = this;
        cc.COCOS2D_DEBUG = this.config.COCOS2D_DEBUG;
        cc.initDebugSetting();
        cc.setup(this.config.tag);
        cc.Loader.getInstance().onloading = function () {
            cc.LoaderScene.getInstance().draw();
        };
        cc.Loader.getInstance().onload = function () {
            that.startScene = engine = cc.Scene.extend({
              onEnter: function(){
                this._super();
                var layer = new Engine();
                $(document).keydown(function(e){layer.onKeyDown(e.which);});
                $(document).keyup(function(e){layer.onKeyUp(e.which);});
                layer.init();
                layer.scheduleUpdate();
                this.addChild(layer);
            }});
            cc.AppController.shareAppController().didFinishLaunchingWithOptions();
        };
        cc.Loader.getInstance().preload(resources);
    },
    applicationDidFinishLaunching: function () {
        // initialize director
        var director = cc.Director.getInstance();

        // enable High Resource Mode(2x, such as iphone4) and maintains low resource on other devices.
//     director->enableRetinaDisplay(true);

        // turn on display FPS
        director.setDisplayStats(this.config.showFPS);

        // set FPS. the default value is 1.0/60 if you don't call this
        director.setAnimationInterval(1.0 / this.config.frameRate);

        // create a scene. it's an autorelease object

        // run
        director.runWithScene(new this.startScene());

        return true;
    }
});

var myApp = new cocos2dApp();