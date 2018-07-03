//
//  SSWL_Center.h
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

typedef NS_ENUM(NSInteger, GameDirection){
    Horizontal          = 0, //横屏
    Vertical            = 1, //竖屏
};



@interface SSWL_Center : NSObject



/**
 *
 * 获取SDKCenter单例对象
 *
 **/
+(SSWL_Center *)sharedSSWL_Center;


/**
 *  初始化SDK
 *
 *  @param    appId                 :  游戏提供的appId
 *
 *  @param    screenGameDirection   :  游戏的横竖屏方向：横屏游戏填 Horizontal ；竖屏游戏填 Vertical；
 *
 *  @param    urlScheme             :  游戏提供的urlScheme
 *
 **/
/*
 弃用
- (void)initSDKWithAppId:(NSString *)appId
         screenDirection:(GameDirection)screenGameDirection
               urlScheme:(NSString *)urlScheme;
*/


/**
 *  初始化SDK
 *
 *  @param    appId                 :  游戏提供的appId
 *
 *  @param    screenGameDirection   :  游戏的横竖屏方向：横屏游戏填 Horizontal ；竖屏游戏填 Vertical；
 *
 *  @param    urlScheme             :  游戏提供的urlScheme
 *
 *  @param    userInfo              :  阿里云所需要的参数
 **/
- (void)initSDKWithAppId:(NSString *)appId
         screenDirection:(GameDirection)screenGameDirection
               urlScheme:(NSString *)urlScheme
     sendNotificationAck:(NSDictionary *)userInfo;

/**
 分享成功回调
 暂时用不上
 @param isSuccess 是否成功
 */
//- (void)shareIsSuccess:(BOOL)isSuccess;



/**
 开始登陆接口
 
 @param viewController 记录当前的视图控制器
 @param completion Finished Block
 @param failure Error Block
 */
- (void)startLoginWithViewController:(UIViewController *)viewController
                          completion:(void(^)(NSString *code))completion
                             failure:(void(^_Nullable)(NSError *_Nullable error))failure;






/**
 用户创建角色
 
 @param roleId 角色id
 @param userId 用户id
 @param time 当前时间戳(精确到秒即可)
 @param completion 完成后的回调
 @param failure error回调
 */
- (void)userCreateRoleWithRoleId:(NSString *_Nullable)roleId
                          userId:(NSString *_Nullable)userId
                            time:(NSString *_Nullable)time
                      completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                         failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 角色保持在线到5分钟
 *当用户创建角色并且保持角色在线到达5分钟是调用该接口, 调用一次即可*
 (SDK内部自行调用, 研发不用接入)
 @param userId 用户id
 @param roleId 角色id
 @param time 当前时间戳(精确到秒即可)
 @param completion
 @param failure
 */
//- (void)onlineFor5MinutesWithUserId:(NSString *_Nullable)userId roleId:(NSString *_Nullable)roleId time:(NSString *_Nullable)time completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 角色升级调用接口
 
 @param userId 用户id
 @param roleId 角色id
 @param time 当前时间戳(精确到秒即可)
 @param level 觉得等级
 @param completion
 @param failure
 */
- (void)levelUpWithUserId:(NSString *_Nullable)userId
                   roleId:(NSString *_Nonnull)roleId
                    level:(NSString *_Nullable)level
                     time:(NSString *_Nullable)time
               completion:(void(^_Nonnull)(BOOL isSuccess, id _Nullable respones))completion
                  failure:(void(^_Nullable)(NSError *_Nullable error))failure;



/**
 用户登录游戏服务器id

 @param userId 用户id
 @param serverId 服务器id
 @param loginTime 登录时间
 @param completion completion_block
 @param failure failure_block
 */
- (void)userServerLoginWithUserId:(NSString *)userId
                         serverId:(NSString *)serverId
                        loginTime:(NSString *)loginTime
                       completion:(void(^ __nullable)(BOOL isSuccess, id __nullable respones))completion
                          failure:(void(^ __nullable)(NSError *__nullable error))failure;



/**
 获取ALCDeviceId

 @param deviceId ALCDeviceId
 */
- (void)getALCPushInfoPostServerWithdeviceId:(NSString *)deviceId;


/**
 获取后端推送来的信息
 
 *  方法执行 :
 {
 
 • application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 •                                   &
 • application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
 }
 @param userInfo 后端推送来的信息
 @param callbackHandler callbackHandler
 */
- (void)getAlCPushDidReceiveRemoteNotification:(NSDictionary *__nullable)userInfo
                                    isShowInfo:(BOOL)isShowInfo
                               callbackHandler:(void (^)(NSString * _Nullable message, NSDictionary * __nullable userInfo))callbackHandler;


/**
 获取后端推送来的信息
 * ios 10.0 使用
 * willPresentNotification 和 didReceiveNotificationResponse 方法执行
 @param notification 后端推送来的信息
 @param callbackHandler callbackHandler
 */
- (void)getAlCPushiOS10Notification:(UNNotification *__nullable)notification
                         isShowInfo:(BOOL)isShowInfo
                    callbackHandler:(void(^__nullable)(NSString *__nullable message, NSDictionary *__nullable userInfo))callbackHandler;


/**
 同步当前角标数

 @param badgeNum 设置角标数
 */
- (void)syncBadgeNum:(NSUInteger)badgeNum;
/**
 获取后端推送来的信息
 * ios 10.0 使用
 * userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler 方法执行
 @param userNotification 后端推送来的信息
 @param callbackHandler callbackHandler
 
 - (void)getALCPushWillPresentNotification:(UNNotification *__nullable)userNotification
 callbackHandler:(void(^__nullable)(NSString *__nullable action))callbackHandler API_AVAILABLE(ios(10.0));
 */




/**
 获取后端推送来的信息
 * ios 10.0
 * userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler 方法执行
 @param response 后端推送来的信息
 @param callbackHandler callbackHandler
 
 - (void)getAlcPushDidReceiveNotificationResponse:(UNNotificationResponse *__nullable)response
 callbackHandler:(void(^__nullable)(NSString *__nullable action))callbackHandler API_AVAILABLE(ios(10.0));
 */






/**
 游戏方点击退出登录或切换
 
 @param isSignIn 是否需要SDK主动调起登录接口 ? yes : no
 @param completion Finished Block
 @param failure Error Block
 */
- (void)gameIsSignOutIfNeedSignIn:(BOOL)isSignIn
                       completion:(void(^_Nullable)(NSString *_Nullable code))completion
                          failure:(void(^_Nullable)(NSError *_Nullable error))failure;




- (void)ifIControlTheGameStartLoginWithViewController:(UIViewController *_Nullable)viewController
                                           completion:(void(^_Nullable)(NSString * _Nullable code ,NSString * _Nullable userId, NSString * _Nullable userName))completion
                                              failure:(void(^_Nullable)(NSError *_Nullable error))failure;



- (void)ifIControlTheGameIsSignOutIfNeedSignIn:(BOOL)isSignIn
                                    completion:(void(^_Nullable)(NSString * _Nullable code, NSString *_Nullable userId, NSString *_Nullable userName))completion
                                       failure:(void(^_Nullable)(NSError *_Nullable error))failure;


@end
