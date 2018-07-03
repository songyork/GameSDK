//
//  FirstOpenViewController.h
//  AYSDK
//
//  Created by SDK on 2017/7/25.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FirstOpenViewBlock)();


@interface SSWL_FirstOpenViewController : UIViewController

/**
 * 写着写着突然就弃用了.(需求改变)
 * (屌不屌)
 */


@property(nonatomic,copy)FirstOpenViewBlock block;

@property (nonatomic, assign) int direction;

@property (nonatomic, assign) BOOL isPush;

@end
