//
//  RegisterMobilUserViewController.h
//  AYSDK
//
//  Created by songyan on 2018/1/26.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_RegisterMobilUserViewController : UIViewController

@property (nonatomic, assign) BOOL isPush;

@property(nonatomic,copy) void(^MobilRegisterBlock)();



@end
