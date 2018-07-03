//
//  SSWL_OpenPushInfo.m
//  SSWLSDK
//
//  Created by SDK on 2018/7/2.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_OpenPushInfo.h"
#import "PushInfoWindow.h"
@interface SSWL_OpenPushInfo ()

@property (nonatomic, strong) PushInfoWindow *pushInfoWindow;

@end

@implementation SSWL_OpenPushInfo

- (void)openPushInfoForKey:(NSString *)key {
    if (key.length < 1) {
        return;
    };
    
    
    [self openWindow];

    [UIView animateWithDuration:.2f animations:^{
        
    }];
   
}

- (void)openWindow {
   
}


@end
