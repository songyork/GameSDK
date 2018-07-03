//
//  AddIdentityInfo.h
//  AYSDK
//
//  Created by songyan on 2018/1/30.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AddIdentityInfoViewClickStates) {
    ViewIsClickClose         = 0, // 点击了关闭
    ViewIsClickSubmit        = 1, // 点击了提交
    ViewIsClickCancel        = 2, // 点击了取消
};

@interface SSWL_AddIdentityInfo : UIView


@property (nonatomic, assign) AddIdentityInfoViewClickStates addIdentityInfoViewStates;


@property (nonatomic ,copy) void (^addIdentityInfoViewBlock)(AddIdentityInfoViewClickStates addViewStates);


- (id)initIfNeedMandatoryBindIdInfo:(BOOL)isNeedMandatory
                     viewController:(UIViewController *)viewController;


- (void)getAddIdentityInfoViewClickStates:(AddIdentityInfoViewClickStates)addViewStates;


@end
