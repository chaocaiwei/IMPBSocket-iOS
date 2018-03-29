//
//  LoginManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/27.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import ProtocolBuffers


var kCurrentUid : UInt32?;
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
    
   static func requstUser(withBodyMsg body:GeneratedMessageBuilder,server:UserCmd) throws ->Common {
        do {
            let bodyData = try body.build().data()
            let user =  UserMsg.Builder().setCmd(server).setBody(bodyData)
            return try requst(withBodyMsg: user, server: .user)
        } catch let err {
            print(err)
            throw err
        }
    }
    
    static func login(user:String,pwd:String,completion:@escaping (LoginRes?,Error?)->Void){
        let loginReq = LoginReq.Builder().setPwd(pwd).setNickName(user)
        guard let req = try? requst(withBodyMsg: loginReq,server: .user) else { return }
        SocketManager.shared().sent(msg: req) { (res, err) in
            if let res = res as? LoginRes {
                completion(res,nil)
            }else{
                completion(nil,err)
            }
        }
    }
    
    static func signin(user:String,pwd:String,completion:@escaping (SiginRes?,Error?)->Void){
        let loginReq = SigninReq.Builder().setPwd(pwd).setNickName(user)
        guard let req = try? requstUser(withBodyMsg: loginReq,
                                    server: UserCmd.userCmdSignIn)  else { return }
        SocketManager.shared().sent(msg: req) { (res, err) in
            if let res = res as? SiginRes {
                completion(res,nil)
            }else{
                completion(nil,err)
            }
        }
    }
    
    static func logout(completion:@escaping (Bool,Error?)->Void){
        let loginReq = LogoutReq.Builder()
        guard let req = try? requst(withBodyMsg: loginReq,server: .user) else { return }
        SocketManager.shared().sent(msg: req) { (res, err) in
            if err == nil  {
                completion(true,nil)
            }else{
                completion(false,err)
            }
        }
    }
    
    
}
