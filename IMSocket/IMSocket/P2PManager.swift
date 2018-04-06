//
//  P2PManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/4/2.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class P2PManager : NSObject {

    var p2pPort : Int32 {
        return Int32(56740 + kCurrentUid)
    }
    
    lazy var soket : GCDAsyncUdpSocket = {
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do{
            try sock.enableBroadcast(true) // 允许广播
            try sock.bind(toPort: UInt16(p2pPort))
            try sock.beginReceiving()
        }catch let errr{
            print(errr)
        }
        
        return sock
    }()

    static let _instance = P2PManager()
    private override init(){
        super.init()
        SocketManager.shared().notificationDelegate  = self
    }
    static func shared()->P2PManager {
        return _instance
    }
    
    var connectIp = [String:String]()
    var ip : String?
    var port : Int32?
    func connet(ip:String,port:Int32){
        self.startToPunch(ip: ip, port: port)
    }
    
    
    func listenOn(port:Int32){
        do{
            try soket.bind(toPort: UInt16(p2pPort))
            try soket.beginReceiving()
        }catch let errr{
            print(errr)
        }
    }
    
    
    func receiveConnectRequest(req:P2PReceiveConnectNotification){
        guard let uid = req.sponsorUid ,let ip = req.sponsorIp,let port = req.sponsorPort else{ return }
        listenOn(port: p2pPort)
        postIP(uid: uid,port: p2pPort)
        connet(ip: ip, port: port)
    }
    
    func connnetReadyNoti(noti:P2PConnectReadyNotification){
        guard let ip = noti.ip,let port = noti.port else {
            return
        }
        self.ip  = ip
        self.port  = port
        connet(ip: ip, port: port)
    }
    
    func sent(data:Data,type:BaseType,timeOut:TimeInterval = 30.0,completion:((Bool)->())? = nil)  {
        guard let sData = SocketDataBuilder.shared().build(withType: type, body:data) else { return }
        switch sData {
        case .sent(seq: let seq, data: let data):
            guard let ip = self.ip  , let port = self.port  else { return }
            self.soket.send(data, toHost: ip, port: UInt16(port), withTimeout: timeOut, tag: Int(seq))
            completion?(true)
            break
        default:
            break;
        }
        
    }
    
    func postIP(uid:UInt32,port:Int32){
        guard  let ip = DeviceHelper().getIPAddress(true) else { return }
        do {
            let req = try P2PPostIpRequest.Builder().setIp(ip).setPort(port).setUid(kCurrentUid).setSponsorUid(uid).build().data()
            let p2p = P2PConnect.Builder().setType(.enumP2PTypePostIp).setBody(req)
            let rreq = try requst(withBodyMsg: p2p, server: .commonMethodP2PConnect)
            SocketManager.shared().sent(data: rreq.data(), type: .requist, completion:.requist({ (data, err) in
                if let data = data,let res = try? P2PPostIpResponse.parseFrom(data: data) {
                    
                }else{
                    
                }
            }))
        } catch let err {
            print(err)
        }
    }
    
    func p2pConnect(uid:UInt32){
        guard  let ip = DeviceHelper().getIPAddress(true) else { return }
        do {
            let req = try P2PconnectRequest.Builder().setIp(ip).setPort(p2pPort).setUid(kCurrentUid).setTargetUid(uid).build().data()
            let p2p = P2PConnect.Builder().setType(.enumP2PTypeConnectRequest).setBody(req)
            let rreq = try requst(withBodyMsg: p2p, server: .commonMethodP2PConnect)
            SocketManager.shared().sent(data: rreq.data(), type: .requist, completion:.requist({ (data, err) in
                if let data = data,let res = try? P2PconnectResponse.parseFrom(data: data) {
                    if (res.isOnline == true){
                        self.listenOn(port: self.p2pPort)
                    }
                }else{
                    
                }
            }))
        } catch let err {
            print(err)
        }
        
    }
    
    
    private func startToPunch(ip:String,port:Int32){
        while true {
            self.sent(data: Data(), type: BaseType.ping) { (isSuc) in
                
            }
        }
    }
    
}


extension P2PManager : NotificationDelegate {
    func onReceive(noti: NotificationMsg) {
        guard let body = noti.body else {
            return
        }
        do {
            switch noti.type {
            case .enumNotificationTypeP2PConnectReady:
                let ready = try P2PConnectReadyNotification.parseFrom(data: body)
                self.connnetReadyNoti(noti: ready)
                break;
            case .enumNotificationTypeP2PReceiveConnectReq:
                let receiv = try P2PReceiveConnectNotification.parseFrom(data: body)
                self.receiveConnectRequest(req: receiv)
                break
            default:
                break
            }
        } catch let err {
            print(err)
        }
        
        
    }
    
    
    
    
}

extension P2PManager : GCDAsyncUdpSocketDelegate {
    @objc(udpSocket:didNotConnect:)
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: NSError?) {
        print("P2PManager udpSocket didNotConnect error=\(error)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("P2PManager didSendDataWithTag tag=\(tag)")
    }
    
    @objc(udpSocketDidClose:withError:)
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: NSError?) {
        print("P2PManager close sock error=\(error)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        let host = GCDAsyncUdpSocket.host(fromAddress: address)
        let port = GCDAsyncUdpSocket.port(fromAddress: address)
        print("P2PManager didConnectToAddress \(host ?? ""):\(port)")
    }
    
    @objc(udpSocket:didNotSendDataWithTag:dueToError:)
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: NSError?) {
        print("P2PManager didNotSendDataWithTag")
    }
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let msgArr = SocketDataBuilder.shared().parse(data: data)
        for (socketData) in msgArr {
            switch (socketData){
            case .receive(seq: let seq, type:let type,body: let body):
                switch type {
                case .chart:
                    handle(message: body, seq: seq)
                    break;
                case .ping:
                    handle(ping: data, seq: seq)
                    break;
                default:break;
                }
                break
            default:break
            }
        }
    }
    
    
    fileprivate func handle(message data:Data,seq:UInt32){
        MessageManager.shared().onReceive(msg: data)
    }
    
    fileprivate func handle(ping data:Data,seq:UInt32){
       
        
        
    }
    
    
}



