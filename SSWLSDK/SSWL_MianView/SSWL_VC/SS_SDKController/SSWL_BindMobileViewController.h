//
//  AYBindMobileViewController.h
//  AYSDK
//
//  Created by songyan on 2017/8/29.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_BindMobileViewController : UIViewController

/*隐藏HUD的block,返回上级页面隐藏*/
@property (nonatomic, copy) void(^HudHiddenBlock)(BOOL isShow);

/*没什么好注释的*/


@end
