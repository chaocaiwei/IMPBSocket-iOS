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




protocol PingDelegate {
    func onReceivePing()
}

protocol NotificationDelegate {
    func onReceive(noti:NotificationMsg)
}

protocol ConnectDelegate {
    func onConnectSuceess()
    func onFalseConnect()
}

class SocketManager : NSObject {
    
    
    var pingDelegate : PingDelegate?
    var notificationDelegate : NotificationDelegate?
    var connectdelegate : ConnectDelegate?
    var host : String?
    var port : UInt16?
    var isConnected  = false
    
    private override init(){
        super.init()
    }
    static let _ins = SocketManager()
    static func shared()->SocketManager{
        return _ins;
    }
    
    enum SentMsgCompletion {
        case requist(((Data?,Error?)->Void))
        case message(((Bool)->Void))
        case ping(((Bool)->Void))
    }
    
    private let delegateQueue = DispatchQueue.global()
    private lazy var socket :GCDAsyncSocket = {
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
        return socket
    }()
    
    private var connectCompl : ((Bool)->Void)?
    private let comSem = DispatchSemaphore(value: 1)
    private var completionDic = [UInt32:SentMsgCompletion]()
    
    private func dispatchSentComepletion(withTag tag:UInt32,isSuc:Bool,root:Data?,error:Error?){

        guard let completion = self.completionDic[tag] else { return }
        
        DispatchQueue.main.async{
            switch completion {
            case .requist(let compl):
                if (root == nil && error == nil){ return }
                compl(root,error)
                break;
            case .message(let compl):
                compl(isSuc)
                break;
            case .ping(let compl):
                compl(isSuc)
                break
            }
            self.completionDic.removeValue(forKey: tag)
        }
    }
    
    func connect(toHost host:String , port:UInt16 ,completion:@escaping (Bool)->Void)  {
        do {
            self.connectCompl  = completion
            self.host  = host
            self.port = port
            socket.delegate   = self
            try socket.connect(toHost: host, onPort: port)
            socket.readData(withTimeout:-1, tag: 0)
        } catch let err {
            print(err)
            completion(false)
        }
    }
    
    func disconnect(){
        socket.disconnect()
    }
    
    func reconect(completion:@escaping (Bool)->Void) {
        guard let host = self.host , let port = self.port else {
            completion(false);
            return
        }
        self.connect(toHost: host, port: port,completion: completion)
    }
    
    func sent(data:Data,type:BaseType,completion:SentMsgCompletion)  {
        if self.isConnected == false {
            self.reconect(){[weak self] isSuc in
                if(isSuc){
                    self?._sent(data: data, type: type, completion: completion)
                }else{
                    switch (completion){
                    case .requist(let compl):
                        let err = try? Error.Builder().setType(.comomErr).setMsg("连接失败").build()
                        compl(nil,err)
                    case .message(let compl):
                        compl(false)
                    case .ping(let compl):
                        compl(false)
                    }
                }
            }
        }else{
            self._sent(data: data, type: type, completion: completion)
        }
    }
    
    func _sent(data:Data,type:BaseType,completion:SentMsgCompletion)  {
        guard let sData = SocketDataBuilder.shared().build(withType: type, body:data) else { return }
        switch sData {
        case .sent(seq: let seq, data: let data):
            self.completionDic[seq] = completion
            self.sent(data: data,tag:Int(seq))
            break
        default:
            break;
        }
    }
    
    private func sent(data:Data,tag:Int){
        self.socket.write(data, withTimeout:5 * 60, tag: 0)
    }
    
}


extension SocketManager : GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let msgArr = SocketDataBuilder.shared().parse(data: data)
        for (socketData) in msgArr {
            switch (socketData){
            case .receive(seq: let seq, type:let type,body: let body):
                switch type {
                case .requist:
                    handle(respon: body, seq: seq)
                    break;
                case .chart:
                    handle(message: body, seq: seq)
                    break;
                case .ping:
                    handle(ping: data, seq: seq)
                    break;
                case .notification:
                    handle(notification: body, seq: seq)
                    break;
                }
                break
            default:break
            }
        }
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
        print("socket \(sock) didWriteDataWithTag \(tag)")
        dispatchSentComepletion(withTag: UInt32(tag), isSuc: true, root: nil, error: nil)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        self.connectdelegate?.onConnectSuceess()
        self.connectCompl?(true)
        self.isConnected = true
        print("socket \(sock) didConnectToHost \(host) port \(port)")
    }
    
    
    @objc(socketDidDisconnect:withError:)
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: NSError?) {
        self.connectdelegate?.onFalseConnect()
        self.connectCompl?(false)
        self.isConnected  = false
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
        let err = try? Error.Builder().setType(ErrorType.invalidParams).setMsg("请求超时").build()
        dispatchSentComepletion(withTag: UInt32(tag), isSuc: false, root: nil, error: err)
        return -1
    }
    
}

/// MARK  private mathod
extension SocketManager{
    fileprivate func handle(respon data:Data,seq:UInt32){
        do {
            let respon = try CommonRespon.parseFrom(data: data)
            dispatchSentComepletion(withTag: seq,isSuc: respon.error == nil, root: respon.respon, error: respon.error)
        } catch let err {
            print(err)
        }
    }
    
    fileprivate func handle(message data:Data,seq:UInt32){
        MessageManager.shared().onReceive(msg: data)
    }
    
    fileprivate func handle(ping data:Data,seq:UInt32){
        self.pingDelegate?.onReceivePing()
    }
    
    fileprivate func handle(notification data:Data,seq:UInt32){
        do {
            let noti =  try NotificationMsg.parseFrom(data: data)
            self.notificationDelegate?.onReceive(noti: noti)
            P2PManager.shared().onReceive(noti: noti)
        } catch let err {
            print(err)
        }
        
    }
    
}


