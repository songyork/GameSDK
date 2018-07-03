//
//  PushInfoWindow.h
//  SSWLSDK
//
//  Created by SDK on 2018/7/2.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushInfoWindow : UIWindow


@property (nonatomic, copy) void(^PushInfoBlock)(void);

@end
