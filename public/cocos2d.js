var canvas = $('#gameCanvas')[0];

if(canvas) {
context = canvas.getContext('2d'); 
context.imageSmoothingEnabled = true;
context.mozImageSmoothingEnabled = true;
context.oImageSmoothingEnabled = true;
context.webkitImageSmoothingEnabled = true;
}

//Configuration
var config = {
    screen: {
        width: 1024,
        height: 768,
        scale: 1
    },
    assetsFolder: "assets/",
    libFiles: [
        'vendor/random/MersenneTwister.js',
        'lib/patches.js',
        'lib/World.js',
        'lib/Async.js',
        'lib/SpatialHash.js',
        'lib/Background.js',
        'lib/CustomSprites.js',
        'lib/Engine.js'
    ]
};

config.screen.width = config.screen.width * config.screen.scale;
config.screen.height = config.screen.height * config.screen.scale;
config.screen.centerX = config.screen.width/2;
config.screen.centerY = config.screen.height/2;
config.screen.cameraOffset = config.screen.centerX*0.6;

//Preloads
var resources = {
    tiles:          {type:"sprite-json", src:config.assetsFolder+"sprites/tiles3.json"},
    grasstiles:     {type:"sprite-json", src:config.assetsFolder+"sprites/grasstiles.json"},
    leechedtiles:   {type:"sprite-json", src:config.assetsFolder+"sprites/leechedtiles.json"},
    prairietiles:   {type:"sprite-json", src:config.assetsFolder+"sprites/prairietiles.json"},
    deserttiles:    {type:"sprite-json", src:config.assetsFolder+"sprites/deserttiles.json"},
    plaintiles:     {type:"sprite-json", src:config.assetsFolder+"sprites/plaintiles.json"},
    taigatiles:     {type:"sprite-json", src:config.assetsFolder+"sprites/taigatiles.json"},
    polartiles:     {type:"sprite-json", src:config.assetsFolder+"sprites/polartiles.json"},
    doodads:        {type:"sprite-json", src:config.assetsFolder+"sprites/doodads.json"}
};

(function () {
    var d = document;
    var c = {
        COCOS2D_DEBUG:2, //0 to turn debug off, 1 for basic debug, and 2 for full debug
        box2d:false,
        chipmunk:false,
        showFPS:true,
        frameRate:60,
        loadExtension:false,
        tag:'gameCanvas', //the dom element to run cocos2d on
        engineDir:'vendor/cocos2d-html5/cocos2d/',
        appFiles: config.libFiles
    };
    window.addEventListener('DOMContentLoaded', function () {
        //first load engine file if specified
        var s = d.createElement('script');
        s.src = c.engineDir + 'platform/jsloader.js';
        d.ccConfig = c;
        s.id = 'cocos2d-html5';
        d.body.appendChild(s);
    });
})();