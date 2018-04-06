/**
 * Created by jztech-weichaocai on 2018/3/28.
 */

var socketMap  = {};
var sockIdMap  = {};
function getSockId(sock) {
    return sock.remoteAddress + ':' + sock.remotePort
}

function getSocketId(sock) {
    var id = sock.remoteAddress + ":" + sock.remotePort
    return id
}

exports.cachSock = function(sock,user){
    var id = getSocketId(sock)
    var dic = {}
    dic["user"] = user
    dic["sock"] = sock
    dic["time_temp"]  = new Date().getTime()
    socketMap[id] = dic
    sockIdMap[user.user_id] = id
}

exports.sockWithUid = function (uid) {
    var sid = sockIdMap[uid]
    var sockDic = socketMap[sid]
    if (sockDic){
        return sockDic.sock
    }
    return undefined
}

exports.latestBeatWithSock =function(sock){
    var id = getSocketId(sock)
    var dic = socketMap[id]
    return dic ? dic.time_temp : undefined
}

exports.beatWithUid = function (uid) {
    var sid = sockIdMap[uid]
    var dic = socketMap[sid]
    return dic ? dic.time_temp : undefined
}

exports.beatWithSock = function(sock){
    var id = getSocketId(sock)
    var dic = socketMap[id]
    return dic ? dic.time_temp : undefined
}

exports.uidWithSock  = function (sock) {
    var id = getSocketId(sock)
    var dic = socketMap[id]
    if(dic && dic.user && dic.user.user_id){
        return dic.user.user_id
    }else {
        return undefined
    }
}

exports.offlineWithSock = function (sock) {
    var id = getSocketId(sock)
    socketMap[id] = undefined
}
