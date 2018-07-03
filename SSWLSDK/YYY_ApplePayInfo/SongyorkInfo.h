//
//  SongyorkInfo.h
//  SDK
//
//  Created by songyan on 2017/8/15.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongyorkInfo : NSObject



@property (nonatomic ,copy) NSString *proId;//商品ID

@property (nonatomic ,copy) NSString *productName;//商品名称

@property (nonatomic ,copy) NSString *money;//充值金额

@property (nonatomic ,copy) NSString *serverId;//服务器ID

@property (nonatomic ,copy) NSString *moneyType;//货币类型  CNY

@property (nonatomic ,copy) NSString *uid;//用户ID

@property (nonatomic ,copy) NSString *roleId;//游戏角色id

@property (nonatomic ,copy) NSString *roleName;//游戏角色名

@property (nonatomic ,copy) NSString *YYY;//cp订单号

@property (nonatomic ,copy) NSString *appId;//APPID

@property (nonatomic ,copy) NSString *roleLevel;

@property (nonatomic ,copy) NSString *desc;




/**
 检测参数是否是NSString类型和是否为NIL

 @param viewController viewController
 @return BOOL
 */
- (BOOL)paramterIsNilShowToViewController:(UIViewController *)viewController;
@end
