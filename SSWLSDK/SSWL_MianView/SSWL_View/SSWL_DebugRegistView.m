//
//  SSWL_DebugRegistView.m
//  SSWLSDK
//
//  Created by SDK on 2018/6/27.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_DebugRegistView.h"

@implementation SSWL_DebugRegistView

- (id)init{
    if (self = [super init]) {
        [self setUpView];
        [self debugViewIsRegist];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self setUpView];
        [self debugViewIsRegist];
        
    }
    return self;
}

- (void)registClick:(id)sender{
    SYLog(@"regist --- 注册");
    
    
    [self.userTextFiled resignFirstResponder];
    [self.passTextField resignFirstResponder];
    Weak_Self;
    
    
    if (!self.isAgree) {
        [self sendSuperViewMessage:@"请同意'上士用户服务协议'"];
        return;
    }
    
    if (self.userTextFiled.text.length < 6 || self.userTextFiled.text == nil) {
        
        [self sendSuperViewMessage:@"请按规定填写账号"];
        
        return;
    }else{
        //a-zA-Z0-9
        NSString *regex = @"^([\u4E00-\u9FA5]+)$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isEmpty = [SSWL_PublicTool isEmpty:self.userTextFiled.text];
        if([pred evaluateWithObject:self.userTextFiled.text] || isEmpty) {
            [self sendSuperViewMessage:@"请按规定填写账号"];
            return;
        }
        
    }
    
    
    if (self.passTextField.text.length < 6 || self.passTextField.text == nil) {
        [self sendSuperViewMessage:@"请按规定填写密码"];
        return;
    }else{
        NSString *regex = @"^([\u4E00-\u9FA5]+)$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isEmpty = [SSWL_PublicTool isEmpty:self.passTextField.text];
        //![pred evaluateWithObject:self.passTextField.text] ||
        if([pred evaluateWithObject:self.passTextField.text] || isEmpty) {
            [self sendSuperViewMessage:@"请按规定填写密码"];
            return;
        }
    }
    
    SYLog(@"用户注册...");
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.label.text = @"正在注册";
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] registWithUserName:self.userTextFiled.text password:self.passTextField.text regType:RegistTypeName code:nil completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
            weakSelf.HUD.mode = MBProgressHUDModeText;
            weakSelf.HUD.label.text = @"注册成功";
            
            
            
            [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] loginWithUserName:self.userTextFiled.text password:self.passTextField.text completion:^(BOOL isSuccess, id respones) {
                if (isSuccess) {
                    //            NSDictionary *loginDic = respones[@"data"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                        [weakSelf changeHUDModeTips:@"登录成功"];
                        if (weakSelf.DebugBlock) {
                            weakSelf.DebugBlock();
                        }
                    });
                    
                }else{
                    [weakSelf changeHUDModeTips:respones[@"msg"]];
                    
                    
                }
            } failure:^(NSError * _Nullable error) {
                [weakSelf changeHUDModeTips:@"网络异常"];
            }];
            
            
        }else{
            weakSelf.HUD.mode = MBProgressHUDModeText;
            NSString *msg = [NSString stringWithFormat:@"%@", respones[@"msg"]];
            if (msg.length < 1) {
                [weakSelf changeHUDModeTips:@"登录失败"];
            }
            [weakSelf changeHUDModeTips:respones[@"msg"]];
            
            
            //                    SYLog(@"----respones:%@,----message:%@", respones, respones[@"msg"]);
        }
    } failure:^(NSError * _Nullable error) {
        [weakSelf changeHUDModeTips:@"网络异常"];
    }];
    
    
}

- (void)sendSuperViewMessage:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(debugRegistView:showHUDMessage:)]) {
        [self.delegate debugRegistView:self showHUDMessage:message];
    }
}

@end
