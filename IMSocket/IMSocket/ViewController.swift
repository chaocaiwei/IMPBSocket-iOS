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
        
        
        
        
        
    }

    
    @IBAction func signin(_ sender: Any) {
        
        guard let req = RequstBuilder.signinRequest(withUser: self.nameFile.text ?? "", pwd: self.pwdFile.text ?? "") else { return }
        SocketManager.shared().sent(root: req, completion: { (respon,err)  in
            
        })
        
        
    }
    
    @IBAction func login(_ sender: Any) {
        
        guard let req = RequstBuilder.loginRequest(withUser: self.nameFile.text ?? "", pwd: self.pwdFile.text ?? "") else { return }
        SocketManager.shared().sent(root: req, completion: { (respon,err) in
            
        })
        
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

