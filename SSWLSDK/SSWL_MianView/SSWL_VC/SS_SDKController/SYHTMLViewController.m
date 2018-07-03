//
//  SYHTMLViewController.m
//  AYSDK
//
//  Created by SDK on 2017/12/28.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SYHTMLViewController.h"
#import "HTMLBackView.h"
@interface SYHTMLViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
/*支付webview*/
@property (nonatomic, strong)WKWebView *webView;


@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (strong, nonatomic) UIProgressView *progressView;//进度条



/*get链接参数*/
@property (nonatomic, strong)NSMutableDictionary *paramsDict;


@property (nonatomic, strong) NSDictionary *dic;

@end

@implementation SYHTMLViewController

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"backToGame"];
    //    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"applePay"];


    
    SYLog(@"页面将要出现");
    
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"backToGame"];
//    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"applePay"];


    
    SYLog(@"页面将要消失");
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [self setUpWebView];
    [self loadWebViewData];
    
    [self initProgressView];
    
    [self layoutSubView];
    [self  getNavView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)getNavView{
    Weak_Self;
    HTMLBackView *navView = [[HTMLBackView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, SS_StatusBarAndNavigationBarHeight)];
    [self.view addSubview:navView];
    navView.backGameBlock = ^{
        [weakSelf closeClick];
    };
}

- (void)setUpWebView{
    if (!self.webView) {
        self.configuration = [[WKWebViewConfiguration alloc] init];
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        self.webView = [[WKWebView alloc] init];
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        self.webView.scrollView.bounces = NO;
        [self.view addSubview:self.webView];

    }
}

- (void)layoutSubView{
  
    self.webView.frame = CGRectMake(0, SS_StatusBarAndNavigationBarHeight, self.view.width, self.view.height - SS_StatusBarAndNavigationBarHeight);
}


- (void)loadWebViewData{
    self.dic = [[NSDictionary alloc] init];
    self.dic = @{
                          @"user_id"        :   self.songyorkInfo.uid,
                          @"money"          :   self.songyorkInfo.money,
                          @"money_type"     :   self.songyorkInfo.moneyType,
                          @"server"         :   self.songyorkInfo.serverId,
                          @"cp_trade_sn"    :   self.songyorkInfo.YYY,
                          @"goods_id"       :   self.songyorkInfo.proId,
                          @"goods_name"     :   self.songyorkInfo.productName,
                          @"goods_desc"     :   self.songyorkInfo.desc,
                          @"game_role_id"   :   self.songyorkInfo.roleId,
                          @"game_role_name" :   self.songyorkInfo.roleName,
                          @"game_role_level":   self.songyorkInfo.roleLevel,
                          @"pay_type"       :   @"apple",
                          @"sub_pay_type"   :   @"apple",
                          @"app_channel"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                          @"device_id"      :   [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
                          @"app_id"         :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"idfv"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
                          @"sdk_version"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"platform"       :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                          @"system_version" :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].system_Version,
                          @"system_name"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model,
                          @"time"           :   [SSWL_PublicTool getTimeStamps],
                          };
    NSString *sign = [SSWL_PublicTool makeSignStringWithParams:self.dic];
    SYLog(@"---sign:%@", sign);
    self.paramsDict = [NSMutableDictionary dictionaryWithDictionary:self.dic];
    [self.paramsDict setObject:sign forKey:@"sign"];
    
    [self getDataToServer:self.paramsDict];
    
    
}


- (void)getDataToServer:(NSMutableDictionary *)dic{
    NSMutableArray *urlArr = [NSMutableArray new];
    NSMutableArray *paramArr = [NSMutableArray new];
    
    
    //排序
    NSArray *keyArray = [dic allKeys];
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    for (NSString *keys in sortArray) {
        NSString * encodingString = [SSWL_PublicTool encodeString:[NSString stringWithFormat:@"%@", dic[keys]]];
        
        NSString *str = [NSString stringWithFormat:@"%@=%@",keys, encodingString];
        [paramArr addObject:str];
    }
    
    
    for (NSString *str in paramArr) {
        NSString *paramStr = [NSString stringWithFormat:@"&%@", str];
        [urlArr addObject:paramStr];
    }
    
    //    self.zUrlString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",self.zUrl, urlArr[0], urlArr[1], urlArr[2], urlArr[3], urlArr[4], urlArr[5], urlArr[6], urlArr[7], urlArr[8], urlArr[9], urlArr[10], urlArr[11], urlArr[12], urlArr[13], urlArr[14], urlArr[15], urlArr[16], urlArr[17], urlArr[18]];
    
    for (int i = 0; i < urlArr.count; i++) {
        self.urlString = [NSString stringWithFormat:@"%@%@", self.urlString, urlArr[i]];
    }
    SYLog(@"----------------zfUrlString :%@", self.urlString);
    
    
    
    
    
    NSURL *url = [NSURL URLWithString: self.urlString];
    
    
//     if ([[UIApplication sharedApplication] canOpenURL:url]) {
//         [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
//             if (success) {
//                 SYLog(@"-----yes------");
//
//             }
//         }];
//     }
    
    
    
    // 3.创建Request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 4.加载网页
    [self.webView loadRequest:request];
    
    
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    SYLog(@"%@", message.body);
    if ([message.name isEqualToString:@"backToGame"]) {
        
        [self closeClick];
    }
    
//    if ([message.name isEqualToString:@"applePay"]) {
//        [self giveSonyorkForApp];
//    }

}



//- (void)giveSonyorkForApp{
//    [[HX_SSWL_ZFForHtml sharedHX_SSWL_ZFForHtml] startCheckTheSYWayWithViewController:self syInfo:self.songyorkInfo completion:^(NSString *message, id param) {
//        
//    }];
//}

- (void)closeClick{
    
    if (self.closeBlock) {
        self.closeBlock();
    }
    
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

- (NSMutableDictionary *)paramsDict{
    if (!_paramsDict) {
        _paramsDict = [[NSMutableDictionary alloc] init];
    }
    return _paramsDict;
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
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    SYLog(@"%s",__FUNCTION__);
    
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    
}




#pragma mark WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    SYLog(@"%s",__FUNCTION__);
    
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
    if([self isJumpToExternalAppWithURL:navigationAction.request.URL]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
//    if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
//        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
//            if (success) {
//                SYLog(@"-----yes------");
//
//            }
//        }];
//        decisionHandler(WKNavigationActionPolicyAllow);
//        return;
//    }
//
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

- (BOOL)isJumpToExternalAppWithURL:(NSURL *)URL{
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https"]];
    return ![validSchemes containsObject:URL.scheme];
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
