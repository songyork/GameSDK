//
//  ServiceAgreementView.h
//  AYSDK
//
//  Created by songyan on 2018/1/28.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSWL_ServiceAgreementView : UIView


/*
 阅读并同意 上士服务协议
 */

@property (nonatomic ,copy) void (^AgreeBlock)(BOOL isAgree);



- (id)init;




@end
