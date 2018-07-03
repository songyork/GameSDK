//
//  ErrorView.h
//  AYSDK
//
//  Created by SDK on 2017/10/16.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_ErrorView : UIView


/**
 init方法

 @param frame : frame
 @param text : 提示文字
 @return UIview : ErrorView
 */
- (id)initWithFrame:(CGRect)frame
           tipsText:(NSString *)text;

@end
