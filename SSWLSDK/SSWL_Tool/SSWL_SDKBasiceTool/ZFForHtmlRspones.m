//
//  ZFForHtmlRspones.m
//  SSWLSDK
//
//  Created by SDK on 2018/5/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "ZFForHtmlRspones.h"

@implementation ZFForHtmlRspones


+ (void)linkServerWithSongyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(BOOL))completion{
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];

    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkSongyorkWithSongyorkInfo:songyorkInfo completion:^(BOOL isSuccess, id  _Nullable respones) {
        
        if (isSuccess) {
            NSDictionary *dic = respones[@"data"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString = dic[@"o"];
//            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString = @"https://sypay.shangshiwl.com/?ac=web";
            if (completion) {
                completion(isSuccess);
            }
            
        }else{
            if (completion) {
                completion(isSuccess);
            }
        }
    } failure:^(NSError * _Nullable error) {
        if (completion) {
            completion(NO);
        }
    }];
    
}
@end
