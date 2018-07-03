//
//  SS_ZFForHtml.m
//  SSSDK
//
//  Created by SDK on 2018/3/10.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "HX_SSWL_ZFForHtml.h"
#import "ShowWindow.h"
#import "ZFForHtmlRspones.h"
@interface HX_SSWL_ZFForHtml ()

@property (nonatomic ,strong) SSWL_AddIdentityInfo *addIdentityView;

@property (nonatomic ,strong) NSDictionary *info;

@property (nonatomic ,copy) NSString *message;


@property (nonatomic, strong) UIViewController *viewController;

@property (nonatomic, assign) BOOL isO;

@end

@implementation HX_SSWL_ZFForHtml

SYSingletonM(HX_SSWL_ZFForHtml)

/**
 检测zhifu环境, 并开始zhifu
 
 @param viewVontroller 调起支付功能的viewVontroller
 @param syInfo 支付所需参数
 @param completion 完成后回调
 */
- (void)starChectSongyorkWayWithViewContorller:(UIViewController *)viewController syInfo:(SongyorkInfo *)syInfo completion:(void (^)(NSString *, id))completion{
    Weak_Self;
    SongyorkInfo *songyorkInfo = [[SongyorkInfo alloc] init];
    songyorkInfo = syInfo;
   
    //检测SongyorkInfo信息是否有nil
    if ([songyorkInfo paramterIsNilShowToViewController:viewController]) {

        // 是否需要绑定身份证
#pragma mark ----------------------------------------------强制进入身份证页面
        //    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.sy_User_Idcard_Check = YES;
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.sy_User_Idcard_Check && ![SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard) {
            [self checkIdentityBeforeLoggingIsConstraint:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindModel.sy_User_Idcard_Check_Need completion:^(AddIdentityInfoViewClickStates addViewClickStates) {
                if (addViewClickStates == 0) {
                    [weakSelf verificationIsFinishedWithMessage:@"请验证身份信息后再进行支付"];
                }else{
                    if (addViewClickStates == 1) {
//                        [weakSelf verificationIsFinishedWithMessage:@"验证成功"];
                    }
                    [weakSelf verificationIsFinishedWithMessage:nil];
                    
                    [self dealWithViewController:viewController songyorkInfo:syInfo completion:^(NSString *message, id params) {
                        if (completion) {
                            completion(message, params);
                        }
                    }];
                }
            }];
            
        }else{
            [self dealWithViewController:viewController songyorkInfo:syInfo completion:^(NSString *message, id params) {
                if (completion) {
                    completion(message, params);
                }
            }];
        }
        
    }
    
}


// 开始Z动作
- (void)dealWithViewController:(UIViewController *)viewController songyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(NSString *message, id params))completion{
    
    
    
     Weak_Self;
    [ZFForHtmlRspones linkServerWithSongyorkInfo:songyorkInfo completion:^(BOOL isSuccess) {
        if (isSuccess) {
            [weakSelf startAppSYWithViewController:viewController songyorkInfo:songyorkInfo completion:^(NSString *message, id param) {
                if (completion) {
                    completion(message, param);
                }
            }];
        }else{
            [SSWL_PublicTool showHUDWithViewController:viewController Text:@"支付失败"];
        }
    }];
    
    
}


/*
 * 开始支付接口
 */
-(void)startAppSYWithViewController:(UIViewController *)viewController songyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(NSString *, id))completion{
    
    [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] destroyFloatWindow];
    
    
    
    
     if (![ShowWindow isShowWindowWithSongyorkInfo:songyorkInfo]) {
         if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].canClick) {
             [SSWL_BasiceInfo sharedSSWL_BasiceInfo].canClick = NO;
             [self justSongyorkForGameWithViewController:viewController songyorkInfo:songyorkInfo completion:^(NSString *message, id params) {
                 if (completion) {
                     completion(message, params);
                     
                 }
             }];
         }
     }
    
    
   
    
    
}

- (void)justSongyorkForGameWithViewController:(UIViewController *)viewController songyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(NSString *, id))completion{
    [[SongyorkBase sharedSongyorkBase] dealWithSongyorkInfo:songyorkInfo viewController:viewController completion:^(NSString *message, id params) {
        if (completion) {
            completion(message, params);
        }
    }];
}




/**
 创建验证身份证页面
 
 @param isConstraint 是否强制绑定
 @param completion 完成后回调
 */
- (void)checkIdentityBeforeLoggingIsConstraint:(BOOL)isConstraint completion:(void(^)(AddIdentityInfoViewClickStates addViewClickStates))completion{
    
    //    [self.hud hideAnimated:YES];
    self.addIdentityView = [[SSWL_AddIdentityInfo alloc] initIfNeedMandatoryBindIdInfo:isConstraint viewController:self.viewController];
    self.addIdentityView.addIdentityInfoViewBlock = ^(AddIdentityInfoViewClickStates addViewStates) {
        if (completion) {
            completion(addViewStates);
        }
    };
    self.addIdentityView.center = self.viewController.view.center;
    
    [self.viewController.view addSubview:self.addIdentityView];
    
}

- (void)verificationIsFinishedWithMessage:(NSString *)message{
    [UIView animateWithDuration:0.3 animations:^{
        self.addIdentityView.y = Screen_Height;
    } completion:^(BOOL finished) {
        self.addIdentityView.hidden = YES;
        self.addIdentityView = nil;
    }];
    if (message.length > 0 && message) {
        [SSWL_PublicTool showHUDWithViewController:self.viewController Text:message];
    }
    
}

/*
 - (void)openTheWebForData:(SongyorkInfo *)data{
 NSDictionary *dic = [[NSDictionary alloc] init];
 dic = @{
 @"user_id"        :   data.uid,
 @"money"          :   data.money,
 @"money_type"     :   data.moneyType,
 @"server"         :   data.serverId,
 @"cp_trade_sn"    :   data.gameOrder,
 @"goods_id"       :   data.proId,
 @"goods_name"     :   data.productName,
 @"goods_desc"     :   data.desc,
 @"game_role_id"   :   data.roleId,
 @"game_role_name" :   data.roleName,
 @"game_role_level":   data.roleLevel,
 @"pay_type"       :   @"apple",
 @"sub_pay_type"   :   @"apple",
 @"app_channel"    :   @"",
 @"device_id"      :   [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
 @"app_id"         :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].AYAppId,
 @"idfv"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
 @"sdk_version"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkVer,
 @"platform"       :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
 @"system_version" :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].systemVer,
 @"system_name"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel,
 @"time"           :   [SS_PublicTool getTimeStamps],
 };
 NSString *sign = [SS_PublicTool makeSignStringWithParams:dic];
 SYLog(@"---sign:%@", sign);
 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:dic];
 [params setObject:sign forKey:@"sign"];
 
 [self getDataToServer:params];
 
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
 NSString * encodingString = [SS_PublicTool encodeString:[NSString stringWithFormat:@"%@", dic[keys]]];
 
 NSString *str = [NSString stringWithFormat:@"%@=%@",keys, encodingString];
 [paramArr addObject:str];
 }
 
 
 for (NSString *str in paramArr) {
 NSString *paramStr = [NSString stringWithFormat:@"&%@", str];
 [urlArr addObject:paramStr];
 }
 
 //    zUrlString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",self.zUrl, urlArr[0], urlArr[1], urlArr[2], urlArr[3], urlArr[4], urlArr[5], urlArr[6], urlArr[7], urlArr[8], urlArr[9], urlArr[10], urlArr[11], urlArr[12], urlArr[13], urlArr[14], urlArr[15], urlArr[16], urlArr[17], urlArr[18]];
 NSString *zfUrlString = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].zhiUrl;
 for (int i = 0; i < urlArr.count; i++) {
 zfUrlString = [NSString stringWithFormat:@"%@%@", zfUrlString, urlArr[i]];
 }
 SYLog(@"%@", zfUrlString);
 
 
 
 
 
 NSURL *url = [NSURL URLWithString: zfUrlString];
 
 
 if ([[UIApplication sharedApplication] canOpenURL:url]) {
 [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
 if (success) {
 SYLog(@"-----yes------");
 if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus) {
 [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
 }
 }
 }];
 }
 
 }
 
 
 */

@end
