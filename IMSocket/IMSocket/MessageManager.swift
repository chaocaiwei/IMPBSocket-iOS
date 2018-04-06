//
//  MessageManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/30.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit

protocol  MessageManagerDelegate {
    func manager(didReceive message:Message)
}

struct MessageHeader {
    var from : Int32?
    var fromInfo : UserInfo?
    var to : Int32?
    var toInfo : UserInfo?
    var timeTemp : TimeInterval?
    var type : EnumMsgContentType = .enumMsgContentTypeText
    
}

enum Message {
    case c2c(CommonMessage)
    case group(groupInfo:GroupInfo,CommonMessage)
}

enum CommonMessage {
    case text(header : MessageHeader?,text:String)
    case image(header : MessageHeader?,url:String)
}


class MessageManager {

    static let _instance = MessageManager()
    private init(){}
    static func shared()->MessageManager{  return _instance }
    typealias SentCompletion = (Bool)->(Void)
    var delegate : MessageManagerDelegate?
    func sent(to uid:Int32,text:String,completion:@escaping SentCompletion){
        do {
            let content = try MsgTextContent.Builder().setText(text).build().data()
            sent(to: uid, type:.enumMsgContentTypeText,content: content, completion: completion)
        } catch let err {
            print(err)
        }
    }
    
    func sent(to uid:Int32,type:EnumMsgContentType,content:Data,completion:@escaping SentCompletion){
        do {
            let c2cMsg = try C2CMsg.Builder().setType(type).setContent(content).setFrom(Int32(kCurrentUid)).setTo(uid).build().data()
            let msg = try BaseMsg.Builder().setType(.enumMsgTypeC2C).setBody(c2cMsg).build().data()
//            SocketManager.shared().sent(data: msg, type: .chart,completion: .message({ (isSuc) in
//                completion(isSuc)
//            }))
            P2PManager.shared().sent(data: msg, type: .chart) { (isSuc) in
                
            }
        } catch let err {
            print(err)
        }
    }
    
}

extension MessageManager  {
    func onReceive(msg: Data) {
        do {
            let msg = try BaseMsg.parseFrom(data: msg)
            switch msg.type   {
            case .enumMsgTypeC2C:
                let c2c = try C2CMsg.parseFrom(data: msg.body)
                let content = try MsgTextContent.parseFrom(data:c2c.content)
                switch (c2c.type){
                case .enumMsgContentTypeText:
                    let header = MessageHeader(from: c2c.from, fromInfo: c2c.fromInfo, to: c2c.to, toInfo: c2c.toInfo, timeTemp: 0, type: c2c.type)
                    let result  = Message.c2c(.text(header: header, text: content.text))
                    self.delegate?.manager(didReceive: result)
                    break;
                default:
                    break;
                }
                break;
            default:
                break;
            }
        } catch let err {
            print(err)
        }
    }
}

