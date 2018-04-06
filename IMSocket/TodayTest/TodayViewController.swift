//
//  TodayViewController.swift
//  TodayTest
//
//  Created by JZTech-weichaocai on 2018/3/29.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import NotificationCenter
import AFNetworking
import CoreLocation


class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var timer  : Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    var time_t = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.extensionContext?.widgetLargestAvailableDisplayMode  = .expanded
        let req = URLRequest(url: URL(string:"https://1255975138.vod2.myqcloud.com/88030775vodtransgzp1255975138/33b42c997447398155218396387/1522223727_1284545461.100_0.jpg")!)
        let manager = AFHTTPSessionManager()
        
        
        
        manager.downloadTask(with: req, progress: { (pro) in
            print(pro)
        }, destination: { (url, resopn) -> URL in
            print(url)
            print(resopn)
            return url
        }, completionHandler: { (respon, url, eror) in
            print("\(respon)  \(url) \(eror)")
        }).resume()
        
    }
  
    deinit {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
    
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        switch activeDisplayMode {
        case .compact:
            self.preferredContentSize  = CGSize.zero
        case .expanded:
            self.preferredContentSize  = CGSize(width: UIScreen.main.bounds.size.width, height: 44*9)
        }
        
    }
    
    
    @IBAction func openAction(_ sender: Any) {
        if let url = URL(string:"imsocket://open") {
            self.extensionContext?.open(url, completionHandler: { (isSuc) in
                print(isSuc)
            })
        }

    }
    
}

extension TodayViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text  = "测试消息"
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
}

