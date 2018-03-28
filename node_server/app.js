var net = require('net');
var loginRoute = require("./routes/loginRoute");
var global = require("./global")
var ProtoBuf = require("protobufjs");
var builder = ProtoBuf.loadProtoFile("./impb/root.proto"),
    Message = builder.build("root"),
    BaseServer = builder.build("enum_root_server");


var HOST = '127.0.0.1';
var PORT = 6969;
var server = net.createServer();
server.listen(PORT, HOST);
server.on('connection', function(sock) {

    console.log('CONNECTED: ' + sock.remoteAddress +':'+ sock.remotePort);

    sock.on('data', function(data) {

        var margic = data.readUInt8(0)
        var type   = data.readUInt8(1)
        var lenth  = data.readUInt16BE(2)

        var newBuf = data.slice(4,lenth)


        try  {
            var msg = Message.decode(newBuf);
            switch (msg.header.server){
                case BaseServer.enum_root_server_login:
                    loginRoute.handleReq(msg,sock)
                    break;
                case BaseServer.enum_root_server_ping:
                    break;
                case BaseServer.enum_root_server_sent_msg:
                    break;
                default:
                    break;
            }
            console.log('DATA ' + sock.remoteAddress + ': ' + data);
        }catch (err){
            console.log(err);
        }

    });

    // 为这个socket实例添加一个"close"事件处理函数
    sock.on('close', function(data) {
        console.log('CLOSED: ' + sock.remoteAddress + ' ' + sock.remotePort);
    });

});


