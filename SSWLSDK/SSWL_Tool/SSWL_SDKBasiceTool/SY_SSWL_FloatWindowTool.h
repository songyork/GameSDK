//
//  SY_SSWL_FloatWindowTool.h
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSWL_UserManager.h"
#import "SSWL_PersonCenterWindow.h"
#import "SSWL_FloatWindow.h"
#import "SSWL_UserManagerNavController.h"
#import "SSWL_UserManagerController.h"
@interface SY_SSWL_FloatWindowTool : NSObject


@property (nonatomic, strong) UIWindow *htmlWindow; //H5Window

/* *悬浮窗 */
@property(nonatomic, strong) SSWL_FloatWindow *change_floatWindow;

@property (nonatomic ,strong) SSWL_PersonCenterWindow *personCenterW;

@property (nonatomic ,strong) SSWL_UserManager *userManagerW;

@property (nonatomic, strong) SSWL_UserManagerNavController *userManagerNav;

@property (nonatomic, strong) SSWL_UserManagerController *uVC;

@property (nonatomic, strong) UIWindow *tipsWebWindow;


SYSingletonH(SY_SSWL_FloatWindowTool)



/**
 创建悬浮窗
 */
- (void)createFloatWindow;


/**
 改绑手机
 */
- (void)changeBindMobilPhone;



/**
 销毁悬浮窗
 */
- (void)destroyFloatWindow;



/**
 创建HTML_Game页面
 
 @param openuUrl 打开链接
 @param zUrl GQ链接
 */
- (void)creatHtmlGameWithUrl:(NSString *_Nullable)openuUrl
                        zUrl:(NSString *_Nullable)zUrl;



@end
