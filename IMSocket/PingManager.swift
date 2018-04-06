//
//  PingManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/30.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit

class PingManager {

    private let pingDuration : TimeInterval  = 10
    private let pingTimeOut  : TimeInterval  = 30
    static let _instance = PingManager()
    private init(){}
    static func shared()->PingManager {  return _instance }
    var latestBeatTime : TimeInterval = 0
    
    lazy var timer : Timer = {
        let timer = Timer(timeInterval:pingDuration , repeats: true, block: {[weak self] (timer) in
            guard let ss = self else { return }
            self?.timerHandle()
        })
        return timer
    }()
    
    func timerHandle(){
        let now = Date().timeIntervalSince1970
        if now - self.latestBeatTime  > self.pingTimeOut {
            self.finish()
            SocketManager.shared().disconnect()
        }else{
            self.sentPing()
        }
    }
    
    private func sentPing(){
        SocketManager.shared().sent(data: Data(), type: .ping, completion: SocketManager.SentMsgCompletion.ping({ (isSuc) in }))
        SocketManager.shared().pingDelegate  = self
    }
    
    func start(){
        sentPing()
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    func finish(){
        if timer.isValid {
            timer.invalidate()
        }
        SocketManager.shared().pingDelegate = nil
    }
    
}

extension PingManager : PingDelegate {
    func onReceivePing() {
        latestBeatTime  = Date().timeIntervalSince1970
    }
}

