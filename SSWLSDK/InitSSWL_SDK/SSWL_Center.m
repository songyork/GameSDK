//
//  SSWL_Center.m
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_Center.h"
#import "SSWL_LoginNavigationController.h"
#import "SSWL_LoginViewController.h"
#import "SSWL_RegistViewController.h"
#import "SSWL_FirstOpenViewController.h"
#import "SSWL_LoginForPhoneViewController.h"
#import "CheckSongyorkFromLocal.h"
#import "GiftController.h"

#import "SSWL_OpenPushInfo.h"

/* *审核模式下新login页面 */
#import "SSWL_DebugModeViewController.h"

/* *ali推送 */
#import <CloudPushSDK/CloudPushSDK.h>

#import "PushInfoWindow.h"

@interface SSWL_Center ()
{
    NSTimer *_timer;
    int _currentTime;
    NSString *_roleId;
    NSString *_userId;
    NSString *_gameTime;
}
@property (nonatomic, strong) AFNetworkReachabilityManager *manager;

@property(nonatomic,strong)UIWindow *loginWindow;

@property(nonatomic,strong)MBProgressHUD *HUD;

@property (nonatomic ,copy) NSString *appID;

@property (nonatomic, assign) int direction;

@property (nonatomic, assign) BOOL isOut;

@property (nonatomic ,strong) UIViewController *viewC;

@property (nonatomic, strong) PushInfoWindow *pushInfoWindow;

@end

@implementation SSWL_Center




SYSingletonM(SSWL_Center)

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SYLog(@"---销毁通知---");
}


#pragma mark --- 1、初始化SDK
// 不带推送初始化
- (void)initSDKWithAppId:(NSString *)appId screenDirection:(GameDirection)screenGameDirection urlScheme:(NSString *)urlScheme{
    
    [self setUpSSWL_SDKAppId:appId screenDirection:screenGameDirection urlScheme:urlScheme];
 
}

// 带有推送 初始化
- (void)initSDKWithAppId:(NSString *)appId screenDirection:(GameDirection)screenGameDirection urlScheme:(NSString *)urlScheme sendNotificationAck:(NSDictionary *)userInfo {
    
    [self setUpSSWL_SDKAppId:appId screenDirection:screenGameDirection urlScheme:urlScheme];
    
    /* *CloudPush */
    [self registerMessageReceive];
    [CloudPushSDK sendNotificationAck:userInfo];
    
}


/**
 初始化公共方法

 @param appId appid
 @param screenGameDirection 屏幕方向
 @param urlScheme urlScheme
 */
- (void)setUpSSWL_SDKAppId:(NSString *)appId screenDirection:(GameDirection)screenGameDirection urlScheme:(NSString *)urlScheme {
    if (appId.length < 1) {
        return;
    }
    if (screenGameDirection == 1) {
        self.direction = 1;
    }else if (screenGameDirection == 0){
        self.direction = 0;
    }else{
        return;
    }
    
    /**
     * songyorkCenter初始化
     */
#pragma mark ------------------------------------------------ 注册SongyorkBase
    [[SongyorkBase sharedSongyorkBase] registerBase];
    
    self.appID = appId;
    [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] setSDKInfoWithAppId:appId directionNumber:self.direction];
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].needAuto = YES;
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlScheme = urlScheme;
    
    
    /*网络请求初始化*/
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getCustomerServiceCompletion:^(BOOL isSuccess, id response) {
        if (isSuccess) {
            //            SYLog(@"-----------response:%@", response);
            NSDictionary *dict = response[@"data"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].customerService = dict[@"url"];
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getRegexpCompletion:^(BOOL isSuccess, id  _Nullable response) {
        if (isSuccess) {
            //            SYLog(@"%@", response);
            NSDictionary *dict = response[@"data"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].regexModel = [SSWL_RegexModel getRegexWithData:dict];
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
    
    
    /*
     * 是否激活
     */
    Weak_Self;
    [self thereNetworkSignalCurrentlyBlock:^(BOOL hasSignal) {
        if (hasSignal) {
            if (![SSWL_PublicTool getCurrentActivateFlag]){
                [weakSelf userActivate];
            }else{
                SYLog(@"用户已激活");
            }
        }else{
            SYLog(@"当前没有网络可用");
        }
    }];
    
    
    
    /*通知 : 退出游戏*/
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(signOutGame:) name:SSWL_SignOutGame object:nil];
    
    [CheckSongyorkFromLocal checkSongyorkFromLocal];
    
//    NSString *stringTest = [SSWL_PublicTool getSourceFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"sdk_Channel"];
    
}

//用户激活
- (void)userActivate{
    
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getUserActivateCompletion:^(BOOL isActivate, id response) {
        if (isActivate) {
            SYLog(@"用户激活成功----%@", response);
            [SSWL_PublicTool saveActivateFlag:YES];
        }else{
            if (![response[@"msg"] isEqualToString:@"此设备ID已激活过"]) {
                [SSWL_PublicTool showHUDWithViewController:[SSWL_PublicTool getKeyWindowRootVcr] Text:@"网络异常"];

            }
        }
        
    } failure:^(NSError * _Nullable error) {
        [SSWL_PublicTool showHUDWithViewController:[SSWL_PublicTool getKeyWindowRootVcr] Text:@"网络异常"];
    }];
    
}





/**
 开始登录接口
 
 @param viewController viewController
 @param completion 完成回调(给研发)
 */
- (void)startLoginWithViewController:(UIViewController *)viewController completion:(void (^)(NSString *))completion failure:(void (^)(NSError * _Nullable))failure{

    
#pragma mark ------------------------------------------------测试第一次登录
    //    [SSWL_PublicTool firstOpenaApplication:NO];
    if ([SSWL_PublicTool getCurrenFirstOpenApplication]) {
        [self loginTypeWithFirstOrNot:NO completion:^(NSString *url, NSString *gqUrl, NSString *code) {
            
            if (completion) {
                completion(code);
            }
        }];
    }else{
        [self loginTypeWithFirstOrNot:YES completion:^(NSString *url, NSString *gqUrl, NSString *code) {
            if (completion) {
                completion(code);
            }
            
            
        }];
    }
    self.viewC = viewController;
}


/**
 是否是第一次登录
 
 @param isFirst BOOL
 @param completion 完成回调
 */
- (void)loginTypeWithFirstOrNot:(BOOL)isFirst completion:(void(^)(NSString *url, NSString *gqUrl, NSString *code))completion{
    Weak_Self;
    
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isTouristLogin = [SSWL_PublicTool getTouristState];
    
    /**
     * 获取基本信息
     * 是否开启正式服
     * 是否开启审核模式登录页面 & 正式登录页面 & 无登录页面
     */
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getInfoWithAppId:self.appID completion:^(BOOL isSuccess, id  _Nullable respones) {
        if (isSuccess) {
//            SYLog(@"----------%@", respones);
            
            
            NSDictionary *dict = respones[@"data"][@"idcard_check"];
            
            SYLog(@"%@", dict);
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel = [SSWL_BindIdentituInfoModel getBindIdentityInfoWithData:dict];
            
            /**
             * 技术是否是正式版本
             * isAppStatus
             */
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus = [respones[@"data"][@"app_status"] boolValue];
            
            // 是否进入登录框
            int status = [respones[@"data"][@"ui_status"] intValue];
//            status = 1;
            if (status == 1) {
#pragma mark ------------------------------------------------强制进入正式版
//                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus = YES;
//            SYLog(@"-----------------------------isAppStatus:%d", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus);
#pragma mark ------------------------------------------------直接一键登录游戏
                if (![SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus) {
                    
                    [weakSelf getUserOnce_LoginSuccess:^(NSString *code) {
                        if (completion) {
                            completion(@"", @"", code);
                        }
                    } failure:^(NSError * _Nullable error) {
                        
                    }];
                    return;
                }
                
                [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkLoginNoticeCompletion:^(BOOL isSuccess, id response) {
                    
                    NSDictionary *dic = response[@"data"];
                    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].tipsID = dic[@"id"];
                    // 判断是否保存账号,自动登录
                    //创建登录注册界面
                    //防止与主window冲突，延迟执行；
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                        
                        [weakSelf getRootWindowWithType:isFirst completion:^(NSString *url, NSString *gqUrl, NSString *code) {
                            if (completion) {
                                completion(url, gqUrl, code);
                            }
                        }];
                    });
                    
                } failure:^(NSError *error) {
                    //        [self showHUDWithText:@"网络异常"];
                }];
                
            }else{
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                    
                    [weakSelf getRootWindowForDebugModeCompletion:completion];
                });
                
            }
            

            
                
            
   
        }else{
            
            weakSelf.HUD = [MBProgressHUD showHUDAddedTo:weakSelf.viewC.view animated:YES];
            weakSelf.HUD.mode = MBProgressHUDModeText;
            weakSelf.HUD.label.text = @"网络异常";
            [weakSelf.HUD hideAnimated:YES afterDelay:1];
            completion(@"网络异常", @"网络异常", @"网络异常");
            
//            SYLog(@"----------%@", respones);
            
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
    
}


/**
 rootviewcontrol
 
 @param isFirst 是否是第一次
 @param completion 完成后回调
 */
- (void)getRootWindowWithType:(BOOL)isFirst completion:(void(^)(NSString *url, NSString *gqUrl, NSString *code))completion{
    Weak_Self;
    _loginWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _loginWindow.backgroundColor = SYNOColor;
    _loginWindow.windowLevel = UIWindowLevelAlert + 0.1;
    [_loginWindow makeKeyAndVisible];
    if (isFirst) {
        SSWL_FirstOpenViewController *firstVC = [[SSWL_FirstOpenViewController alloc] init];
        firstVC.block = ^{
            weakSelf.loginWindow.alpha = 0;
            weakSelf.loginWindow = nil;
            NSString *url = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl;
            NSString *money = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString;
            NSString *gameCode = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode;
            
            if (gameCode.length < 1) {
                gameCode = @".......";
            }
            if (completion) {
                completion(url, money, gameCode);
            }
        };
        SSWL_LoginNavigationController *lNav = [[SSWL_LoginNavigationController alloc] initWithRootViewController:firstVC];
        [SSWL_PublicTool stopSystemPopGestureRecognizerForNavigationController:lNav];
        
        _loginWindow.rootViewController = lNav;
    }else{
        
        SSWL_LoginForPhoneViewController *loginVC = [[SSWL_LoginForPhoneViewController alloc] init];
        loginVC.isOnline = YES;
        loginVC.block = ^{
            weakSelf.loginWindow.alpha = 0;
            weakSelf.loginWindow = nil;
            NSString *url = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl;
            NSString *money = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString;
            NSString *gameCode = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode;
            
            if (gameCode.length < 1) {
                gameCode = @".......";
            }
            if (completion) {
                completion(url, money, gameCode);
            }
        };
        SSWL_LoginNavigationController *lNav = [[SSWL_LoginNavigationController alloc] initWithRootViewController:loginVC];
        [SSWL_PublicTool stopSystemPopGestureRecognizerForNavigationController:lNav];
        
        _loginWindow.rootViewController = lNav;
    }
    
    
    
    
}


/**
 debug下 登录页面

 @param completion finished_block
 */
- (void)getRootWindowForDebugModeCompletion:(void(^)(NSString *url, NSString *gqUrl, NSString *code))completion {
    
    Weak_Self;
    _loginWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _loginWindow.backgroundColor = SYNOColor;
    _loginWindow.windowLevel = UIWindowLevelAlert + 0.1;
    [_loginWindow makeKeyAndVisible];
    
    
    SSWL_DebugModeViewController *debugLoginVC = [[SSWL_DebugModeViewController alloc] init];
    debugLoginVC.isDebugMode = YES;
    debugLoginVC.DebugLoginBlock = ^{
        weakSelf.loginWindow.alpha = 0;
        weakSelf.loginWindow = nil;
        NSString *url = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl;
        NSString *money = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString;
        NSString *gameCode = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode;
        [weakSelf createFloatWindowIntoGame];
        if (gameCode.length < 1) {
            gameCode = @"Debug-----no game code";
        }
        if (completion) {
            completion(url, money, gameCode);
        }
    };
    
    SSWL_LoginNavigationController *lNav = [[SSWL_LoginNavigationController alloc] initWithRootViewController:debugLoginVC];
    [SSWL_PublicTool stopSystemPopGestureRecognizerForNavigationController:lNav];
    
    _loginWindow.rootViewController = lNav;
}


- (void)userCreateRoleWithRoleId:(NSString *_Nullable)roleId userId:(NSString *_Nullable)userId time:(NSString *_Nullable)time completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion failure:(void(^_Nullable)(NSError *_Nullable error))failure{
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] userCreateRoleWithRoleId:roleId userId:userId htmlSign:@"" time:time completion:^(BOOL isSuccess, id  _Nullable respones) {
        if (isSuccess) {
            SYLog(@"创建角色成功");
            _currentTime = 0;
            _roleId = roleId;
            _userId = userId;
            _gameTime = time;
            /* *自行调用5分钟在线 */
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(fiveMinSender:) userInfo:nil repeats:YES];
            [_timer fire];
            if (completion) {
                completion(YES, respones);
            }
        }else{
            if (completion) {
                completion(NO, respones);
            }
            SYLog(@"创建角色失败");
        }
    } failure:failure];
}


/**
 NSTimer 方法

 @param sender sender
 */
- (void)fiveMinSender:(id)sender{
    _currentTime++;
    SYLog(@"currenTime = %d", _currentTime);
    if (_currentTime == 300) {
        [self onlineFor5MinutesWithUserId:_userId roleId:_roleId time:_gameTime completion:^(BOOL isSuccess, id  _Nullable respones) {
            if (isSuccess) {
                SYLog(@"角色在线5分钟成功");
                
            }else{
                
                SYLog(@"角色在线5分钟失败");
            }
            
        } failure:^(NSError * _Nullable error) {
            
        }];
    }
}

/*在线5分钟接口*/
- (void)onlineFor5MinutesWithUserId:(NSString *)userId roleId:(NSString *)roleId time:(NSString *)time completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] onlineFor5MinutesWithUserId:userId roleId:roleId time:time htmlSign:@"" completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
            SYLog(@"角色在线5分钟");
            if (completion) {
                completion(YES, respones);
            }
           
        }else{
            if (completion) {
                completion(NO, respones);
            }
           
            SYLog(@"角色在线5分钟");
        }
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
            _currentTime = 0;
        }
        
    } failure:^(NSError *error) {
       
        if (failure) {
            failure(error);
        }
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
            _currentTime = 0;
        }
    }];
}

/*角色升级接口*/
- (void)levelUpWithUserId:(NSString *)userId roleId:(NSString *)roleId level:(NSString *)level time:(NSString *)time completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] levelUpWithUserId:userId roleId:roleId level:level time:time htmlSign:@"" completion:completion failure:failure];
}


/* *用户登录服务器 */
- (void)userServerLoginWithUserId:(NSString *)userId serverId:(NSString *)serverId loginTime:(NSString *)loginTime completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] userServerLoginWithUserId:userId serverId:serverId loginTime:loginTime time:@"" gameSign:@"" completion:completion failure:failure];
}

/*接收通知,退出游戏*/
- (void)signOutGame:(NSNotification *)notification{
    SYLog(@"-----object:%@ ----- userInfo:%@ ------ name:%@", notification.object, notification.userInfo, notification.name);
    NSDictionary *dic = notification.userInfo;
    self.isOut = [[dic valueForKey:notification.object] boolValue];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        _currentTime = 0;
    }
    if (self.isOut) {
        [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] destroyFloatWindow];
        
    }else{
        SYLog(@".....");
    }
    
}

/*给研发的退出游戏接口*/
- (void)gameIsSignOutIfNeedSignIn:(BOOL)isSignIn completion:(void (^ _Nullable)(NSString * _Nullable))completion failure:(void (^ _Nullable)(NSError * _Nullable))failure{
    
    SYLog(@"研发方退出登录");
    [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] destroyFloatWindow];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        _currentTime = 0;
    }
    //isSignOut ? YES (自动弹出登录框) : NO (不会弹出登录框)
    if (isSignIn) {
        [self startLoginWithViewController:self.viewC completion:completion failure:failure];
    }
    
}

- (void)getALCPushInfoPostServerWithdeviceId:(NSString *)deviceId {
    //    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] postServerUserDeviceId:deviceId completion:completion failure:failure];
    [SSWL_PushInfo sharedSSWL_PushInfo].alcDeviceId = deviceId;
}


- (void)getAlCPushDidReceiveRemoteNotification:(NSDictionary *)userInfo isShowInfo:(BOOL)isShowInfo callbackHandler:(void (^)(NSString * _Nullable, NSDictionary * _Nullable))callbackHandler {
    
    // 取得APNS通知内容
    NSDictionary *userInfoDictionary = [userInfo valueForKey:@"aps"];
    // 内容
    NSString *content = [userInfoDictionary valueForKey:@"alert"];
    // badge数量
    int badge = [[userInfoDictionary valueForKey:@"badge"] intValue];
    // 播放声音
    NSString *sound = [userInfoDictionary valueForKey:@"sound"];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
    NSString *url = [userInfoDictionary valueForKey:@"url"];

    SYLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, extras);
    
    [SSWL_PushInfo sharedSSWL_PushInfo].content = content;
    [SSWL_PushInfo sharedSSWL_PushInfo].sound = sound;
    [SSWL_PushInfo sharedSSWL_PushInfo].badge = badge;
    [SSWL_PushInfo sharedSSWL_PushInfo].extras = extras;
    [SSWL_PushInfo sharedSSWL_PushInfo].pushKeyUrl = url;

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self syncBadgeNum:0];
    [CloudPushSDK sendNotificationAck:userInfo];
    if (isShowInfo) {
        [self openPushInfoWithKey:url];

    }

    
    if (callbackHandler) {
        callbackHandler(@"暂时只返回推送内容", userInfoDictionary);
    }
}


- (void)getAlCPushiOS10Notification:(UNNotification *)notification isShowInfo:(BOOL)isShowInfo callbackHandler:(void (^)(NSString * _Nullable, NSDictionary * _Nullable))callbackHandler {
    if (@available(iOS 10.0, *)) {
        UNNotificationRequest *request = notification.request;
        UNNotificationContent *content = request.content;
        NSDictionary *userInfoDictionary = content.userInfo;
        // 通知时间
        NSDate *noticeDate = notification.date;
        // 标题
        NSString *title = content.title;
        // 副标题
        NSString *subtitle = content.subtitle;
        // 内容
        NSString *body = content.body;
        // 角标
        int badge = [content.badge intValue];
        // 取得通知自定义字段内容，例：获取key为"Extras"的内容
        NSString *extras = [userInfoDictionary valueForKey:@"Extras"];
        
        NSString *url = [userInfoDictionary valueForKey:@"url"];
        
        SYLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
        
        [SSWL_PushInfo sharedSSWL_PushInfo].noticeDate = noticeDate;
        [SSWL_PushInfo sharedSSWL_PushInfo].title = title;
        [SSWL_PushInfo sharedSSWL_PushInfo].subtitle = subtitle;
        [SSWL_PushInfo sharedSSWL_PushInfo].body = body;
        [SSWL_PushInfo sharedSSWL_PushInfo].badge = badge;
        [SSWL_PushInfo sharedSSWL_PushInfo].extras = extras;
        [SSWL_PushInfo sharedSSWL_PushInfo].pushKeyUrl = url;
        
        // 通知角标数清0
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self syncBadgeNum:0];
        [CloudPushSDK sendNotificationAck:userInfoDictionary];
        
        if (isShowInfo) {
            [self openPushInfoWithKey:url];
            
        }
        if (callbackHandler) {
            callbackHandler(@"暂时只返回推送内容", userInfoDictionary);
        }
    } else {
        // Fallback on earlier versions
    }
    
    
}

- (void)openPushInfoWithKey:(NSString *)key {
    if (key.length > 0) {
      [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] destroyFloatWindow];
        Weak_Self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
            weakSelf.pushInfoWindow = [[PushInfoWindow alloc] initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, Screen_Height)];
            weakSelf.pushInfoWindow.PushInfoBlock = ^{
                [UIView animateWithDuration:.2f animations:^{
                    weakSelf.pushInfoWindow.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height);
                    weakSelf.pushInfoWindow.alpha = .1f;
                } completion:^(BOOL finished) {
                    weakSelf.pushInfoWindow.hidden = YES;
                    weakSelf.pushInfoWindow = nil;
                    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus && [SSWL_PushInfo sharedSSWL_PushInfo].isLoginStatus) {
                        [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
                    }
                }];
             
            };
            [UIView animateWithDuration:.2f animations:^{
                weakSelf.pushInfoWindow.frame = [UIScreen mainScreen].bounds;

            } completion:^(BOOL finished) {

            }];
            [weakSelf.pushInfoWindow makeKeyAndVisible];

//            [SSWL_PublicTool mainWindowAddSubViewWindow:self.pushInfoWindow];
        });
    }
    
}

- (void)ifIControlTheGameStartLoginWithViewController:(UIViewController *)viewController completion:(void(^)(NSString *code ,NSString *userId, NSString *userName))completion failure:(void(^_Nullable)(NSError *_Nullable error))failure{
#pragma mark ------------------------------------------------测试第一次登录
    //    [SSWL_PublicTool firstOpenaApplication:NO];
    if ([SSWL_PublicTool getCurrenFirstOpenApplication]) {
        [self loginTypeWithFirstOrNot:NO completion:^(NSString *url, NSString *gqUrl, NSString *code) {
            
            NSString *username = [NSString stringWithFormat:@"%@", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser];
            NSString *userId = [NSString stringWithFormat:@"%@", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].userId];
            if (completion) {
                completion(code, userId, username);
            }
        }];
    }else{
        [self loginTypeWithFirstOrNot:YES completion:^(NSString *url, NSString *gqUrl, NSString *code) {
            NSString *username = [NSString stringWithFormat:@"%@", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser];
            NSString *userId = [NSString stringWithFormat:@"%@", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].userId];
            if (completion) {
                completion(code, userId, username);
            }
            
            
        }];
    }
    self.viewC = viewController;
}
- (void)ifIControlTheGameIsSignOutIfNeedSignIn:(BOOL)isSignIn completion:(void (^)(NSString * _Nullable, NSString * _Nullable, NSString * _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    SYLog(@"研发方退出登录");
    [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] destroyFloatWindow];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        _currentTime = 0;
    }
    //isSignOut ? YES (自动弹出登录框) : NO (不会弹出登录框)
    if (isSignIn) {
        [self ifIControlTheGameStartLoginWithViewController:self.viewC completion:completion failure:failure];
    }
}


/*
- (void)shareIsSuccess:(BOOL)isSuccess{
    
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isShareSuccess = isSuccess;
        if (isSuccess) {
            GiftController *giftVC = [[GiftController alloc] init];
            [giftVC ifShareIsSuccess];
        }
}
*/
 
 
/**
 直接登录

 @param completion finished block
 @param failure error block
 */
- (void)getUserOnce_LoginSuccess:(void(^)(NSString * code))completion failure:(void (^)(NSError * _Nullable error))failure{
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] registTouristCompletion:^(BOOL isSuccess, id  _Nullable respones) {
        if (isSuccess) {
            [weakSelf createFloatWindowIntoGame];
            if (completion) {
                completion([SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode);
            }else{
                NSDictionary *dic = respones;
                [SSWL_PublicTool showHUDWithViewController:weakSelf.viewC Text:dic[@"msg"]];
            }
        }
    } failure:^(NSError * _Nullable error) {
        [SSWL_PublicTool showHUDWithViewController:weakSelf.viewC Text:@"网络异常"];
    }];
    
}


- (void)createFloatWindowIntoGame{
    
    [SSWL_PublicTool createFloatWindowIntoGameAndPostALCDeviceIdCompletion:nil];
   
}


- (void)thereNetworkSignalCurrentlyBlock:(void(^)(BOOL hasSignal))block{
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getNetWorkStateBlock:^(NSInteger netStatus) {
        if (netStatus == 1 || netStatus == 2) {
            if (block) {
                block(YES);
            }
        }else{
            if (block) {
                block(NO);
            }
        }
        [weakSelf logCurrenNetworkStatus:netStatus];
    }];
}

- (void)logCurrenNetworkStatus:(NSInteger)netStatus{
    switch (netStatus) {
        case 0:
            SYLog(@"------------------断网状态");
            break;
            
        case 1:
            SYLog(@"------------------Wifi状态");
            break;
            
        case 2:
            SYLog(@"------------------流量状态");
            break;
            
        case 3:
            SYLog(@"------------------未知状态");
            break;
            
        default:
            break;
    }
    
}

/**
 *    注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
    SYLog(@"注册推送消息到来监听");
}

/**
 *    处理到来推送消息
 *
 *    @param     notification : 通知
 */
- (void)onMessageReceived:(NSNotification *)notification {
    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    SYLog(@"Receive message title: %@, content: %@.", title, body);
}

/* 同步通知角标数到服务端 */
- (void)syncBadgeNum:(NSUInteger)badgeNum {
    [CloudPushSDK syncBadgeNum:badgeNum withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            SYLog(@"Sync badge num: [%lu] success.", (unsigned long)badgeNum);
        } else {
            SYLog(@"Sync badge num: [%lu] failed, error: %@", (unsigned long)badgeNum, res.error);
        }
    }];
}

@end
