//
//  SSWL_DebugButtonView.h
//  SSWLSDK
//
//  Created by SDK on 2018/6/23.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_DebugButtonView : UIView


@property (nonatomic, copy) void(^ButtonStatusBlock)(BOOL isLogin);

- (id)init;

- (id)initWithFrame:(CGRect)frame;



@end
