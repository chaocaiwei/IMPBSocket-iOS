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
    var latestSeq  : Int32 = 1;
    
    private let comSem = DispatchSemaphore(value: 1)
    // 添加发送数据的回调函数到派发表里
    // @raturn completion对应的seq 队列顺序标识
    private func add(sentCompletion completion:@escaping SentMsgCompletion)->Int32{
        comSem.wait()
        let tamp = self.latestSeq;
        self.completionDic[tamp] = completion
        self.latestSeq  += 1;
        comSem.signal()
        return tamp
    }
    
    private func dispatchSentComepletion(withTag tag:Int,root:Root,error:Error){
        comSem.wait()
        let completion = self.completionDic[root.header.seq]
        completion?(root,error)
        comSem.signal()
    }
    
    func connect(toHost host:String , port:UInt16) throws {
        do {
            socket.delegate   = self
            try socket.connect(toHost: host, onPort: port)
            socket.readData(withTimeout:-1, tag: 0)
        } catch let err {
            print(err)
            throw err
        }
    }
    
    func disconnect(){
        socket.disconnect()
    }
    
    func sent(root:Root,completion:@escaping SentMsgCompletion)  {
        do {
            let seq = add(sentCompletion: completion)
//            var data = try root.getBuilder().header.getBuilder().setSeq(seq).build().data()
            let data = SocketDataPaser.shared().build(withType: SocketDataPaser.BaseType.chart, body: root)!
            self.sent(data: data,tag:0)
        } catch let err {
            print(err)
        }
    }
    
    private func sent(data:Data,tag:Int){
        self.socket.write(data, withTimeout:5 * 60, tag: 0)
    }
    
}


extension SocketManager : GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        do {
            let root = try Root.parseFrom(data: data)
            let err = try Error.parseFrom(data: root.body)
            dispatchSentComepletion(withTag: tag, root: root, error: err)
        } catch let err {
            print(err);
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        print("socket \(sock) didConnectTo \(url)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("socket \(sock) didWriteDataWithTag \(tag)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("socket \(sock) didConnectToHost \(host) port \(port)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("socket \(sock) didAcceptNewSocket \(newSocket) ")
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        print("socket \(sock) didReadPartialDataOfLength \(partialLength)  tag\(tag)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        print("socket \(sock) didWritePartialDataOfLength \(partialLength)  tag\(tag)")
    }
    
    func socketDidSecure(_ sock: GCDAsyncSocket) {
        print("socketDidSecure \(sock)")
    }
    
    func socketDidCloseReadStream(_ sock: GCDAsyncSocket) {
        print("socketDidCloseReadStream \(sock)")
    }
    
    
    @objc(socketDidDisconnect:withError:)
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: NSError?) {
        print("socketDidCloseReadStream \(sock) withError ")
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        print("socket \(sock) didReceive trust \(trust)  ")
        completionHandler(true)
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        print("socket \(sock) shouldTimeoutReadWithTag  \(tag)  elapsed \(elapsed) bytesDone \(length)")
        return -1
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        print("socket \(sock) shouldTimeoutWriteWithTag  \(tag)  elapsed \(elapsed) bytesDone \(length)")
        return -1
    }
    
    
    
}

