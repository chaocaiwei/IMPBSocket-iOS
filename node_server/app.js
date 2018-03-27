var net = require('net');
var loginHandle = require("./LoginHandle");
var ProtoBuf = require("protobufjs");
var builder = ProtoBuf.loadProtoFile("./impb/root.proto"),
    Message = builder.build("root"),
    Header  = builder.build("msg_header"),
    Info  = builder.build("ext_key_info"),
    BaseType = builder.build("enum_root_type"),
    BaseServer = builder.build("enum_root_server");
var LoginBuilder = ProtoBuf.loadProtoFile("./impb/login.proto"),
    SiginReq   = LoginBuilder.build("signin_req");


var HOST = '127.0.0.1';
var PORT = 6969;
var server = net.createServer();
server.listen(PORT, HOST);
server.on('connection', function(sock) {

    console.log('CONNECTED: ' +
        sock.remoteAddress +':'+ sock.remotePort);
    // 其它内容与前例相同

    // 为这个socket实例添加一个"data"事件处理函数
    sock.on('data', function(data) {

        try  {
            var msg = Message.decode(data);
            var header = msg.header;
            var respon = {};
            switch (msg.header.server){
                case BaseServer.enum_root_server_login:
                    respon = loginHandle.handleReq(msg.body,msg.header.method)
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
            var responData = respon.toBuffer();
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


