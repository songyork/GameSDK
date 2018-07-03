//
//  PushInfoWindow.m
//  SSWLSDK
//
//  Created by SDK on 2018/7/2.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "PushInfoWindow.h"
#import "SSWL_PushInfoViewController.h"
#import "SSWL_UserManagerNavController.h"
@implementation PushInfoWindow


- (instancetype)init{
    
    self = [super init];
    if (self) {
        [self setUpNav];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpNav];
    }
    return self;
    
}

- (void)setUpNav {
    
    self.backgroundColor = SYWhiteColor;
    self.windowLevel = UIWindowLevelAlert+.1f;
    SSWL_PushInfoViewController *pushVC = [[SSWL_PushInfoViewController alloc] init];
    Weak_Self;
    pushVC.PushInfoViewBlock = ^{
        if (weakSelf.PushInfoBlock) {
            weakSelf.PushInfoBlock();
        }
    };
    UINavigationController *pushNavgation = [[UINavigationController alloc] initWithRootViewController:pushVC];
    pushNavgation.navigationBar.hidden = YES;
    [SSWL_PublicTool stopSystemPopGestureRecognizerForNavigationController:pushNavgation];
    self.rootViewController = pushNavgation;
}

@end
