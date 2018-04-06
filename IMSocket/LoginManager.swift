//
//  LoginManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/27.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import ProtocolBuffers


var kCurrentUid : UInt32 = 1;
func requst(withBodyMsg body:GeneratedMessageBuilder,server:CommonMethod) throws ->Common {
    do {
        let bodyData = try body.build().data()
        let comom = try Common.Builder().setMethod(server).setBody(bodyData).build()
        return comom;
    } catch let err {
        print(err)
        throw err
    }
}


class LoginManager {
    
    static func userReq(withBodyMsg body:GeneratedMessageBuilder,server:UserCmd) throws ->(data:Data,type:BaseType) {
        do {
            let bodyData = try body.build().data()
            let user  =  try UserMsg.Builder().setCmd(server).setBody(bodyData).build().data()
            let comom =  try Common.Builder().setMethod(.commonMethodUser).setBody(user).build().data()
            return (comom,.requist)
        } catch let err {
            print(err)
            throw err
        }
    }
    
    static func login(user:String,pwd:String,completion:@escaping (LoginResponse?,Error?)->Void){
        let ip = DeviceHelper().getIPAddress(true)!
        let port = P2PManager.shared().p2pPort
        let loginReq = LoginRequest.Builder().setPwd(pwd).setNickName(user).setIp(ip).setPort(port)
        guard let req = try? userReq(withBodyMsg: loginReq, server: .userCmdLogin) else { return }
        SocketManager.shared().sent(data: req.data, type: req.type,completion: .requist({ (res, err) in
            if let data = res, let res = try? LoginResponse.parseFrom(data: data){
                kCurrentUid  = res.uid
                PingManager.shared().start()
                completion(res,nil)
            }else{
                completion(nil,err)
            }
        }))
    }
    
    static func signin(user:String,pwd:String,completion:@escaping (SiginResponse?,Error?)->Void){
        let loginReq = SigninRequest.Builder().setPwd(pwd).setNickName(user)
        guard let req = try? userReq(withBodyMsg: loginReq,
                                    server: UserCmd.userCmdSignIn)  else { return }
        SocketManager.shared().sent(data: req.data, type: req.type , completion: .requist({ (res, err) in
            if let data = res, let res = try? SiginResponse.parseFrom(data: data) {
                kCurrentUid  = res.uid
                PingManager.shared().start()
                completion(res,nil)
            }else{
                completion(nil,err)
            }
        }))
    }
    
    static func logout(completion:@escaping (Bool,Error?)->Void){
        let loginReq = LogoutRequest.Builder()
        guard let req = try? userReq(withBodyMsg: loginReq,server:.userCmdLogout) else { return }
        SocketManager.shared().sent(data: req.data, type: req.type ,completion: .requist({ (res, err) in
            PingManager.shared().finish()
            if err == nil  {
                completion(true,nil)
            }else{
                completion(false,err)
            }
        }))
    }
    

    
}
