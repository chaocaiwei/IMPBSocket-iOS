/**
 * Created by jztech-weichaocai on 2018/3/29.
 */


var loginRoute = require("./user"),
    friendRoute = require("./friendRoute"),
    messageRoute = require("./pullMessageRoute")
var ProtoBuf = require("protobufjs");
var builder = ProtoBuf.loadProtoFile("./impb/common.proto"),
    Common = builder.build("Common"),
    MethodType = builder.build("Common_method")
var app = require("../app")


exports.route = function(body,completion){


    try {
        var comon = Common.decode(body)
        switch (comon.method){
            case MethodType.user:
                loginRoute.route(comon.body,completion)
                break;
            case  MethodType.message:
                messageRoute.route(comon.body,completion)
                break;
            case  MethodType.friend:
                friendRoute.route(comon.body,completion)
                break;
        }
    }catch (err){
        console.log(err)
    }

}

