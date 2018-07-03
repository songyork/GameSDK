//
//  SSWL_UserManagerController.h
//  AYSDK
//
//  Created by songyan on 2017/8/28.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UMBlock)();


@interface SSWL_UserManagerController : UIViewController


@property (nonatomic, assign) BOOL isOnline;



 /**
  * 可能用的上
  */
@property (nonatomic ,copy) UMBlock block;

@end
