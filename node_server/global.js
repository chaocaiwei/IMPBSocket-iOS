/**
 * Created by jztech-weichaocai on 2018/3/28.
 */

var socketMap  = {};
var sockeIdMap = {};
function getSocketId(sock) {
    var id = sock.remoteAddress + ":" + sock.remotePort
    return id
}

exports.cachSock = function(sock,uid){
    socketMap[uid] = sock
}

exports.sockWithUid = function (uid) {
    return socketMap[uid]
}
