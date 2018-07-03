//
//  AYPersonTabBarController.h
//  AYSDK
//
//  Created by SDK on 2017/10/10.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_PersonTabBarController : UITabBarController

/**
 * 还是弃用吧
 */
@property (nonatomic ,copy) void(^TabBarBlock)();

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL changeBind;




@end
