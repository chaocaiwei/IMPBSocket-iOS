//
//  DeviceHelper.h
//  IMSocket
//
//  Created by JZTech-weichaocai on 2018/4/2.
//  Copyright © 2018年 JZTech-weichaocai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceHelper : NSObject

- (void)getDeviceInfo;
- (NSString *)macaddress;
- (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
