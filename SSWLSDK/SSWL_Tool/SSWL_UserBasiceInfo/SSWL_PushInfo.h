//
//  SSWL_PushInfo.h
//  SSWLSDK
//
//  Created by SDK on 2018/6/15.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AYSYSingleton.h"

@interface SSWL_PushInfo : NSObject
/* *ALCDeviceId */
@property (nonatomic, copy) NSString *alcDeviceId;

/* *内容 : alert */
@property (nonatomic, copy) NSString *content;

/* *badge数量 */
@property (nonatomic, assign) int badge;

/* *播放声音 */
@property (nonatomic, copy) NSString *sound;

/* *取得通知自定义字段内容，例：获取key为"Extras"的内容 */
@property (nonatomic, copy) NSString *extras;

/* *标题 */
@property (nonatomic, copy) NSString *title;

/* *副标题 */
@property (nonatomic, copy) NSString *subtitle;

/* *内容 */
@property (nonatomic, copy) NSString *body;

/* *通知时间 */
@property (nonatomic, strong) NSDate *noticeDate;

/* *url */
@property (nonatomic, copy) NSString *pushKeyUrl;

/* *是否是登录状态 */
@property (nonatomic, assign) BOOL isLoginStatus;

/*
 * 以下为预留 key
 */

/* *<#note#> */
//@property (nonatomic, copy) NSString *<#Name#>;

/* *<#note#> */
//@property (nonatomic, copy) NSString *<#Name#>;




SYSingletonH(SSWL_PushInfo)


@end
