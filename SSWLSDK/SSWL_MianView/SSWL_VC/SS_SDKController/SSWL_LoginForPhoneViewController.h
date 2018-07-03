//
//  SYLoginForPhoneViewController.h
//  AYSDK
//
//  Created by songyan on 2018/1/26.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^LoginForPhone)();

@interface SSWL_LoginForPhoneViewController : UIViewController

@property (nonatomic ,copy) NSString *usernameString;

@property (nonatomic, assign) BOOL isPush;

@property(nonatomic,copy)LoginForPhone block;

@property (nonatomic, assign) BOOL isOnline;//是否上线


@end
