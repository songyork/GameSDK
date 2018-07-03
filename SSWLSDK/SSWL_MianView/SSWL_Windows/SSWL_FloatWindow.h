//
//  SSWL_FloatWindow.h
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TagBlock)(NSInteger tag);

@interface SSWL_FloatWindow : UIWindow

@property (nonatomic ,copy) TagBlock backBlock;

- (id)init;

- (id)initWithFrame:(CGRect)frame
      mainImageName:(NSString *)imgName
           titleArr:(NSArray *)titleArr
        startBtnTag:(int)btnTag
     animationColor:(UIColor *)color;

- (void)stopTiming;

- (void)logSomething;

@end
