//
//  FatherViewController.h
//  AYSDK
//
//  Created by 松炎 on 2017/8/2.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
@interface FatherViewController : UIViewController<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

/*
 * 社区页面所有webview的爸爸
 * 父类
 * 只有基础设置
 */

@property (nonatomic, assign) float tabBarHight;//tabbar的高度

@property (nonatomic, strong) MBProgressHUD *webHUD;//HUD提示

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

//@property (nonatomic, strong) AFNetworkReachabilityManager *manager;//判断是否有网络

@property (nonatomic, assign) BOOL isNetWorking;

@property (nonatomic ,copy) NSString *requestUrl;//请求的链接

@property (nonatomic ,strong) WKWebView *webView;//wkwebview

@property (strong, nonatomic) UIProgressView *progressView;//进度条


@property (nonatomic, assign) BOOL barHidden;//barHidden : 用于退出Window时把状态栏隐藏(屌不屌)

@property (nonatomic, strong) NSDictionary *infoContextDict;

@property (nonatomic ,copy) void(^WebBlock)();//block



-(BOOL)shouldAutorotate;

-(UIInterfaceOrientationMask)supportedInterfaceOrientations;

/*
 * 设置webview
 */
- (void)setUpWebView;

/*系统方法 : 用于隐藏状态栏*/
- (BOOL)prefersStatusBarHidden;

/*通过这个方法在回到游戏按钮响应时改变 barHidden ,prefersStatusBarHidden方法识别是否显示状态栏(屌不屌)*/
- (BOOL)isBarHidden;

/*放在这里,失败*/
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator;

/**
 * 加载条
 */
- (void)initProgressView;

//加载HUD
- (void)showHUDForViewIsLoading;

//webView加载失败HUD
- (void)webViewDidLoadFail;

//webView加载失败
- (void)ifWebViewLoadFailToGoBack;


- (BOOL)getShareContext;

- (void)getShareContextCompletion:(void(^_Nullable)(BOOL isSuccess, id _Nullable dict))completion failure:(void(^_Nullable)(NSError *_Nullable error))failure;



/*
 * webView请求连接是否是空
 * 空 : remove
 */
- (void)webViewLoadData;

//- (void)reloadWebViewForRequestUrl:(NSString *)requestUrl;

/**
 * 是否是有网的状态
 * 给子类一个bool值作为判断基础
 * @param isNetWorking  :   NO (没有网络)
 */
- (void)isNetWorking:(BOOL)isNetWorking;

/*
 * 子类可以获取是否是空
 * param YES      :     有数据
 * param NO       :     没数据
 */
- (void)isLoadData:(BOOL)isLoad;

//- (void)fristCustomActions;
// 判断网络
- (void)judgeNet;

/**
 * 注销通知
 */
- (void)dealloc;

/*wkwebview代理*/
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error;

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView;

//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
@end
