//
//  SY_SSWL_FloatWindowTool.m
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SY_SSWL_FloatWindowTool.h"
#import "SSWL_FloatWindow.h"
#import "SSWL_WebTipSController.h"

@interface SY_SSWL_FloatWindowTool ()


@end

@implementation SY_SSWL_FloatWindowTool


SYSingletonM(SY_SSWL_FloatWindowTool)

//创建HTLM游戏页面
- (void)creatHtmlGameWithUrl:(NSString *)openuUrl zUrl:(NSString *)zUrl{
    //    Weak_Self;
    self.htmlWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    self.htmlWindow.backgroundColor = SYWhiteColor;
    SSWL_GameToHtmlViewController *h5 = [[SSWL_GameToHtmlViewController alloc] init];
    h5.requestURL = openuUrl;
    h5.zUrl = zUrl;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:h5];
    nav.navigationBar.hidden = YES;
    
    self.htmlWindow.rootViewController = nav;
    
    [self.htmlWindow makeKeyAndVisible];
}


//创建悬浮窗
- (void)createFloatWindow{
    Weak_Self;//
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        
        
     
        if (self.change_floatWindow) {
            return ;
        }
        if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"]){
            weakSelf.change_floatWindow = [[SSWL_FloatWindow alloc] initWithFrame:CGRectMake(30, 30, 60, 60) mainImageName:@"xf_tb" titleArr:@[@"tb_zh",@"tb_lb",@"tb_kf", @"tb_gg", @"tb_back"] startBtnTag:100 animationColor:[UIColor clearColor]];
        }else{
            weakSelf.change_floatWindow = [[SSWL_FloatWindow alloc] initWithFrame:CGRectMake(30, 30, 60, 60) mainImageName:@"xf_tb" titleArr:@[@"tb_zh",@"tb_lb",@"tb_kf", @"tb_gg", @"ling", @"tb_back"] startBtnTag:100 animationColor:[UIColor clearColor]];
        }
        
        weakSelf.change_floatWindow.hidden = NO;
        
        //*** 点击悬浮窗按钮
        weakSelf.change_floatWindow.backBlock = ^(NSInteger tag){
            if (tag == 100) {
                //*** 账号
                if (weakSelf.userManagerW == nil) {
                    SYLog(@"========账号");
                    
                    
                    
                    weakSelf.uVC = [[SSWL_UserManagerController alloc] init];
                    weakSelf.userManagerNav = [[SSWL_UserManagerNavController alloc] initWithRootViewController:weakSelf.uVC];
                    //                        [SSWL_PublicTool stopSystemPopGestureRecognizerForNavigationController:weakSelf.userManagerNav];
                    //                        [weakSelf.change_floatWindow.rootViewController presentViewController:weakSelf.userManagerNav animated:YES completion:^{
                    //                            [weakSelf destroyFloatWindow];
                    //                        }];
                    
                    
                    weakSelf.userManagerW = [[SSWL_UserManager alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                    weakSelf.userManagerW.UserBlock = ^{
                        weakSelf.userManagerW.hidden = YES;
                        weakSelf.userManagerW = nil;
                    };
                    [weakSelf.userManagerW makeKeyAndVisible];
                   
                }
            }else if (tag == 101){
                //*** 礼包
                SYLog(@"========礼包");
                
                
                
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].selectedIndex = 1;
                
                //                    SSWL_PersonTabBarController *tabBarC = [[SSWL_PersonTabBarController alloc] init];
                //                    tabBarC.changeBind = NO;
                //                    [weakSelf.change_floatWindow.rootViewController presentViewController:tabBarC animated:YES completion:^{
                //                        [weakSelf destroyFloatWindow];
                //                    }];
                
                if (weakSelf.personCenterW == nil) {
                    if (weakSelf.userManagerW) {
                        weakSelf.userManagerW.hidden = YES;
                        weakSelf.userManagerW = nil;
                        [weakSelf destroyFloatWindow];
                    }else{
                        [weakSelf destroyFloatWindow];
                    }
                    weakSelf.personCenterW = [[SSWL_PersonCenterWindow alloc] initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, Screen_Height) rootViewControllerIndex:1 isChangeBindPhone:NO];
                    weakSelf.personCenterW.TabBarBlock = ^{
                        [UIView animateWithDuration:0.3 animations:^{
                            weakSelf.personCenterW.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height);
                        } completion:^(BOOL finished) {
                            weakSelf.personCenterW.alpha = 0;
                            weakSelf.personCenterW = nil;
                            [weakSelf createFloatWindow];
                        }];
                    };
                    
                    [weakSelf.personCenterW makeKeyAndVisible];
                    [UIView animateWithDuration:0.3 animations:^{
                        weakSelf.personCenterW.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
                    }];
                    
                    //                     [weakSelf destroyFloatWindow];
                }
                
                
                
            }else if (tag == 102){
                //*** 客服
                SYLog(@"========客服");
                
                
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].selectedIndex = 2;
                //                    SSWL_PersonTabBarController *tabBarC = [[SSWL_PersonTabBarController alloc] init];
                //
                //
                //                    tabBarC.changeBind = NO;
                //                    [weakSelf.change_floatWindow.rootViewController presentViewController:tabBarC animated:YES completion:^{
                //                        [weakSelf destroyFloatWindow];
                //                    }];
                if (weakSelf.personCenterW == nil) {
                    if (weakSelf.userManagerW) {
                        weakSelf.userManagerW.hidden = YES;
                        weakSelf.userManagerW = nil;
                        [weakSelf destroyFloatWindow];
                    }else{
                        [weakSelf destroyFloatWindow];
                    }
                    weakSelf.personCenterW = [[SSWL_PersonCenterWindow alloc] initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, Screen_Height) rootViewControllerIndex:2 isChangeBindPhone:NO];
                    weakSelf.personCenterW.TabBarBlock = ^{
                        [UIView animateWithDuration:0.3 animations:^{
                            weakSelf.personCenterW.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height);
                        } completion:^(BOOL finished) {
                            weakSelf.personCenterW.alpha = 0;
                            weakSelf.personCenterW = nil;
                            [weakSelf createFloatWindow];
                        }];
                    };
                    [weakSelf.personCenterW makeKeyAndVisible];
                    [UIView animateWithDuration:0.3 animations:^{
                        weakSelf.personCenterW.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
                    }];
                    //                     [weakSelf destroyFloatWindow];
                }
                
                /*
                 if (weakSelf.kefuWindow == nil) {
                 weakSelf.kefuWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                 weakSelf.kefuWindow.backgroundColor = [UIColor clearColor];
                 KeFuViewController *kfVC = [[KeFuViewController alloc] init];
                 kfVC.BackBlock = ^{
                 weakSelf.kefuWindow = nil;
                 weakSelf.kefuWindow.hidden = YES;
                 };
                 weakSelf.kefuWindow.rootViewController = kfVC;
                 [weakSelf.kefuWindow makeKeyAndVisible];
                 }
                 */
                
            }else if (tag == 103){
                SYLog(@"公告");
                
                
                SSWL_WebTipSController *webTips = [[SSWL_WebTipSController alloc] init];
                
                //                    weakSelf.userManagerNav = [[UserManagerNavController alloc] initWithRootViewController:webTips];
                //                    [weakSelf.change_floatWindow.rootViewController presentViewController:weakSelf.userManagerNav animated:YES completion:^{
                //                        [weakSelf destroyFloatWindow];
                //                    }];
                
                
                if (weakSelf.tipsWebWindow == nil) {
                    if (weakSelf.userManagerW) {
                        weakSelf.userManagerW.hidden = YES;
                        weakSelf.userManagerW = nil;
                        [weakSelf destroyFloatWindow];
                    }else{
                        [weakSelf destroyFloatWindow];
                    }
                    weakSelf.tipsWebWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, Screen_Height, Screen_Width /2, Screen_Height)];
                    SSWL_WebTipSController *webTips = [[SSWL_WebTipSController alloc] init];
                    
                    weakSelf.userManagerNav = [[SSWL_UserManagerNavController alloc] initWithRootViewController:webTips];
                    webTips.GoBackBlock = ^{
                        [UIView animateWithDuration:0.3 animations:^{
                            weakSelf.tipsWebWindow.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height);
                        } completion:^(BOOL finished) {
                            weakSelf.tipsWebWindow.alpha = 0;
                            weakSelf.tipsWebWindow = nil;
                            [weakSelf createFloatWindow];
                        }];
                        
                    };
                    weakSelf.tipsWebWindow.rootViewController = weakSelf.userManagerNav;
                    [weakSelf.tipsWebWindow makeKeyAndVisible];
                    [UIView animateWithDuration:0.3 animations:^{
                        weakSelf.tipsWebWindow.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
                    }];
                    //                     [weakSelf destroyFloatWindow];
                }
                
                
            }else if (tag == 104){
                if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"]){
                    SYLog(@"返回");
                    
                }else{
                    NSURL *storeURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/jie-zou-da-shi/id1314361976?mt=8"];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:storeURL]){
                        [[UIApplication sharedApplication] openURL:storeURL options:@{} completionHandler:^(BOOL success) {
                            if (success) {
                                SYLog(@"1111111111111");
                            }
                        }];
                    }
                }
                
            }else if (tag == 105){
                SYLog(@"返回");
                
            }
            
            
            
        };
    });
}


// 销毁悬浮窗
-(void)destroyFloatWindow{
    [self.change_floatWindow stopTiming];
    self.change_floatWindow.hidden = YES;
    self.change_floatWindow.alpha = 0;
    self.change_floatWindow = nil;
    
}

/**
 * 改绑手机
 */
- (void)changeBindMobilPhone{
    Weak_Self;
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].selectedIndex = 3;
    
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].changeBind = YES;
    
    
    if (self.personCenterW == nil) {
        
        
        if (self.userManagerW) {
            self.userManagerW.hidden = YES;
            self.userManagerW = nil;
            [self destroyFloatWindow];
        }else{
            [self destroyFloatWindow];
        }
        
        self.personCenterW = [[SSWL_PersonCenterWindow alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) rootViewControllerIndex:3 isChangeBindPhone:YES];
        self.personCenterW.TabBarBlock = ^{
            weakSelf.personCenterW.alpha = 0;
            weakSelf.personCenterW = nil;
            [weakSelf createFloatWindow];
        };
        [self.personCenterW makeKeyAndVisible];
    }
    
    //    SSWL_PersonTabBarController *tabBarC = [[SSWL_PersonTabBarController alloc] init];
    
    
    //    SSWL_PersonTabBarController *tabBarC = [[SSWL_PersonTabBarController alloc] init];
    //    self.change_floatWindow = [[SSWL_FloatWindow alloc] initWithFrame:CGRectMake(0, 0, 0, 0) mainImageName:nil titleArr:nil startBtnTag:100 animationColor:SYNOColor];
    //    self.change_floatWindow.alpha = 0.0;
    //    self.change_floatWindow.hidden = YES;
    //    [self.change_floatWindow.rootViewController presentViewController:tabBarC animated:YES completion:^{
    //        [weakSelf.uVC dismissViewControllerAnimated:YES completion:^{
    //            [weakSelf destroyFloatWindow];
    //        }];
    //    }];
    
    
   
    
    
}





@end
