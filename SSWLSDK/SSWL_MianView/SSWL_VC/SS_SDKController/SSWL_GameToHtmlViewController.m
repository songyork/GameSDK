//
//  GameToHtmlViewController.m
//  AYSDK
//
//  Created by songyan on 2018/2/3.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_GameToHtmlViewController.h"
#import "SSWL_HtmlInfoToUserModel.h"
#import <CommonCrypto/CommonDigest.h>

@interface SSWL_GameToHtmlViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong)WKWebView *webView;


@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (strong, nonatomic) UIProgressView *progressView;//进度条

@property (nonatomic, assign) BOOL barHidden;//barHidden : 用于退出Window时把状态栏隐藏(屌不屌)

@property (nonatomic ,strong) SSWL_HtmlInfoToUserModel *model;

/*get链接参数*/
@property (nonatomic, strong)NSMutableDictionary *params;


@property (nonatomic, strong) NSDictionary *dic;

/*loading图片*/
@property (nonatomic, strong)UIImageView *loadingImgView;

@end

@implementation SSWL_GameToHtmlViewController

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SSWL_SignOutGame object:nil];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏前调入");
         self.view.frame = [[UIScreen mainScreen] bounds];
         self.webView.frame = [[UIScreen mainScreen] bounds];
//         CGPoint point = CGPointMake(Screen_Width / 2, Screen_Height / 2);
//         self.BGView.center = point;
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏后调入");
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [self setUpWebView];
    [self initProgressView];
    [self webViewLoadData];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.loadingImgView];
    UILabel *loadingLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    loadingLab.text = @"Loading...";
    loadingLab.textColor = [UIColor whiteColor];
    loadingLab.textAlignment = 1;
    loadingLab.font = [UIFont systemFontOfSize:17];
    loadingLab.center = self.view.center;
    [self.loadingImgView addSubview:loadingLab];
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(signOutGame:) name:SSWL_SignOutGame object:nil];
    
}


/**
 * 系统方法
 * 是否隐藏
 */

- (BOOL)prefersStatusBarHidden {
    return YES;
}



//自己看.h文件
- (void)setUpWebView{
    
    if (!self.webView) {
        self.configuration = [[WKWebViewConfiguration alloc] init];
//        self.configuration.allowsInlineMediaPlayback = YES;
//        self.configuration.mediaPlaybackRequiresUserAction = false;
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        self.webView = [[WKWebView alloc] init];
        self.webView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
        self.webView.backgroundColor = SYWhiteColor;
        [self.webView sizeToFit];
        self.webView.scrollView.bounces = NO;
        //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self.view addSubview:self.webView];
        
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

/**
 * 自己看.h文件
 * 给你一个提示,判断URL
 */
- (void)webViewLoadData{
    if (self.requestURL.length < 1) {
        [self.webView removeFromSuperview];
        self.webView = nil;
        return;
    }
//    self.requestURL = @"https://www.shangshiwl.com/h5game.html?platform=ios&debug=1";
//    self.requestURL = [NSString stringWithFormat:@"%@&debug=1", self.requestURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestURL]]];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"h5Pay"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"roleOnline"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"createRole"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"roleLevel"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"serverLogin"];
}




- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"h5Pay"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"roleOnline"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"createRole"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"roleLevel"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"serverLogin"];
    
    
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


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //    SYLog(@"%@", message.body);

    /*给前端签名(屌不屌)*/
    if ([message.name isEqualToString:@"h5Pay"]) {
        [self getSY:message.body];
    }
    if ([message.name isEqualToString:@"roleOnline"]){
        [self online5Minutes:message.body];
    }
    
    if ([message.name isEqualToString:@"createRole"]){
        [self creatRole:message.body];
    }
    
    if ([message.name isEqualToString:@"roleLevel"]) {
        [self levelUp:message.body];
    }
    
    if ([message.name isEqualToString:@"serverLogin"]) {
        [self serverLogin:message.body];
    }
    
}



- (void)online5Minutes:(NSDictionary *)param{
    self.model = [[SSWL_HtmlInfoToUserModel alloc] init];
    self.model.user_id = param[@"user_id"];
    self.model.game_role_id = param[@"role_id"];
    self.model.time = param[@"time"];
    self.model.game_sign = param[@"game_sign"];
    if (self.model.game_sign && self.model.game_sign.length > 0){
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] onlineFor5MinutesWithUserId:self.model.user_id roleId:self.model.game_role_id time:self.model.time htmlSign:self.model.game_sign completion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
                SYLog(@"在线5分钟成功");
                
            }else{
                SYLog(@"在线5分钟-----------失败");
                
            }
        } failure:^(NSError *error) {
            
        }];
        
    }
    
}

- (void)levelUp:(NSDictionary *)param{
    self.model = [[SSWL_HtmlInfoToUserModel alloc] init];
    NSDictionary *paramDict = [self.model paramterIsNotStringFromDictionary:param];
    self.model.user_id = paramDict[@"user_id"];
    self.model.game_role_id = paramDict[@"role_id"];
    self.model.game_role_level = paramDict[@"level"];
    self.model.time = paramDict[@"time"];
    self.model.game_sign = paramDict[@"game_sign"];
    if (self.model.game_sign && self.model.game_sign.length > 0){
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] levelUpWithUserId:self.model.user_id roleId:self.model.game_role_id level:self.model.game_role_level time:self.model.time htmlSign:self.model.game_sign completion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
                SYLog(@"升级成功");
                
            }else{
                SYLog(@"升级失败");
            }
        } failure:^(NSError *error) {
            
        }];
    }
    
}

- (void)creatRole:(NSDictionary *)param{
    self.model = [[SSWL_HtmlInfoToUserModel alloc] init];
    NSDictionary *paramDict = [self.model paramterIsNotStringFromDictionary:param];
    self.model.user_id = paramDict[@"user_id"];
    self.model.game_role_id = paramDict[@"role_id"];
    self.model.time = paramDict[@"time"];
    self.model.game_sign = paramDict[@"game_sign"];
    if (self.model.game_sign && self.model.game_sign.length > 0){
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] userCreateRoleWithRoleId:self.model.game_role_id userId:self.model.user_id htmlSign:self.model.game_sign time:self.model.time completion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
                SYLog(@"创建角色成功");
            }else{
                SYLog(@"创建角色失败");
            }
        }failure:^(NSError *error) {
            
        }];
    }
}


- (void)serverLogin:(NSDictionary *)param{
    self.model = [[SSWL_HtmlInfoToUserModel alloc] init];
    NSDictionary *paramDict = [self.model paramterIsNotStringFromDictionary:param];
    self.model.user_id = paramDict[@"user_id"];
    self.model.game_role_id = paramDict[@"role_id"];
    self.model.time = paramDict[@"time"];
    self.model.game_sign = paramDict[@"game_sign"];
    self.model.server = paramDict[@"server_id"];
    self.model.login_time = paramDict[@"login_time"];
    if (self.model.game_sign && self.model.game_sign.length > 0){
        
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] userServerLoginWithUserId:self.model.user_id serverId:self.model.server loginTime:self.model.login_time time:self.model.time gameSign:self.model.game_sign completion:^(BOOL isSuccess, id  _Nullable respones) {
            if (isSuccess) {
                SYLog(@"登录服务器------成功");
            }else{
                SYLog(@"登录服务器------失败:");
            }
        } failure:^(NSError * _Nullable error) {
            SYLog(@"请求错误 -------------error: %@", error);
        }];
        
    }
}


- (void)getSY:(NSDictionary *)param{
    
    NSMutableDictionary *stringParam =[NSMutableDictionary dictionary];
    for (NSString *key in param) {
        SYLog(@"key : %@, value : %@", key, [param valueForKey:key]);
        if (![[param valueForKey:key] isKindOfClass:[NSString class]]) {
            [stringParam setValue:[NSString stringWithFormat:@"%@", [param valueForKey:key]] forKey:key];
        }else{
            [stringParam setValue:[param valueForKey:key] forKey:key];
        }
//        [stringParam setValue:[param valueForKey:key] forKey:key];
    }
    
    self.model = [[SSWL_HtmlInfoToUserModel alloc] init];
    self.model.user_id = stringParam[@"user_id"];
    self.model.game_role_id = stringParam[@"game_role_id"];
    self.model.game_role_name = [SSWL_PublicTool decodeString:stringParam[@"game_role_name"]];
    self.model.cp_trade_sn = stringParam[@"cp_trade_sn"];
    self.model.money = stringParam[@"money"] ;
    self.model.money_type = stringParam[@"money_type"];
    self.model.goods_id = stringParam[@"goods_id"];
    self.model.goods_name = [SSWL_PublicTool decodeString:stringParam[@"goods_name"]];
    self.model.goods_desc = stringParam[@"goods_desc"];
    self.model.server = stringParam[@"server"];
    self.model.time = stringParam[@"time"];
    self.model.game_sign = param[@"game_sign"];
    self.model.appId = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId;
    self.model.game_role_level = stringParam[@"game_role_level"];
//    if (![self.model.money_type isEqualToString:@"CYN"]) {
//        self.model.money_type = @"CYN";
//    }
    
    
    NSDictionary *params = @{
                            @"user_id"              :   param[@"user_id"],
                            @"game_role_id"         :   param[@"game_role_id"],
                            @"game_role_name"       :   param[@"game_role_name"],
                            @"game_role_level"      :   param[@"game_role_level"],
                            @"game_sign"            :   param[@"game_sign"],
                            @"cp_trade_sn"          :   param[@"cp_trade_sn"],
                            @"money"                :   param[@"money"],
                            @"money_type"           :   param[@"money_type"],
                            @"goods_id"             :   param[@"goods_id"],
                            @"goods_name"           :   param[@"goods_name"],
                            @"goods_desc"           :   param[@"goods_desc"],
                            @"server"               :   param[@"server"],
                            @"time"                 :   param[@"time"],
                            @"app_id"               :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                            };

    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkWebSYSignWithParams:params completion:^(BOOL isSuccess, id  _Nullable respones) {
        //                    isSuccess = YES;
        if (isSuccess) {
            [weakSelf ifVerificationpassedWithParams:weakSelf.model];
           
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
    
//    self.model.system_version = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].systemVer;
//    self.model.device_id = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid;
//    self.model.system_name = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel;
  
}

- (void)ifVerificationpassedWithParams:(SSWL_HtmlInfoToUserModel *)SYModel{
    SongyorkInfo *songyork = [[SongyorkInfo alloc] init];

    
    songyork.uid = SYModel.user_id;
    songyork.appId = SYModel.appId;
    songyork.roleId = SYModel.game_role_id;
    songyork.roleName = SYModel.game_role_name;
    songyork.roleLevel = SYModel.game_role_level;
    songyork.serverId = SYModel.server;
    songyork.YYY = SYModel.cp_trade_sn;
    songyork.money = SYModel.money;
    songyork.moneyType = SYModel.money_type;
    songyork.proId = SYModel.goods_id;
    songyork.productName = SYModel.goods_name;
    songyork.desc = SYModel.goods_desc;
    
    
    [[HX_SSWL_ZFForHtml sharedHX_SSWL_ZFForHtml] starChectSongyorkWayWithViewContorller:self syInfo:songyork completion:^(NSString *message, id param) {
        /**
         @param message : 只会返回@“支付成功”
         @param param : 返回提交支付的参数
         */
        SYLog(@"message:%@---------------info:%@", message, param);
    }];

}

#pragma mark - WKUIDelegate And WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    [self.loadingImgView removeFromSuperview];
    self.loadingImgView = nil;
    
    
    
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
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}


/**
 * 接收通知的响应事件方法
 */
- (void)signOutGame:(NSNotification *)notification{
    BOOL isOut = [[notification.userInfo valueForKey:notification.object] boolValue];
    
    if (isOut) {
        if (self.webView) {
            self.webView.hidden = YES;
            [self.webView removeFromSuperview];
            self.webView.UIDelegate = nil;
            self.webView.navigationDelegate = nil;
//            self.webView = nil;
        }
    }
}


- (UIImageView *)loadingImgView{
    if (!_loadingImgView) {
        //@"loading" ofType:@"jpg"]]
        _loadingImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [_loadingImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"loading" withType:@"jpg"]];
    }
    return _loadingImgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//*** 3、将字符串转换成md5
- (NSString *_Nullable)toMD5:(NSString *_Nullable)targetString{
    if (targetString){
        const char* data = [targetString UTF8String];
        unsigned int len= (unsigned int)strlen(data);
        unsigned char result[16];
        CC_MD5(data,len,result);
        NSString* md5_string = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                                result[0],result[1],result[2],result[3],result[4],result[5],result[6],
                                result[7],result[8],result[9],result[10],
                                result[11],result[12],result[13],result[14],result[15]];
        return [md5_string lowercaseString];
    }
    return nil;
}

/**
 请求签名
 */

- (NSString *_Nullable)makeSignStringWithParams:(NSDictionary *_Nullable)params{
    NSString *string1 =[[NSString alloc]init];
    NSArray *sortedArray = [params.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *sortedKey in sortedArray) {
        
        NSString *keyValue = [NSString stringWithFormat:@"%@=%@&",sortedKey,params[sortedKey]];
        NSString *string2 =[NSString stringWithFormat:@"%@%@",string1,keyValue];
        string1 = string2;
    }
    NSString *sortedString = [NSString string];
    NSString *lastString = [NSString string];
    if (string1.length > 0) {
        sortedString = [NSString stringWithFormat:@"%@%@",SSWL_KEY,string1];
        lastString = [sortedString substringWithRange:NSMakeRange(0, sortedString.length - 1)];
        
    }else{
        sortedString = [NSString stringWithFormat:@"%@",SSWL_KEY];
        lastString = [sortedString substringWithRange:NSMakeRange(0, sortedString.length)];
        
    }
    NSString *sign = [self toMD5:lastString];
    return sign;
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
