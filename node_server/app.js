var net = require('net');

var global = require("./global")
var ProtoBuf = require("protobufjs");
var builder = ProtoBuf.loadProtoFile("./impb/root.proto"),
    BaseServer = builder.build("enum_root_server");
var pingRoute = require("./routes/pinRoute"),
    commonRoute = require("./routes/commonRoute"),
    messageRoute = require("./routes/messageRoute"),
    notificationRoute = require("./routes/notificationRoute")

var HOST = '127.0.0.1';
var PORT = 6969;
var server = net.createServer();
server.listen(PORT, HOST);
server.on('connection', function(sock) {

    console.log('CONNECTED: ' + sock.remoteAddress +':'+ sock.remotePort);

    sock.on('data', function(data) {

        var tempData = data
        while (tempData.length){
            var header = data.slice(0,8)
            var margic = header.readUInt8(0)
            var seq    = header.readUInt32BE(1)
            var type   = header.readUInt8(5)
            var lenth  = header.readUInt16BE(6)
            var body =   tempData.slice(8,lenth+8)
            var lest = tempData.length - ( lenth + 8 )
            handle(type,header,body)
            if (lest){
                tempData = data.slice(lenth+8,lest)
            }else {
                break
            }
        }

        // type 1心跳包 2普通数据请求 3聊天消息 4推送
        function handle(type,header,body) {
            switch (type){
                case 1:
                    pingRoute.route(function () {
                        sock.write(data)
                    })

                case 2:
                    commonRoute.route(body,function (rsp,uid) {
                        if (uid){
                            global.cachSock(sock,uid)
                        }
                        sentWith(header,rsp)
                    })
                    break;
                case 3:
                    messageRoute.route(body,function (uids) {
                        for ( uid in uids ){
                            var sock = global.sockWithUid(uid)
                            if(sock){
                                sock.write(data)
                            }else{
                                // 离线消息处理

                            }

                        }
                    })
                    break;
                case 4: // 收到推送的回执
                    notificationRoute.route(body,function () {
                        sock.write(data)
                    })
                    break;
            }
        }

        function sentWith(header,response) {
            var resData = response.toBuffer()
            // 去掉length并替换
            var ops = header.writeUInt16BE(resData.length,6)
            var result = Buffer.concat([header,resData])
            sock.write(result)
        }

    });

    // 为这个socket实例添加一个"close"事件处理函数
    sock.on('close', function(data) {
        console.log('CLOSED: ' + sock.remoteAddress + ' ' + sock.remotePort);
    });

});



exports.server = server;

