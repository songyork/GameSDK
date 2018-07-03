//
//  SS_HtmlInfoToUserModel.h
//  SSSDK
//
//  Created by SDK on 2018/3/10.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSWL_HtmlInfoToUserModel : NSObject


/* *用户ID */
@property (nonatomic, copy)NSString *user_id;
/* *服务器ID */
@property (nonatomic, copy)NSString *server;
/*请求时间戳，精确到秒即可*/
@property (nonatomic, copy)NSString *time;
/*充值金额*/
@property (nonatomic, copy)NSString *money;
/*游戏角色ID*/
@property (nonatomic, copy)NSString *game_role_id;
/*游戏角色名称，需进行urlencode*/
@property (nonatomic ,copy)NSString *game_role_name;
/*游戏订单号*/
@property (nonatomic ,copy)NSString *cp_trade_sn;
/*货币类型，默认为CNY*/
@property (nonatomic ,copy)NSString *money_type;
/*游戏内购商品ID*/
@property (nonatomic ,copy)NSString *goods_id;
/*游戏内购商品名称, 需进行urlencode*/
@property (nonatomic ,copy)NSString *goods_name;
/*游戏内购商品描述, 需进行urlencode*/
@property (nonatomic ,copy)NSString *goods_desc;
/*加密字符串，参照下面签名规则*/
@property (nonatomic ,copy)NSString *game_sign;
/*APPID*/
@property (nonatomic, copy)NSString *appId;
/*系统版本号*/
@property (nonatomic, copy)NSString *system_version;
/*设备号*/
@property (nonatomic, copy)NSString *device_id;
/*设备名*/
@property (nonatomic, copy)NSString *system_name;
/* *角色等级 */
@property (nonatomic, copy)NSString *game_role_level;
/* *用户登录时间 */
@property (nonatomic, strong) NSString *login_time;

- (NSDictionary *)paramterIsNotStringFromDictionary:(NSDictionary *)dictionary;

@end
