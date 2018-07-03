//
//  CallBackToServer.h
//  SSWLSDK
//
//  Created by SDK on 2018/5/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallBackToServer : NSObject


+ (CallBackToServer *)registerCallBackToServer;

- (void)informBackgroundShipWithDict:(NSMutableDictionary *)dict;

@end
