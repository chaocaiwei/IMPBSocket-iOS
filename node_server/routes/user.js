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
var LoginBuilder = ProtoBuf.loadProtoFile("./impb/user.proto"),
    SiginReq   = LoginBuilder.build("signin_req"),
    SiginRespon   = LoginBuilder.build("sigin_res"),
    LoginReq   = LoginBuilder.build("login_req"),
    LoginRespon   = LoginBuilder.build("login_res"),
    LogoutReq   = LoginBuilder.build("logout_req"),
    CommonRes   = LoginBuilder.build("common_res"),
    User_msg    = LoginBuilder.build("User_msg"),
    User_cmd    = LoginBuilder.build("User_cmd")
var ErrorBuilder = ProtoBuf.loadProtoFile("./impb/error.proto"),
    Error    = ErrorBuilder.build("Error");
var db = require("../dataBase")

var handle = {};




function handleLoginMsg(root,compl) {
    var req = LoginReq.decode(root.body);
    var name = req.nick_name;
    var pwd  = req.pwd ;
    db.userWithName(name,function (user,err) {
        if (user ){
            if (user.pwd != pwd){
                print(err)
                var err = Error.builder()
                err.msg  = "密码错误"
                if(compl){
                    compl(err)
                }
                return;
            }

            var res = new LoginRespon();
            res.token = user.token;
            res.uid   = user.uid;
            if(compl){
                compl(res,user.uid)
            }

        }else{
            print(err)
            var err = Error.builder()
            err.msg  = "用户不存在"
            if(compl){
                compl(err)
            }
        }

    })
}

function  handleSigninMsg(root,compl) {
    var req = SiginReq.decode(root.body);
    var name = req.nick_name;
    var pwd  = req.pwd;
    var token = Math.ceil(Math.random()*9999999) + "_" + name
    db.insertLoginInfo(name,pwd,token,function (err) {
        if(err){
            var errRes = Error.builder()
            errRes.msg  = err.toString()
            root.body  = errRes.toBuffer();
            root.header.type  = BaseType.enum_root_type_error
            sock.write(root.toBuffer());
            return
        }
        db.latestUserId(function (id) {
            var res = new SiginRespon();
            res.uid   = id;
            res.token = token.toString();
            if(compl){
                compl(res,id)
            }
        })
    })

}

function  handleLogoutMsg(root,compl) {
    var req = LogoutReq.decode(root.body);
    var name = req.nick_name;
    var pwd  = req.pwd;
    var user = {
        "online":0,
        "user_id":req.header.uid
    }
    db.updateUser(user)
    var res = new CommonRes();
    res.msg = "退出成功";
    if(compl){
        compl(res)
    }


}


exports.route = function (root,completion){

    var user = User_msg.decode(root);

    switch(user.cmd)  {
        case User_cmd.User_cmd_login:
            handleLoginMsg(user,completion)
            break;
        case User_cmd.User_cmd_sign_in:
            handleSigninMsg(user,completion)
            break;
        case User_cmd.User_cmd_logout:
            handleLogoutMsg(user,completion)
            break;
    }
};
