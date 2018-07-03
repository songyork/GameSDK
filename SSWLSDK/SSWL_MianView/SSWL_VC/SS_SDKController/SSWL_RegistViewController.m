//
//  RegistViewController.m
//  AYSDK
//
//  Created by SDK on 2017/7/25.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_RegistViewController.h"
#import "SSWL_LoginViewController.h"


@interface SSWL_RegistViewController ()<UITextFieldDelegate,UITableViewDataSource,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>


@property (nonatomic, strong) SSWL_BGView *bgView;

@property (nonatomic, strong) SSWL_BGView *tipsView;

@property (nonatomic, strong) SSWL_ErrorView *errorView;

@property (nonatomic, strong) SYSaveTouristInfo *saveTouristInfoView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) MBProgressHUD *webHUD;

@property (nonatomic, strong) SSWL_VerifyDynamicView *verifyDynamicView;

@property (nonatomic ,strong) SSWL_AddIdentityInfo *addIdentityView;

@property (nonatomic ,strong) SSWL_ServiceAgreementView *serviceAgreementView;

@property (nonatomic, assign) BOOL isAgree;

@property (nonatomic, assign) BOOL isShowPassword;//是否展示密码

@property (nonatomic, assign) BOOL isRead;//是否同意

@property (nonatomic, strong) NSDictionary *responesParam;//请求下来的参数

@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic ,strong) UIImageView *logoBG;//logo背景

@property (nonatomic, strong) UIImageView *userImgView;//账号图片

@property (nonatomic, strong) UIImageView *passImgView;//密码图片

@property (nonatomic, strong) UITextField *userTextFiled;//账号

@property (nonatomic, strong) UITextField *passTextField;//密码

@property (nonatomic, strong) UITextField *rePassTextFiled;//在输入密码

@property (nonatomic, strong) UIButton *registBtn;//注册按钮

@property (nonatomic, strong) UIButton *oldUserBtn;//老用户登录

@property (nonatomic, strong) UIButton *touristBtn;//游客模式

@property (nonatomic ,strong) UIButton *eyesBtn;//是否显示密码BTN

@property (nonatomic ,strong) UIButton *readBtn;//打钩√

@property (nonatomic, strong) UIButton *backBtn;//返回(弃用)

@property (nonatomic, strong) UIView *userBorderView;//账号边框

@property (nonatomic, strong) UIView *passBorderView;//密码边框

@property (nonatomic, strong) UIImageView *userBorderImgView;//账号边框

@property (nonatomic, strong) UIImageView *passBorderImgView;//密码边框

@property (nonatomic, strong) UILabel *userLineLab;//分割线

@property (nonatomic, strong) UILabel *passLineLab;//分割线

@property (nonatomic ,strong) UILabel *agreeLab;//我已阅读

@property (nonatomic ,strong) UILabel *dealLab;//通行证注册协议


@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值

@property (nonatomic, strong) UIImageView *bgViewImg;



@property (nonatomic, strong)UIButton *knowBtn;//知道了BTN

@property (nonatomic ,copy) NSString *requestUrl;//请求的链接

@property (nonatomic ,strong) WKWebView *webView;//wkwebview

@property (strong, nonatomic) UIProgressView *progressView;//进度条

@property (nonatomic ,strong) UIImageView *ggLogo;//logo背景

@property (nonatomic, strong)dispatch_source_t time;

@property (nonatomic, assign) int secNum;

@property (nonatomic, assign) int page;

@end

@implementation SSWL_RegistViewController
/*
 * 注销键盘的通知事件
 
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isOnline = YES;
    self.isAgree = YES;
    self.view.backgroundColor = SYNOColor;
    
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
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.userTextFiled];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.passTextField];
    
    [self.view addSubview:self.bgView];
    
   
    self.bgView.center = self.view.center;
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
    
//    [self.bgView addSubview:self.logoBG];

    [self.bgView addSubview:self.logoImgView];
    
    [self.bgView addSubview:self.backBtn];
    
    [self.bgView addSubview:self.userBorderImgView];
    
    [self.bgView addSubview:self.passBorderImgView];
   
    [self.bgView addSubview:self.userBorderView];

    [self.bgView addSubview:self.passBorderView];
    
    [self.bgView addSubview:self.userImgView];

    [self.bgView addSubview:self.passImgView];
    
    [self.bgView addSubview:self.userLineLab];
    
    [self.bgView addSubview:self.passLineLab];
    
    [self.bgView addSubview:self.userTextFiled];
    
    [self.bgView addSubview:self.passTextField];
    
    [self.bgView addSubview:self.eyesBtn];
    
    Weak_Self;
    [self.bgView addSubview:self.serviceAgreementView];
    self.serviceAgreementView.AgreeBlock = ^(BOOL isAgree) {
        weakSelf.isAgree = isAgree;
    };
//    [self.bgView addSubview:self.readBtn];
    
//    [self.bgView addSubview:self.agreeLab];
    
//    [self.bgView addSubview:self.dealLab];
    self.dealLab = [self addGestureRecognizerToView:self.dealLab Tag:100 Type:1];
    
    
    [self.bgView addSubview:self.registBtn];
    
//    [self.bgView addSubview:self.oldUserBtn];
    
//    [self.bgView addSubview:self.touristBtn];

    self.isRead = YES;
    
    self.isShowPassword = NO;
    
    [self layoutSubView];
    
    
    //    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.backBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"back_bt" withType:@"png"] forState:UIControlStateNormal];
    //    [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    //    [self.bgView addSubview:self.backBtn];
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


/*
 * 页面布局
 
 */
- (void)layoutSubView{
    Weak_Self;
    //约束
    /**
    [self.logoBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        make.height.mas_equalTo(68);
    }];
    */
    /**
     
     [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.equalTo(weakSelf.bgView).offset(34);
     make.centerX.equalTo(weakSelf.bgView);
     make.size.mas_equalTo(CGSizeMake(106, 30));
     }];

     */
    
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_6_Plus"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_6s_Plus"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_7_Plus"]){
        [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.bgView).offset(30);
            make.centerX.equalTo(weakSelf.bgView);
            make.size.mas_equalTo(CGSizeMake(150, 30));

            //            make.centerX.equalTo(weakSelf.bgView);
            //            make.size.mas_equalTo(CGSizeMake(180, 35));
        }];

    }else{
        [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.bgView).offset(30);
            make.centerX.equalTo(weakSelf.bgView);
            make.size.mas_equalTo(CGSizeMake(150, 30));

            //            make.centerX.equalTo(weakSelf.bgView);
            //            make.size.mas_equalTo(CGSizeMake(180, 35));
        }];

    }
    CGFloat btnW;
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_SE"]) {
        

        btnW = self.bgView.width - 42;

        [self.userBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(15);
            //            make.centerY.equalTo(weakSelf.userBorderImgView);
            make.left.equalTo(weakSelf.bgView).offset(21);
//            make.right.equalTo(weakSelf.bgView).offset(-21);
//            make.height.mas_equalTo(40);
            make.size.mas_equalTo(CGSizeMake(btnW, 40));

        }];
        
        
        
    }else{
        
        

        btnW = self.bgView.width - 82;

        [self.userBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(15);
            //            make.centerY.equalTo(weakSelf.userBorderImgView);
            make.left.equalTo(weakSelf.bgView).offset(41);
//            make.right.equalTo(weakSelf.bgView).offset(-41);
//            make.height.mas_equalTo(40);
            make.size.mas_equalTo(CGSizeMake(btnW, 40));

        }];
    }
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.centerY.equalTo(weakSelf.logoImgView).offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    /*
    [self.userBorderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.userBorderView);
        make.centerY.equalTo(weakSelf.userBorderView);
        make.size.mas_equalTo(CGSizeMake(btnW + 20, 60));
    }];
    */
    
    [self.userImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.userBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.userBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.userLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.userBorderView.mas_top).offset(8);
        make.bottom.equalTo(weakSelf.userBorderView.mas_bottom).offset(-8);
        make.left.equalTo(weakSelf.userImgView.mas_right).offset(10);
        make.width.mas_equalTo(1);
    }];
    
    [self.userTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.userLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.userBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.userBorderView.mas_right).offset(-5);
    }];
    
    
    
    [self.passBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.userBorderView.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.userBorderView);
        make.right.equalTo(weakSelf.userBorderView);
        make.height.mas_equalTo(40);
        //        make.centerY.equalTo(weakSelf.passBorderImgView);
        //        make.size.mas_equalTo(CGSizeMake(243, 40));
    }];

    /*
    [self.passBorderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.passBorderView);
        make.centerY.equalTo(weakSelf.passBorderView);
        make.size.mas_equalTo(CGSizeMake(btnW + 20, 60));
        
    }];
     */
    
    [self.passImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.passBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.passLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passBorderView.mas_top).offset(8);
        make.bottom.equalTo(weakSelf.passBorderView.mas_bottom).offset(-8);
        make.left.equalTo(weakSelf.passImgView.mas_right).offset(10);
        make.width.mas_equalTo(@1);
    }];
    
    [self.passTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.passBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.passBorderView.mas_right).offset(-40);
    }];

    [self.eyesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passTextField.mas_right).offset(5);
        make.right.equalTo(weakSelf.passBorderView.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(20, 15));
        make.centerY.equalTo(weakSelf.passBorderView);
    }];
    /**
     * 暂时弃用
    [self.readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.top.equalTo(weakSelf.passBorderView.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.agreeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.readBtn);
        make.left.equalTo(weakSelf.readBtn.mas_right).offset(3);
        make.height.mas_equalTo(15);
    }];
    
    [self.dealLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.agreeLab.mas_right).offset(3);
        make.height.mas_equalTo(15);
        make.centerY.equalTo(weakSelf.readBtn);
    }];
    */
    
    [self.registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passBorderView.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.userBorderView);
        make.right.equalTo(weakSelf.userBorderView);
        make.height.mas_equalTo(30);
    }];
   
    
    
    [self.serviceAgreementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.registBtn.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.height.mas_equalTo(20);
    }];
    /*
    [self.touristBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.registBtn.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.userBorderView);
        make.size.mas_equalTo(CGSizeMake(btnW /2 - 15, 30));
        
    }];
    [self.oldUserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.registBtn.mas_bottom).offset(15);
        make.right.equalTo(weakSelf.userBorderView);
        make.left.equalTo(weakSelf.touristBtn.mas_right).offset(30);
        make.height.mas_equalTo(30);
       }];
    */
    
}

/*
 添加手势
 */
- (id)addGestureRecognizerToView:(id)view Tag:(int)tag Type:(NSInteger)type{
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tap:)];
    //    配置属性
    //    轻拍次数
    tapGestureRecognizer.numberOfTapsRequired =1;
    //    轻拍手指个数
    tapGestureRecognizer.numberOfTouchesRequired =1;
    //    讲手势添加到指定的视图上
    
    if (type == 1) {
        UILabel *lab = (UILabel *)view;
        lab.userInteractionEnabled = YES;
        lab.tag = tag;
        [lab addGestureRecognizer:tapGestureRecognizer];
        return lab;
    }else if (type == 2){
        UIImageView *imgV = (UIImageView *)view;
        imgV.userInteractionEnabled = YES;
        imgV.tag = tag;
        [imgV addGestureRecognizer:tapGestureRecognizer];
        return imgV;
    }else if (type == 3){
        UITextView *textV = (UITextView *)view;
        textV.userInteractionEnabled = YES;
        textV.tag = tag;
        [textV addGestureRecognizer:tapGestureRecognizer];
        return textV;
    }
    
    
    return nil;
    
}


- (void)tap:(UITapGestureRecognizer *)sender{

    NSURL *url = [NSURL URLWithString:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].customerService];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            SYLog(@"%d", success);
        }];
    }

    SYLog(@"点击了");
    
}







#pragma mark ----------------------------------------------Click
/**
 * 登录click
 */
- (void)loginClick:(id)sender{
    [self.userTextFiled resignFirstResponder];
    [self.passTextField resignFirstResponder];

    self.isLoginCome = NO;

    [self.navigationController popViewControllerAnimated:NO];
    
    if (self.isLoginCome) {
       
    }else{
        
//        LoginViewController *lVC = [[LoginViewController alloc] init];
//        lVC.isPush = YES;
//        lVC.block = ^{
//            if (_block) {
//                _block();
//            }
//        };
//        [self.navigationController pushViewController:lVC animated:NO];

    }
    
}


/**
 * 注册
 */
- (void)registClick:(UIButton *)sender{
    [self.userTextFiled resignFirstResponder];
    [self.passTextField resignFirstResponder];
    Weak_Self;

   
    if (!self.isAgree) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请同意'上士用户服务协议'"];
        return;
    }
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
       if (sender.tag == 1000) {
           
        if (self.userTextFiled.text.length < 6 || self.userTextFiled.text == nil) {
            [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写账号"];
                return;
        }else{
            //\u4E00-\u9FA5
            NSString *regex = @"^([a-zA-Z0-9]+)$";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            BOOL isEmpty = [SSWL_PublicTool isEmpty:self.userTextFiled.text];
           
            if(![pred evaluateWithObject:self.passTextField.text] || isEmpty) {
                [SSWL_PublicTool showHUDWithViewController:self Text:@"请按规定填写账号"];
                return;
            }
        }
        
        if (self.passTextField.text.length < 6 || self.passTextField.text == nil) {
            [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写密码"];
            return;
        }else{
            NSString *regex = @"^([a-zA-Z0-9]+)$";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            BOOL isEmpty = [SSWL_PublicTool isEmpty:self.passTextField.text];

            if(![pred evaluateWithObject:self.passTextField.text] || isEmpty) {
                [SSWL_PublicTool showHUDWithViewController:self Text:@"请按规定填写密码"];
                return;
            }
//            if ([self.passTextField.text hasPrefix:@" "]) {
//                [self showHUDWithText:@"密码开头不能有空格"];
//                
//                return;
//            }
//            if ([self.passTextField.text hasSuffix:@" "]) {
//                [self showHUDWithText:@"密码最后一位不能有空格"];
//                return;
//            }
        }
        
        [self.HUD removeFromSuperview];
        self.HUD = nil;
        
        SYLog(@"用户注册...");
        
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.label.text = @"正在注册";
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] registWithUserName:self.userTextFiled.text password:self.passTextField.text regType:RegistTypeName code:nil completion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
                weakSelf.HUD.mode = MBProgressHUDModeText;
                weakSelf.HUD.label.text = @"注册成功";

                weakSelf.responesParam = respones[@"data"];
//                SYLog(@"-------responesParam:%@",weakSelf.responesParam);
//                [SSWL_PublicTool saveToken:weakSelf.responesParam[@"token"]];
                [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] loginWithUserName:weakSelf.userTextFiled.text password:weakSelf.passTextField.text completion:^(BOOL isSuccess, id respones) {
                    if (isSuccess) {
#pragma mark ----------------------------------------------强制进入身份证页面
    //                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.reg_User_Idcard_Check = YES;
                        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.reg_User_Idcard_Check && ! [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard) {
                            [weakSelf checkIdentityBeforeLoggingIsConstraint:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.reg_User_Idcard_Check_Need completion:^(AddIdentityInfoViewClickStates addViewClickStates) {
                                if (addViewClickStates == 0) {
                                    [weakSelf verificationFailedGoToLoginView];
                                }else{
                                    weakSelf.HUD.label.text = @"登录成功";
                                    [weakSelf.HUD hideAnimated:YES];
                                    
                                    [weakSelf readTipsForLoginAfterWhitIsTourist:NO];                                }
                            }];
                            
                        }else{
                            weakSelf.HUD.label.text = @"登录成功";
                            [weakSelf.HUD hideAnimated:YES];
                            
                            [weakSelf readTipsForLoginAfterWhitIsTourist:NO];
                            
                        }
     
                    }else{
                        weakSelf.HUD.mode = MBProgressHUDModeText;
                       
                        weakSelf.HUD.label.text = respones[@"msg"];

                       
                        [weakSelf.HUD hideAnimated:YES afterDelay:1];
                        
//                        SYLog(@"----respones:%@,----message:%@", respones, respones[@"msg"]);

                    }
                } failure:^(NSError * _Nullable error) {
                    [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
                }];
                }else{
                    weakSelf.HUD.mode = MBProgressHUDModeText;
                    NSString *msg = [NSString stringWithFormat:@"%@", respones[@"msg"]];
                    if (msg.length < 1) {
                        msg = @"登录失败";
                    }
                    weakSelf.HUD.label.text = msg;
                    [weakSelf.HUD hideAnimated:YES afterDelay:1];
//                    SYLog(@"----respones:%@,----message:%@", respones, respones[@"msg"]);
                }
        } failure:^(NSError * _Nullable error) {
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
        }];
        
    }else{
        SYLog(@"游客登录....");

        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.HUD.mode = MBProgressHUDModeIndeterminate;   //选择不同类型的mode；
        _HUD.label.text = @"正在登录..." ;
        
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] registTouristCompletion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
//                SYLog(@"----respones:%@,----message:%@", respones, respones[@"msg"]);
                

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                    int authType = [respones[@"data"][@"auth_type"] intValue];
                    if (authType == 1) {
                        [weakSelf.HUD hideAnimated:YES];
                        [weakSelf alertVerifyDynamicView];
                    }else{
                        self.HUD.mode = MBProgressHUDModeText;
                        weakSelf.HUD.label.text = @"登录成功";
                        [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
                        //*** 回调消除登录的window
                        [weakSelf readTipsForLoginAfterWhitIsTourist:YES];

                    }
                });

                
            }else{
//                SYLog(@"----respones:%@,----message:%@", respones, respones[@"msg"]);
                weakSelf.HUD.mode = MBProgressHUDModeText;
                
                weakSelf.HUD.label.text = respones[@"msg"];
               
                [weakSelf.HUD hideAnimated:YES afterDelay:1];
//                [weakSelf.HUD removeFromSuperview];
//                weakSelf.HUD = nil;

            }
        } failure:^(NSError * _Nullable error) {
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
        }];
        
       
    }
    
}

/**
 创建验证身份证页面
 
 @param isConstraint 是否强制绑定
 @param completion 完成后回调
 */
- (void)checkIdentityBeforeLoggingIsConstraint:(BOOL)isConstraint completion:(void(^)(AddIdentityInfoViewClickStates addViewClickStates))completion{
    
    Weak_Self;
    self.addIdentityView = [[SSWL_AddIdentityInfo alloc] initIfNeedMandatoryBindIdInfo:isConstraint viewController:self];
    self.addIdentityView.addIdentityInfoViewBlock = ^(AddIdentityInfoViewClickStates addViewStates) {
        if (completion) {
            completion(addViewStates);
        }
    };
    self.addIdentityView.center = self.view.center;
    self.bgView.hidden = YES;
    [self.view addSubview:self.addIdentityView];
    
}
- (void)alertVerifyDynamicView{
    Weak_Self;
    [self.view addSubview:self.verifyDynamicView];
    self.verifyDynamicView.BtnBlock = ^(BOOL isSuccess, id dic) {
        if (isSuccess) {
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"登录成功"];
            [weakSelf readTipsForLoginAfterWhitIsTourist:NO];
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

- (void)verificationFailedGoToLoginView{
    [self backClick];
}

- (void)backClick
{
    SYLog(@"返回");
    [self.navigationController popViewControllerAnimated:NO];
}


/**
 * 暂时弃用
 */
- (void)readClick:(id)sender{
    self.isRead = !self.isRead;
    
    if (self.isRead) {
        [self.readBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"v_2" withType:@"png"] forState:UIControlStateNormal];
        SYLog(@"已同意");
    }else{
         [self.readBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"v_1" withType:@"png"] forState:UIControlStateNormal];
        SYLog(@"不同意");
    }
    
    
}

/*
 * 展示或者隐藏密码
 */
- (void)showClick:(id)sender{
    
    self.isShowPassword = !self.isShowPassword;
    if (self.isShowPassword) {
         [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_on" withType:@"png"] forState:UIControlStateNormal];
        self.passTextField.secureTextEntry = NO;

        SYLog(@"----显示密码");

    }else{
        [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
        self.passTextField.secureTextEntry = YES;

        SYLog(@"----不显示密码");
    }
    
    
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



- (void)readTipsForLoginAfterWhitIsTourist:(BOOL)isTourist{
    
    Weak_Self;

    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] noticeBeforTheLoginCompletion:^(BOOL isSuccess, id respones) {
       
        if (isSuccess) {
           // weakSelf.isLoginAfter = YES;

            NSDictionary *dictNotice = respones[@"data"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber = [dictNotice[@"number"] intValue];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                [weakSelf.view addSubview:self.tipsView];
                weakSelf.tipsView.center = self.view.center;
                if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber > 1) {
                    [self.knowBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"c_01" withType:@"png"] forState:UIControlStateNormal];
                    
                }else if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber <= 1){
                    [self.knowBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"knowBtn" withType:@"png"] forState:UIControlStateNormal];
                    
                }
                [weakSelf layouttipsView];
                weakSelf.requestUrl = [NSString stringWithFormat:@"%@?platform=ios&token=%@", SSWL_URL_BeforTips, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken];
                [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
                weakSelf.tipsView.hidden = NO;
                [weakSelf.view insertSubview:self.tipsView atIndex:8];
                
            });
            
        }else{
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber = 0;
            if (isTourist) {
#pragma mark ------------------------------------------------ 测试保存页面

//                [SSWL_PublicTool saveFirstOpen:NO];
                if (![SSWL_PublicTool getCurrenFirstOpen]) {
                    self.saveTouristInfoView = [[SYSaveTouristInfo alloc] initWithViewController:self];
                    [self.view addSubview:self.saveTouristInfoView];
                    self.saveTouristInfoView.buttonBlock = ^(ScreenshotState screenshotState) {
                        switch (screenshotState) {
                            case SaveSuccess:
                            {
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"屏幕截图已保存到相册,请妥善保管"];
                                    
                                    [SSWL_PublicTool saveFirstOpen:YES];
                                    [weakSelf createFloatWindowIntoGame];
                                });
                               
                                /*
                                [SSWL_PublicTool showAlertToViewController:weakSelf alertControllerTitle:nil alertControllerMessage:@"屏幕截图已保存到相册,请妥善保管" alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:^(UIAlertAction * _Nonnull action) {
                                    [weakSelf createFloatWindowIntoGame];
                                } reportHandler:nil completion:^{
                                    
                                }];
                                 */
                            }
                                break;
                                
                            case SaveCancel:
                            {
                                
                                    [SSWL_PublicTool saveFirstOpen:YES];
                                    [weakSelf createFloatWindowIntoGame];
                                
                                
                            }
                                break;
                                
                            case SaveFailure:
                            {
                                
                               
                                
                            }
                                break;
                                
                            case LoadResourceError:
                            {
                                /*
                                 [UIView animateWithDuration:0.3 animations:^{
                                 weakSelf.saveTouristInfoView.size = CGSizeMake(0, 0);
                                 } completion:^(BOOL finished) {
                                 [weakSelf.saveTouristInfoView removeFromSuperview];
                                 weakSelf.saveTouristInfoView = nil;
                                 }];
                                 */
                                SYLog(@"访问出错");
                            }
                                break;
                                
                            default:
                                break;
                        }
                    };
                    
                }else{
                    [weakSelf createFloatWindowIntoGame];
                }
            }else{
                [weakSelf createFloatWindowIntoGame];
            }

           
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)createFloatWindowIntoGame{
    
    Weak_Self;
    [SSWL_PublicTool createFloatWindowIntoGameAndPostALCDeviceIdCompletion:^(BOOL canIntoGame) {
        
        if (canIntoGame) {
            if (_block) {
                _block();
            }
        }else{
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"登录失败"];
        }
        
    }];
}



#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.userTextFiled || textField == self.passTextField) {
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
/*输入框输入的文字限制*/

-(void)textFieldEditChanged:(NSNotification *)obj{
    
    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.userTextFiled) {
        [self limitTextLengthFor:textField length:15];
    }
    if (textField == self.passTextField) {
        [self limitTextLengthFor:textField length:15];
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
    
    
    // 获取键盘弹出动画时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    //记录注册视图的Y和H值
    self.viewY = self.bgView.y;
    self.viewH = self.bgView.height;
    SYLog(@"viewY:%d__________viewH:%d", self.viewY, self.viewH);
    
    int textH = self.textFieldY + self.bgView.y + self.userTextFiled.height;
    int heighToBottom = (int)self.view.height - textH;
    
    if (height > heighToBottom) {
        int differHeight = height - heighToBottom + 30;
        self.bgView.frame = CGRectMake(self.bgView.x, self.bgView.y - differHeight, self.bgView.width, self.bgView.height);
    }
    
    
    float passTextY = self.verifyDynamicView.height + self.verifyDynamicView.y;
    float keyY = self.view.height - height;
    if (self.verifyDynamicView.verifyTextField.isFirstResponder) {
        if (passTextY >= keyY) {
            SYLog(@"输入框被遮挡");
            
            [UIView animateWithDuration:animationDuration animations:^{
                self.verifyDynamicView.y = Screen_Height - (height + self.verifyDynamicView.height) ;
            }];
            
        }
        
    }

}

#pragma mark ----------------------------------------------回收键盘
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    
    
    // 获取键盘弹出动画时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (self.verifyDynamicView.verifyTextField.isFirstResponder) {
        self.verifyDynamicView.center = self.bgView.center;
        
    }else{
        self.bgView.frame = CGRectMake(self.bgView.x, self.viewY, self.bgView.width, self.bgView.height);
        self.bgView.center = self.view.center;
    }
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
    
    /*
     AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
     [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
     
     
     [manager POST:@"https://syuser.shangshiwl.com/?ct=notice&ac=getLoginNoticeContent" parameters:dict  progress:^(NSProgress * _Nonnull uploadProgress) {
     
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
     
     SYLog(@"%@", originalDic);
     
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     
     }];
     */
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






#pragma mark ----------------------------------------------懒加载
//懒加载

- (UIButton *)touristBtn{
    if (!_touristBtn) {
        _touristBtn = [UIButton buttonWithType:UIButtonTypeCustom];
       
        _touristBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        
            [_touristBtn setTitle:@"一键注册" forState:UIControlStateNormal];
            [_touristBtn setTitle:@"一键注册" forState:UIControlStateHighlighted];
            //[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00]
            [_touristBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateNormal];
            [_touristBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateHighlighted];
            
//            [_touristBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_01" withType:@"png"] forState:UIControlStateNormal];
//            [_touristBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_02" withType:@"png"] forState:UIControlStateHighlighted];
       
        
        [_touristBtn addTarget:self action:@selector(registClick:) forControlEvents:UIControlEventTouchUpInside];
        _touristBtn.tag = 1001;
    }
    return _touristBtn;
}


- (UIButton *)oldUserBtn{
    if (!_oldUserBtn) {
        _oldUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _oldUserBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        
            [_oldUserBtn setTitle:@"老用户登录" forState:UIControlStateNormal];
            [_oldUserBtn setTitle:@"老用户登录" forState:UIControlStateHighlighted];
            //[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00]
            [_oldUserBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateNormal];
            [_oldUserBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateHighlighted];

            
//            [_oldUserBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an3_01" withType:@"png"] forState:UIControlStateNormal];
//            [_oldUserBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an3_02" withType:@"png"] forState:UIControlStateHighlighted];

 
        
        
        [_oldUserBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _oldUserBtn;
}

- (UIButton *)registBtn{
    if (!_registBtn) {
        _registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
            [_registBtn setTitle:@"注册" forState:UIControlStateNormal];
            [_registBtn setTitle:@"注册" forState:UIControlStateHighlighted];
            [_registBtn setBackgroundColor:button_Color];
            _registBtn.layer.cornerRadius = 15;
            _registBtn.layer.masksToBounds = YES;
//            [_registBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_01" withType:@"png"] forState:UIControlStateNormal];
//            [_registBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_02" withType:@"png"] forState:UIControlStateHighlighted];
            
//            [_registBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_1_01" withType:@"png"] forState:UIControlStateNormal];
//            [_registBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_2_02" withType:@"png"] forState:UIControlStateHighlighted];

   

        [_registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_registBtn addTarget:self action:@selector(registClick:) forControlEvents:UIControlEventTouchUpInside];
        _registBtn.tag = 1000;
    }
    return _registBtn;
}

- (UIButton *)readBtn{
    if (!_readBtn) {
        _readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_readBtn addTarget:self action:@selector(readClick:) forControlEvents:UIControlEventTouchUpInside];
        [_readBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"v_2" withType:@"png"] forState:UIControlStateNormal];
        
    }
    return _readBtn;
}

- (UIButton *)eyesBtn{
    if (!_eyesBtn) {
        _eyesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
        [_eyesBtn addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _eyesBtn;
}

- (UIButton *)knowBtn{
    if (!_knowBtn) {
        _knowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        //        [_knowBtn setTitle:@"知道了" forState:UIControlStateNormal];
        //        [_knowBtn setTitle:@"知道了" forState:UIControlStateHighlighted];
        [_knowBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"knowBtn" withType:@"png"] forState:UIControlStateNormal];
        //            [_touristBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_2_02" withType:@"png"] forState:UIControlStateHighlighted];
        
        //        _knowBtn.backgroundColor = [UIColor redColor];
        
        
        [_knowBtn addTarget:self action:@selector(knowClick:) forControlEvents:UIControlEventTouchUpInside];
        //        _registBtn.tag = 1001;
        
    }
    return _knowBtn;
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
//        self.bgViewImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _bgView.width, _bgView.height)];
//
//        [self.bgViewImg setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"BG" withType:@"png"]];
//        self.bgViewImg.userInteractionEnabled = YES;
//        [_bgView addSubview:self.bgViewImg];

        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (SSWL_ErrorView *)errorView{
    if (!_errorView) {
        _errorView = [[SSWL_ErrorView alloc] initWithFrame:CGRectMake(10, 60, self.tipsView.width - 20, self.tipsView.height - 120) tipsText:@"数据获取失败"];
        
    }
    return _errorView;
}

- (SSWL_ServiceAgreementView *)serviceAgreementView{
    if (!_serviceAgreementView) {
        _serviceAgreementView = [[SSWL_ServiceAgreementView alloc] init];
    }
    return _serviceAgreementView;
}


- (SSWL_VerifyDynamicView *)verifyDynamicView{
    if (!_verifyDynamicView) {
        _verifyDynamicView = [[SSWL_VerifyDynamicView alloc] initWithFrame:CGRectMake(0, 0, self.bgView.width, 200)];
        _verifyDynamicView.center = self.bgView.center;
        _verifyDynamicView.backgroundColor = [UIColor whiteColor];
        
    }
    return _verifyDynamicView;
}


- (UIView *)userBorderView{
    
    if (!_userBorderView) {
        _userBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]
        _userBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _userBorderView.layer.borderWidth = 1.0f;
        _userBorderView.backgroundColor = [UIColor whiteColor];

        _userBorderView.layer.masksToBounds = YES;
        _userBorderView.layer.cornerRadius = 20;
        
    }
    
    return _userBorderView;
}


- (UIView *)passBorderView{
    if (!_passBorderView) {
        _passBorderView = [[UIView alloc] init];
        _passBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _passBorderView.layer.borderWidth = 1.0f;
        _passBorderView.backgroundColor = [UIColor whiteColor];

        _passBorderView.layer.masksToBounds = YES;
        _passBorderView.layer.cornerRadius = 20;
        
    }
    
    return _passBorderView;
}

- (UIImageView *)ggLogo{
    if (!_ggLogo) {
        _ggLogo = [[UIImageView alloc] init];
        [_ggLogo setImage:get_SSWL_Logo];
        
    }
    return _ggLogo;
}


- (UIImageView *)userBorderImgView{
    
    if (!_userBorderImgView) {
        _userBorderImgView = [[UIImageView alloc] init];
        [_userBorderImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"border01" withType:@"png"]];
 //       _userBorderImgView.contentMode = UIViewContentModeScaleAspectFill;
        //        _userBorderImgView.backgroundColor = [UIColor redColor];
    }
    return _userBorderImgView;
}
    
    
- (UIImageView *)passBorderImgView{
    if (!_passBorderImgView) {
        _passBorderImgView = [[UIImageView alloc] init];
        [_passBorderImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"border02" withType:@"png"]];
//        _passBorderImgView.contentMode = UIViewContentModeScaleAspectFill;
        //        _passBorderImgView.backgroundColor = [UIColor redColor];
    }
    return _passBorderImgView;
}

    

    
    
- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        
            [_logoImgView setImage:get_SSWL_Logo];
            
      

    }
    return _logoImgView;
}
- (UIImageView *)logoBG{
    if (!_logoBG) {
        _logoBG = [[UIImageView alloc] init];
//        [_logoBG setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"bg1" withType:@"png"]];
        [_logoBG setImage:get_BundleImage(@"bg1")];
    }
    return _logoBG;
}


- (UIImageView *)userImgView{
    if (!_userImgView) {
        _userImgView = [[UIImageView alloc] init];
//        [_userImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"id_01" withType:@"png"]];
        [_userImgView setImage:get_BundleImage(@"id_01")];
        _userImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _userImgView;
}

- (UIImageView *)passImgView{
    
    if (!_passImgView) {
        _passImgView = [[UIImageView alloc] init];
//        [_passImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key" withType:@"png"]];
        [_passImgView setImage:get_BundleImage(@"key")];

        _passImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _passImgView;
}

- (UITextField *)userTextFiled{
    if (!_userTextFiled) {
        _userTextFiled = [[UITextField alloc] init];
        _userTextFiled.translatesAutoresizingMaskIntoConstraints = NO;
        
            _userTextFiled.placeholder =  @"账号(6-15个字母或数字)";
            
       
        _userTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userTextFiled.font = [UIFont systemFontOfSize:14];
        _userTextFiled.keyboardType = UIKeyboardTypeDefault;
        _userTextFiled.delegate = self;
//        self.passTextField.secureTextEntry = YES;
        _userTextFiled.returnKeyType = UIReturnKeyDone;
        _userTextFiled.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _userTextFiled;
}

- (UITextField *)passTextField{
    if (!_passTextField) {
        _passTextField = [[UITextField alloc] init];
        _passTextField.translatesAutoresizingMaskIntoConstraints = NO;
        
            _passTextField.placeholder =  @"密码(6-15个字母或数字)";

        

        //    self.passTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passTextField.font = [UIFont systemFontOfSize:14];
        _passTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _passTextField.delegate = self;
        _passTextField.secureTextEntry = YES;
        _passTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _passTextField.returnKeyType = UIReturnKeyDone;
    }
    return _passTextField;
}

- (UILabel *)userLineLab{
    if (!_userLineLab) {
        _userLineLab = [[UILabel alloc] init];
        _userLineLab.backgroundColor = [UIColor blackColor];
    }
    return _userLineLab;
}

- (UILabel *)passLineLab{
    if (!_passLineLab) {
        _passLineLab = [[UILabel alloc] init];
        _passLineLab.backgroundColor = [UIColor blackColor];
    }
    return _passLineLab;
}


- (UILabel *)agreeLab{
    if (!_agreeLab) {
        _agreeLab = [[UILabel alloc] init];
        _agreeLab.text = @"我已阅读并同意";
        _agreeLab.textColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
        _agreeLab.textAlignment = 1;
        _agreeLab.font = [UIFont systemFontOfSize:15];
    }
    return _agreeLab;
}

- (UILabel *)dealLab{
    if (!_dealLab) {
        _dealLab = [[UILabel alloc] init];
        _dealLab.text = @"《通行证注册协议》";
        _dealLab.textColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
        _dealLab.textAlignment = 1;
        _dealLab.font = [UIFont systemFontOfSize:15];
        _dealLab = [SSWL_PublicTool changeTextColor:[UIColor colorWithRed:0.30 green:0.61 blue:0.96 alpha:1.0] ChangeTitle:@"通行证注册协议" Titile:@"《通行证注册协议》" ToLabel:_dealLab];
    }
    return _dealLab;
}


- (NSDictionary *)responesParam{
    if (!_responesParam) {
        _responesParam = [[NSDictionary alloc] init];
        
    }
    return _responesParam;
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
