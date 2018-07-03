//
//  CheckSongyorkFromLocal.m
//  SSWLSDK
//
//  Created by SDK on 2018/5/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "CheckSongyorkFromLocal.h"
@interface CheckSongyorkFromLocal ()

//注意＊＊这里不需要✳️号 可以理解为dispatch_time_t 已经包含了
@property (nonatomic, strong)dispatch_source_t time;

/* *计数器 */
@property (nonatomic, assign) int sswl_count;

@end
@implementation CheckSongyorkFromLocal




+ (void)checkSongyorkFromLocal{
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    
    CheckSongyorkFromLocal *checkSongyorkFromLocal = [[CheckSongyorkFromLocal alloc] init];
    [checkSongyorkFromLocal startScanningLocally];
}

- (void)startScanningLocally{
    Weak_Self;
    self.sswl_count = 0;
    //获得队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //创建一个定时器
    self.time = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC));
    //设置时间间隔
    uint64_t interval = (uint64_t)(90.0* NSEC_PER_SEC);
    //设置定时器
    dispatch_source_set_timer(self.time, start, interval, 0);
    //设置回调
    dispatch_source_set_event_handler(self.time, ^{
        
        //设置当执行五次是取消定时器
        weakSelf.sswl_count++;
        if(weakSelf.sswl_count == 5){
            dispatch_cancel(weakSelf.time);
        }
        
        NSDictionary *dict = [KeyChainWrapper load:SSWL_apple_dict_key];
        SYLog(@"保存字典的元素个数:%lu",(unsigned long)dict.count);
        if (dict.count > 0) {
            for (NSNumber *key in dict) {
                //            NSLog(@"字典中保存元素的key值:%@",date);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //开启网络请求
                    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkSongyorkToServerWithReceiptInfo:[dict objectForKey:key] completion:^(BOOL isSuccess, id  _Nullable respones) {
                        if (isSuccess) {
                            SYLog(@"上报成功，从本地删除保存的对应订单信息");
                            NSMutableDictionary *songyorkInfoDict = [KeyChainWrapper load:SSWL_apple_dict_key];
                            [songyorkInfoDict removeObjectForKey:[[dict objectForKey:key]  objectForKey:@"time"]];
                            [KeyChainWrapper save:SSWL_apple_dict_key data:songyorkInfoDict];
                        }
                    } failure:^(NSError * _Nullable error) {
                        
                    }];
                    
                });
            };
        }else{
            dispatch_cancel(weakSelf.time);
        }
        
    });
    //由于定时器默认是暂停的所以我们启动一下
    //启动定时器
    dispatch_resume(self.time);
}

@end
