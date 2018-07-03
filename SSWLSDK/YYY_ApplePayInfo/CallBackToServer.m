//
//  CallBackToServer.m
//  SSWLSDK
//
//  Created by SDK on 2018/5/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "CallBackToServer.h"
@interface CallBackToServer ()
@property (nonatomic, assign) int requestTime;

@end
static CallBackToServer *_callBackToServer;

@implementation CallBackToServer

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    // 一次函数
    dispatch_once(&onceToken, ^{
        if (_callBackToServer == nil) {
            _callBackToServer = [super allocWithZone:zone];
        }
    });
    
    return _callBackToServer;
}


+ (CallBackToServer *)registerCallBackToServer{
    
    return  [[self alloc] init];
}



#pragma mark ----------------------------------------------------- 支付成功，把凭证传给后台，通知发货
- (void)informBackgroundShipWithDict:(NSMutableDictionary *)dict{
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    /**
     * 请求接口
     * 向后台发送支付完成请求
     */
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] callBackToSongyorkServerWithReceiptInfo:dict completion:^(BOOL isSuccess, id respones) {
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
    
    /**
     * 如果接口请求失败
     * 延时再次发送
     * 预计是发8次 一共
     */
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



@end
