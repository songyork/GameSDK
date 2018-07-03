//
//  GetCodeForMessageViewController.m
//  AYSDK
//
//  Created by 松炎 on 2017/7/28.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_GetCodeForMessageViewController.h"
#import "SSWL_CustomerServiceViewController.h"
#import "SSWL_ChangePassWordController.h"
//#import "ServiceAgreementView.h"
#import "SSWL_FirstOpenViewController.h"
#import "SSWL_LoginViewController.h"


@interface SSWL_GetCodeForMessageViewController ()<UITextFieldDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    int _addViewStates;
}
@property (nonatomic, strong) SSWL_BGView *bgView;

@property (nonatomic, strong) SSWL_BGView *tipsView;

@property (nonatomic, strong) MBProgressHUD *webHUD;

@property (nonatomic ,strong) SSWL_ServiceAgreementView *serviceAgreementView;

@property(nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic, strong) SSWL_ErrorView *errorView;

@property (nonatomic, strong) SSWL_VerifyDynamicView *verifyDynamicView;

@property (nonatomic, strong) NSDictionary *responesParam;//请求下来的参数

@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic, strong) UIImageView *phoneImgView;//账号图片

@property (nonatomic, strong) UIImageView *codeImgView;//密码图片

@property (nonatomic, strong) UITextField *phoneNumTextField;//账号

@property (nonatomic, strong) UITextField *codeTextField;//密码

@property (nonatomic, strong) UIView *passwordBorderView;//输入框边框

@property (nonatomic, strong) UIImageView *passworImgView;//图片

@property (nonatomic, strong) UITextField *passworTextField;//新密码

@property (nonatomic ,strong) UIButton *eyesBtn;//是否显示密码BTN

@property (nonatomic, strong) UIButton *sureBtn;//确定

@property (nonatomic, strong) UIButton *getCodeBtn;//获取验证码

@property (nonatomic, strong) UIButton *backBtn;//返回

@property (nonatomic ,strong) UIButton *onlineServiceBtn;

@property (nonatomic, strong) UIView *phoneBorderView;//输入框边框

@property (nonatomic, strong) UIView *codeBorderView;//

@property (nonatomic, strong) UILabel *phoneLineLab;//分割线

@property (nonatomic, strong) UILabel *codeLineLab;//分割线

@property (nonatomic, strong) UILabel *passwordLineLab;//分割线

@property (nonatomic ,strong) UILabel *tipsLab;//提示

@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值

@property(nonatomic,strong)NSTimer *telCodeTimer;//验证码倒计时

@property(nonatomic,assign)NSInteger timerNumber;//倒计时时间

@property (nonatomic ,copy) NSString *account;//账号

@property (nonatomic ,strong) UILabel *accountLab;//手机账号提示label

@property (nonatomic, assign) BOOL isAgree;// 是否同意服务协议

@property (nonatomic ,strong) UIImageView *ggLogo;//logo背景

@property (nonatomic, strong)UIButton *knowBtn;//知道了BTN

@property (nonatomic ,copy) NSString *requestUrl;//请求的链接

@property (nonatomic ,strong) WKWebView *webView;//wkwebview

@property (strong, nonatomic) UIProgressView *progressView;//进度条

@property (strong, nonatomic) NSString *fastPassStr;//自动登录密码

@property (strong, nonatomic) NSString *fastUserStr;//自动登录账号

@property (nonatomic, assign) BOOL isLoginAfter;//登陆后公告

@property (nonatomic, assign) BOOL isShowPassword;

@property (nonatomic, assign) int page;

@property (nonatomic, assign) int secNum;

@property (nonatomic, strong)dispatch_source_t time;

@property (nonatomic, strong) UIButton *otherLoginWay;//其他登录方式

@property (nonatomic ,strong) SSWL_AddIdentityInfo *addIdentityView;

@end

@implementation SSWL_GetCodeForMessageViewController

/*
 * 注销键盘的通知事件
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.view.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.phoneNumTextField];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.codeTextField];
    
    [self.view addSubview:self.bgView];
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo] directionNumber] == 0) {
          }else{
          }
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];

    self.isAgree = YES;
    [self createUI];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getInfo"];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getInfo"];
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏前调入");
         CGPoint point = CGPointMake(Screen_Width / 2, Screen_Height / 2);
         self.bgView.center = point;
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏后调入");
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)createUI{
    
    [self.bgView addSubview:self.logoImgView];
    
    [self.bgView addSubview:self.backBtn];
    
    
    [self.bgView addSubview:self.codeBorderView];
    
    
    [self.bgView addSubview:self.codeImgView];
    
    
    [self.bgView addSubview:self.codeLineLab];
    
    if (self.getMessageType == FindPassword) {
        [self.bgView addSubview:self.phoneBorderView];

        [self.bgView addSubview:self.phoneImgView];

        [self.bgView addSubview:self.phoneLineLab];

        [self.bgView addSubview:self.phoneNumTextField];
        
        [self.bgView addSubview:self.tipsLab];
        
        [self.bgView addSubview:self.onlineServiceBtn];
//        if (self.getMessageType == VerificationForPhoneLogin) {
//            self.phoneNumTextField.enabled = NO;
//        }

    }else{
        [self.bgView addSubview:self.accountLab];
        [self.bgView addSubview:self.serviceAgreementView];
        if (self.getMessageType == ModifyPasswordForPhone) {
            [self.bgView addSubview:self.eyesBtn];
            [self.bgView addSubview:self.passwordBorderView];
            [self.bgView addSubview:self.passworImgView];
            [self.bgView addSubview:self.passworTextField];
            [self.bgView addSubview:self.passwordLineLab];
        }
        [self getClick:@""];
        
    }
    
    [self.bgView addSubview:self.codeTextField];
    
    [self.bgView addSubview:self.getCodeBtn];
    
    [self.bgView addSubview:self.sureBtn];
    
    
//    [self.bgView addSubview:self.tipsLab];
    
    if (self.isPresent) {
        [self.bgView addSubview:self.otherLoginWay];
    }

    
    [self layoutSubView];
    
    
   
}

/*
 * 页面布局
 
 */
- (void)layoutSubView{
    Weak_Self;
    //约束
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bgView).offset(25);
//        make.left.equalTo(weakSelf.bgView).offset(50);
//        make.right.equalTo(weakSelf.bgView).offset(-50);
        make.size.mas_equalTo(CGSizeMake(150, 30));
        make.centerX.equalTo(weakSelf.bgView);
        
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(weakSelf.bgView).offset(20);
        make.centerY.equalTo(weakSelf.logoImgView).offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    
    if (self.getMessageType == FindPassword) {
        [self.phoneBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(20);
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.height.mas_equalTo(40);
        }];
        
        [self.phoneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.phoneBorderView.mas_left).offset(10);
            make.centerY.equalTo(weakSelf.phoneBorderView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [self.phoneLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.phoneBorderView.mas_top).offset(5);
            make.bottom.equalTo(weakSelf.phoneBorderView.mas_bottom).offset(-5);
            make.left.equalTo(weakSelf.phoneImgView.mas_right).offset(10);
            make.width.mas_equalTo(1);
        }];
        
        [self.phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.phoneLineLab.mas_right).offset(5);
            make.centerY.equalTo(weakSelf.phoneBorderView);
            make.height.mas_equalTo(@30);
            make.right.equalTo(weakSelf.phoneBorderView.mas_right).offset(-30);
        }];
        
        [self.getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.phoneBorderView.mas_bottom).offset(15);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(95, 35));
        }];
    }else{
        [self.accountLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(20);
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.height.mas_equalTo(20);
        }];
        [self.getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.accountLab.mas_bottom).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(95, 35));
        }];
        
      
    }
    

    
    [self.codeBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.getCodeBtn.mas_left).offset(-15);
        make.centerY.equalTo(weakSelf.getCodeBtn);
        make.height.mas_equalTo(@40);
    }];
    
    [self.codeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.codeBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.codeBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.codeLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.codeBorderView.mas_top).offset(5);
        make.bottom.equalTo(weakSelf.codeBorderView.mas_bottom).offset(-5);
        make.left.equalTo(weakSelf.codeImgView.mas_right).offset(10);
        make.width.mas_equalTo(@1);
    }];
    
    [self.codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.codeLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.codeBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.codeBorderView.mas_right).offset(-30);
    }];
    
    if (self.getMessageType == ModifyPasswordForPhone) {
        [self.passwordBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.codeBorderView.mas_bottom).offset(15);
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.height.mas_equalTo(40);
        }];
        
        [self.passworImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.passwordBorderView.mas_left).offset(10);
            make.centerY.equalTo(weakSelf.passwordBorderView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [self.passwordLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.passwordBorderView.mas_top).offset(5);
            make.bottom.equalTo(weakSelf.passwordBorderView.mas_bottom).offset(-5);
            make.left.equalTo(weakSelf.passwordBorderView.mas_right).offset(10);
            make.width.mas_equalTo(1);
        }];
        
        [self.passworTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.passwordBorderView.mas_right).offset(5);
            make.centerY.equalTo(weakSelf.passwordBorderView);
            make.height.mas_equalTo(@30);
            make.right.equalTo(weakSelf.passwordBorderView.mas_right).offset(-30);
        }];
        
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.passwordBorderView.mas_bottom).offset(20);
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.height.mas_equalTo(40);
        }];
        
    }else{
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.codeTextField.mas_bottom).offset(30);
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.height.mas_equalTo(40);
        }];
    }
    
    if (self.isPresent) {
        [self.otherLoginWay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.sureBtn.mas_bottom).offset(10);
            make.left.equalTo(weakSelf.sureBtn);
            make.right.equalTo(weakSelf.sureBtn);
            make.height.mas_equalTo(40);
        }];
        
    }
    
    if (self.getMessageType == RegistPhoneUser) {
        [self.serviceAgreementView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.sureBtn.mas_bottom).offset(10);
            make.left.equalTo(weakSelf.sureBtn);
            make.right.equalTo(weakSelf.sureBtn);
            make.height.mas_equalTo(20);
        }];
    }else if (self.getMessageType == FindPassword){
        [self.onlineServiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.sureBtn.mas_bottom).offset(15);
            make.size.mas_equalTo(CGSizeMake(80, 20));
            make.right.equalTo(weakSelf.sureBtn);
        }];
        
        [self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.onlineServiceBtn.mas_left);
            make.centerY.equalTo(weakSelf.onlineServiceBtn);
            make.height.mas_equalTo(20);
        }];
    }
    
    /*
    CGSize tipsSize = [self.tipsLab.text boundingRectWithSize:CGSizeMake(self.bgView.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tipsLab.font} context:nil].size;
    
    [self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.sureBtn.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.bgView).offset(0);
        make.size.mas_equalTo(CGSizeMake(weakSelf.bgView.width, tipsSize.height+5));
    }];
    */
    
}


/*
 * 使用NSTimer来计时
 * 后期考虑GCD来计时,避免内存泄漏
 */
- (void)currentTime{
    //*** 2、开启计时器
    if (!_telCodeTimer) {
        _timerNumber = 60;
        _telCodeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getTelCodeBtn) userInfo:nil repeats:YES];
        [_telCodeTimer fire];
    }

}


-(void)getTelCodeBtn{
    _timerNumber -- ;
    if (_timerNumber == 0) {
        
        [_telCodeTimer invalidate];
        _telCodeTimer = nil;
        [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getCodeBtn setBackgroundColor:code_Color];
        _getCodeBtn.layer.cornerRadius = 15;
        _getCodeBtn.layer.masksToBounds = YES;

        self.getCodeBtn.enabled = YES;
        
    }else{
        [self.getCodeBtn setBackgroundColor:[UIColor grayColor]];
//        [_getCodeBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"notouch" withType:@"png"] forState:UIControlStateNormal];
//        [_getCodeBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"notouch" withType:@"png"] forState:UIControlStateHighlighted];

        _getCodeBtn.layer.cornerRadius = 15;
        _getCodeBtn.layer.masksToBounds = YES;
        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"(%lds)",(long)_timerNumber] forState:0];
        self.getCodeBtn.enabled = NO;

    }
}


#pragma mark ----------------------------------------------Click

- (void)otherLoginWayClick:(UIButton *)sender{
    [self.passworTextField resignFirstResponder];
    [self.codeTextField resignFirstResponder];
    
    Weak_Self;
   
        
    
        SSWL_FirstOpenViewController *firstVC = [[SSWL_FirstOpenViewController alloc] init];
        firstVC.isPush = YES;
        firstVC.block = ^{
            if (weakSelf.GetMessageBlock) {
                weakSelf.GetMessageBlock();
            }
        };
        [self.navigationController pushViewController:firstVC animated:NO];
    
    
    
    
}


- (void)touchTap:(UITapGestureRecognizer *)sender{
    
   
    SSWL_CustomerServiceViewController *scVC = [[SSWL_CustomerServiceViewController alloc] init];
    //kfVC.isPush = YES;
//    [self.navigationController pushViewController:scVC animated:YES];
    [self presentViewController:scVC animated:YES completion:^{
        
    }];
    
}


- (void)onlineServiceClick{
    SYLog(@"在线客服");


    SSWL_CustomerServiceViewController *csVC = [[SSWL_CustomerServiceViewController alloc] init];
    [self presentViewController:csVC animated:YES completion:^{
        
    }];
}

/*
 * 获取验证码
 */
- (void)getClick:(id)sender{
    Weak_Self;
    
    NSString *PhoneNumberString;
    if (self.getMessageType == FindPassword) {
        PhoneNumberString = self.phoneNumTextField.text;
    }else if (self.getMessageType == RegistPhoneUser || self.getMessageType == VerificationForPhoneLogin){
        PhoneNumberString = self.accountString;
    }else{
        PhoneNumberString = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber;
    }
    BOOL isTel = [SSWL_PublicTool isValidateTel:PhoneNumberString];
    if (isTel) {
        
        if (self.getMessageType == VerificationForPhoneLogin || self.getMessageType == RegistPhoneUser) {
            [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] loginForPhoneSmsWithPhoneNumber:PhoneNumberString completion:^(BOOL isSuccess, id  _Nullable respones) {
                if (isSuccess) {
//                    SYLog(@"-------respones:%@", respones);
                    //                    weakSelf.account = respones[@"data"][@"account"];
                    SYLog(@"------account:%@", weakSelf.account);
                    [weakSelf currentTime];
                }else{
//                    SYLog(@"-------respones:%@", respones);
                    //882136
                    [SSWL_PublicTool showHUDWithViewController:weakSelf Text:respones[@"msg"]];
                    
                }
            } failure:^(NSError * _Nullable error) {
                
            }];
            return;
        }
        
        SYLog(@"获取验证码");

        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getFindPasswordSmsWithPhoneNumber:PhoneNumberString completion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
//                SYLog(@"-------respones:%@", respones);
                weakSelf.account = respones[@"data"][@"account"];
                SYLog(@"------account:%@", weakSelf.account);
                [weakSelf currentTime];
            }else{
//                SYLog(@"-------respones:%@", respones);
                //882136
                [SSWL_PublicTool showHUDWithViewController:weakSelf Text:respones[@"msg"]];
                
            }
        } failure:^(NSError *error) {
            
        }];
        
    }else{
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写正确的手机号码"];
    }
}


- (void)showClick:(id)sender{
    self.isShowPassword = !self.isShowPassword;
    if (self.isShowPassword) {
        [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_on" withType:@"png"] forState:UIControlStateNormal];
        self.passworTextField.secureTextEntry = NO;
        
        SYLog(@"----显示密码");
        
    }else{
        [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
        self.passworTextField.secureTextEntry = YES;
        
        SYLog(@"----不显示密码");
    }
}

- (void)backClick
{
    SYLog(@"返回");
   
    [self.navigationController popViewControllerAnimated:NO];

}

- (void)knowClick:(id)sender{
    
    
    
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber > 0) {
        
        self.page ++;
        
        NSString *string = [NSString stringWithFormat:@"%d", self.page];
        NSString *jsString = [NSString stringWithFormat:@"nextPage('%@')", string];
        [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            SYLog(@"----------%@____%@", result, error);
        }];
        
        if (([SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber - self.page) == 1) {
            [self.knowBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"knowBtn" withType:@"png"] forState:UIControlStateNormal];
        }
        if (self.page == [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber || [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber == 1) {
            self.tipsView.hidden = YES;
            self.tipsView = nil;
            self.webView = nil;
            [self createFloatWindowIntoGame];
   
        }
    }
}



- (void)sureClick:(UIButton *)sender{
   
    
    switch (sender.tag) {
        case 1000:
        {
            [self findPasswordType];
        }
            break;
           
        case 1001:
        {
            [self registerAndLoginType];
        }
            break;
            
        case 1002:
        {
            
        }
            break;
            
        case 1003:
        {
            [self loginToVerificationCodeType];
        }
            break;
            
        default:
            break;
    }
   
    //
    
}

- (void)loginToVerificationCodeType{
    Weak_Self;
    if (self.codeTextField.text.length < 1) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写验证码"];
        return;
    }
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.label.text = @"正在登录";
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] phoneLoginWithPhoneNumber:self.accountString code:self.codeTextField.text completion:^(BOOL isSuccess, id  _Nullable resp, NSString *_Nullable message) {
        if (isSuccess) {
            NSDictionary *loginDic = resp[@"data"];
//            SYLog(@"------respones:%@", resp);
#pragma mark ----------------------------------------------强制进入身份证页面
//            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check = YES;
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check && ! [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard) {
                [weakSelf checkIdentityBeforeLoggingIsConstraint:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.reg_User_Idcard_Check_Need completion:^(AddIdentityInfoViewClickStates addViewClickStates) {
                    if (addViewClickStates == 0) {
                        [weakSelf verificationFailedGoToLoginView];
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{

                            int authType = [loginDic[@"auth_type"] intValue];
                            if (authType == 1) {
                                [weakSelf.HUD hideAnimated:YES];
                                
                                [weakSelf alertVerifyDynamicView];
                                
                                
                            }else{
                                self.HUD.mode = MBProgressHUDModeText;
                                weakSelf.HUD.label.text = @"登录成功";
                                [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
                                
                                [weakSelf readTipsForLoginAfter];
                                
                                
                            }
                            
                        });
                    }
                }];
                
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{

                    int authType = [loginDic[@"auth_type"] intValue];
                    if (authType == 1) {
                        [weakSelf.HUD hideAnimated:YES];
                        
                        [weakSelf alertVerifyDynamicView];
                        
                        
                    }else{
                        self.HUD.mode = MBProgressHUDModeText;
                        weakSelf.HUD.label.text = @"登录成功";
                        [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
                        
                        [weakSelf readTipsForLoginAfter];
                        
                        
                    }
                    
                });
                
            }      
        }else{
            self.HUD.mode = MBProgressHUDModeText;
            weakSelf.HUD.label.text = resp[@"msg"];
            [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
}

- (void)findPasswordType{
    Weak_Self;

    BOOL isTel = [SSWL_PublicTool isValidateTel:self.phoneNumTextField.text];
    if (self.phoneNumTextField.text.length < 1){
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写手机号码"];
        return;
    }
    
    if (!isTel) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写正确的手机号码"];
        
        return;
    }
    if (self.codeTextField.text.length < 1) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写验证码"];
        return;
    }

    SSWL_ChangePassWordController *cpVC = [[SSWL_ChangePassWordController alloc] init];
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkSmsWithPhone:self.phoneNumTextField.text code:self.codeTextField.text completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
//            SYLog(@"----respones:%@", respones);
            cpVC.account = self.account;
            cpVC.code = self.codeTextField.text;
            cpVC.phoneNum = self.phoneNumTextField.text;
            [self.navigationController pushViewController:cpVC animated:NO];
        }else{
//            SYLog(@"----respones:%@", respones);
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:respones[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}


- (void)registerAndLoginType{
    Weak_Self;

    self.serviceAgreementView.AgreeBlock = ^(BOOL isAgree) {
        weakSelf.isAgree = isAgree;
    };
    
    SYLog(@"%d", self.isAgree);
    if (self.isAgree) {
        SYLog(@"-------------登录并注册");
        if (self.codeTextField.text.length < 1) {
            [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写验证码"];
            return;
        }
        
        
        
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] registWithUserName:self.accountString password:nil regType:RegistTypePhone code:self.codeTextField.text completion:^(BOOL isSuccess, id  _Nullable respones) {
            #pragma mark ----------------------------------------------强制注册成功
//            isSuccess = YES;
            if (isSuccess) {
                
                NSString *userName = [NSString stringWithFormat:@"%@", respones[@"data"][@"username"]];
                NSString *password = [NSString stringWithFormat:@"%@", respones[@"data"][@"password"]];
//                userName = @"13794432640";
//                password = @"26db58";
                [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] loginWithUserName:userName password:password completion:^(BOOL isSuccess, id  _Nullable respones) {
                    if (isSuccess) {
                        SYLog(@"--------手机登录成功");
                        #pragma mark ----------------------------------------------强制进入身份证页面
//                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.reg_User_Idcard_Check = YES;
                        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.reg_User_Idcard_Check && ! [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard) {
                            [weakSelf checkIdentityBeforeLoggingIsConstraint:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.reg_User_Idcard_Check_Need completion:^(AddIdentityInfoViewClickStates addViewClickStates) {
                                if (addViewClickStates == 0) {
                                    [weakSelf verificationFailedGoToLoginView];
                                }else{
                                    [weakSelf readTipsForLoginAfter];
                                }
                            }];

                        }else{
                            [weakSelf readTipsForLoginAfter];
                        }
                        
                    }
                } failure:^(NSError * _Nullable error) {
                    [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
                }];
                
            }else{
                [SSWL_PublicTool showHUDWithViewController:weakSelf Text:respones[@"mag"]];
            }
        } failure:^(NSError * _Nullable error) {
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
        }];
        
        
    }else{
//        [SSWL_PublicTool showHUDWithViewController:self Text:@"请同意'用户服务协议'"];
        [SSWL_PublicTool showAlertToViewController:self alertControllerTitle:@"提示" alertControllerMessage:@"请同意'用户服务协议'" alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:nil reportHandler:nil completion:nil];
    }
}


/**
 创建验证身份证页面

 @param isConstraint 是否强制绑定
 @param completion 完成后回调
 */
- (void)checkIdentityBeforeLoggingIsConstraint:(BOOL)isConstraint completion:(void(^)(AddIdentityInfoViewClickStates addViewClickStates))completion{
    
    [self.HUD hideAnimated:YES];
    self.addIdentityView = [[SSWL_AddIdentityInfo alloc] initIfNeedMandatoryBindIdInfo:isConstraint viewController:self];
//    self.addIdentityView.addIdentityInfoViewBlock = completion;
    self.addIdentityView.addIdentityInfoViewBlock = ^(AddIdentityInfoViewClickStates addViewStates) {
        if (completion) {
            completion(addViewStates);
        }
    };
    self.addIdentityView.center = self.view.center;
    self.bgView.hidden = YES;
    [self.view addSubview:self.addIdentityView];
    
}


- (void)verificationFailedGoToLoginView{
    SSWL_LoginViewController *loginVC = [[SSWL_LoginViewController alloc] init];
    loginVC.isPush = YES;
    loginVC.isOnline = YES;
    loginVC.block = self.GetMessageBlock;
    [self.navigationController pushViewController:loginVC animated:NO];
    self.addIdentityView.hidden = YES;
    self.addIdentityView = nil;
    self.bgView.hidden = NO;
    [self.HUD hideAnimated:YES];
}

- (void)alertVerifyDynamicView{
    Weak_Self;
    [self.view addSubview:self.verifyDynamicView];
    self.verifyDynamicView.BtnBlock = ^(BOOL isSuccess, id dic) {
        if (isSuccess) {
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"登录成功"];
            
            [weakSelf readTipsForLoginAfter];
            /*
             if (weakSelf.block) {
             weakSelf.block();
             }
             */
        }else{
            NSString *string = dic[@"msg"];
            if ([string isEqualToString:@"销毁页面"]) {
                weakSelf.verifyDynamicView.hidden = YES;
                weakSelf.verifyDynamicView = nil;
                string = @"取消登录";
            }
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:string];
        }
    };
    
    
}

- (void)readTipsForLoginAfter{
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] noticeBeforTheLoginCompletion:^(BOOL isSuccess, id respones) {
        #pragma mark ----------------------------------------------强制登录公告
//        isSuccess = YES;
        if (isSuccess) {
            weakSelf.isLoginAfter = YES;
            
            NSDictionary *dictNotice = respones[@"data"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber = [dictNotice[@"number"] intValue];
            
//            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber = 6;
            
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber > 1) {
                [self.knowBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"c_01" withType:@"png"] forState:UIControlStateNormal];
                
            }else if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber <= 1){
                [self.knowBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"knowBtn" withType:@"png"] forState:UIControlStateNormal];
                
            }
            
            [weakSelf.view addSubview:self.tipsView];
            weakSelf.tipsView.center = self.view.center;
            
            [weakSelf layouttipsView];
            weakSelf.requestUrl = [NSString stringWithFormat:@"%@?platform=ios&token=%@", SSWL_URL_BeforTips,[SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken];
            
            [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
            weakSelf.tipsView.hidden = NO;
            [weakSelf.view insertSubview:self.tipsView atIndex:8];
            
        }else{
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber = 0;
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl.length > 0) {
                [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] creatHtmlGameWithUrl:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl zUrl:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString];
            }
            [weakSelf createFloatWindowIntoGame];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)layouttipsView{
    [self.tipsView addSubview:self.ggLogo];
    [self.tipsView addSubview:self.knowBtn];
    
    [self setUpWebView];

    Weak_Self;
    [self.ggLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.tipsView.mas_top).offset(15);
        make.centerX.equalTo(weakSelf.tipsView);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    
    [self.knowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.tipsView.mas_bottom).offset(-15);
        make.centerX.equalTo(weakSelf.tipsView);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    [self judgeNet];
    
}


#pragma mark ------------------------------------------------WKWebView Delegate & Method
//自己看.h文件
- (void)setUpWebView{
    self.webHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.webHUD.mode = MBProgressHUDModeIndeterminate;
    self.webHUD.label.text = @"正在加载";
    
    if (!self.webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        configuration.preferences = preferences;
        
        
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(10, 60, self.tipsView.width - 20, self.tipsView.height - 120)];
        self.webView.backgroundColor = [UIColor whiteColor];
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        self.webView.scrollView.bounces = NO;
        //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self.tipsView addSubview:self.webView];
        
        
    }
}

// 判断网络
- (void)judgeNet
{
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getNetWorkStateBlock:^(NSInteger netStatus) {
        if (netStatus == 1 || netStatus == 2) {
            [self isNetWorking:YES];
            if (self.time) {
                dispatch_source_cancel(_time);
                
            }
            
        }else{
            [self webViewDidLoadFail];
            [self isNetWorking:NO];
        }
    }];
    
    if (![SSWL_BasiceInfo sharedSSWL_BasiceInfo].haveInterNet) {
        
    }else{
    }
    [self keepNetWoking];
    
    
}

- (void)keepNetWoking{
    _secNum = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //创建一个定时器
    self.time = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    //设置时间间隔
    uint64_t interval = (uint64_t)(1.0* NSEC_PER_SEC);
    //设置定时器
    dispatch_source_set_timer(self.time, start, interval, 0);
    //设置回调
    SYLog(@"再次刷新网络");
    
    dispatch_source_set_event_handler(self.time, ^{
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].haveInterNet) {
            //            _time = nil; // 将 dispatch_source_t 置为nil
            dispatch_source_cancel(_time);
            _secNum = 0;
        }else{
            _secNum++;
            if (_secNum == 5) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self judgeNet];
                    dispatch_source_cancel(_time);
                    _secNum = 0;
                    
                });
            }
            SYLog(@"重读网络%d", _secNum);
            
        }
    });
    
    
    
    //由于定时器默认是暂停的所以我们启动一下
    //启动定时器
    dispatch_resume(self.time);
    
    
}



- (void)webViewDidLoadFail{
    self.webHUD.mode = MBProgressHUDModeText;
    self.webHUD.label.text = @"网速不给力";
    [self.webHUD hideAnimated:YES afterDelay:0.5f];
    //    self.webHUD = nil;
    //    [self isNetWorking:NO];
    
}



- (void)isNetWorking:(BOOL)isNetWorking{
    if (!isNetWorking) {
        SYLog(@"没网");
        if (self.webView) {
            
            self.webView.hidden = YES;
            [self.webView removeFromSuperview];
            [self.progressView setHidden:YES];
            [self.progressView removeFromSuperview];
            self.progressView = nil;
            
            [self.tipsView addSubview:self.errorView];
            
            
        }
    }
}


/**
 进入游戏, 判断是否是h5, 是否开始悬浮窗
 */
- (void)createFloatWindowIntoGame{
    Weak_Self;
    [SSWL_PublicTool createFloatWindowIntoGameAndPostALCDeviceIdCompletion:^(BOOL canIntoGame) {
       
        if (canIntoGame) {
            if (_GetMessageBlock) {
                _GetMessageBlock();
            }
        }else{
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"登录失败"];
        }
      
    }];
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if ([message.name isEqualToString:@"getInfo"]) {
        [self sendDataForPrama:message.body messageName:message.name];
    }
    
}

/*处理签名*/
- (void)sendDataForPrama:(NSDictionary *)param messageName:(NSString *)name{
    NSString *jsString = [NSString string];
    //    NSArray *paramArr = [NSArray array];
    //    param = @{
    //              @"token"      :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].token,
    //              };
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:param];
    NSString *string = [NSString stringWithFormat:@"%@", dict[@"sign"]];
    if (string.length > 0) {
        [dict removeObjectForKey:@"sign"];
    }
    //        [dict setObject:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].token forKey:@"token"];
    //        [dict setValue:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].token forKey:@"token"];
    NSString *sign = [SSWL_PublicTool makeSignStringWithParams:dict];
    jsString = [NSString stringWithFormat:@"getiOSSign('%@')", sign];
    
    //    paramArr = [param allValues];
    SYLog(@"-----------------dict:%@------------", dict);
    [dict setObject:sign forKey:@"sign"];
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        SYLog(@"----------%@____%@", result, error);
    }];
    
    
}



#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.webHUD hideAnimated:YES afterDelay:0.3f];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    SYLog(@"%s",__FUNCTION__);
    
    [self webViewDidLoadFail];
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    [self webViewDidLoadFail];
    
}


#pragma mark WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    SYLog(@"%s",__FUNCTION__);
    [self webViewDidLoadFail];
    
}



#pragma mark --- 监听键盘
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    
    
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    //    SYLog(@"打印键盘的高度：%d",height);
    
    //记录注册视图的Y和H值
    self.viewY = self.bgView.y;
    self.viewH = self.bgView.height;
    SYLog(@"viewY:%d__________viewH:%d", self.viewY, self.viewH);
    
    int textH = self.textFieldY + self.bgView.y + self.phoneNumTextField.height;
    int heighToBottom = (int)self.view.height - textH;
    
    if (height > heighToBottom) {
        int differHeight = height - heighToBottom + 30;
        self.bgView.frame = CGRectMake(self.bgView.x, self.bgView.y - differHeight, self.bgView.width, self.bgView.height);
    }
    
}

#pragma mark ----------------------------------------------回收键盘
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.bgView.frame = CGRectMake(self.bgView.x, self.viewY, self.bgView.width, self.bgView.height);
    self.bgView.center = self.view.center;
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}





#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.phoneNumTextField || textField == self.codeTextField) {
        if (textField.isFirstResponder) {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.textFieldY = textField.y;
}


# pragma mark --------------------------------------------------------------- 输入框输入的文字限制

-(void)textFieldEditChanged:(NSNotification *)obj{
    
    
    NSString *regex = @"^([0-9]+)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isEmpty = [SSWL_PublicTool isEmpty:self.phoneNumTextField.text];
    if ((self.phoneNumTextField.text.length > 0) || (self.codeTextField.text.length > 0)) {
        if ([self.phoneNumTextField isFirstResponder]) {
            if(![pred evaluateWithObject:self.phoneNumTextField.text] || isEmpty) {
                [SSWL_PublicTool showHUDWithViewController:self Text:@"请按正确格式输入手机号码"];
                self.phoneNumTextField.text = @"";
                [self.phoneNumTextField resignFirstResponder];
                return;
            }
            
        }
        
        
        if ([self.codeTextField isFirstResponder]) {
            if (![pred evaluateWithObject:self.codeTextField.text] || isEmpty) {
                [SSWL_PublicTool showHUDWithViewController:self Text:@"请按正确格式输入验证码"];
                self.codeTextField.text = @"";
                [self.codeTextField resignFirstResponder];
                return;
                
            }
        }

    }
    
    
    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.phoneNumTextField) {
        [self limitTextLengthFor:textField length:11];
    }
    if (textField == self.codeTextField) {
        [self limitTextLengthFor:textField length:10];
    }
}


- (void)limitTextLengthFor:(UITextField *)textField length:(NSInteger)maxLength{
    NSString *toBeString = textField.text;
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > maxLength)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:maxLength];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:maxLength];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
}




#pragma mark ----------------------------------------------懒加载

- (UIButton *)otherLoginWay{
    if (!_otherLoginWay) {
        _otherLoginWay = [UIButton buttonWithType:UIButtonTypeCustom];
        _otherLoginWay.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_otherLoginWay setTitle:@"其他登录>" forState:UIControlStateNormal];
        [_otherLoginWay setTitle:@"其他登录>" forState:UIControlStateHighlighted];
        //[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00]
        
        [_otherLoginWay setBackgroundColor:button_Color];
        _otherLoginWay.layer.cornerRadius = 20;
        _otherLoginWay.layer.masksToBounds = YES;
        [_otherLoginWay setTitleColor:SYWhiteColor forState:UIControlStateNormal];
        [_otherLoginWay setTitleColor:SYWhiteColor forState:UIControlStateHighlighted];
        _otherLoginWay.titleLabel.font = [UIFont systemFontOfSize:18];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_01" withType:@"png"] forState:UIControlStateNormal];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_02" withType:@"png"] forState:UIControlStateHighlighted];
        
        
        
        
        
        [_otherLoginWay addTarget:self action:@selector(otherLoginWayClick:) forControlEvents:UIControlEventTouchUpInside];
        //        _registBtn.tag = 1001;
        
    }
    return _otherLoginWay;
}

- (UIButton *)onlineServiceBtn{
    if (!_onlineServiceBtn) {
        _onlineServiceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [_onlineServiceBtn setTitle:@"在线客服" forState:UIControlStateNormal];
        [_onlineServiceBtn setTitle:@"在线客服" forState:UIControlStateHighlighted];
//        [_onlineServiceBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"zxkf" withType:@"png"] forState:UIControlStateNormal];
        [_onlineServiceBtn addTarget:self action:@selector(onlineServiceClick) forControlEvents:UIControlEventTouchUpInside];
        [_onlineServiceBtn setTitleColor:SYWhiteColor forState:UIControlStateNormal];
        [_onlineServiceBtn setTitleColor:SYWhiteColor forState:UIControlStateHighlighted];
        [_onlineServiceBtn setBackgroundColor:[UIColor colorWithRed:0.15 green:0.84 blue:0.23 alpha:1]];
        _onlineServiceBtn.layer.cornerRadius = 10;
        _onlineServiceBtn.layer.masksToBounds = YES;
    }
    
    return _onlineServiceBtn;
}



- (UIButton *)knowBtn{
    if (!_knowBtn) {
        _knowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_knowBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"knowBtn" withType:@"png"] forState:UIControlStateNormal];
        [_knowBtn addTarget:self action:@selector(knowClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _knowBtn;
}


- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_1_01" withType:@"png"] forState:UIControlStateNormal];
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_2_02" withType:@"png"] forState:UIControlStateHighlighted];
        [_sureBtn setBackgroundColor:button_Color];
        _sureBtn.layer.cornerRadius = 20;
        _sureBtn.layer.masksToBounds = YES;
        switch (self.getMessageType) {
            case FindPassword:
            {
                [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
                [_sureBtn setTitle:@"确定" forState:UIControlStateHighlighted];
                _sureBtn.tag = 1000;

            }
                break;
                
            case RegistPhoneUser:
            {
                [_sureBtn setTitle:@"注册并登录" forState:UIControlStateNormal];
                [_sureBtn setTitle:@"注册并登录" forState:UIControlStateHighlighted];
                _sureBtn.tag = 1001;

            }
                break;
                
            case ModifyPasswordForPhone:
            {
                [_sureBtn setTitle:@"修改密码" forState:UIControlStateNormal];
                [_sureBtn setTitle:@"修改密码" forState:UIControlStateHighlighted];
                _sureBtn.tag = 1002;

            }
                break;
                
            case VerificationForPhoneLogin:
            {
                [_sureBtn setTitle:@"登录" forState:UIControlStateNormal];
                [_sureBtn setTitle:@"登录" forState:UIControlStateHighlighted];
                _sureBtn.tag = 1003;
                
            }
                break;
                
            default:
                break;
        }
        
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_sureBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (UIButton *)getCodeBtn{
    if (!_getCodeBtn) {
        _getCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        [_getCodeBtn setBackgroundColor:code_Color];
        _getCodeBtn.layer.cornerRadius = 15;
        _getCodeBtn.layer.masksToBounds = YES;
        [_getCodeBtn setTitleColor:SYWhiteColor forState:UIControlStateNormal];
        _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        //        [_getCodeBtn setTitle:@"获取验证码" forState:UIControlStateHighlighted];
        _getCodeBtn.enabled = YES;
        [_getCodeBtn addTarget:self action:@selector(getClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _getCodeBtn;
}

- (UIButton *)eyesBtn{
    if (!_eyesBtn) {
        _eyesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
        [_eyesBtn addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _eyesBtn;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//         _backBtn.backgroundColor = [UIColor redColor];
        [_backBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"back" withType:@"png"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backBtn;
}

- (SSWL_BGView *)tipsView{
    if (!_tipsView) {
        _tipsView = [[SSWL_BGView alloc] initWithShowImage:NO showBGView:NO];
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1) {
            _tipsView.height += 100;
            
        }else{
            _tipsView.width += 50;
            
        }
        _tipsView.backgroundColor = [UIColor whiteColor];
        _tipsView.layer.cornerRadius = 10;
        _tipsView.layer.masksToBounds = YES;
    }
    return _tipsView;
}


- (SSWL_BGView *)bgView{
    if (!_bgView) {
        _bgView = [[SSWL_BGView alloc] initWithShowImage:NO showBGView:NO];
        _bgView.backgroundColor = SYWhiteColor;
         _bgView.height = 265;
        if (self.isPresent) {
            _bgView.height += 15;
        }else if (self.getMessageType == FindPassword){
            _bgView.height += 30;
        }
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (SSWL_VerifyDynamicView *)verifyDynamicView{
    if (!_verifyDynamicView) {
        
        _verifyDynamicView = [[SSWL_VerifyDynamicView alloc] initWithFrame:CGRectMake(0, 0, self.bgView.width, 200)];
        _verifyDynamicView.center = self.bgView.center;
        _verifyDynamicView.backgroundColor = [UIColor whiteColor];
        
    }
    return _verifyDynamicView;
}


- (SSWL_ErrorView *)errorView{
    if (!_errorView) {
        _errorView = [[SSWL_ErrorView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchTap:)];
        [_errorView addGestureRecognizer:tap];
    }
    return _errorView;
}

- (SSWL_ServiceAgreementView *)serviceAgreementView{
    if (!_serviceAgreementView) {
        _serviceAgreementView = [[SSWL_ServiceAgreementView alloc] init];
    }
    return _serviceAgreementView;
}

- (UIView *)phoneBorderView{
    
    if (!_phoneBorderView) {
        _phoneBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]
        _phoneBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _phoneBorderView.layer.borderWidth = 1;
        _phoneBorderView.layer.masksToBounds = YES;
        _phoneBorderView.layer.cornerRadius = 20;
        _phoneBorderView.backgroundColor = [UIColor whiteColor];

    }
    
    return _phoneBorderView;
}


- (UIView *)passwordBorderView{
    
    if (!_passwordBorderView) {
        _passwordBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]
        _passwordBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _passwordBorderView.layer.borderWidth = 1;
        _passwordBorderView.layer.masksToBounds = YES;
        _passwordBorderView.layer.cornerRadius = 20;
        _passwordBorderView.backgroundColor = [UIColor whiteColor];
        
    }
    
    return _passwordBorderView;
}

- (UIView *)codeBorderView{
    if (!_codeBorderView) {
        _codeBorderView = [[UIView alloc] init];
        _codeBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _codeBorderView.layer.borderWidth = 1;
        _codeBorderView.layer.masksToBounds = YES;
        _codeBorderView.layer.cornerRadius = 20;
        _codeBorderView.backgroundColor = [UIColor whiteColor];

    }
    
    return _codeBorderView;
}

- (UIImageView *)ggLogo{
    if (!_ggLogo) {
        _ggLogo = [[UIImageView alloc] init];
        [_ggLogo setImage:get_SSWL_Logo];
        
    }
    return _ggLogo;
}

- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        [_logoImgView setImage:get_SSWL_Logo];
    }
    return _logoImgView;
}

- (UIImageView *)phoneImgView{
    if (!_phoneImgView) {
        _phoneImgView = [[UIImageView alloc] init];
        [_phoneImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"tb_phone" withType:@"png"]];
        _phoneImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _phoneImgView;
}

- (UIImageView *)passworImgView{
    if (!_passworImgView) {
        _passworImgView = [[UIImageView alloc] init];
        [_passworImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"tb_pwd" withType:@"png"]];
        _passworImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _passworImgView;
}

- (UIImageView *)codeImgView{
    
    if (!_codeImgView) {
        _codeImgView = [[UIImageView alloc] init];
        [_codeImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"tb_pwd" withType:@"png"]];
        _codeImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _codeImgView;
}

- (UITextField *)phoneNumTextField{
    if (!_phoneNumTextField) {
        _phoneNumTextField = [[UITextField alloc] init];
        _phoneNumTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneNumTextField.placeholder =  @"请输入手机号";
        _phoneNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNumTextField.font = [UIFont systemFontOfSize:14];
        _phoneNumTextField.keyboardType = UIKeyboardTypeNamePhonePad;
        _phoneNumTextField.delegate = self;
        //        self.passTextField.secureTextEntry = YES;
        _phoneNumTextField.returnKeyType = UIReturnKeyDone;
        _phoneNumTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _phoneNumTextField;
}

- (UITextField *)passworTextField{
    if (!_passworTextField) {
        _passworTextField = [[UITextField alloc] init];
        _passworTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passworTextField.placeholder =  @"密码:6-20个字母组合";
        _passworTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passworTextField.font = [UIFont systemFontOfSize:14];
        _passworTextField.keyboardType = UIKeyboardTypeDefault;
        _passworTextField.delegate = self;
        //        self.passTextField.secureTextEntry = YES;
        _passworTextField.returnKeyType = UIReturnKeyDone;
        _passworTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _passworTextField;
}


- (UITextField *)codeTextField{
    if (!_codeTextField) {
        _codeTextField = [[UITextField alloc] init];
        _codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _codeTextField.placeholder =  @"请输入验证码";
        //    self.codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _codeTextField.font = [UIFont systemFontOfSize:14];
        _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _codeTextField.delegate = self;

        _codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _codeTextField.returnKeyType = UIReturnKeyDone;
    }
    return _codeTextField;
}

- (UILabel *)accountLab{
    if (!_accountLab) {
        _accountLab = [[UILabel alloc] init];
        _accountLab.textAlignment = 0;
        _accountLab.textColor = [UIColor blackColor];
        _accountLab.font = [UIFont systemFontOfSize:18];
        NSString *textString = [NSString stringWithFormat:@"验证手机 : %@", self.accountString];
        _accountLab.text = textString;
        _accountLab = [SSWL_PublicTool changeTextColor:[UIColor grayColor] ChangeTitle:self.accountString Titile:textString ToLabel:_accountLab];
    }
    return _accountLab;
}

- (UILabel *)phoneLineLab{
    if (!_phoneLineLab) {
        _phoneLineLab = [[UILabel alloc] init];
        _phoneLineLab.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
    }
    return _phoneLineLab;
}

- (UILabel *)passwordLineLab{
    if (!_passwordLineLab) {
        _passwordLineLab = [[UILabel alloc] init];
        _passwordLineLab.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
    }
    return _passwordLineLab;
}


- (UILabel *)codeLineLab{
    if (!_codeLineLab) {
        _codeLineLab = [[UILabel alloc] init];
        _codeLineLab.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
    }
    return _codeLineLab;
}

- (UILabel *)tipsLab{
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] init];
        
        //
        NSString *text = @"提示:未绑定手机用户找回密码请点击";
        _tipsLab.textColor = [UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1];
        _tipsLab.font = [UIFont systemFontOfSize:12];
        _tipsLab.text = text;
        //        _tipsLab = [SSWL_PublicTool changeTextColor:[UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0] ChangeTitle:@"您的账号为:" Titile:_tipsLab.text ToLabel:_tipsLab];
        _tipsLab.textAlignment = 1;
        
    }
    return _tipsLab;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
