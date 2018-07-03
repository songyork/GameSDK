//
//  LoginViewController.m
//  AYSDK
//
//  Created by SDK on 2017/7/25.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_LoginViewController.h"
#import "SSWL_GetCodeForMessageViewController.h"


#import <WebKit/WebKit.h>
@interface SSWL_LoginViewController () <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) SSWL_BGView *bgView;

@property (nonatomic, strong) SSWL_BGView *tipsView;

@property (nonatomic, strong) MBProgressHUD *webHUD;

@property(nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic, strong) SSWL_ErrorView *errorView;

@property (nonatomic, strong) SSWL_VerifyDynamicView *verifyDynamicView;

@property (nonatomic, strong) SSWL_AddIdentityInfo *addIdentityView;

@property (nonatomic, strong)dispatch_source_t time;

@property (nonatomic, assign) int secNum;

@property (nonatomic, assign) BOOL isShowPassword;//是否展示密码

@property (nonatomic, strong) NSDictionary *responesParam;//请求下来的参数

@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic ,strong) UIImageView *ggLogo;//logo背景

@property (nonatomic, strong) UIImageView *userImgView;//账号图片

@property (nonatomic, strong) UIImageView *passImgView;//密码图片

@property (nonatomic, strong) UITextField *userTextFiled;//账号

@property (nonatomic, strong) UITextField *passTextField;//密码

@property (nonatomic, strong) UITextField *rePassTextFiled;//在输入密码

@property (nonatomic, strong) UIButton *loginBtn;//登录按钮

@property (nonatomic, strong) UIButton *findBtn;//找回密码

@property (nonatomic, strong) UIButton *registBtn;//注册

@property (nonatomic ,strong) UIButton *eyesBtn;//是否显示密码BTN

@property (nonatomic ,strong) UIButton *arrowBtn;//箭头

@property (nonatomic, strong) UIButton *backBtn;//返回

@property (nonatomic, strong) UIView *userBorderView;//账号边框

@property (nonatomic, strong) UIView *passBorderView;//密码边框

@property (nonatomic, strong) UIImageView *userBorderImgView;//账号边框

@property (nonatomic, strong) UIImageView *passBorderImgView;//密码边框

@property (nonatomic, strong) UILabel *userLineLab;//分割线

@property (nonatomic, strong) UILabel *passLineLab;//分割线


@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值


@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic ,strong) NSMutableArray *dataArray;

@property (nonatomic ,strong) NSDictionary *passDic;

@property (nonatomic, assign) BOOL showTable;

@property (nonatomic, strong) UIImageView *bgViewImg;


@property (nonatomic, strong)UIButton *knowBtn;//知道了BTN

@property (nonatomic ,copy) NSString *requestUrl;//请求的链接

@property (nonatomic ,strong) WKWebView *webView;//wkwebview

@property (strong, nonatomic) UIProgressView *progressView;//进度条

@property (strong, nonatomic) NSString *fastPassStr;//自动登录密码

@property (strong, nonatomic) NSString *fastUserStr;//自动登录账号

@property (nonatomic, assign) BOOL isLoginAfter;//登陆后公告

@property (nonatomic, assign) int page;



@end

@implementation SSWL_LoginViewController
/*
 * 注销键盘的通知事件
 
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];

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


- (void)viewDidLoad {
    [super viewDidLoad];
// 临时
    self.isOnline = YES;

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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.passTextField];

    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
   

    
    [self setUpWebView];
    
    [self makeTheViewForLogin];
    
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



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getInfo"];

    
    NSMutableArray *nameArr = [NSMutableArray new];
    NSMutableDictionary *passD = [NSMutableDictionary new];
    
    NSArray *arr = [KeyChainWrapper load:SSWLUsernameKey];
    
    for (NSString *key in arr) {
        [nameArr addObject:key];
    }
    
   NSDictionary *dic = [KeyChainWrapper load:SSWLPasswordKey];
    for (NSString *key in dic) {
        [passD setObject:[dic valueForKey:key] forKey:key];
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
   
    
    self.passDic = passD;
    [self.dataArray addObjectsFromArray:nameArr];
    NSString *pass;
    if (nameArr.count > 0) {
        
        self.userTextFiled.text = nameArr[0];
        if ([self.userTextFiled.text isEqualToString:fastName]){
            pass = fastPass;
        }else{
            pass = [NSString stringWithFormat:@"%@", [self.passDic valueForKey:nameArr[0]]];

        }
        self.passTextField.text = pass;
    }
    
    SYLog(@"---nameArr:%@,------------dict:%@", self.dataArray, self.passDic);
}



- (void)viewWillDisappear:(BOOL)animated{
    self.passDic = nil;
    self.dataArray = nil;
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getInfo"];

}




- (void)createUI{
    
//    [self.bgView addSubview:self.ggLogo];

    
    [self.bgView addSubview:self.logoImgView];
    
//    [self.bgView addSubview:self.userBorderImgView];
//
//    [self.bgView addSubview:self.passBorderImgView];
    
    [self.bgView addSubview:self.userBorderView];
    
    [self.bgView addSubview:self.passBorderView];
    if (self.isPush) {
        [self.bgView addSubview:self.backBtn];
    }
    
    [self.bgView addSubview:self.userImgView];
    
    [self.bgView addSubview:self.passImgView];
    
    [self.bgView addSubview:self.userLineLab];
    
    [self.bgView addSubview:self.passLineLab];
    
    [self.bgView addSubview:self.userTextFiled];
    
    [self.bgView addSubview:self.passTextField];
    
    [self.bgView addSubview:self.eyesBtn];
    
    [self.bgView addSubview:self.arrowBtn];
    
    [self.bgView addSubview:self.loginBtn];

    [self.bgView addSubview:self.findBtn];

    
    [self.bgView addSubview:self.registBtn];
    
    
    self.isShowPassword = NO;
    
    self.showTable = NO;
    
    [self layoutSubView];
    
    
    //    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.backBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"back_bt" withType:@"png"] forState:UIControlStateNormal];
    //    [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    //    [self.bgView addSubview:self.backBtn];
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
        [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.bgView).offset(30);
//            make.left.equalTo(weakSelf.bgView).offset(90);
//            make.right.equalTo(weakSelf.bgView).offset(-90);
//            make.height.mas_equalTo(35);
            make.centerX.equalTo(weakSelf.bgView);
            make.size.mas_equalTo(CGSizeMake(150, 30));
        }];
    }else{
        [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.bgView).offset(30);
//            make.left.equalTo(weakSelf.bgView).offset(90);
//            make.right.equalTo(weakSelf.bgView).offset(-90);
//            make.height.mas_equalTo(30);
            make.centerX.equalTo(weakSelf.bgView);
            make.size.mas_equalTo(CGSizeMake(125, 30));
        }];
    }
    
    CGFloat btnW;//记录userBorderView的宽

//    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel = @"iPhone_SE";
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
    
    if (self.isPush) {
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.centerY.equalTo(weakSelf.logoImgView).offset(0);
            make.size.mas_equalTo(CGSizeMake(15, 20));
        }];
    }
   
    
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
        make.right.equalTo(weakSelf.userBorderView.mas_right).offset(-40);
    }];
    

//    [self.arrowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.userTextFiled.mas_right).offset(5);
//        make.right.equalTo(weakSelf.userBorderView.mas_right).offset(-5);
//        make.size.mas_equalTo(CGSizeMake(20, 15));
//        make.centerY.equalTo(weakSelf.userBorderView);
//    }];

    [self.arrowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.userTextFiled.mas_right).offset(5);
        make.right.equalTo(weakSelf.userBorderView.mas_right).offset(-15);
        make.height.mas_equalTo(10);
//        make.size.mas_equalTo(CGSizeMake(20, 15));
        make.centerY.equalTo(weakSelf.userBorderView);
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
    
    
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passBorderView.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.userBorderView);
        make.right.equalTo(weakSelf.userBorderView);
        make.height.mas_equalTo(30);

    }];
    
    
    /*
     * 暂时不使用找回密码-----等待悬浮窗上线开启
    
    */
    [self.findBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.loginBtn.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.userBorderView);
        make.size.mas_equalTo(CGSizeMake(btnW /2 - 15, 30));
    }];

    
    [self.registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
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
            make.top.equalTo(weakSelf.userTextFiled.mas_bottom).offset(0);
            make.left.equalTo(weakSelf.userTextFiled.mas_left);
            make.right.equalTo(weakSelf.userTextFiled.mas_right);
            make.height.mas_equalTo(100);
        }];
    }else{
        self.tableView.frame = CGRectZero;
        self.tableView.hidden = YES;
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





- (void)loginClick:(id)sender{
    Weak_Self;
    [self.userTextFiled resignFirstResponder];
    [self.passTextField resignFirstResponder];

    
    if (self.userTextFiled.text.length < 6 || self.userTextFiled.text == nil) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请按规定填写账号"];
        return;
    }else{
        //a-zA-Z0-9
        NSString *regex = @"^([\u4E00-\u9FA5]+)$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isEmpty = [SSWL_PublicTool isEmpty:self.userTextFiled.text];
        if([pred evaluateWithObject:self.userTextFiled.text] || isEmpty) {
            [SSWL_PublicTool showHUDWithViewController:self Text:@"请按规定填写账号"];
            return;
        }
        
    }
    [self.HUD removeFromSuperview];
    self.HUD = nil;
    
    if (self.passTextField.text.length < 6 || self.passTextField.text == nil) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请按规定填写密码"];
        return;
    }else{
        NSString *regex = @"^([\u4E00-\u9FA5]+)$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isEmpty = [SSWL_PublicTool isEmpty:self.passTextField.text];
        //![pred evaluateWithObject:self.passTextField.text] ||
        if([pred evaluateWithObject:self.passTextField.text] || isEmpty) {
            [SSWL_PublicTool showHUDWithViewController:self Text:@"请按规定填写密码"];
            return;
        }
        

    }

    

    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.label.text = @"正在登录";
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] loginWithUserName:self.userTextFiled.text password:self.passTextField.text completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
            NSDictionary *loginDic = respones[@"data"];
//            SYLog(@"------respones:%@", respones);
           
            
#pragma mark ----------------------------------------------强制进入身份证页面
//            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check = YES;
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check && ! [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard) {
                [weakSelf checkIdentityBeforeLoggingIsConstraint:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.user_Idcard_Check_Need completion:^(AddIdentityInfoViewClickStates addViewClickStates) {
                    if (addViewClickStates == 0) {
                        [weakSelf verificationFailedStayHere];
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
                        
                        /*
                         if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].zhiUrl.length > 1) {
                         [SSWL_PublicTool showAlertToViewController:weakSelf alertControllerTitle:@"订单号" alertControllerMessage:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].zhiUrl alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:^(UIAlertAction * _Nonnull action) {
                         
                         } reportHandler:nil completion:^{
                         
                         }];
                         }
                         */
                    }
                    
                });
                
            }
            
            
            

        }else{
            weakSelf.HUD.mode = MBProgressHUDModeText;
           
            weakSelf.HUD.label.text = respones[@"msg"];

            [weakSelf.HUD hideAnimated:YES afterDelay:1];

        }
    } failure:^(NSError * _Nullable error) {
        [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"网络异常"];
    }];
}



/**
 创建验证身份证页面
 
 @param isConstraint 是否强制绑定
 @param completion 完成后回调
 */
- (void)checkIdentityBeforeLoggingIsConstraint:(BOOL)isConstraint completion:(void(^)(AddIdentityInfoViewClickStates addViewClickStates))completion{
    [self.HUD hideAnimated:YES afterDelay:1.0f];

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

- (void)verificationFailedStayHere{
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.hidden = NO;
        self.addIdentityView.y = Screen_Height;
    } completion:^(BOOL finished) {
        self.addIdentityView.hidden = YES;
        self.addIdentityView = nil;
    }];
    [SSWL_PublicTool showHUDWithViewController:self Text:@"身份信息验证失败"];
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
    [self.passTextField resignFirstResponder];

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

- (void)registClick:(UIButton *)sender{
    [self.userTextFiled resignFirstResponder];
    [self.passTextField resignFirstResponder];

    Weak_Self;
   
    SSWL_RegistViewController *rVC = [[SSWL_RegistViewController alloc] init];
    rVC.isLoginCome = YES;
    rVC.isOnline = self.isOnline;
    rVC.block = ^{
        if (weakSelf.block) {
            weakSelf.block();
        }
    };

    
    [self.navigationController pushViewController:rVC animated:NO];
    
    
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


- (void)makeTheViewForLogin{
    
    self.page = 0;
    
    [self.view addSubview:self.bgView];
    //self.bgView.center = self.view.center;
    [self createUI];

    //自动登录
    NSMutableDictionary *fastDic = [KeyChainWrapper load:SSWL_UserLogin_Auto];
    for (NSString *key in fastDic) {
        //获取登录账号 key为账号
        self.fastUserStr = key;
    }
    self.fastPassStr = fastDic[self.fastUserStr];
    if (self.fastPassStr.length > 1) {
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].needAuto) {
            [self userAutoLoginToUserName:self.fastUserStr Password:self.fastPassStr];
        }
        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].needAuto = NO;
        
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
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.textAlignment = 1;
    
  return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.userTextFiled.text = self.dataArray[indexPath.row];
    self.passTextField.text = [NSString stringWithFormat:@"%@", [self.passDic valueForKey:self.dataArray[indexPath.row]]];

    
    [self arrowClick:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
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

- (UIButton *)registBtn{
    if (!_registBtn) {
        _registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _registBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        


        [_registBtn setTitle:@"注册账号" forState:UIControlStateNormal];
        [_registBtn setTitle:@"注册账号" forState:UIControlStateHighlighted];
        //[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00]
        [_registBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateNormal];
        [_registBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateHighlighted];
        _registBtn.titleLabel.font = [UIFont systemFontOfSize:18];

    
        
        [_registBtn addTarget:self action:@selector(registClick:) forControlEvents:UIControlEventTouchUpInside];
        _registBtn.tag = 1001;
    }
    return _registBtn;
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
        
        [_findBtn setTitle:@"密码找回" forState:UIControlStateNormal];
        [_findBtn setTitle:@"密码找回" forState:UIControlStateHighlighted];
        //[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00]
        [_findBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateNormal];
        [_findBtn setTitleColor:[UIColor colorWithRed:0.29 green:0.58 blue:0.94 alpha:1.00] forState:UIControlStateHighlighted];
        _findBtn.titleLabel.font = [UIFont systemFontOfSize:18];

        [_findBtn addTarget:self action:@selector(findClick:) forControlEvents:UIControlEventTouchUpInside];
        //        _registBtn.tag = 1001;
        
    }
    return _findBtn;
}

- (UIButton *)loginBtn{
    
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn setTitle:@"登录" forState:UIControlStateHighlighted];
        
        [_loginBtn setBackgroundColor:button_Color];
        _loginBtn.layer.cornerRadius = 15;
        _loginBtn.layer.masksToBounds = YES;
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

- (UIButton *)eyesBtn{
    if (!_eyesBtn) {
        _eyesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
        [_eyesBtn addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _eyesBtn;
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


- (UIView *)passBorderView{
    if (!_passBorderView) {
        _passBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00].CGColor;
        _passBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        
        _passBorderView.layer.borderWidth = 1.0f;
//        [_passBorderView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"border" withType:@"png"]];
        _passBorderView.backgroundColor = [UIColor whiteColor];

        _passBorderView.layer.masksToBounds = YES;
        _passBorderView.layer.cornerRadius = 20;
        
    }
    
    return _passBorderView;
}


 //光效
- (UIImageView *)userBorderImgView{
    if (!_userBorderImgView) {
        _userBorderImgView = [[UIImageView alloc] init];
        [_userBorderImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"border01" withType:@"png"]];
//        _userBorderImgView.contentMode = UIViewContentModeScaleAspectFill;
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

- (UIImageView *)passImgView{
    
    if (!_passImgView) {
        _passImgView = [[UIImageView alloc] init];
        [_passImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key" withType:@"png"]];
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
