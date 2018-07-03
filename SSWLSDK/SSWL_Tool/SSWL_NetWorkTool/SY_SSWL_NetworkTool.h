//
//  SY_SSWL_NetworkTool.h
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYSYSingleton.h"


/**
 * 四个基础请求参数
 *param @"sdk_version" : [SS_SDKBasicInfo sharedSS_SDKBasicInfo].sdkVer,
 *
 *param @"time"        : [PublicTool getTimeStamps],
 *
 *param @"device_id"   : [SS_SDKBasicInfo sharedSS_SDKBasicInfo].uuid,
 *
 *param @"token"       : [SS_SDKBasicInfo sharedSS_SDKBasicInfo].sdkToken,
 *
 */
@class SongyorkInfo;

typedef NS_ENUM(NSInteger, RegistType) {
    RegistTypeName             = 0, //用户名
    RegistTypePhone            = 1, // 手机号
    
};



@interface SY_SSWL_NetworkTool : NSObject



SYSingletonH(SY_SSWL_NetworkTool)



/**
 初始化属性_manager
 */
- (void)getManagerBySingleton;

//#pragma mark --- 2、点击切换账号调用方法:1、关闭悬浮窗；2、调用登录接口
//- (void)switchBtnClick;




/**
 获取网络状态

 @param statusBlock statusBlock
 */
- (void)getNetWorkStateBlock:(void(^_Nullable)(NSInteger netStatus))statusBlock;

#pragma mark --- 5、删除保存的账号密码
//- (void)deleteUserInfoWithIndex:(NSUInteger)index;


#pragma mark ---------------网络请求------------
#pragma mark -------------激活

/**
 激活

 @param completion block
 */
- (void)getUserActivateCompletion:(void(^_Nullable)(BOOL isActivate, id _Nullable response))completion
                          failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 获取客服html接口

 @param completion Finished block
 */
- (void)getCustomerServiceCompletion:(void(^_Nullable)(BOOL isSuccess, id _Nullable response))completion
                             failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 获取游戏基本信息

 @param completion Finished block
 @param failure Error block
 */
- (void)getGameInfoCompletion:(void(^_Nullable)(BOOL isSuccess, id _Nullable response)) completion
                      failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 获取正则表达式
 
 @param completion Finished block
 @param failure Error block
 */
- (void)getRegexpCompletion:(void(^_Nullable)(BOOL isSuccess, id _Nullable response)) completion
                    failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 检测用户是否存在
 
 @param userName 用户名
 @param userType 用户类型
 */
- (void)checkIfTheUserExistsWithUserName:(NSString *_Nullable)userName
                                userType:(NSInteger)userType
                              completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable response)) completion
                                 failure:(void(^_Nullable)(NSError *_Nullable error))failure;;

/**
 登录前公告
 
 @param completion Finished block
 @param failure Error block
 */
- (void)checkLoginNoticeCompletion:(void(^_Nullable)(BOOL isSuccess, id _Nullable response)) completion
                           failure:(void(^_Nullable)(NSError *_Nullable error))failure;




/**
 给市场同事方便删除自己的deviceI的接口

 @param appId APPID
 @param completion Finished block
 @param failure Error block
 */
- (void)clearDeviceIdWithAppId:(NSString *_Nullable)appId
                    completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable resp))completion
                       failure:(void(^_Nullable)(NSError *_Nullable error))failure;





/**
 检查token是否过期
 
 @param token token
 @param userName 用户名
 @param completion Finished block
 @param failure Error block
 */
- (void)checkExpiredForToken:(NSString *_Nullable)token
                    userName:(NSString *_Nullable)userName
                  completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable resp))completion
                     failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 token过期是用验证码登录接口
 
 @param phoneNumber 电话号码
 @param code 验证码
 @param completion Finished block
 @param failure Error block
 */
- (void)phoneLoginWithPhoneNumber:(NSString *_Nullable)phoneNumber
                             code:(NSString *_Nullable)code
                       completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable resp, NSString *_Nullable message))completion
                          failure:(void(^_Nullable)(NSError *_Nullable error))failure;



/**
 一键注册接口

 @param completion Finished block
 @param failure Error block
 */
- (void)registTouristCompletion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                        failure:(void(^_Nullable)(NSError *_Nullable error))failure;

/**
 注册

 @param userName 用户名
 @param password 密码
 @param registType 注册方式 (1-手机号注册, 0-用户名注册)
 @param code 手机号注册的验证码
 @param completion Finished block
 @param failure Error block
 */
- (void)registWithUserName:(NSString *_Nullable)userName
                  password:(NSString *_Nullable)password
                   regType:(RegistType)registType
                      code:(NSString *_Nullable)code
                completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                   failure:(void(^_Nullable)(NSError *_Nullable error))failure;





/**
 获取登录后公告

 @param completion Finished block
 @param failure Error block
 */
- (void)noticeBeforTheLoginCompletion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                              failure:(void(^_Nullable)(NSError *_Nullable error))failure;


/**
 *  游客登录
 */

//- (void)touristLoginCompletion:(void(^)(BOOL isSuccess, id respones))completion;


/**
 登录接口

 @param userName 用户名
 @param password 密码
 @param completion Finished block
 @param failure Error block
 */
- (void)loginWithUserName:(NSString *_Nullable)userName
                 password:(NSString *_Nullable)password
               completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                  failure:(void(^_Nullable)(NSError *_Nullable error))failure;




/**
 验证动态口令

 @param key 口令
 @param completion Finished block
 @param failure Error block
 */
- (void)verifyDynamicPasswordWithKey:(NSString *_Nullable)key
                          completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                             failure:(void(^_Nullable)(NSError *_Nullable error))failure;



/**
 绑定手机号码

 @param tokenStr token
 @param code 手机验证码
 @param phoneNum 手机号码
 @param completion Finished block
 @param failure Error block
 */
- (void)bindMobileWithToken:(NSString *_Nullable)tokenStr
                       code:(NSString *_Nullable)code
                phoneNumber:(NSString *_Nullable)phoneNum
                 completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                    failure:(void(^_Nullable)(NSError *_Nullable error))failure;



/**
 获取用户基本信息

 @param completion Finished block
 @param failure Error block
 */
- (void)getUserBasicInfoCompletion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                           failure:(void(^_Nullable)(NSError *_Nullable error))failure;




/**
 通过老密码修改新密码

 @param tokenStr token
 @param oldPassword 老密码
 @param password 新密码
 @param repassword 新密码确认
 @param completion Finished block
 @param failure Error block
 */
- (void)modifyPasswordWithToken:(NSString *_Nullable)tokenStr
                    oldPassword:(NSString *_Nullable)oldPassword
                       password:(NSString *_Nullable)password
                     repasswrod:(NSString *_Nullable)repassword
                     completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                        failure:(void(^ _Nullable)(NSError *_Nullable error))failure;

/**找回密码短信发送接口
 * param phoneNum : 电话号码
 */

/**
 找回密码短信发送接口

 @param phoneNum 电话号码
 @param completion Finished block
 @param failure Error block
 */
- (void)getFindPasswordSmsWithPhoneNumber:(NSString *_Nullable)phoneNum
                               completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                                  failure:(void(^_Nullable)(NSError * _Nullable error))failure;




/**
 绑定手机信息

 @param phoneNum 电话号码
 @param completion Finished block
 @param failure Error block
 */
- (void)bindPhoneSmsWithPhoneNumber:(NSString *_Nullable)phoneNum
                         completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                            failure:(void(^ _Nullable)(NSError *_Nullable error))failure;





/**
 手机号码登录

 @param phoneNum 电话号码
 @param completion Finished block
 @param failure Error block
 */
- (void)loginForPhoneSmsWithPhoneNumber:(NSString *_Nullable)phoneNum
                             completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                                failure:(void(^ _Nullable)(NSError *_Nullable error))failure;




/**
 找回密码短信验证接口

 @param phoneNum 电话号码
 @param code 验证码
 @param completion Finished block
 @param failure Error block
 */
- (void)checkSmsWithPhone:(NSString *_Nullable)phoneNum
                     code:(NSString *_Nullable)code
               completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                  failure:(void(^ _Nullable)(NSError *_Nullable error))failure;


/**
 修改密码

 @param password 新密码
 @param phoneNum 电话号码
 @param code 验证码
 @param completion Finished block
 @param failure Error block
 */
- (void)changePassword:(NSString *_Nullable)password
              phoneNum:(NSString *_Nullable)phoneNum
                  code:(NSString *_Nullable)code
            completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
               failure:(void(^_Nullable)(NSError *_Nullable error))failure;



/**
 获取是否有未读的新公告

 @param completion Finished block
 @param failure Error block
 */
- (void)checkGameNoticeCompletion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                          failure:(void(^ _Nullable)(NSError *_Nullable error))failure;






/**
 上传阿里云推送deviceId到服务器

 @param userDeviceId 阿里云推送deviceID
 @param completion finished_block
 @param failure failure_block
  */
 - (void)postServerUserDeviceId:(NSString *)userDeviceId
 completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
 failure:(void(^ _Nullable)(NSError *_Nullable error))failure;
 




/**
 验证身份证信息

 @param name 用户姓名
 @param idCard 用户身份证号码
 @param completion Finished block
 @param failure Error block
 */
- (void)verifyIdcardWithName:(NSString *_Nullable)name
                      idCard:(NSString *_Nullable)idCard
                  completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                     failure:(void(^ _Nullable)(NSError *_Nullable error))failure;




/**
 分享游戏礼包 (无限期停用)

 @param completion Finished block
 @param failure Error block
 */
- (void)shareTheGameGiftInfoCompletion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable response))completion
                               failure:(void(^ _Nullable)(NSError *_Nullable error))failure;


/**
 获取应用信息

 @param appId APPID
 @param completion Finished block
 @param failure Error block
 */
- (void)getInfoWithAppId:(NSString *_Nullable)appId
              completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                 failure:(void(^ _Nullable)(NSError *_Nullable error))failure;



/**
 用户注册游戏角色

 @param roleId 角色id
 @param userId 用户id
 @param htmlSign HTML签名
 @param time 时间戳
 @param completion Finished block
 @param failure Error block
 */
- (void)userCreateRoleWithRoleId:(NSString *_Nullable)roleId
                          userId:(NSString *_Nullable)userId
                        htmlSign:(NSString *_Nullable)htmlSign
                            time:(NSString *_Nullable)time
                      completion:(void(^_Nullable)(BOOL isSuccess, id _Nullable respones))completion
                         failure:(void(^_Nullable)(NSError *_Nullable error))failure;




/**
 用户保持角色在线5分钟

 @param userId 用户id
 @param roleId 角色id
 @param time 时间戳
 @param htmlSign HTML签名
 @param completion Finished block
 @param failure Error block
 */
- (void)onlineFor5MinutesWithUserId:(NSString *_Nullable)userId
                             roleId:(NSString *_Nullable)roleId
                               time:(NSString *_Nullable)time
                           htmlSign:(NSString *_Nullable)htmlSign
                         completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                            failure:(void(^ _Nullable)(NSError * _Nullable error))failure;




/**
 用户升级

 @param userId 用户id
 @param roleId 角色id
 @param level 角色等级
 @param time 时间戳
 @param htmlSign HTML签名
 @param completion Finished block
 @param failure Error block
 */
- (void)levelUpWithUserId:(NSString *_Nullable)userId
                   roleId:(NSString *_Nullable)roleId
                    level:(NSString *_Nullable)level
                     time:(NSString *_Nullable)time
                 htmlSign:(NSString *_Nullable)htmlSign
               completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                  failure:(void(^ _Nullable)(NSError *_Nullable error))failure;



/**
 用户登录哪个服务器

 @param userId uid
 @param serverId 服务器id
 @param loginTime 登录时间
 @param time 时间戳
 @param gameSign HTML签名
 @param completion finished block
 @param failure error block
 */
- (void)userServerLoginWithUserId:(NSString *)userId
                         serverId:(NSString *)serverId
                        loginTime:(NSString *)loginTime
                             time:(NSString *)time
                         gameSign:(NSString *)gameSign
                       completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                          failure:(void(^ _Nullable)(NSError *_Nullable error))failure;


/**
 验证游戏参数与签名是否正确

 @param params 游戏参数
 @param completion Finished block
 @param failure Error block
 */
- (void)checkWebSYSignWithParams:(NSDictionary *_Nullable)params
                      completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                         failure:(void(^ _Nullable)(NSError *_Nullable error))failure;



/**
 检查以哪种方式来进行GQ

 @param songyorkInfo SongyorkInfo
 @param completion Finished block
 @param failure Error block
 */
- (void)checkSongyorkWithSongyorkInfo:(SongyorkInfo *_Nullable)songyorkInfo
                          completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                             failure:(void(^ _Nullable)(NSError *_Nullable error))failure;



/**
 GQ下DingDan接口

 @param songyorkInfo SongyorkInfo
 @param completion Finished block
 @param failure Error block
 */
- (void)requestSongyorkWithInfo:(SongyorkInfo *_Nullable)songyorkInfo
                        completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                           failure:(void(^ _Nullable)(NSError *_Nullable error))failure;


/**
 GQ成功后给服务器的回调

 @param param 参数
 @param completion Finished block
 @param failure Error block
 */
- (void)callBackToSongyorkServerWithReceiptInfo:(id _Nullable)param
                             completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                                failure:(void(^ _Nullable)(NSError *_Nullable error))failure;

/**
 * 检查是否有weifukuan的信息
 */

/**
 检查室友有掉单

 @param param 参数
 @param completion Finished block
 @param failure Error block
 */
- (void)checkSongyorkToServerWithReceiptInfo:(id _Nullable)param
                            completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                               failure:(void(^ _Nullable)(NSError *_Nullable error))failure;

//- (void)loginForForumWithUserName:(NSString *_Nullable)userName Password:(NSString *_Nullable)password failure:(void(^ _Nullable)(NSError *_Nullable error))failure;




/**
 test接口

 @param completion Finished block
 @param failure Error block
 */
- (void)testInfoToAnyParamCompletion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                             failure:(void(^ _Nullable)(NSError *_Nullable error))failure;




@end
