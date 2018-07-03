//
//  AYBGView.h
//  AYSDK
//
//  Created by songyan on 2017/8/28.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+Extension.h"

@interface SSWL_BGView : UIView

@property (nonatomic ,strong) UIImageView *bgImg;

@property (nonatomic, strong) UIViewController *vc;


@property (nonatomic, copy) void(^CleanDeviceBlock)(BOOL isCleanSuccess);


/**
 初始化 BGView
 
 @param isShow 是否显示上士令牌图片
 @param isShowBG 是否显示背景图片
 @return bgview
 */
- (id)initWithShowImage:(BOOL)isShow
             showBGView:(BOOL)isShowBG;


/**
 初始化 BGView

 @param isShow 是否显示上士令牌图片
 @param isShowBG 是否显示背景图片
 @param isShowCleanView 是否开启清除设备号按钮
 @return bgview
 */
- (id)initWithShowImage:(BOOL)isShow
             showBGView:(BOOL)isShowBG
          showCleanView:(BOOL)isShowCleanView;



@end
