/**
 * Created by jztech-weichaocai on 2018/3/27.
 */

var ProtoBuf = require("protobufjs");
var builder = ProtoBuf.loadProtoFile("./impb/root.proto"),
    Root   = builder.build("root"),
    Header   = builder.build("msg_header"),
    UserInfo = builder.build("user_info"),
    BaseType = builder.build("enum_root_type"),
    BaseServer = builder.build("enum_root_server");
    SeverMethod = builder.build("enum_server_method");
var LoginBuilder = ProtoBuf.loadProtoFile("./impb/login.proto"),
    SiginReq   = LoginBuilder.build("signin_req"),
    SiginRespon   = LoginBuilder.build("sigin_res"),
    LoginReq   = LoginBuilder.build("login_req"),
    LoginRespon   = LoginBuilder.build("login_res"),
    LogoutReq   = LoginBuilder.build("logout_req"),
    CommonRes   = LoginBuilder.build("common_res");

var handle = {};

var latestUid = 1;



function headerWithType(server,method) {
    var header = new Header();
    header.server  = server;
    header.type    = BaseType.enum_root_type_respond;
    header.method  = method;
}

function responWithBody(body,server,method) {
    var root = new Root();
    root.header = headerWithType(server,method);
    root.body  = body.toBuffer();
    return root;
}


function handleLoginMsg(reqData) {
    var req = LoginReq.decode(reqData);
    var name = req.nick_name;
    var pwd  = req.pwd ;


    var res = new LoginRespon();
    res.token = name + "_" + pwd ;
    res.uid   = latestUid + "";
    latestUid++;

    return responWithBody(res)
}

function  handleSigninMsg(reqData) {
    var req = SiginReq.decode(reqData);
    var name = req.nick_name;
    var pwd  = req.pwd ;

    var res = new SiginRespon();
    res.token = name + "_" + pwd ;
    res.uid   = latestUid + "";
    latestUid++;

    return responWithBody(res)
}

function  handleLogoutMsg(reqData) {
    var req = LogoutReq.decode(reqData);
    var name = req.nick_name;
    var pwd  = req.pwd ;

    var res = new CommonRes();
    res.msg = "退出成功";

    return responWithBody(res)
}


exports.handleReq = function (reqData,method){

    switch(method)  {
        case SeverMethod.login:
            return handleLoginMsg(reqData)
            break;
        case SeverMethod.signin:
            return handleSigninMsg(reqData)
            break;
        case SeverMethod.logout:
            return handleLogoutMsg(reqData)
            break;
    }
};


exports  = handle;