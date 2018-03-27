//
//  SocketManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/27.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import ProtocolBuffers

class SocketManager : NSObject {
    private override init(){
        super.init()
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
    }
    static let _ins = SocketManager()
    static func shared()->SocketManager{
        return _ins;
    }
    typealias SentMsgCompletion = (Root?,Error?)->Void
    let delegateQueue = DispatchQueue.global()
    var socket :GCDAsyncSocket!
    var uid : String?
    var token : String?
    var completionDic = [Int32:SentMsgCompletion]()
    var latestSeq  : Int32 = 0;
    
    
    private let comSem = DispatchSemaphore(value: 1)
    private func oprationCompletionDic(opration:()->()){
        comSem.wait()
        opration()
        comSem.signal()
    }
    
    func connect(toHost host:String , port:UInt16) throws {
        do {
            socket.delegate   = self
            try socket.connect(toHost: host, onPort: port)
            socket.readData(withTimeout: 999999, tag: 0)
        } catch let err {
            print(err)
            throw err
        }
    }
    
    func disconnect(){
        socket.disconnect()
    }
    
    func sent(root:Root,completion:@escaping SentMsgCompletion)  {
        oprationCompletionDic{
            do {
                let rootBuild =  try root.toBuilder()
                let header =  try root.header.toBuilder().setSeq(self.latestSeq).build()
                self.completionDic[self.latestSeq] = completion
                self.latestSeq  += 1;
                rootBuild.setHeader(header)
                self.sent(data: root.data())
            } catch let err {
                print(err)
            }
        }
    }
    
    private func sent(data:Data){
        self.socket.write(data, withTimeout: 999999, tag: 0)
    }
    
    
    
}


extension SocketManager : GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        do {
            let root = try Root.parseFrom(data: data)
            let seq = root.header.seq ?? 0
            let completion = self.completionDic[seq]
            if root.header.type == .enumRootTypeError{
                let err = try? Error.parseFrom(data: root.body)
                completion?(nil,err)
            }else{
                completion?(root,nil)
            }
        } catch let err {
            print(err);
        }
        
    }
    
    
}

