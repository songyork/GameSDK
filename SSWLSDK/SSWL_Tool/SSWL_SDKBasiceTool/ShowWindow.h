//
//  ShowWidow.h
//  SSWLSDK
//
//  Created by SDK on 2018/5/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongyorkInfo.h"
@interface ShowWindow : NSObject



/**
 是否返回链接

 @param songyorkInfo songyorkInfo
 @return BOOL
 */
+ (BOOL)isShowWindowWithSongyorkInfo:(SongyorkInfo *)songyorkInfo;

@end
