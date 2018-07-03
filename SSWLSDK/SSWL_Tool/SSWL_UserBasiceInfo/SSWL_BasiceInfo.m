//
//  SSWL_BasiceInfo.m
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_BasiceInfo.h"

@implementation SSWL_BasiceInfo

SYSingletonM(SSWL_BasiceInfo)

- (void)setSDKInfoWithAppId:(NSString *)appId directionNumber:(int)directionNumber{
    
    
    // appid 方向信息
    self.sswl_AppId = appId;
    if (directionNumber) {
        self.directionNumber = directionNumber;
    }
   
    
    self.canClick = YES;
    
    self.isBindPhone = NO;
    self.sdk_Version = SSWL_SDK_Version;
    
    //*** 2、设备信息
    self.system_Version = [[UIDevice currentDevice] systemVersion];
    //    self.deviceName = [[UIDevice currentDevice] localizedModel];
    
    self.uuid = [self getUUID];
    
    //    self->_ipAddress = [self deviceIPAdress]; //*** 获取的内网ip，没有意义
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0){
        self.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }else{
        self.idfa = @"system version is lower than 6.0";
    }
    
    if ([[[UIDevice currentDevice] identifierForVendor] UUIDString] && [[[[UIDevice currentDevice] identifierForVendor] UUIDString] length] > 0) {
        self.idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    self.app_channel = [self getAppChannel];
    
    self.app_Version = [self getAppVersion];
    
    
    
    self.gameName = [self getGameName];
    
    
    self.isShareSuccess = NO;
    
    self.package_name = [[NSBundle mainBundle] bundleIdentifier];
    //    self.platform = @"android";
    self.platform = @"ios";
    
    self.device_Model = [self deviceModelName];
    self.deviceScreenBounds = [self getScreenSizeString];
    
//    SYLog(@"URLScheme : %@", [self getURLScheme]);
}


/*记录用户是否激活*/
- (void)saveActivateFlag:(BOOL)activated{
    [[NSUserDefaults standardUserDefaults] setBool:activated forKey:@"userActivate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * 获取用户是否激活
 */
- (BOOL)getCurrentActivateFlag{
    BOOL activated = [[NSUserDefaults standardUserDefaults]boolForKey:@"userActivate"];
    return activated;
    
}

- (void)saveCustomerService:(NSString *)customerService{
    
    [[NSUserDefaults standardUserDefaults] setValue:customerService forKey:@"customerService"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getCustomerService{
    
    NSString *customerService = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerService"];
    
    return customerService;
}


- (NSString*)getAppVersion{
    NSString *appversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (appversion && [appversion length] >0) {
        return appversion;
    }else{
        return @"";
    }
}

- (NSString *)getAppChannel{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *appChannel = pasteboard.string;
    if (appChannel.length < 1) {
        appChannel = @"";
    }
    return appChannel;
}

/* *name */
- (NSString *)getGameName{
    NSString *gameName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    
    if (gameName && [gameName length] >0) {
        return gameName;
    }else{
        return @"测试用";
    }
    
}

/* *没有用 */
- (NSArray *)getURLScheme{
    NSArray *urlSchemeArray = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLSchemes"];
    
    
    if (urlSchemeArray && [urlSchemeArray count] >0) {
        return urlSchemeArray;
    }else{
        return nil;
    }
    
}

- (NSString *)getScreenSizeString{
    NSString *size = [NSString stringWithFormat:@"%0.0lf*%0.0lf",[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width];
    if (size && [size length] >0) {
        return size;
    }else{
        return nil;
    }
    
    
}


/*获取设备信息*/
- (NSDictionary *)getDeviceInfo{
    //    NSString *str = [NSString stringWithFormat:@"%@6666", self.uuid];
    NSDictionary *deviceInfoDictionary =  @{
                           @"sdk_version": self.sdk_Version,
                           @"app_version": self.app_Version,
                           @"system_name":self.device_Model,
                           @"device_id": self.uuid,
                           @"idfa": self.idfa,
                           @"platform": self.platform,
                           @"idfv": self.idfv,
                           @"app_channel" : self.app_channel,
                           @"app_name" : self.gameName,
                           @"app_id" : self.sswl_AppId,
                           @"package_name" : self.package_name,
                           @"screen_size" : self.deviceScreenBounds,
                           @"system_version" : self.system_Version,
                           };
    return deviceInfoDictionary;
    
}




//获取设备唯一标识码
- (NSString *)getUUID
{
    NSString *strUUID = [[NSString alloc] initWithData:[KeyChainWrapper load:@"uuid"] encoding:NSUTF8StringEncoding];
    
    if (!(strUUID.length>0))
    {
        
        NSString *str = [[NSUUID UUID] UUIDString];
        strUUID = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [KeyChainWrapper save:@"uuid" data:[strUUID dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    
    
    return strUUID;
}

//设备链接的网络IP地址
-(NSString *)deviceIPAdress
{
    NSString *address = @"1111111";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    //        NSLog(@"手机的IP是：%@", address);
    return address;
}


//设备的具体型号
-(NSString*)deviceModelName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // iPhione
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone_7";         // 国行、日版、港行
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone_7 Plus";    // 港行、国行
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone_7";         // 美版、台版
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone_7_Plus";    // 美版、台版
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone_8";         // 国行(A1863)、日行(A1906)
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone_8";         // 美版(Global/A1905)
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";    // 国行(A1864)、日行(A1898)
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";    // 美版(Global/A1897)
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone_X";         // 国行(A1865)、日行(A1902)
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone_X";         // 美版(Global/A1901)
    
    // iPod
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod_Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod_Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod_Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod_Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod_Touch (5 Gen)";

    // iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad_3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad_2";           // (WiFi)
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad_2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad_2";           // (CDMA)
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad_2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad_Mini";        // (WiFi)
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad_Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad_Mini";        // (GSM+CDMA)
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad_3";           //  (WiFi)
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad_3";           // (GSM+CDMA)
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad_3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad_4";           // (WiFi)
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad_4";           // (GSM+CDMA)
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad_Air";         // (WiFi)
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad_Air";         // (Cellular)
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad_Mini_2";      // (WiFi)
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad_Mini_2";      // (Cellular)
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad_Mini_2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad_Mini_3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad_Mini_3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad_Mini_3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad_Mini_4";      // (WiFi)
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad_Mini_4";      // (LTE)
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad_Air_2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad_Air_2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad_Pro_9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad_Pro_9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad_Pro_12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad_Pro_12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad_5";            // (WiFi)
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad_5";            // (Cellular)
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad_Pro_12.9";     // inch 2nd gen (WiFi)
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad_Pro_12.9";     // inch 2nd gen (Cellular)
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad_Pro_10.5";     // inch (WiFi)
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad_Pro_10.5";     // inch (Cellular)
    
    // Apple TV
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple_TV_2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple_TV_3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple_TV_3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple_TV_4";
    
    
    // 模拟机
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}

@end
