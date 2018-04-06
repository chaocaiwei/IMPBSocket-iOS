//
//  ViewController.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/27.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nameFile: UITextField!
    @IBOutlet weak var pwdFile: UITextField!
    @IBOutlet weak var connectStateLable: UILabel!
    @IBOutlet weak var seqLabel: UILabel!
    @IBOutlet weak var uidLable: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var ipTextFiled: UITextField!
    @IBOutlet weak var portTextfiled: UITextField!
    @IBOutlet weak var targetUidField: UITextField!
    @IBOutlet weak var groupFiled: UITextField!
    @IBOutlet weak var messageTextFiled: UITextView!
    @IBOutlet weak var receiveTextView: UITextView!
    @IBOutlet weak var loginStateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketManager.shared().connectdelegate  = self
        MessageManager.shared().delegate  = self
        
        DeviceHelper().getDeviceInfo()

        
        
    }

    
    @IBAction func signin(_ sender: Any) {
        
        LoginManager.signin(user: self.nameFile.text ?? "", pwd: self.pwdFile.text ?? "") { (res, err) in
            if let res = res {
                let uid = res.uid
                let token = res.token
                self.uidLable.text  = "\(uid!)"
                self.tokenLabel.text = "\(token!)"
            }else{
                print(err ?? "")
                self.logErr(err: err)
            }
            
        }
        
       
        
        
    }
    
    @IBAction func login(_ sender: Any) {
        
        LoginManager.login(user: self.nameFile.text ?? "", pwd: self.pwdFile.text ?? "") { (res, err) in
            if let res = res {
                let uid = res.uid
                let token = res.token
                self.uidLable.text  = "\(uid!)"
                self.tokenLabel.text = "\(token!)"
                self.loginStateLabel.text  = "已登录"
                
            }else{
                print(err)
                self.logErr(err: err)
            }
            
        }
        
    }
    
    func logErr(err:Any?){
        guard let err = err else {
            return
        }
        DispatchQueue.main.async {
            var text = self.receiveTextView.text ?? ""
            text  = text + "\n \(err) "
            self.receiveTextView.text  = text
        }
       
    }
    
    
    @IBAction func p2pAction(_ sender: Any) {
        P2PManager.shared().p2pConnect(uid: UInt32(self.targetUidField.text ?? "3") ?? 3)
    }
    
    
    @IBAction func connetct(_ sender: Any) {
        let host = self.ipTextFiled.text ?? "127.0.0.1"
        let port = UInt16(self.portTextfiled.text ?? "6969") ?? 6969
        SocketManager.shared().connect(toHost: host, port: port, completion:{ _ in })
    }
    
    @IBAction func disconnet(_ sender: Any) {
        SocketManager.shared().disconnect()
    }
    
    @IBAction func logout(_ sender: Any) {
        LoginManager.logout { (isSuc, err) in
            self.loginStateLabel.text  = "未登录"
        }
    }
    
    
    @IBAction func sentC2C(_ sender: Any) {
        let uid  = Int32(self.targetUidField.text ?? "") ?? 0
        let text = self.messageTextFiled.text ?? ""
        MessageManager.shared().sent(to: uid, text: text) { (isSuc) -> (Void) in
            DispatchQueue.main.async {
                var text = self.receiveTextView.text ?? ""
                text  = text + "\n 发送消息 uid=\(uid) \(isSuc ? "成功" : "失败")"
                self.receiveTextView.text  = text
            }
            
        }
        
        
        
    }
    
    @IBAction func sentGroup(_ sender: Any) {
        
    }
    
    @IBAction func broadcast(_ sender: Any) {
        
    }
    
    
    
}

extension ViewController : MessageManagerDelegate {
    func  manager(didReceive message:Message){
        DispatchQueue.main.async {
            switch (message){
                case .c2c(let contmsg):
                    switch (contmsg){
                    case .text(header: let header, text: let tex):
                        self.logErr(err:"\(header?.from ?? 10000) : \(tex)" )
                    default:break;
                    }
                    break;
            default:break;
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension ViewController : ConnectDelegate {
    func onConnectSuceess() {
        DispatchQueue.main.async {
            self.connectStateLable.text  = "已连接"
        }
    }
    
    func onFalseConnect() {
        DispatchQueue.main.async {
            self.connectStateLable.text  = "未连接"
        }
    }
    
    
}


