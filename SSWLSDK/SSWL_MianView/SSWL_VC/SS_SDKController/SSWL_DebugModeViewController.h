//
//  SSWL_DebugModeViewController.h
//  SSWLSDK
//
//  Created by SDK on 2018/6/23.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_DebugModeViewController : UIViewController


@property (nonatomic, copy) void(^DebugLoginBlock)(void);

// 预留
@property (nonatomic, assign) BOOL isDebugMode;

@end
