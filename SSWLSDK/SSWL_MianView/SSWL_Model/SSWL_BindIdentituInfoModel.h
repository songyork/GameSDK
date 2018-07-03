//
//  SS_BindIdentituInfoModel.h
//  SSSDK
//
//  Created by SDK on 2018/3/10.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSWL_BindIdentituInfoModel : NSObject

/*
 idcard_check = {
 reg_user_idcard_check_need = 0;
 user_idcard_check_need = 0;
 user_idcard_check = 0;
 pay_user_idcard_check_need = 0;
 reg_user_idcard_check = 0;
 pay_user_idcard_check = 0;
 };
 */


/**
 注册后是否需要强制认证
 */
@property (nonatomic, assign) BOOL reg_User_Idcard_Check_Need;


/**
 登录后是否需要强制认证
 */
@property (nonatomic, assign) BOOL user_Idcard_Check_Need;


/**
 支付时是否需要强制认证
 */
@property (nonatomic, assign) BOOL sy_User_Idcard_Check_Need;


/**
 登录是否需要验证
 */
@property (nonatomic, assign) BOOL user_Idcard_Check;


/**
 注册是否需要验证
 */
@property (nonatomic, assign) BOOL reg_User_Idcard_Check;


/**
 支付是否需要验证
 */
@property (nonatomic, assign) BOOL sy_User_Idcard_Check;



+ (SSWL_BindIdentituInfoModel *)getBindIdentityInfoWithData:(id)data;



@end
