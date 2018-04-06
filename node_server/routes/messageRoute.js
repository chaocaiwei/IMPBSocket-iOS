/**
 * Created by jztech-weichaocai on 2018/3/29.
 */

var ProtoBuf = require("protobufjs");
var builder = require("../impb/message_pb"),
    Message = builder.base_msg
    ContentType = builder.enum_msg_content_type
var C2CMsg  = builder.C2C_msg
var Group_msg  = builder.Group_msg
var Msg_type   = builder.enum_msg_type

exports.route = function(body,completion){

    try {
        var message = Message.decode(body)
        var subBody  = message.body;
        switch (message.type){
            case Msg_type.ENUM_MSG_TYPE_C2C:
                var cmessage = C2CMsg.decode(subBody);
                var uid = cmessage.to
                completion([uid])
                break;
            case Msg_type.ENUM_MSG_TYPE_GROUP:
                var gmsg = Group_msg.decode(subBody);
                var uids = allUidInGroup(gmsg.group_id)
                break;
            case Msg_type.ENUM_MSG_TYPE_BROACAST:
                break;
            case Msg_type.ENUM_MSG_CUSTOM:
                break;
        }
    }catch(err) {

    }

}


function completion(uids) {
    for (var i = 0;i < uids.length;i++ ){
        var uid = uids[i]
        var tsock = global.sockWithUid(uid)
        if(tsock){
            tsock.write(data)
        }else{
            // 离线消息处理
        }
    }
}

function allUidInGroup(groupid) {

    return [groupid]
}


function  handle() {

}