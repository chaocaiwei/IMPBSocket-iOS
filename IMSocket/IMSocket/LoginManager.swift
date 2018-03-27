//
//  LoginManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/27.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import ProtocolBuffers

func requst(withBodyMsg body:GeneratedMessageBuilder,server:EnumRootServer,methd:EnumServerMethod) throws ->Root {
    do {
        let header = try MsgHeader.Builder()
            .setType(.enumRootTypeRequest).setServer(server).setMethod(methd).build()
        let tdata  = try body.build().data()
        let msg   = try Root.Builder().setBody(tdata).setHeader(header).build()
        return msg;
    } catch let err {
        print(err)
        throw err
    }
}

class LoginManager {

    static func login(user:String,pwd:String,completion:@escaping (LoginRes?,Error?)->Void){
        let loginReq = LoginReq.Builder().setPwd(pwd).setNickName(user)
        guard let req = try? requst(withBodyMsg: loginReq,server: .enumRootServerLogin, methd: .login) else { return }
        SocketManager.shared().sent(root: req) { (res, err) in
            if let res = res {
                let  loginRes  = try? LoginRes.parseFrom(data: res.body)
                completion(loginRes,nil)
            }else{
                completion(nil,err)
            }
        }
    }
    
    static func signin(user:String,pwd:String,completion:@escaping (SiginRes?,Error?)->Void){
        let loginReq = SigninReq.Builder().setPwd(pwd).setNickName(user)
        guard let req = try? requst(withBodyMsg: loginReq,
                                    server: .enumRootServerLogin,
                                    methd: .signin)  else { return }
        SocketManager.shared().sent(root: req) { (res, err) in
            if let res = res {
                let  loginRes  = try? SiginRes.parseFrom(data: res.body)
                completion(loginRes,nil)
            }else{
                completion(nil,err)
            }
        }
    }
    
    static func logout(completion:@escaping (CommonRes?,Error?)->Void){
        let loginReq = LogoutReq.Builder()
        guard let req = try? requst(withBodyMsg: loginReq,server: .enumRootServerLogin, methd: .logout) else { return }
        SocketManager.shared().sent(root: req) { (res, err) in
            if let res = res {
                let  loginRes  = try? CommonRes.parseFrom(data: res.body)
                completion(loginRes,nil)
            }else{
                completion(nil,err)
            }
        }
    }
    
    
}
