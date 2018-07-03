//
//  SSWL_PushInfoViewController.m
//  SSWLSDK
//
//  Created by SDK on 2018/7/2.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_PushInfoViewController.h"

@interface SSWL_PushInfoViewController () <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic ,copy) NSString *requestUrl;//请求的链接

@property (nonatomic, strong) MBProgressHUD *webHUD;//HUD提示

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic ,strong) WKWebView *webView;//wkwebview

@property (strong, nonatomic) UIProgressView *progressView;//进度条

@property (nonatomic, strong) UIView *navLineView;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) SSWL_ErrorView *errorView;

@property (nonatomic, assign) BOOL isHaveSignal;

@end

@implementation SSWL_PushInfoViewController

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}


- (void)haveSignalHandler:(void(^)(BOOL haveSignal))handler {
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getNetWorkStateBlock:^(NSInteger netStatus) {
        if (netStatus == 1 || netStatus == 2) {
            weakSelf.isHaveSignal = YES;
            if (handler) {
                handler(YES);
            }
        }else{
            weakSelf.isHaveSignal = NO;
            if (handler) {
                handler(NO);
            }
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SYWhiteColor;
    
    [self setUpBackButton];
    [self initProgressView];

    Weak_Self;
    [self haveSignalHandler:^(BOOL haveSignal) {
        if (haveSignal) {
             [weakSelf setUpWebView];
        }else {
            [weakSelf resetWebOnNoSignal];
        }
    }];

}

- (void)resetWebOnNoSignal {
    
    self.webView.hidden = YES;

    [self.webHUD hideAnimated:YES afterDelay:.5f];
    [self.view addSubview:self.errorView];
    
}

- (void)setUpBackButton {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.navLineView];
    [self.view addSubview:self.titleLabel];
}

- (void)backClick {
    SYLog(@"点击返回....");
    

    if (self.webView.canGoBack) {
        SYLog(@"后退...");
        [self.webView goBack];
    }else {
        SYLog(@"退出推送通知.....");
        if (self.PushInfoViewBlock) {
            self.PushInfoViewBlock();
        }
    }
    
}

- (void)touchTap:(UITapGestureRecognizer *)tapGR{
    if (self.errorView) {
        self.errorView.hidden = YES;
        self.errorView = nil;
    }
//    [self setUpWebView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
    [self showHUDForViewIsLoading];

    self.webView.hidden = NO;
    self.progressView.hidden = NO;
    
}

//自己看.h文件
- (void)setUpWebView{
    
    
    self.configuration = [[WKWebViewConfiguration alloc] init];
    
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 40.0;
    self.configuration.preferences = preferences;
    
    
    _webView = [[WKWebView alloc] init];
    _webView.frame = CGRectMake(0, 30 + SS_StatusBarHeight, self.view.frame.size.width, self.view.height - 30 - SS_StatusBarHeight);
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    if ([SSWL_PushInfo sharedSSWL_PushInfo].pushKeyUrl.length > 0) {
        self.requestUrl = [SSWL_PushInfo sharedSSWL_PushInfo].pushKeyUrl;
    }else{
        if (self.PushInfoViewBlock) {
            self.PushInfoViewBlock();
        }
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
    
    _webView.scrollView.bounces = NO;
    //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.view addSubview:self.webView];

    [self showHUDForViewIsLoading];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];


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

- (void)showHUDForViewIsLoading{
    self.webHUD = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    self.webHUD.mode = MBProgressHUDModeIndeterminate;
    self.webHUD.label.text = @"正在加载";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        if (!self.isHaveSignal) {
            [self resetWebOnNoSignal];
        }
    });
   
}

- (void)webViewDidLoadFail{
    [self.webView stopLoading];
    if (self.webHUD) {
        self.webHUD.mode = MBProgressHUDModeText;
        self.webHUD.label.text = @"网速不给力";
        [self.webHUD hideAnimated:YES afterDelay:0.5f];
    }
   
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




#pragma mark - WKUIDelegate And WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    
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
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    
    
}

- (UIView *)navLineView {
    if (!_navLineView) {
        _navLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29 + SS_StatusBarHeight, Screen_Width, 1)];
        _navLineView.backgroundColor = SYLineColor;
    }
    return _navLineView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0) {
            if ([SSWL_PublicTool isIphone_X]) {
                _backButton.frame = CGRectMake(20, 5, 15, 20);
            }else {
                _backButton.frame = CGRectMake(10, 5, 15, 20);
            }
        }else {
            _backButton.frame = CGRectMake(10, SS_StatusBarHeight, 15, 20);
        }
        [_backButton setImage:get_BundleImage(@"back") forState:UIControlStateNormal];
        [_backButton setImage:get_BundleImage(@"back") forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(0, 0, Screen_Width, self.backButton.height);
        _titleLabel.center = CGPointMake(Screen_Width / 2, self.backButton.centerY);
        _titleLabel.text = @"推送通知";
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.08 alpha:1.00];
        _titleLabel.textAlignment = 1;
        
    }
    return _titleLabel;
}

- (SSWL_ErrorView *)errorView{
    if (!_errorView) {
        _errorView = [[SSWL_ErrorView alloc] init];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchTap:)];
        [_errorView addGestureRecognizer:tap];
    }
    return _errorView;
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
