//
//  SocketDataPaser.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/28.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import ProtocolBuffers

let margic_num : UInt8 = 0b10000001
let header_length : Int  = 8
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
        var seq   : UInt32
        var type  : BaseType
        var lenth : UInt16
    }
    
    
    class _Parser {
        var header : BaseHeader?
        var body   : GeneratedMessage?
        var seq    : UInt32?
        var data   : Data?
        
        init(data:Data) {
            self.data  = data
        }
        
        init(type:BaseType,seq:UInt32,body:GeneratedMessage) {
            self.body    = body
            let header   = BaseHeader(seq:seq, type: type, lenth: UInt16(body.data().count))
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
            
            let bodyData = data[header_length..<(Int(header.lenth) + header_length)]
            do {
                self.body    = try SiginRes.parseFrom(data: bodyData)
                self.data  = data.dropFirst(Int(header.lenth) + header_length)
            } catch let err {
                print(err)
                return false
            }
            return true
        }
        
        /**
         8个字节
         margic_num 魔法数字  头部标识 0b10000001
         legth 包体长度 两个字节  无符号整型unsigned short
         type  消息类型 一个字节  0心跳包 1普通数据请求 2聊天消息 3推送
         ***/
        private func getHeader(from data:Data)->BaseHeader?{
            if data.count < header_length {
                return nil
            }
            var headerData  = data[0..<header_length]
            let tag : UInt8 = headerData[0..<1].withUnsafeBytes{ $0.pointee }
            if tag != margic_num {
                return nil
            }
            let seq : UInt32 = headerData[1..<5].withUnsafeBytes({$0.pointee })
            let typeValue : UInt8  =  headerData[5..<6].withUnsafeBytes({$0.pointee })
            let length : UInt16    =  headerData[6..<8].withUnsafeBytes({$0.pointee })
            let type  = BaseType(rawValue: typeValue.bigEndian)!
            let head = BaseHeader(seq: seq.bigEndian, type: type, lenth: length.bigEndian)
            return head
        }
        
        func build(withHeader header:BaseHeader)->Data {
            
            var data = Data()
            var marg = margic_num.bigEndian
            var seq  = header.seq.bigEndian
            var type = header.type.rawValue.bigEndian
            var length = header.lenth.bigEndian
            
            let mp = UnsafeBufferPointer(start: &marg, count: 1)
            let sp = UnsafeBufferPointer(start: &seq, count: 1)
            let tp = UnsafeBufferPointer(start: &type, count: 1)
            let lp = UnsafeBufferPointer(start: &length, count: 1)
           
            data.append(mp)
            data.append(sp)
            data.append(tp)
            data.append(lp)
            
            return data
            
        }
        
        
    }
    
    
    
    func build(withType type:BaseType,seq:UInt32,body:GeneratedMessage)->Data?{
        return _Parser(type: type,seq:seq, body: body).data
    }
    
    func parse(data:Data)->[(BaseHeader?,GeneratedMessage?)]{
        var result:[(BaseHeader?,GeneratedMessage?)] = []
        let paser = _Parser(data: data)
        while paser.parse() {
            result.append((paser.header,paser.body))
        }
        return result
    }
    
    
}
