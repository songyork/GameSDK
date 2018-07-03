//
//  ZFForHtmlRspones.h
//  SSWLSDK
//
//  Created by SDK on 2018/5/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZFForHtmlRspones : NSObject



/**
 链接服务器

 @param songyorkInfo songyorkInfo
 @param completion completion block
 */
+ (void)linkServerWithSongyorkInfo:(SongyorkInfo *)songyorkInfo
                 completion:(void (^)(BOOL isSuccess))completion;

@end
