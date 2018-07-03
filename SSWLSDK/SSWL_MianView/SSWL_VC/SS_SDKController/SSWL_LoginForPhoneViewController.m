
//
//  SYLoginForPhoneViewController.m
//  AYSDK
//
//  Created by songyan on 2018/1/26.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_LoginForPhoneViewController.h"
#import "SSWL_FirstOpenViewController.h"
#import "SSWL_GetCodeForMessageViewController.h"
#import "SSWL_LoginViewController.h"
#import "UsernameTableViewCell.h"
#import "SSWL_UserModel.h"
@interface SSWL_LoginForPhoneViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,SYUserCellDelegate>

@property (nonatomic, strong) SSWL_BGView *bgView;

@property (nonatomic, strong) SSWL_BGView *tipsView;

@property (nonatomic, strong) MBProgressHUD *webHUD;

@property(nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic, strong) SSWL_ErrorView *errorView;

@property (nonatomic, strong) SSWL_VerifyDynamicView *verifyDynamicView;

@property (nonatomic ,strong) SSWL_AddIdentityInfo *addIdentityView;

@property (nonatomic, strong)dispatch_source_t time;


@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic, strong) UIView *userBorderView;//账号边框


@property (nonatomic, strong) UIImageView *userImgView;//账号图片

@property (nonatomic, strong) UITextField *userTextFiled;//账号

@property (nonatomic, strong) UIButton *loginBtn;//登录按钮

@property (nonatomic ,strong) UIButton *arrowBtn;//箭头

@property (nonatomic, strong) UIButton *backBtn;//返回

@property (nonatomic, strong) UIButton *findBtn;//找回密码

@property (nonatomic, strong) UIButton *otherLoginWay;//其他登录方式

@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值

@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic ,strong) NSMutableArray *dataArray;

@property (nonatomic ,strong) NSDictionary *passDic;

@property (nonatomic ,strong) NSDictionary *tokenDict;

@property (nonatomic, assign) BOOL showTable;

@property (nonatomic, strong)UIButton *knowBtn;//知道了BTN

@property (nonatomic ,copy) NSString *requestUrl;//请求的链接

@property (nonatomic ,strong) WKWebView *webView;//wkwebview

@property (strong, nonatomic) UIProgressView *progressView;//进度条

@property (strong, nonatomic) NSString *fastPassStr;//自动登录密码

@property (strong, nonatomic) NSString *fastUserStr;//自动登录账号

@property (nonatomic, assign) BOOL isLoginAfter;//登陆后公告

@property (nonatomic, assign) int page;

@property (nonatomic, assign) int secNum;

@property (nonatomic ,strong) UIImageView *ggLogo;//logo背景

@property (nonatomic ,strong) UIButton *deleteUserInfoBtn;

@end

static NSString *cellID = @"UserCell";


@implementation SSWL_LoginForPhoneViewController

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
    
    
    
    self.isLoginAfter = NO;
    
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
    
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    
    if (self.isPush) {
        [self setUpWebView];
        
        [self makeTheViewForLogin];
    }else{
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsID.length > 0) {
            [self.view addSubview:self.tipsView];
            self.tipsView.center = self.view.center;
            self.requestUrl = [NSString stringWithFormat:@"%@?platform=ios&appid=%@",  SSWL_URL_Tips, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId];
            self.webHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.webHUD.mode = MBProgressHUDModeIndeterminate;
            self.webHUD.label.text = @"正在加载";
            
            [self setUpWebView];
            
            [self layouttipsView];
            
        }else{
            [self setUpWebView];
            
            [self makeTheViewForLogin];
        }
        
    }
   
    
    
}

- (void)layouttipsView{
    [self.tipsView addSubview:self.ggLogo];
    [self.tipsView addSubview:self.knowBtn];
    
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


//自己看.h文件
- (void)setUpWebView{
    
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



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getInfo"];
    
    
    NSMutableArray *nameArr = [NSMutableArray new];
    NSMutableDictionary *passD = [NSMutableDictionary new];

    
    NSArray *arr = [KeyChainWrapper load:SSWLUsernameKey];
    
    for (NSString *key in arr) {
        [nameArr addObject:key];
    }
    
    NSDictionary *passDic = [KeyChainWrapper load:SSWLPasswordKey];
    for (NSString *key in passDic) {
        [passD setObject:[passDic valueForKey:key] forKey:key];
    }
    
    
    
    
   
    
    //    NSString *fastName = [NSString stringWithFormat:@"%@", [KeyChainWrapper load:SSWL_UserName_Fast]];
    //    NSString *fastPass = [NSString stringWithFormat:@"%@", [KeyChainWrapper load:SSWL_Password_Fast]];
    /*
     * 游客登录账号密码
     */
    NSString *fastName = [KeyChainWrapper load:SSWL_UserName_Fast];
    NSString *fastPass = [KeyChainWrapper load:SSWL_Password_Fast];
    
    //    fastPass = @"123456789"; u141557
    /*
     * fastPass.length > 0
     * 游客登录
     */
    if (fastPass.length > 0) {
        //nameArr 不包含fastName 则添加进nameArr
        if (![nameArr containsObject:fastName]) {
            NSInteger index = nameArr.count;
            if (!index) {
                //如果nameArr.count = 0 添加fastName
                [nameArr addObject:fastName];
                
            }else{
                //插入最后一位
                [nameArr insertObject:fastName atIndex:index];
            }
            //保存进字典
            [passD setObject:fastPass forKey:fastName];
        }
    }
    NSDictionary *tokenDic = [KeyChainWrapper load:SYMobilTokenKey];

    self.tokenDict = tokenDic;
    self.passDic = passDic;
    
    if (nameArr.count > 0) {
        for (NSString *key in nameArr) {
            if ([SSWL_PublicTool isValidateTel:key]) {
                self.userTextFiled.text = key;
                [nameArr removeObject:key];
                [nameArr insertObject:self.userTextFiled.text atIndex:0];
                break;
            }else{
                self.userTextFiled.text = [nameArr firstObject];
            }
        }
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:nameArr];
      
        NSString *pass = [NSString stringWithFormat:@"%@", [self.passDic valueForKey:nameArr[0]]];
    }
    
    SYLog(@"---nameArr:%@,------------dict:%@", self.dataArray, self.passDic);
    if (self.isPush) {
        if (self.usernameString.length > 1) {
            [self userLoginWithUsername:self.usernameString];
        }
    }
    
    
}



- (void)viewWillDisappear:(BOOL)animated{
    self.passDic = nil;
    self.dataArray = nil;
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getInfo"];
    self.isPush = NO;
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
    
    [self.bgView addSubview:self.userBorderView];
    
    if (self.isPush) {
        [self.bgView addSubview:self.backBtn];
    }
    
    [self.bgView addSubview:self.userImgView];

    [self.bgView addSubview:self.userTextFiled];

    [self.bgView addSubview:self.arrowBtn];
    
    [self.bgView addSubview:self.loginBtn];
    
    [self.bgView addSubview:self.findBtn];
    
    [self.bgView addSubview:self.otherLoginWay];
    
    
    self.showTable = NO;
    
    [self layoutSubView];
    
}

/*
 
 if (self.isPush) {
 self.isPush = NO;
 [self.navigationController popViewControllerAnimated:NO];
 
 }
 
 */


/*
 * 页面布局
 
 */
- (void)layoutSubView{
    Weak_Self;
    //约束
    
    
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_6_Plus"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_6s_Plus"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_7_Plus"]){
       
    }else{
      
    }
    
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bgView).offset(30);
        make.centerX.equalTo(weakSelf.bgView);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    CGFloat btnW;//记录userBorderView的宽
    
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_SE"]) {
        
        
        btnW = self.bgView.width - 42;
        [self.userBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(15);
            make.left.equalTo(weakSelf.bgView).offset(21);
            //            make.right.equalTo(weakSelf.bgView).offset(-21);
            //            make.height.mas_equalTo(40);
            make.size.mas_equalTo(CGSizeMake(btnW, 40));
        }];
        
        
        
    }else{
        
        
        
        
        btnW = self.bgView.width - 82;
        [self.userBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(15);
            
            make.left.equalTo(weakSelf.bgView).offset(41);
            //            make.right.equalTo(weakSelf.bgView).offset(-41);
            //            make.height.mas_equalTo(40);
            make.size.mas_equalTo(CGSizeMake(btnW, 40));
            
        }];
        
    }
    if (self.isPush) {
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.centerY.equalTo(weakSelf.logoImgView).offset(0);
            make.size.mas_equalTo(CGSizeMake(15, 20));
        }];
    }
    

    
    [self.userImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.userBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.userBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    
    
    [self.userTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.userImgView.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.userBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.userBorderView.mas_right).offset(-40);
    }];
    
        [self.arrowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.userTextFiled.mas_right).offset(5);
//            make.right.equalTo(weakSelf.userBorderView.mas_right).offset(-10);
            make.size.mas_equalTo(CGSizeMake(20, 10));
            make.centerY.equalTo(weakSelf.userBorderView);
        }];
    
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.userBorderView.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.userBorderView);
        make.right.equalTo(weakSelf.userBorderView);
        make.height.mas_equalTo(30);
        
    }];
    
    [self.findBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.loginBtn.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.userBorderView);
        make.size.mas_equalTo(CGSizeMake(btnW /2 - 15, 30));
    }];
    
    
    [self.otherLoginWay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.loginBtn.mas_bottom).offset(15);
        make.right.equalTo(weakSelf.userBorderView);
        make.left.equalTo(weakSelf.findBtn.mas_right).offset(30);
        make.height.mas_equalTo(30);
        //        make.size.mas_equalTo(CGSizeMake(120, 30));
    }];
    
    
    
}



#pragma mark ----------------------------------------------Click

- (void)backClick
{
    SYLog(@"返回");
    [self.navigationController popViewControllerAnimated:NO];
}



- (void)arrowClick:(id)sender{
    Weak_Self;
    self.showTable = !self.showTable;
    [self.bgView addSubview:self.tableView];

    if (self.showTable) {
        
        self.tableView.hidden = NO;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.userTextFiled.mas_bottom);
            make.left.equalTo(weakSelf.userBorderView);
            make.right.equalTo(weakSelf.userBorderView);
            make.height.mas_equalTo(100);
        }];
    }else{
        self.tableView.frame = CGRectZero;
        self.tableView.hidden = YES;
        self.tableView = nil;
    }
}


- (void)userAutoLoginToUserName:(NSString *)userName Password:(NSString *)password{
    Weak_Self;
    
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.label.text = @"正在登录";
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] loginWithUserName:userName password:password completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
            self.HUD.mode = MBProgressHUDModeText;
            weakSelf.HUD.label.text = @"登录成功";
            [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
            weakSelf.HUD.minSize = CGSizeMake(0, 0);
//            SYLog(@"------respones:%@", respones);
            
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
                    [weakSelf readTipsForLoginAfter];
                }
            });
            
        }else{
            weakSelf.HUD.mode = MBProgressHUDModeText;
            
            weakSelf.HUD.label.text = respones[@"msg"];
            
            [weakSelf.HUD hideAnimated:YES afterDelay:1];
            
        }
    } failure:^(NSError * _Nullable error) {
        [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
    }];
}

/*
- (void)loginClick:(id)sender{
    
    AddIdentityInfo *addView = [[AddIdentityInfo alloc] initIfNeedMandatoryBindIdInfo:NO viewController:self];
    addView.center = self.view.center;
    addView.addIdentityInfoViewBlock = ^(AddIdentityInfoViewClickStates addViewStates) {
        SYLog(@"%ld", (long)addViewStates);
    };
    [self.view addSubview:addView];
    self.bgView.hidden = YES;
}
*/

- (void)nextStepClick{
    
  
    /*
     code=0, 账号已经存在
     code=-1, 账号不存在
     code=-2,
     
     */
    
}

- (void)loginClick:(id)sender{
    Weak_Self;
    
    
    
    [self.userTextFiled resignFirstResponder];
    NSString *user;
    NSInteger userType;
    if (self.usernameString.length > 1) {
        user = self.usernameString;
    }else{
        user = self.userTextFiled.text;
    }
    
    if (user.length < 6 || user == nil) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请按规定填写账号"];
        return;
    }else{
        //a-zA-Z0-9
        NSString *regex = @"^1[3,4,5,7,8, 9][0-9]{9}$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//        [pred evaluateWithObject:self.userTextFiled.text]
        BOOL isEmpty = [SSWL_PublicTool isEmpty:user];
        if(isEmpty) {
            [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写账号"];
            return;
        }
        
        
        
        if (![SSWL_PublicTool isValidateTel:user]) {
            userType = 0;
        }else{
            userType = 1;
        }
        
    }
    [self.HUD removeFromSuperview];
    self.HUD = nil;

    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.label.text = @"正在登陆...";
    if ([SSWL_PublicTool isValidateTel:user]) {
        
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkIfTheUserExistsWithUserName:self.userTextFiled.text userType:userType completion:^(BOOL isSuccess, id  _Nullable response) {
            NSInteger code = [response[@"code"] integerValue];
#pragma mark ----------------------------------------------强制进入注册流程
            //        code = -1;
            switch (code) {
                case 0:
                {
                    [self userLoginWithUsername:user];
                }
                    break;
                    
                case -1:
                {
                    [weakSelf.HUD hideAnimated:YES afterDelay:0.5];
                    SSWL_GetCodeForMessageViewController *regPhoneVC = [[SSWL_GetCodeForMessageViewController alloc] init];
                    regPhoneVC.getMessageType = RegistPhoneUser;
                    regPhoneVC.accountString = user;
                    regPhoneVC.GetMessageBlock = self.block;
                    [self.navigationController pushViewController:regPhoneVC animated:NO];
                }
                    break;
                    
                case -2:
                {
                    weakSelf.HUD.mode = MBProgressHUDModeText;
                    weakSelf.HUD.label.text = @"手机号已绑定用户";
                    [weakSelf.HUD hideAnimated:YES afterDelay:0.5];

                }
                    break;
                    
                default:
                    break;
            }
        } failure:^(NSError * _Nullable error) {
            
        }];
    }else{
        [self userLoginWithUsername:user];
    }
}


- (void)userLoginWithUsername:(NSString *)username{
    [self.userTextFiled resignFirstResponder];
    Weak_Self;
    NSString *user = username;
    
    
    self.tokenDict = [KeyChainWrapper load:SYMobilTokenKey];
    NSString *token = [self.tokenDict valueForKey:user];
    if (token.length < 1) {
        token = @"";
    }
    
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkExpiredForToken:token userName:user completion:^(BOOL isSuccess, id  _Nullable resp) {
#pragma mark ----------------------------------------------强制token过期
        //        isSuccess = NO;
        if (isSuccess) {
            NSDictionary *loginDic = resp[@"data"];
//            SYLog(@"------respones:%@", resp);
#pragma mark ----------------------------------------------强制进入身份验证页
            //            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check = YES;
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check && ! [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard) {
                [weakSelf checkIdentityBeforeLoggingIsConstraint:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check_Need completion:^(AddIdentityInfoViewClickStates addViewClickStates) {
                    if (addViewClickStates == 0) {
                        [weakSelf verificationFailedGoToLoginView];
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{

                            int authType = [loginDic[@"auth_type"] intValue];
                            if (authType == 1) {
                                [weakSelf.HUD hideAnimated:YES];
                                
                                [weakSelf alertVerifyDynamicView];
                                
                                
                            }else{
                                weakSelf.HUD.mode = MBProgressHUDModeText;
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
                        weakSelf.HUD.mode = MBProgressHUDModeText;
                        weakSelf.HUD.label.text = @"登录成功";
                        [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
                        
                        [weakSelf readTipsForLoginAfter];
                        
                        
                    }
                    
                });
            }
            
            
            
        }else{
            
            if ([SSWL_PublicTool isValidateTel:user]) {
                [weakSelf.HUD hideAnimated:YES afterDelay:0.5f];
                SSWL_GetCodeForMessageViewController *getVC = [[SSWL_GetCodeForMessageViewController alloc] init];
                getVC.getMessageType = VerificationForPhoneLogin;
                getVC.isPresent = YES;
                getVC.GetMessageBlock = self.block;
                getVC.accountString = user;
                //                [weakSelf presentViewController:getVC animated:YES completion:^{
                //                    getVC.GetMessageBlock = weakSelf.block;
                //                }];
                [weakSelf.navigationController pushViewController:getVC animated:NO];
            }else{
                NSMutableDictionary *passwordDic = [KeyChainWrapper load:SSWLPasswordKey];
                NSString *password = [passwordDic valueForKey:user];
                if (password.length < 1) {
                    NSString *touristUser = [KeyChainWrapper load:SSWL_UserName_Fast];
                    if ([user isEqualToString:touristUser]) {
                        password = [KeyChainWrapper load:SSWL_Password_Fast];
                    }else{
                        password = @"";
                    }
                }
                [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] loginWithUserName:user password:password completion:^(BOOL isSuccess, id  _Nullable respones) {
                    if (isSuccess) {
                        NSDictionary *loginDic = resp[@"data"];
//                        SYLog(@"------respones:%@", resp);
                        
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{

                            int authType = [loginDic[@"auth_type"] intValue];
                            if (authType == 1) {
                                [weakSelf.HUD hideAnimated:YES];
                                
                                [weakSelf alertVerifyDynamicView];
                                
                                
                            }else{
                                weakSelf.HUD.mode = MBProgressHUDModeText;
                                weakSelf.HUD.label.text = @"登录成功";
                                [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
                                
                                [weakSelf readTipsForLoginAfter];
                                
                                
                            }
                            
                        });
                        
                    }else{
                        
                        weakSelf.HUD.mode = MBProgressHUDModeText;
                        weakSelf.HUD.label.text = respones[@"msg"];
                        [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
                        weakSelf.HUD.completionBlock = ^{
                            SSWL_LoginViewController *loginVC = [[SSWL_LoginViewController alloc] init];
                            loginVC.isPush = YES;
                            loginVC.isOnline = weakSelf.isOnline;
                            loginVC.block = ^{
                                if (weakSelf.block) {
                                    weakSelf.block();
                                }
                            };
                            [weakSelf.navigationController pushViewController:loginVC animated:NO];
                        };
                        
                    }
                } failure:^(NSError * _Nullable error) {
                    [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
                }];
            }
            
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)checkIdentityBeforeLoggingIsConstraint:(BOOL)isConstraint completion:(void(^)(AddIdentityInfoViewClickStates addViewClickStates))completion{
    
    
    self.addIdentityView = [[SSWL_AddIdentityInfo alloc] initIfNeedMandatoryBindIdInfo:isConstraint viewController:self];
    self.addIdentityView.addIdentityInfoViewBlock = ^(AddIdentityInfoViewClickStates addViewStates) {
//        _addViewStates = addViewStates;
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
    loginVC.block = self.block;
    [self.navigationController pushViewController:loginVC animated:NO];
    self.addIdentityView.hidden = YES;
    self.addIdentityView = nil;
    self.bgView.hidden = NO;
}


- (void)alertVerifyDynamicView{
    Weak_Self;
    [self.view addSubview:self.verifyDynamicView];
    self.verifyDynamicView.BtnBlock = ^(BOOL isSuccess, id dic) {
        if (isSuccess) {
            weakSelf.HUD.mode = MBProgressHUDModeText;
            weakSelf.HUD.label.text = @"登录成功";
            [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
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
        
        if (isSuccess) {
            weakSelf.isLoginAfter = YES;
            
            NSDictionary *dictNotice = respones[@"data"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber = [dictNotice[@"number"] intValue];
            
            //[SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsNumber = 6;
            
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
            [self createFloatWindowIntoGame];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)findClick:(id)sender{
    
    [self.userTextFiled resignFirstResponder];
    

    SSWL_GetCodeForMessageViewController *fVC = [[SSWL_GetCodeForMessageViewController alloc] init];
    fVC.getMessageType = FindPassword;
    [self.navigationController pushViewController:fVC animated:NO];
    /*
     NSURL *url = [NSURL URLWithString:@"appOne://"];
     if ([[UIApplication sharedApplication] canOpenURL:url]) {
     [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
     SYLog(@"%d", success);
     }];
     }
     */
    
}




- (void)knowClick:(id)sender{
    
    
    
    if (self.isLoginAfter) {
        
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
                self.tipsView = nil;
                self.webView = nil;
                [self createFloatWindowIntoGame];
                
            }
        }
        
        
    }else{
        self.tipsView.hidden = YES;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
        [self makeTheViewForLogin];
    }
    
    
}

- (void)otherLoginWayClick:(UIButton *)sender{
    [self.userTextFiled resignFirstResponder];
    
    
    Weak_Self;
    if (self.isPush) {
        SSWL_LoginViewController *loginVC = [[SSWL_LoginViewController alloc] init];
        loginVC.isPush = YES;
        loginVC.isOnline = self.isOnline;
        loginVC.block = ^{
            if (weakSelf.block) {
                weakSelf.block();
            }
        };
        [self.navigationController pushViewController:loginVC animated:NO];

    }else{
        SSWL_FirstOpenViewController *firstVC = [[SSWL_FirstOpenViewController alloc] init];
        firstVC.isPush = YES;
        firstVC.block = ^{
            if (weakSelf.block) {
                weakSelf.block();
            }
        };
        [self.navigationController pushViewController:firstVC animated:NO];

    }
   

    
    
    
}



- (void)makeTheViewForLogin{
    
    self.page = 0;
    Weak_Self;
//    [NSString stringWithFormat:]
    [self.view addSubview:self.bgView];
    self.bgView.CleanDeviceBlock = ^(BOOL isCleanSuccess) {
        if (isCleanSuccess) {
            [SSWL_PublicTool showAlertToViewController:weakSelf alertControllerTitle:@"清除成功" alertControllerMessage:[NSString stringWithFormat:@"设备号已重置,请彻底关闭应用重新打开"] alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:nil reportHandler:nil completion:nil];
        }else{
            [SSWL_PublicTool showAlertToViewController:weakSelf alertControllerTitle:@"清除失败" alertControllerMessage:[NSString stringWithFormat:@"设备号已清除失败,请重试"] alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:nil reportHandler:nil completion:nil];
        }
        

    };                                   
    //self.bgView.center = self.view.center;
    [self createUI];
    
   
    
    //自动登录
    NSMutableDictionary *fastDic = [KeyChainWrapper load:SSWL_UserLogin_Auto];
    for (NSString *key in fastDic) {
        //获取登录账号 key为账号
        self.fastUserStr = key;
    }
    
    NSString *userToken;
    NSMutableDictionary *tokenDic = [KeyChainWrapper load:SYMobilTokenKey];
    for (NSString *key in tokenDic) {
        if ([key isEqualToString:self.fastUserStr]) {
            userToken = [tokenDic valueForKey:key];
            break;
        }
    }
    self.fastPassStr = fastDic[self.fastUserStr];
    
    if (self.fastPassStr.length > 1) {
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].needAuto) {
            if ([SSWL_PublicTool isValidateTel:self.fastUserStr]) {
                [self userLoginWithUsername:self.fastUserStr];
            }else{
               [self userAutoLoginToUserName:self.fastUserStr Password:self.fastPassStr];
            }
            
        }
        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].needAuto = NO;
        
    }else if (self.fastUserStr.length > 1){
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].needAuto) {
            if ([SSWL_PublicTool isValidateTel:self.fastUserStr]) {
                [self userLoginWithUsername:self.fastUserStr];
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].needAuto = NO;
            }
        }
    }
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
    if (textField == self.userTextFiled) {
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
        self.bgView.frame = CGRectMake(self.bgView.x, self.viewY, self.bgView.width, self.bgView.height);
        self.bgView.center = self.view.center;
    }else{
        self.bgView.frame = CGRectMake(self.bgView.x, self.viewY, self.bgView.width, self.bgView.height);
        self.bgView.center = self.view.center;
    }
    
    
}








- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    if (self.showTable) {
        [self arrowClick:@"yes"];
    }
}





#pragma mark ----------------------------------------------tableViewDelegate-tableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UsernameTableViewCell *cell = (UsernameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UsernameTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //（这种是没有点击后的阴影效果)
    
    SYLog(@"dataArray---------------- :%@", self.dataArray);
    SSWL_UserModel *model = [SSWL_UserModel new];
    model.userName = self.dataArray[indexPath.row];
    cell.model = model;
    cell.delegate = self;

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.userTextFiled.text = self.dataArray[indexPath.row];
    NSString *passwordString = [NSString stringWithFormat:@"%@", [self.passDic valueForKey:self.dataArray[indexPath.row]]];
    [self.tableView reloadData];
    
    [self arrowClick:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

- (void)cell:(UITableViewCell *)cell deleteUsernameInfoIsDone:(BOOL)isDone deleteUsername:(NSString *)username{
    if (isDone) {
        NSMutableArray *nameArr = [KeyChainWrapper load:SSWLUsernameKey];
        /*
         * 游客登录账号密码
         */
        NSString *fastName = [KeyChainWrapper load:SSWL_UserName_Fast];
        NSString *fastPass = [KeyChainWrapper load:SSWL_Password_Fast];
        
        //    fastPass = @"123456789"; u141557
        /*
         * fastPass.length > 0
         * 游客登录
         */
        if (fastPass.length > 0) {
            //nameArr 不包含fastName 则添加进nameArr
            if (![nameArr containsObject:fastName]) {
                NSInteger index = nameArr.count;
                if (!index) {
                    //如果nameArr.count = 0 添加fastName
                    [nameArr addObject:fastName];
                    
                }else{
                    //插入最后一位
                    [nameArr insertObject:fastName atIndex:index];
                }
                //保存进字典
                NSMutableDictionary *dict = [KeyChainWrapper load:SSWLPasswordKey];
//                [self.passD setObject:fastPass forKey:fastName];
            }
        }
        self.dataArray = [NSMutableArray arrayWithArray:nameArr];
        if ([self.userTextFiled.text isEqualToString:username]) {
            self.userTextFiled.text = [self.dataArray firstObject];
        }
        [self.tableView reloadData];
        [self arrowClick:@""];
    }
}

#pragma mark ----------------------------------------------懒加载
//懒加载

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.alpha = 1.0f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UsernameTableViewCell class] forCellReuseIdentifier:cellID];
    }
    return _tableView;
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

- (UIButton *)findBtn{
    if (!_findBtn) {
        _findBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _findBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_findBtn setTitle:@"密码找回>" forState:UIControlStateNormal];
        [_findBtn setTitle:@"密码找回>" forState:UIControlStateHighlighted];
        //[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00]
        [_findBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateNormal];
        [_findBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateHighlighted];
        _findBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_01" withType:@"png"] forState:UIControlStateNormal];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_02" withType:@"png"] forState:UIControlStateHighlighted];

            
            
       
        
        //            [_findBtn setTitle:@"Forget" forState:UIControlStateNormal];
        //            [_findBtn setTitle:@"Forget" forState:UIControlStateHighlighted];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"anv_02_1" withType:@"png"] forState:UIControlStateNormal];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"anv_02_2" withType:@"png"] forState:UIControlStateHighlighted];
        
        
        [_findBtn addTarget:self action:@selector(findClick:) forControlEvents:UIControlEventTouchUpInside];
        //        _registBtn.tag = 1001;
        
    }
    return _findBtn;
}

- (UIButton *)otherLoginWay{
    if (!_otherLoginWay) {
        _otherLoginWay = [UIButton buttonWithType:UIButtonTypeCustom];
        _otherLoginWay.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_otherLoginWay setTitle:@"其他登录>" forState:UIControlStateNormal];
        [_otherLoginWay setTitle:@"其他登录>" forState:UIControlStateHighlighted];
        //[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00]
        [_otherLoginWay setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateNormal];
        [_otherLoginWay setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateHighlighted];
        _otherLoginWay.titleLabel.font = [UIFont systemFontOfSize:18];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_01" withType:@"png"] forState:UIControlStateNormal];
        //            [_findBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an2_02" withType:@"png"] forState:UIControlStateHighlighted];
        
            
            
       
        
        [_otherLoginWay addTarget:self action:@selector(otherLoginWayClick:) forControlEvents:UIControlEventTouchUpInside];
        //        _registBtn.tag = 1001;
        
    }
    return _otherLoginWay;
}

- (UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn setTitle:@"登录" forState:UIControlStateHighlighted];
        [_loginBtn setBackgroundColor:button_Color];
        _loginBtn.layer.cornerRadius = 15;
        _loginBtn.layer.masksToBounds = YES;
        
        //            [_loginBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_01" withType:@"png"] forState:UIControlStateNormal];
        //            [_loginBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_02" withType:@"png"] forState:UIControlStateHighlighted];
//        [_loginBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_1_01" withType:@"png"] forState:UIControlStateNormal];
//        [_loginBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an1_2_02" withType:@"png"] forState:UIControlStateHighlighted];
        
        
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.tag = 1000;
        
        
    }
    return _loginBtn;
}

- (UIButton *)arrowBtn{
    if (!_arrowBtn) {
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_arrowBtn addTarget:self action:@selector(arrowClick:) forControlEvents:UIControlEventTouchUpInside];
        [_arrowBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"arrow" withType:@"png"] forState:UIControlStateNormal];
        
    }
    return _arrowBtn;
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
        _bgView = [[SSWL_BGView alloc] initWithShowImage:NO showBGView:NO showCleanView:YES];
        _bgView.backgroundColor = SYWhiteColor;
        _bgView.height -= 60;
        _bgView.vc = self;

        //        self.bgViewImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _bgView.width, _bgView.height)];
        
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
        _userBorderView.backgroundColor = [UIColor whiteColor];
        
        _userBorderView.layer.borderWidth = 1.0f;
        _userBorderView.layer.masksToBounds = YES;
        _userBorderView.layer.cornerRadius = 20;
        
    }
    
    return _userBorderView;
}
- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        
        [_logoImgView setImage:get_SSWL_Logo];
            
        
//            [_logoImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"Log" withType:@"png"]];
            
        
    }
    return _logoImgView;
}

- (UIImageView *)ggLogo{
    if (!_ggLogo) {
        _ggLogo = [[UIImageView alloc] init];
        [_ggLogo setImage:get_SSWL_Logo];
        
    }
    return _ggLogo;
}
- (UIImageView *)userImgView{
    if (!_userImgView) {
        _userImgView = [[UIImageView alloc] init];
        [_userImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"id_01" withType:@"png"]];
        _userImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _userImgView;
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

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
        
    }
    return _dataArray;
}

- (NSDictionary *)passDic{
    if (!_passDic) {
        _passDic = [[NSDictionary alloc] init];
    }
    return _passDic;
}
- (NSDictionary *)tokenDict{
    if (!_tokenDict) {
        _tokenDict = [[NSDictionary alloc] init];
    }
    return _tokenDict;
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
