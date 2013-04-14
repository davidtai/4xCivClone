rm -rf release
mkdir release
mkdir release\public
mkdir release\public\vendor

cp -r assets release\public\assets
cp index.html release\public\index.html
cp build\cocos2d-built.js release\public\cocos2d.js
cp -r vendor\random release\public\vendor\random

type vendor\cocos2d-html5\lib\Cocos2d-html5-v2.1.1.min.js lib\World.js lib\Async.js lib\Background.js lib\CustomSprites.js lib\Engine.js lib\Overlay.js lib\patches.js lib\SpatialHash.js > release\public\gamemerged.js
start cmd /K "uglifyjs release\public\gamemerged.js > release\public\game.js && exit"

start cmd /K "uglifyjs main.js > release\public\main.js && rm -f release\public\gamemerged.js && exit"
start cmd /K "uglifyjs build\config-built.js > release\public\config.js && exit"

http-server release/public