//
//  SocketDataPaser.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/28.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit


let margic_num : UInt8 = 0b10000001
let header_length : Int  = 4
class SocketDataPaser {

    static let _instance = SocketDataPaser()
    static func shared()->SocketDataPaser{
        return _instance
    }
    
    enum BaseType : UInt8 {
        case ping = 1
        case requist = 2
        case chart = 3
        case notification = 4
    }
    
    struct BaseHeader {
        var type : BaseType
        var lenth : UInt16
    }
    
    
    class _Parser {
        var header : BaseHeader?
        var body   : Root?
        var data   : Data?
        
        init(data:Data) {
            self.data  = data
        }
        
        init(type:BaseType,body:Root) {
            self.body    = body
            let header   = BaseHeader(type: type, lenth: UInt16(body.data().count))
            self.header  = header
            var data = build(withHeader: header)
            let bodyData = body.data()
            data.append(bodyData)
            self.data  = data
        }
        
        func parse()->Bool{
            guard let data = self.data  else {
                return false
            }
            guard let header  = getHeader(from: data) else {
                return false
            }
            self.header  = header
            let bodyData = data.subdata(in: header_length..<(Int(header.lenth) + header_length))
            self.body    = try? Root.parseFrom(data: bodyData)
            self.data  = data.dropFirst(Int(header.lenth) + header_length)
            return true
        }
        
        /**
         4个字节
         margic_num 魔法数字  头部标识 0b10000001
         legth 包体长度 两个字节  无符号整型unsigned short
         type  消息类型 一个字节  0心跳包 1普通数据请求 2聊天消息 3推送
         ***/
        private func getHeader(from data:Data)->BaseHeader?{
            if data.count < header_length {
                return nil
            }
            var headerData = data.subdata(in: 0..<4)
            var tag :  UInt8 = 0
            headerData.copyBytes(to: &tag, count: 1)
            headerData = headerData.dropFirst()
            if tag != margic_num {
                return nil
            }
            var typeValue : UInt8 = 0
            headerData.copyBytes(to: &typeValue, count: 1)
            headerData = headerData.dropFirst()
            let type = BaseType(rawValue:typeValue)!
            
            let length : UInt16  = headerData.withUnsafeMutableBytes { (prt:UnsafeMutablePointer<UInt16>) -> UInt16 in
                return prt[0]
            }
            let head = BaseHeader(type: type, lenth: length)
            
            return head
        }
        
        func build(withHeader header:BaseHeader)->Data {
            var data = Data()
            var marg = margic_num
            data.append(UnsafeBufferPointer<UInt8>.init(start: &marg, count: 1))
            var type = header.type.rawValue
            data.append(UnsafeBufferPointer<UInt8>.init(start: &type, count: 1))
            var length = header.lenth
            let point = UnsafeBufferPointer<UInt16>.init(start: &length, count: 1)
            data.append(point)
            return data
        }
        
        
    }
    
    
    
    func build(withType type:BaseType,body:Root)->Data?{
        return _Parser(type: type, body: body).data
    }
    
    func parse(data:Data)->[(BaseHeader?,Root?)]{
        var result:[(BaseHeader?,Root?)] = []
        let paser = _Parser(data: data)
        while paser.parse() {
            result.append((paser.header,paser.body))
        }
        return result
    }
    
    
}
