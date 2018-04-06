/**
 * Created by jztech-weichaocai on 2018/3/29.
 */


var loginRoute = require("./user"),
    friendRoute = require("./friendRoute"),
    messageRoute = require("./pullMessageRoute"),
    p2pRoute     = require("./p2pRoute");
var ProtoBuf = require("protobufjs");
var builder = require("../impb/common_pb"),
    Common = builder.Common;
    MethodType = builder.Common_method;
    Respon     = builder.CommonRespon;
var app = require("../app");
var errb = require("../impb/error_pb"),
    ErrType  = errb.error_type;

exports.route = function(header,body,sock){

    function handle(isSuc,res) {
        if (!isSuc){
            if (!res.type){
                res.type = ErrType.COMOM_ERR;
            }
            var respond = new Respon();
            respond.setError(res);
            respond.setIssuc(false);
            sent(header,respond,sock)
        }else {
            var respond = new Respon();
            respond.setIssuc(true)
            if(res){
                var data =  res.serializeBinary()
                respond.setRespon(data)
            }
            sent(header,respond,sock)
        }
        function  sent(header,respond,sock) {
            var resData = respond.serializeBinary()
            header.writeUInt16BE(resData.length,6)
            var buf = Buffer(resData)
            var result = Buffer.concat([header,buf])
            sock.write(result)
        }

    }

    try {
        var datas = new Uint8Array(body)
        var common =  new Common.deserializeBinary(datas)
        var method = common.getMethod()
        switch (method){
            case MethodType.COMMON_METHOD_USER:
                loginRoute.route(common.getBody(),sock,handle);
                break;
            case  MethodType.COMMON_METHOD_MESSAGE:
                messageRoute.route(common.getBody(),handle);
                break;
            case  MethodType.COMMON_METHOD_FRIEND:
                friendRoute.route(common.getBody(),handle);
                break;
            case MethodType.COMMON_METHOD_P2P_CONNECT:
                p2pRoute.route(common.getBody(),handle);
                break;
        }
    }catch (err){
        console.log(err);
    }

}

