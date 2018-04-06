//
//  SocketDataPaser.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/28.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import ProtocolBuffers

enum SocketData {
    case sent(seq:UInt32,data:Data)
    case receive(seq:UInt32,type:BaseType,body:Data)
}

enum BaseType : UInt8 {
    case ping = 1
    case requist = 2
    case chart = 3
    case notification = 4
}

fileprivate let margic_num : UInt8 = 0b10000001
fileprivate let header_length : Int  = 8
class SocketDataBuilder {

    static let _instance = SocketDataBuilder()
    static func shared()->SocketDataBuilder{
        return _instance
    }
    
    struct BaseHeader {
        var seq   : UInt32
        var type  : BaseType
        var lenth : UInt16
    }
    
    
    class _Parser {
        var header : BaseHeader?
        var body   : Data?
        var data   : Data?
        var ptrIndex : Int = 0
        init(data:Data) {
            self.data  = Data(data)
        }
        
        init(type:BaseType,body:Data) {
            self.body    = body
            let seq      =  arc4random();
            let header   = BaseHeader(seq:seq, type: type, lenth: UInt16(body.count))
            self.header  = header
            var data = build(withHeader: header)
            data.append(body)
            self.data  = data
        }
        
        func parse()->Bool{
            guard let data = self.data  else {
                return false
            }
            if data.count < header_length {
                return false
            }
            if self.ptrIndex >= data.count {
                return false
            }
            let headerData = data[ptrIndex..<(ptrIndex+header_length)]
            guard let header  = getHeader(from: headerData) else {
                return false
            }
            self.header  = header
            ptrIndex += header_length
            let end   = ptrIndex + Int(header.lenth)
            if end <= data.count {
                let bodyData = data[ptrIndex..<end]
                self.body    = bodyData
                ptrIndex     += Int(header.lenth)
                return true
            }else{
                return false
            }
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
            var headerData  = Data(data)
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
    
    func build(withType type:BaseType,body:Data)->SocketData?{
        let parser = _Parser(type: type, body: body)
        if let data = parser.data, let seq = parser.header?.seq {
            return .sent(seq: seq, data: data)
        }
        return nil
    }
    
    func parse(data:Data)->[SocketData]{
        var result:[SocketData] = []
        let paser = _Parser(data: data)
        while paser.parse() {
            if let seq = paser.header?.seq ,let body = paser.body,let type = paser.header?.type {
                let data = SocketData.receive(seq:seq,type:type,body:body)
                result.append(data)
            }
        }
        return result
    }
    
    
}
