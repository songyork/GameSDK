//
//  GetCodeForMessageViewController.h
//  AYSDK
//
//  Created by 松炎 on 2017/7/28.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GetMessageType){
    RegistPhoneUser                  = 0, //注册手机账号
    FindPassword                     = 1, //找回密码
    ModifyPasswordForPhone           = 2, //手机号修改密码
    VerificationForPhoneLogin        = 3, //验证手机登录
};

@interface SSWL_GetCodeForMessageViewController : UIViewController

@property (nonatomic ,copy) NSString *accountString;

@property (nonatomic, assign) GetMessageType getMessageType;

@property (nonatomic ,copy) void (^GetMessageBlock)();

@property (nonatomic, assign) BOOL isPresent;
@end
