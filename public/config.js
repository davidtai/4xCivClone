(function(global){
  //Configuration
  global.config = {
      screen: {
          width: 512,
          height: 384,
          scale: 2
      },
      assetsFolder: "assets/",
      libFiles: [
          'lib/patches.js',
          'lib/World.js',
          'lib/Async.js',
          'lib/SpatialHash.js',
          'lib/Background.js',
          'lib/CustomSprites.js',
          'lib/Overlay.js',
          'lib/Engine.js'
      ]
  };

  // TODO collapse all into config
  var canvas = $('#gameCanvas')[0];
  config.disabledSmoothing = true; //hard coded since we basically don't want to scale.

  if(canvas) {
      context = canvas.getContext('2d'); 
      if(context.imageSmoothingEnabled ||
          context.mozImageSmoothingEnabled ||
          context.oImageSmoothingEnabled ||
          context.webkitImageSmoothingEnabled)
      {
          config.disabledSmoothing = true;
      }
  }

  if(!config.disabledSmoothing) {
      config.screen.width = config.screen.width * config.screen.scale;
      config.screen.height = config.screen.height * config.screen.scale;
  }

  config.screen.centerX = config.screen.width/2;
  config.screen.centerY = config.screen.height/2;
  config.screen.cameraOffset = config.screen.centerX*0.6;

  //Preloads
  global.resources = {
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
}(this));