var net = require('net');
var loginRoute = require("./routes/LoginRoute");
var ProtoBuf = require("protobufjs");
var builder = ProtoBuf.loadProtoFile("./impb/root.proto"),
    Message = builder.build("root"),
    Header  = builder.build("msg_header"),
    Info  = builder.build("ext_key_info"),
    BaseType = builder.build("enum_root_type"),
    BaseServer = builder.build("enum_root_server");
var LoginBuilder = ProtoBuf.loadProtoFile("./impb/login.proto"),
    SiginReq   = LoginBuilder.build("signin_req");

var socketMap  = {};
var sockeIdMap = {};
var db = require("./DataBase")

function getSocketId(socket) {
    var id = sock.remoteAddress + ":" + sock.remotePort
    return id
}

db.connect()

var HOST = '127.0.0.1';
var PORT = 6969;
var server = net.createServer();
server.listen(PORT, HOST);
server.on('connection', function(sock) {

    console.log('CONNECTED: ' +
        sock.remoteAddress +':'+ sock.remotePort);
    socketMap[getSocketId(sock)] = sock

    sock.on('data', function(data) {

        try  {
            var msg = Message.decode(data);

            var uid = msg.header.uid
            var socketId = sockeIdMap[uid]
            var socket  = socketMap[socketId]

            var respon = {};
            switch (msg.header.server){
                case BaseServer.enum_root_server_login:
                    respon = loginRoute.handleReq(msg.body,msg.header.method)
                    if (respon.uid){
                        sockeIdMap[uid]  = getSocketId(sock)
                    }
                    break;
                case BaseServer.enum_root_server_ping:
                    break;
                case BaseServer.enum_root_server_sent_msg:
                    break;
                default:
                    break;
            }

            console.log('DATA ' + sock.remoteAddress + ': ' + respon.body);
            // 回发该数据，客户端将收到来自服务端的数据
            msg.header.type  = BaseType.enum_root_type_respond
            msg.body  = respon.toBuffer()
            var responData = msg.toBuffer();
            sock.write(responData);

        }catch (err){
            console.log(err);
        }

    });

    // 为这个socket实例添加一个"close"事件处理函数
    sock.on('close', function(data) {
        console.log('CLOSED: ' +
            sock.remoteAddress + ' ' + sock.remotePort);
    });

});


