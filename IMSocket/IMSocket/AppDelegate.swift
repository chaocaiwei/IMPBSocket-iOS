//
//  AppDelegate.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/3/27.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let ud = UserDefaults(suiteName: "group.chaocaiwei")
        let value = ud?.value(forKey: "key")
        
        let alert = UIAlertController(title: "Tip", message: "\(value ?? 90)", preferredStyle: .alert)
        
        self.window?.rootViewController?.present(alert, animated:true, completion: {
            
        })
        
        return true
    }


}

