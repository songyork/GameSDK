//
//  SYSaveTouristInfo.h
//  AYSDK
//
//  Created by SDK on 2018/1/22.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYSaveTouristInfo : UIView

typedef NS_ENUM(NSInteger, ScreenshotState){
    SaveSuccess          = 0, //保存成功
    SaveFailure          = 1, //保存失败
    SaveCancel           = 2, //保存取消
    LoadResourceError    = 4, //加载数据错误
};

@property (nonatomic, copy) void(^buttonBlock)(ScreenshotState screenshotState);



- (id)initWithFrame:(CGRect)frame
     viewController:(UIViewController *)viewController;

- (id)initWithViewController:(UIViewController *)viewController;

@end
