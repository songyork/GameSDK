//
//  SSWL_DebugBassView.h
//  SSWLSDK
//
//  Created by SDK on 2018/6/27.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface SSWL_DebugBassView : UIView <UITextFieldDelegate>


@property (nonatomic, strong) UITextField *userTextFiled;//账号

@property (nonatomic, strong) UITextField *passTextField;//密码

@property (nonatomic, strong) UIButton *registBtn;//注册按钮

@property (nonatomic, strong) UIButton *loginBtn;//登录按钮

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, assign) BOOL isAgree;

@property (nonatomic, copy) void(^DebugBlock)(void);


@property (nonatomic, copy) void(^KeyboardHideBlock)(float originY, BOOL isHidden, NSTimeInterval animationDuration);

//@property (nonatomic, weak) id<DebugLoginDelegate> delegate;

//- (id)init;

//- (id)initWithFrame:(CGRect)frame;

- (void)sendSuperViewMessage:(NSString *)message;

- (void)changeHUDModeTips:(NSString *)tips;

- (void)clearTextField;

- (void)setUpView;

- (void)debugViewIsLogion;

- (void)debugViewIsRegist;

@end
