(function () {
    var d = document;
    var c = {
        COCOS2D_DEBUG:0, //0 to turn debug off, 1 for basic debug, and 2 for full debug
        box2d:false,
        chipmunk:false,
        showFPS:true,
        frameRate:60,
        loadExtension:false,
        tag:'gameCanvas', //the dom element to run cocos2d on
        SingleEngineFile: 'game.js'
    };
    window.addEventListener('DOMContentLoaded', function () {
        var s = d.createElement('script');

        if (c.SingleEngineFile && !c.engineDir) {
            s.src = c.SingleEngineFile;
        } else {
            alert('You must specify either the single engine file OR the engine directory in "cocos2d.js"');
        }

        document.ccConfig = c;
        s.id = 'cocos2d-html5';
        d.body.appendChild(s);
    });
})();