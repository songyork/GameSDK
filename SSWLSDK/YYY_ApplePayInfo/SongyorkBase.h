//
//  SongyorkCenter.h
//  SSWL_SDK
//
//  Created by SDK on 2018/5/7.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SongyorkInfo;

@interface SongyorkBase : NSObject

@property (nonatomic, copy) void(^songyorkCallback)(NSString *message, id params);


+ (SongyorkBase *)sharedSongyorkBase;

- (void)registerBase;

- (void)dealWithSongyorkInfo:(SongyorkInfo *)songyorkInfo
                   viewController:(UIViewController *)viewController
                       completion:(void (^)(NSString *message, id params))completion;


@end
