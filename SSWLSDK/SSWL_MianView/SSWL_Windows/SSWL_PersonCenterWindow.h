
//
//  AYPersonCenterWindow.h
//  AYSDK
//
//  Created by 松炎 on 2017/8/2.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_PersonCenterWindow : UIWindow

@property (nonatomic ,copy) void(^TabBarBlock)();

/*
 * 初始化Window
 * @param frame : 坐标
 * @param index : 进入哪个页面 (TabBar的下标,进入礼包或者客服页面)
 * @param isChange : 控制进入绑定手机或改绑手机页面
 * @return UIwindow : AYPersonCenterWindow
 */
- (id)initWithFrame:(CGRect)frame
rootViewControllerIndex:(NSInteger)index
  isChangeBindPhone:(BOOL)isChange;

@end
