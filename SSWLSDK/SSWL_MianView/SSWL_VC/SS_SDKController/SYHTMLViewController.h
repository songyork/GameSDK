//
//  SYHTMLViewController.h
//  AYSDK
//
//  Created by SDK on 2017/12/28.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongyorkInfo.h"

typedef void(^CloseBlock)();


@interface SYHTMLViewController : UIViewController

@property (nonatomic ,strong) SongyorkInfo *songyorkInfo;

@property (nonatomic ,copy) NSString *urlString;

@property (nonatomic ,copy) CloseBlock closeBlock;

@end
