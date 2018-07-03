//
//  RegistViewController.h
//  AYSDK
//
//  Created by SDK on 2017/7/25.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^RegistViewBlock)();


@interface SSWL_RegistViewController : UIViewController


@property(nonatomic,copy)RegistViewBlock block;

@property (nonatomic, assign) BOOL isLoginCome;//从登录页面跳转
@property (nonatomic, assign) BOOL isOnline;//是否上线


@end
