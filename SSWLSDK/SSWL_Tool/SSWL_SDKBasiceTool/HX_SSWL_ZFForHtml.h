//
//  SS_ZFForHtml.h
//  SSSDK
//
//  Created by SDK on 2018/3/10.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HX_SSWL_ZFForHtml : NSObject




+ (HX_SSWL_ZFForHtml *)sharedHX_SSWL_ZFForHtml;

/**
 检测zhifu环境, 并开始zhifu
 startCheckTheSYWayWithViewController
 @param viewController 调起Z功能的viewVontroller
 @param syInfo 支付所需参数
 @param completion 完成后回调
 */
- (void)starChectSongyorkWayWithViewContorller:(UIViewController *)viewController
                                      syInfo:(SongyorkInfo *)syInfo
                                  completion:(void (^)(NSString *message, id param))completion;


/**
 Songyork Info

 @param viewController viewController
 @param songyorkInfo songyorkInfo
 @param completion completion
 */
//- (void)justSongyorkForGameWithViewController:(UIViewController *)viewController songyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(NSString *message, id param))completion;

@end
