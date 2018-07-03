//
//  ChangePassWordController.h
//  AYSDK
//
//  Created by 松炎 on 2017/7/29.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_ChangePassWordController : UIViewController

@property (nonatomic ,copy) NSString *account;//账号

@property (nonatomic ,copy) NSString *phoneNum;//电话号码

@property (nonatomic ,copy) NSString *code;//短信验证码
@end
