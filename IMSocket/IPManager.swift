//
//  IPManager.swift
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/4/1.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

import UIKit
import SystemConfiguration
import CFNetwork

struct DeveiceInfoManager {

    static let _instance = DeveiceInfoManager()
    private init(){}
    static func shared()->DeveiceInfoManager{
        return _instance;
    }
    
    func getMacAddress()->String?{
        
        
        var  mib = UnsafeMutablePointer<Int32>.allocate(capacity: 6)
        mib[0] = CTL_NET;
        mib[1] = AF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_LINK;
        mib[4] = NET_RT_IFLIST;
        mib[5] = Int32(if_nametoindex("en0"))
        
        if (mib[5] == 0) {
            print("Error: if_nametoindex error/n");
            return nil;
        }
        
        
        var  len : size_t  = 0
        if (sysctl(mib, 6, nil, &len, nil, 0) < 0) {
            print("Error: sysctl, take 1/n");
            return nil;
        }
     
        var  buf = UnsafeMutableRawPointer.allocate(byteCount: len, alignment: 0)
        if (sysctl(mib, 6,buf, &len, nil, 0) < 0) {
            print("Error: sysctl, take 2");
            return nil;
        }
        
        var ifm = if_msghdr()
        var sdl = sockaddr_dl()
        buf.copyMemory(from: &ifm, byteCount: MemoryLayout.size(ofValue: ifm))
        buf =  buf.advanced(by: MemoryLayout.size(ofValue: ifm))
        buf.copyMemory(from: &sdl, byteCount: MemoryLayout.size(ofValue: sdl))
        let str = String.init(format:"%02x:%02x:%02x:%02x:%02x:%02x",sdl.sdl_data.0,sdl.sdl_data.1,sdl.sdl_data.2,sdl.sdl_data.3,sdl.sdl_data.4,sdl.sdl_data.5).uppercased()
        
        return str
    }
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
}
