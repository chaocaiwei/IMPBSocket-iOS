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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            let head = try MsgHeader.Builder().setSeq(7888).setUid(788).setType(.enumRootTypeMessage).setMethod(.broadcast).setServer(.enumRootServerLogin).build()
            let body = try LoginReq.Builder().setNickName("faffa").setPwd("fds8899").build().data()
            let root = try Root.Builder().setHeader(head).setBody(body).build()
            let data = SocketDataPaser.shared().build(withType: .chart, body: root)
            let header = SocketDataPaser.shared().parse(data: data!)
            print(header);
        } catch let err {
            print(err)
        }
        
        
        
        
    }

    
    @IBAction func signin(_ sender: Any) {
        
        LoginManager.signin(user: self.nameFile.text ?? "", pwd: self.pwdFile.text ?? "") { (res, err) in
            if let res = res {
                
            }else{
                print(err)
            }
            
        }
        
       
        
        
    }
    
    @IBAction func login(_ sender: Any) {
        
        LoginManager.login(user: self.nameFile.text ?? "", pwd: self.pwdFile.text ?? "") { (res, err) in
            if let res = res {
                
            }else{
                print(err)
            }
            
        }
        
    }
    
    @IBAction func connetct(_ sender: Any) {
        do {
            try SocketManager.shared().connect(toHost: "127.0.0.1", port: 6969)
        }catch let err {
            print(err);
        }
    }
    
    @IBAction func disconnet(_ sender: Any) {
        SocketManager.shared().disconnect()
    }
    
    
    
    
}

