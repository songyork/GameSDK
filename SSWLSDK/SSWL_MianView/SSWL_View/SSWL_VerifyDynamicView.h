//
//  VerifyDynamicView.h
//  AYSDK
//
//  Created by SDK on 2017/11/14.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_VerifyDynamicView : UIView




@property (nonatomic ,strong) UITextField *verifyTextField;


@property (nonatomic, copy) void(^BtnBlock)(BOOL isSuccess, id dic);


- (void)addTapBlock:(void(^)(UIButton *btn))block;






@end
