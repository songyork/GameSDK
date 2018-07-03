//
//  SSWL_DebugLoginView.h
//  SSWLSDK
//
//  Created by SDK on 2018/6/27.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_DebugBassView.h"

@protocol DebugLoginDelegate <NSObject>

- (void)debugLoginView:(UIView *)debugLoginView showHUDMessage:(NSString *)message;



@end

@interface SSWL_DebugLoginView : SSWL_DebugBassView

- (id)init;

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<DebugLoginDelegate> delegate;


@end
