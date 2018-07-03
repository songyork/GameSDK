//
//  LoginViewController.h
//  AYSDK
//
//  Created by SDK on 2017/7/25.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSWL_RegistViewController.h"


typedef void(^LoginViewBlock)();

@interface SSWL_LoginViewController : UIViewController

@property(nonatomic,copy)LoginViewBlock block;


@property (nonatomic, assign) BOOL isOnline;//是否上线

@property (nonatomic, assign) BOOL isPush;//从注册页面跳转

@end
