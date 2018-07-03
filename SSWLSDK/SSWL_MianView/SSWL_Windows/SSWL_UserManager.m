//
//  UserManager.m
//  AYSDK
//
//  Created by songyan on 2017/8/26.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_UserManager.h"
#import "SSWL_UserManagerController.h"
#import "SSWL_UserManagerNavController.h"

@interface SSWL_UserManager()

@property (nonatomic, strong) SSWL_UserManagerNavController *userManagerNav;
@end

@implementation SSWL_UserManager

- (instancetype)init{
    
    self = [super init];
    if (self) {
       
//        self.layer.cornerRadius = 10;
//        self.layer.masksToBounds = YES;
        
          }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = 0.5;
        SSWL_UserManagerController *umVC = [[SSWL_UserManagerController alloc] init];
        umVC.block = ^{
            if (_UserBlock) {
                _UserBlock();
            }
        };
        self.userManagerNav = [[SSWL_UserManagerNavController alloc] initWithRootViewController:umVC];
        [SSWL_PublicTool stopSystemPopGestureRecognizerForNavigationController:self.userManagerNav];
//        userManagerNav.navigationBar.hidden = YES;
        
        self.rootViewController = self.userManagerNav;

    }
    return self;

}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
