//
//  AYPersonCenterWindow.m
//  AYSDK
//
//  Created by 松炎 on 2017/8/2.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_PersonCenterWindow.h"
#import "SSWL_PersonTabBarController.h"
#import "ComViewController.h"
#import "AccountController.h"
#import "GiftController.h"
#import "CustomServerController.h"

@interface SSWL_PersonCenterWindow ()<UITabBarDelegate>

@property (nonatomic, strong) SSWL_PersonTabBarController *tabBarC;




@end


@implementation SSWL_PersonCenterWindow


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;

}


- (id)initWithFrame:(CGRect)frame rootViewControllerIndex:(NSInteger)index isChangeBindPhone:(BOOL)isChange{

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = 0.5;
        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].selectedIndex = index;

        self.tabBarC = [[SSWL_PersonTabBarController alloc] init];
      
        Weak_Self;
        self.tabBarC.TabBarBlock = ^{
            if (weakSelf.TabBarBlock) {
                weakSelf.TabBarBlock();
            }
        };
        self.tabBarC.changeBind = isChange;
//        self.tabBarC.index = index;
        self.rootViewController = self.tabBarC;
    
       
    }
    
    return self;
}
/*
-(BOOL)shouldAutorotate
{
    //    if([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1){
    //        return NO;
    //    }
    //    if([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0){
    //        return YES;
    //    }
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1)    //竖屏有游戏
    //    {
    //        return UIInterfaceOrientationMaskPortrait;
    //    }
    //    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0)    //横屏游戏
    //    {
    //        return UIInterfaceOrientationMaskLandscape;
    //    }
    //    return UIInterfaceOrientationMaskAllButUpsideDown;
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
*/


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
