//
//  SSWL_OpenPushInfo.h
//  SSWLSDK
//
//  Created by SDK on 2018/7/2.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSWL_OpenPushInfo : NSObject

@property (nonatomic, copy) void(^OpenPushInfoBlock)(void);

- (void)openPushInfoForKey:(NSString *)key;

@end
