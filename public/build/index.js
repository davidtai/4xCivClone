var express = require('express'),
    server = express();

server.use(express.logger());
server.use("/", express.static(__dirname+"/public"));

server.listen(process.env.PORT || 8080);