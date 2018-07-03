//
//  AYWebTipSController.m
//  AYSDK
//
//  Created by SDK on 2017/11/13.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_WebTipSController.h"

@interface SSWL_WebTipSController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) MBProgressHUD *webHUD;//HUD提示

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic ,copy) NSString *requestUrl;//请求的链接

@property (nonatomic ,strong) WKWebView *webView;//wkwebview

@property (strong, nonatomic) UIProgressView *progressView;//进度条

@property (nonatomic, assign) BOOL barHidden;//barHidden : 用于退出Window时把状态栏隐藏(屌不屌)

@property (nonatomic, strong) SSWL_ErrorView *errorView;


@end

@implementation SSWL_WebTipSController
- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpWebView];
    [self initProgressView];
//    [self webViewLoadData];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

/**
 * 系统方法
 * 是否隐藏
 */
- (BOOL)prefersStatusBarHidden {
    return [self isBarHidden];
}

- (BOOL)isBarHidden{
    /*返回 self.barHidden*/
    return self.barHidden;
}





- (void)setUpWebView{
    
        self.configuration = [[WKWebViewConfiguration alloc] init];
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, Screen_Width, Screen_Height)];
        
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        self.webView.scrollView.bounces = NO;
        //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
    
    [self.view addSubview:self.webView];
    
    self.requestUrl = [NSString stringWithFormat:@"%@?platform=ios&token=%@", SSWL_URL_GameTips, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
    [self showHUDForViewIsLoading];
    [self judgeNet];

}


- (void)showHUDForViewIsLoading{
    
    //    UIImageView *customImg = [[UIImageView alloc] initWithImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key" withType:@"png"]];
    //    customImg.frame = CGRectMake(0, 0, 10, 10);
    self.webHUD = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    self.webHUD.mode = MBProgressHUDModeIndeterminate;
    //    [self.webHUD setCustomView :customImg];
    self.webHUD.label.text = @"正在加载";
}




//自己看.h文件
- (void)initProgressView
{
    //    CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 2)];
    progressView.tintColor = [UIColor colorWithRed:0 green:0.58 blue:1 alpha:1];
    progressView.trackTintColor = [UIColor whiteColor];
    self.progressView = progressView;
    [self.view addSubview:self.progressView];
    [self.progressView setHidden:NO];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"toGame"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getMsg"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getInfo"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"statistics"];
    
    
    //        //首先设置UIInterfaceOrientationUnknown欺骗系统，避免可能出现直接设置无效的情况
    //        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    //        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    //
    //        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    //        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"toGame"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getMsg"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"statistics"];
    
    //    [self clearData];
    
}

- (void)isNetWorking:(BOOL)isNetWorking{
    if (!isNetWorking) {
        SYLog(@"没网");
        if (self.webView) {
            self.webView.hidden = YES;
            [self.progressView setHidden:YES];
            [self.view addSubview:self.errorView];
        }
    }
}


// 判断网络
- (void)judgeNet
{
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getNetWorkStateBlock:^(NSInteger netStatus) {
        switch (netStatus) {
            case 0:{
                [weakSelf webViewDidLoadFail];
                
            }
                break;
                
            case 1:{
                
                [weakSelf isNetWorking:YES];
                
            }
                break;
                
            case 2:{
                [weakSelf isNetWorking:YES];
                
            }
                break;
                
            case 3:{
                [weakSelf webViewDidLoadFail];
                
            }
                break;
                
            default:
                break;
        }
    }];

    

}

- (void)webViewDidLoadFail{
    [self.webView stopLoading];
    self.webHUD.mode = MBProgressHUDModeText;
    self.webHUD.label.text = @"网速不给力";
    [self.webHUD hideAnimated:YES afterDelay:0.5f];
    //    self.webHUD = nil;
    [self isNetWorking:NO];
}


- (void)touchTap:(UITapGestureRecognizer *)tapGR{
    [self setUpWebView];

    self.webView.hidden = NO;
    self.progressView.hidden = NO;
    if (self.errorView) {
        self.errorView.hidden = YES;
        self.errorView = nil;
    }
}


- (void)goBackGame{
    [self dismissViewControllerAnimated:YES completion:^{
        [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
    }];
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //    SYLog(@"%@", message.body);
    if ([message.name isEqualToString:@"toGame"]) {
        /**
         *       self.barHidden = YES
         *    爸爸会自动识别,并把状态栏给隐藏 (屌不屌)
         */
        self.barHidden = YES;//在这里设置yes
        [self isBarHidden];
        if (self.GoBackBlock) {
            self.GoBackBlock();
            
        }
        [self goBackGame];
    }
    /*给前端签名(屌不屌)*/
    if ([message.name isEqualToString:@"getInfo"]) {
        [self sendDataForPrama:message.body messageName:message.name];
    }
    if ([message.name isEqualToString:@"statistics"]){
//        [self statisticsAllEventWithMessageName:message.name Param:message.body];
    }
    
    
}




/*处理签名*/
- (void)sendDataForPrama:(NSDictionary *)param messageName:(NSString *)name{
    NSString *jsString = [NSString string];
    //    NSArray *paramArr = [NSArray array];
    param = @{
              @"token"      :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
              };
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
    
    
    [manager POST:@"http://192.168.100.135/7977.platform/trunk/web/user/?ct=notice&ac=getGameNoticeLists" parameters:dict  progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];

        SYLog(@"%@", originalDic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
     */
    
}



#pragma mark - KVO
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}


- (SSWL_ErrorView *)errorView{
    if (!_errorView) {
        _errorView = [[SSWL_ErrorView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchTap:)];
        [_errorView addGestureRecognizer:tap];
    }
    return _errorView;
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    self.webView.hidden = NO;
    [self.webHUD hideAnimated:YES afterDelay:0.3f];
//    if (self.time) {
//        dispatch_source_cancel(_time);
//        _time = nil; // 将 dispatch_source_t 置为nil
//    }
    
    
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}



// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    //    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    
  
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    if (![navigationAction.request.URL.host hasPrefix:@"systatic"]){
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    SYLog(@"-----yes------");
                    
                }
            }];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    

    
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
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
