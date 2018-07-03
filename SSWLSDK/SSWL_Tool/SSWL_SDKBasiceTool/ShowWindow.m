//
//  ShowWidow.m
//  SSWLSDK
//
//  Created by SDK on 2018/5/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "ShowWindow.h"
#import "SYHTMLViewController.h"
//#import "SY_SongyorkViewController.h"
#import "SSWL_ZFNavigationVontroller.h"




@implementation ShowWindow



+ (BOOL)isShowWindowWithSongyorkInfo:(SongyorkInfo *)songyorkInfo{
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString.length > 0) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.backgroundColor = [UIColor clearColor];
        SYHTMLViewController *h5 = [[SYHTMLViewController alloc] init];
        h5.urlString = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString;
        h5.songyorkInfo = songyorkInfo;
        h5.closeBlock = ^{
            ShowWindow *showWindow = [[ShowWindow alloc] init];
            [showWindow willDisappearWithWindow:window];
        };
        SSWL_ZFNavigationVontroller *nav = [[SSWL_ZFNavigationVontroller alloc] initWithRootViewController:h5];
        window.rootViewController = nav;
        [window makeKeyAndVisible];
        
        return YES;
    }
    return NO;
}



/**
 关闭动画

 @param window window
 */
- (void)willDisappearWithWindow:(UIWindow *)window{
    
    [UIView animateWithDuration:.3f animations:^{
        window.alpha = 0.1f;
        window.hidden = YES;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus) {
                [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
            }
        }
        
    }];
    window = nil;
}


@end
