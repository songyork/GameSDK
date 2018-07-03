//
//  SSWL_DebugRegistView.h
//  SSWLSDK
//
//  Created by SDK on 2018/6/27.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_DebugBassView.h"

@protocol DebugRegistDelegate <NSObject>

- (void)debugRegistView:(UIView *)debugRegistView showHUDMessage:(NSString *)message;

@end

@interface SSWL_DebugRegistView : SSWL_DebugBassView


- (id)init;

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<DebugRegistDelegate> delegate;


@end
