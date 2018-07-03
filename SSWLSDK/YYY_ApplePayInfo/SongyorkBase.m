//
//  SongyorkCenter.m
//  SSWL_SDK
//
//  Created by SDK on 2018/5/7.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SongyorkBase.h"
#import "CallBackToServer.h"
#import <StoreKit/StoreKit.h>

@interface SongyorkBase() <SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic, copy) NSString *appleProductID;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, assign) int requestTime;

@property(nonatomic,strong)SongyorkInfo *songyorkInfo;

@property (nonatomic, strong) UIViewController *currenViewController;

@end
@implementation SongyorkBase
SYSingletonM(SongyorkBase)

- (void)dealloc{
    // 移除监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark ------------------------------------ 初始化
-(void)registerBase{
    
    // 添加购买监听
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
}


/**
 隐藏HUD
 */
- (void)hideHud{
    if (self.HUD) {
        [self.HUD hideAnimated:YES];
        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].canClick = YES;
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus) {
            [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
        }
    }
}


- (void)dealWithSongyorkInfo:(SongyorkInfo *)songyorkInfo viewController:(UIViewController *)viewController completion:(void (^)(NSString *, id))completion{
    
    [self songyorkBegainCheckInfoWithViewController:viewController songyorkInfo:songyorkInfo completion:^(NSString *message, id params) {
        if (completion) {
            completion(message, params);
        }
    }];
}

/**
 验证songyork订单
 
 @param viewController VC
 @param songyorkInfo 订单信息
 @param completion callback
 */
- (void)songyorkBegainCheckInfoWithViewController:(UIViewController *)viewController songyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(NSString *message, id params))completion{

    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] requestSongyorkWithInfo:songyorkInfo completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
//            SYLog(@"----------respones:%@", respones);
            NSDictionary *data = respones[@"data"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].yyy = [NSString stringWithFormat:@"%@", data[@"order_sn"]];
            
            [self songyorkBegainActionWithViewController:viewController songyorkInfo:songyorkInfo completion:^(NSString *message, id params) {
                if (completion) {
                    completion(message, params);
                }
            }];
            
        }else{
//            SYLog(@"----------respones:%@", respones);
            
        }
    } failure:^(NSError *error) {
        
    }];
    
  
}

/**
 开始songyork Info动作
 
 @param viewController VC
 @param songyorkInfo 订单信息
 @param completion callback
 */
- (void)songyorkBegainActionWithViewController:(UIViewController *)viewController songyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void(^)(NSString *message, id params))completion{
    SYLog(@"开始songyork Info动作");
    
    [self actionBegainWithViewController:viewController songyorkInfo:songyorkInfo];
    self.songyorkCallback = ^(NSString *message, id params) {
        if (completion) {
            completion(message, params);
        }
    };
   
}

- (void)actionBegainWithViewController:(UIViewController *)viewController songyorkInfo:(SongyorkInfo *)songyorkInfo{
    // 旋转图标
    self.HUD = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    self.HUD.mode = MBProgressHUDModeIndeterminate;   //选择不同类型的mode；
    self.HUD.label.text = @"正在进行支付...";
    
    // 给属性赋值
    self.songyorkInfo = songyorkInfo;
    self.appleProductID = self.songyorkInfo.proId;
    if (self.appleProductID.length < 1) {
        SYLog(@"苹果商品id出错");
        [self hideHud];
        return;
    }
    
    // 检测是否允许内购
    if([SKPaymentQueue canMakePayments]){
        [self requestProductInfoWithKey:self.appleProductID];
    }else{
        SYLog(@"不允许程序内付费");
        [self hideHud];
    }
}

#pragma mark ------------------------------------------------------------ 请求商品
- (void)requestProductInfoWithKey:(NSString *)key{
    SYLog(@"请求商品");
    NSSet *nsset = [NSSet setWithObject:key];
    // 请求动作
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}


#pragma mark ----------------------------------------------- SKProducts Request Delegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SYLog(@"收到了请求反馈");
    NSArray *productArray = response.products;
    if(productArray.count == 0){
        SYLog(@"没有这个商品");
        [self hideHud];
        return;
    }
    
    SYLog(@"productID:%@", response.invalidProductIdentifiers);
    SYLog(@"产品付费数量:%ld",(long)productArray.count);
    
    
    SKProduct *product = nil;
    // 所有的商品, 遍历招到我们的商品
    for (SKProduct *pro in productArray) {
//        SYLog(@"%@", [pro description]);
//        SYLog(@"%@", [pro localizedTitle]);
//        SYLog(@"%@", [pro localizedDescription]);
//        SYLog(@"%@", [pro price]);
//        SYLog(@"%@", [pro productIdentifier]);
        if([pro.productIdentifier isEqualToString:self.appleProductID]) {
            product = pro;
        }
    }
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    SYLog(@"发送购买请求------------------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self hideHud];
    SYLog(@"请求内购列表失败：%@", [error localizedDescription]);
}

- (void)requestDidFinish:(SKRequest *)request {
    SYLog(@"%@", request);
    SYLog(@"请求结束");
}


#pragma mark ---------------------------------------------- SKPayment Transaction Observer
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for(SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                SYLog(@"交易完成");
                
                //通知后台苹果支付成功
                [self informBackgroundSuccessWithTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
            {
                SYLog(@"商品添加进列表");
//                [self hideHud];

            }
                break;
            case SKPaymentTransactionStateRestored:
            {
                SYLog(@"已经购买过商品");
                [self hideHud];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                SYLog(@"*****交易失败");
                SYLog(@"%@",[[transaction error] localizedDescription]);
                [self hideHud];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            default:
                break;
        }
    }
}





- (void)informBackgroundSuccessWithTransaction:(SKPaymentTransaction *)transaction{
    SYLog(@"苹果支付成功，处理通知后台发货的逻辑");
    SYLog(@"苹果订单号:%@",transaction.transactionIdentifier);
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    if (!receiptData) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [self hideHud];
        return;
    }
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    
    //通知后台所需参数
    NSDictionary *infoParam = @{
                                   @"order_sn"      :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].yyy,
                                   @"pay_method"    :   @"app",
                                   @"receiptdata"   :   receipt,
                                   @"time"          :   [SSWL_PublicTool getTimeStamps],
                                   };
    
    NSString *sign = [SSWL_PublicTool makeSignStringWithParams:infoParam];
    SYLog(@"---sign:%@", sign);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:infoParam];
    [params setObject:sign forKey:@"sign"];
    //将该订单凭证临时保存在本地
    NSMutableDictionary *infoDict = [KeyChainWrapper load:SSWL_apple_dict_key];
    
    if (infoDict) {
        [infoDict setObject:params forKey:[params objectForKey:@"time"]];
        [KeyChainWrapper save:SSWL_apple_dict_key data:infoDict];
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:params forKey:[params objectForKey:@"time"]];
        [KeyChainWrapper save:SSWL_apple_dict_key data:dict];
    }
    
    // 关闭旋转视图
    [self hideHud];

    // 该订单支付完成
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    // 开启网络请求通知后台发货
//    [self informBackgroundShipWithDict:params];
    
    [[CallBackToServer registerCallBackToServer] informBackgroundShipWithDict:params];
    
    self.requestTime = 0;
    
    // 去苹果服务器验证
    //    [self postTest:receipt];
    
    NSDictionary *syInfoDict = @{
                                 @"productId"      :   self.songyorkInfo.proId,
                                 @"productName"    :   self.songyorkInfo.productName,
                                 @"money"          :   self.songyorkInfo.money,
                                 @"moneyType"      :   self.songyorkInfo.moneyType,
                                 @"serverId"       :   self.songyorkInfo.serverId,
                                 @"uid"            :   self.songyorkInfo.uid,
                                 @"roleId"         :   self.songyorkInfo.roleId,
                                 @"roleName"       :   self.songyorkInfo.roleName,
                                 @"gameOrder"      :   self.songyorkInfo.YYY,
                                 @"appId"          :   self.songyorkInfo.appId,
                                 };
    
    if (self.songyorkCallback) {
        self.songyorkCallback(@"支付成功", syInfoDict);
    }
}





/*
#pragma mark ----------------------------------------------------- 支付成功，把凭证传给后台，通知发货
- (void)informBackgroundShipWithDict:(NSMutableDictionary *)dict{
 
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] callBackToServerWithReceiptInfo:dict completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
            SYLog(@"-------------respones:%@", respones);
            NSMutableDictionary *infoDict = [KeyChainWrapper load:SSWL_apple_dict_key];
            [infoDict removeObjectForKey:[dict objectForKey:@"time"]];
            [KeyChainWrapper save:SSWL_apple_dict_key data:infoDict];
        }else{
            [self relinkServerWithParams:dict];
        }
    } failure:^(NSError *error) {
        [self relinkServerWithParams:dict];
    }];
 
}

- (void)relinkServerWithParams:(NSMutableDictionary *)params{
    self.requestTime++;
    
 
    float time = 0;
    if (self.requestTime < 8) {
        if (self.requestTime == 1) {
            time = 10.0;
        }
        if (self.requestTime == 2) {
            time = 300.0;
        }
        if (self.requestTime == 3) {
            time = 900.0;
        }
        if (self.requestTime == 4) {
             time = 1800.0;
        }
        if (self.requestTime == 5) {
            time = 3600.0;
        }
        if (self.requestTime == 6) {
            time = 18000.0;
        }
        if (self.requestTime == 7) {
            time = 36000.0;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
            [self informBackgroundShipWithDict:params];
        });
    }
   
}
*/


@end
