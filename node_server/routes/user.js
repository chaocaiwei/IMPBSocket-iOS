/**
 * Created by jztech-weichaocai on 2018/3/27.
 */

var logger = require('../log').logger('user');
var LoginBuilder =  require("../impb/user_pb");
var SiginReq = LoginBuilder.sigin_response;  // request response
var SiginRespon   = LoginBuilder.sigin_response;
var LoginReq   = LoginBuilder.login_request;
var LoginRespon   = LoginBuilder.login_response;
var LogoutReq   = LoginBuilder.logout_request;
var CommonRes   = LoginBuilder.common_response;
var User_msg    = LoginBuilder.User_msg;
var User_cmd    = LoginBuilder.User_cmd;
var ErrorBuilder = require("../impb/error_pb");
var SocketError    = ErrorBuilder.Error;
var db = require("../dataBase");
var global = require("../global");


function handleLoginMsg(root,sock,compl) {
    var req =  LoginReq.deserializeBinary(root.getBody()) ;
    var name = req.getNickName();
    var pwd  = req.getPwd();
    logger.info("login with name=" + name + " pwd=" + pwd);
    db.userWithName(name,function (user,err) {
        if(!user || err){
            var newerr = new SocketError();
            newerr.setMsg("" + err);
            logger.error("login query user with name error " + err);
            if(compl){
                compl(false,newerr)
            }
            return;
        }
        if (!user.length){
            var newer = new SocketError();
            newer.setMsg( "用户不存在");
            logger.error("login error 用户不存在");
            if(compl){
                compl(false,newer)
            }
            return
        }

        var curUser = user[0];
        if (curUser.pwd !== pwd){
            var newErr = new SocketError();
            newErr.setMsg("密码错误")
            logger.error("login  error " + "密码错误");
            if(compl){
                compl(false,newErr)
            }
            return;
        }

        var ip   = req.getIp();
        var port = req.getPort();
        var sock_ip = sock.remoteAddress;
        var sock_port = sock.remotePort;
        var user = {
            "user_id":curUser.user_id,
            "online":0,
            "socket_ip":sock_ip,
            "sock_port":sock_port,
            "port":port,
            "ip":ip
        };

        db.updateUser(user);
        global.cachSock(sock,user)
        var res = new LoginRespon()
        res.setToken(curUser.token);
        res.setUid(curUser.user_id);
        logger.info("login  sucess " + "token=" + res.getToken() + " uid=" + res.getUid() );
        if(compl){
            compl(true,res,curUser.user_id)
        }


    })
}

function  handleSigninMsg(root,compl) {
    var req = new SiginReq.deserializeBinary(root.getBody());
    var name = req.getNickName();
    var pwd  = req.getPwd();
    var token = Math.ceil(Math.random()*9999999) + "_" + name;
    db.userWithName(name,function (user) {
        if( user && user.length){
            var errRes = new SocketError();
            errRes.setMsg("用户已存在");
            errRes.setType(1);
            logger.error("login error 用户已存在");
            compl(false,errRes);
        }else{
            db.insertLoginInfo(name,pwd,token,function (err) {
                if(err){
                    var errRes = new SocketError();
                    errRes.setMsg(err + "");
                    compl(false,errRes);
                    logger.error("login insert user error " + errRes)
                }else{
                    var res = new SiginRespon();
                    logger.info("login suceess with name=" + name);
                    compl(true,res);
                }
            })

        }
    })



}

function  handleLogoutMsg(root,compl) {
    var req =  LogoutReq.deserializeBinary(root.getBody());
    var name = req.getNickName();
    var pwd  = req.getPwd();
    var user = {
        "online":0,
        "user_id":req.header.uid
    };
    db.updateUser(user);
    var res = new CommonRes();
    res.setMsg("退出成功");
    logger.info("退出成功");
    if(compl){
        compl(true,res);
    }


}


exports.route = function (root,sock,completion){

    var user =  User_msg.deserializeBinary(root);

    switch(user.getCmd())  {
        case User_cmd.USER_CMD_LOGIN:
            handleLoginMsg(user,sock,completion);
            break;
        case User_cmd.USER_CMD_SIGN_IN:
            handleSigninMsg(user,completion);
            break;
        case User_cmd.USER_CMD_LOGOUT:
            handleLogoutMsg(user,completion);
            break;
    }
};
