//
//  SSWL_BasiceInfo.h
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYSYSingleton.h"
#import "SSWL_BindIdentituInfoModel.h"
#import "SSWL_RegexModel.h"


@interface SSWL_BasiceInfo : NSObject

/* *游戏appKey */
@property (nonatomic, copy) NSString *sswl_AppId;
/* *游戏方向，0位横屏游戏、1位竖屏游戏/3iPadH5游戏 */
@property (nonatomic, assign) int directionNumber;
/* *是否绑定身份证 */
@property (nonatomic, assign) BOOL isBindingIdCard;
/* *是否绑定手机 */
@property (nonatomic, assign) BOOL isBindPhone;
/* *包名 bundleId */
@property (nonatomic, copy) NSString *package_name;
/* *APP版本 */
@property (nonatomic, copy) NSString *app_Version;
/* *SDK版本 */
@property (nonatomic, copy) NSString *sdk_Version;
/* *app渠道 */
@property (nonatomic, copy) NSString *app_channel;
/* *手机系统版本 */
@property (nonatomic, copy) NSString *system_Version;
/* *手机本地保存，app对应的唯一表示 */
@property (nonatomic, copy) NSString *uuid;
/* *IDFA */
@property (nonatomic, copy) NSString *idfa;
/* *IDFV */
@property (nonatomic, copy) NSString *idfv;
/* *苹果手机型号 */
@property (nonatomic, copy) NSString *device_Model;
/* *平台 固定是iOS */
@property (nonatomic, copy) NSString *platform;
/* *客服链接 */
@property (nonatomic, copy) NSString *customerService;
/* *h5游戏链接 */
@property (nonatomic ,copy) NSString *requestUrl;
/* *zhifu */
@property (nonatomic ,copy) NSString *urlString;
/* *token值 */
@property (nonatomic ,copy) NSString *sdkToken;
/* *给游戏方验证的token值 */
@property (nonatomic, copy) NSString *gameCode;

/* *给游戏方验证的dd值 */
@property (nonatomic, copy) NSString *yyy;

/* *退出游戏 */
@property (nonatomic, assign) BOOL isSignOut;
/* *当前登录的账号 */
@property (nonatomic, copy) NSString *loginUser;
/* *需要保存 */
@property (nonatomic ,copy) NSString *fastUserName;
/* *是否需要自动登录 */
@property (nonatomic, assign) BOOL needAuto;
/* *app状态,是否是正式服 */
@property (nonatomic, assign) BOOL isAppStatus;
/* *是否有网络 */
@property (nonatomic, assign) BOOL haveInterNet;
/* *改绑手机 */
@property (nonatomic, assign) BOOL changeBind;
/* *已绑定的手机号码 */
@property (nonatomic, copy) NSString *bindPhoneNumber;
/* *论坛id */
@property (nonatomic, copy) NSString *bbsID;
/* *公告id */
@property (nonatomic ,copy) NSString *tipsID;
/* *游戏名 */
@property (nonatomic, copy) NSString *gameName;
/* *公告数目 */
@property (nonatomic, assign) int tipsNumber;
/* *礼包id */
@property (nonatomic, copy) NSString *giftId;
/* *是否是一键注册 */
@property (nonatomic, assign) BOOL isTouristLogin;
/* *tabbar所选中的index */
@property (nonatomic, assign) NSInteger selectedIndex;
/* *强制绑定身份信息model */
@property (nonatomic ,strong) SSWL_BindIdentituInfoModel *bindModel;
/* *正则表达式model */
@property (nonatomic ,strong) SSWL_RegexModel *regexModel;
/* *是否是自己出包 */
@property (nonatomic, assign) BOOL isMyOwn;
/* *userid */
@property (nonatomic, strong) NSString *userId;
/* *urlScheme */
@property (nonatomic, copy) NSString *urlScheme;
/* *连续点击处理 */
@property (nonatomic, assign) BOOL canClick;
SYSingletonH(SSWL_BasiceInfo)


-(void)setSDKInfoWithAppId:(NSString *)appId
           directionNumber:(int)directionNumber;


/*记录激活*/
- (void)saveActivateFlag:(BOOL)activated;

/*获取激活*/
- (BOOL)getCurrentActivateFlag;

/*保存客服的链接*/
- (void)saveCustomerService:(NSString *)customerService;

/*获取客服链接*/
- (NSString *)getCustomerService;

/*获取UUID*/
- (NSString *)getUUID;

/*获取设备信息*/
- (NSDictionary *)getDeviceInfo;


//@property (strong) NSString *deviceName;

@property (nonatomic, strong) NSString *ipAddress;     //ip地址

@property(nonatomic, strong)NSString *deviceInternet;


@property (nonatomic, strong) NSString *deviceScreenBounds;

@property (nonatomic, assign) BOOL getImageSuccess;

@property (nonatomic, assign) BOOL isShareSuccess;

@end
