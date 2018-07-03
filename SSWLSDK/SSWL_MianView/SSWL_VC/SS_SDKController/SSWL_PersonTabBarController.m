//
//  AYPersonTabBarController.m
//  AYSDK
//
//  Created by SDK on 2017/10/10.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_PersonTabBarController.h"
#import "ComViewController.h"
#import "AccountController.h"
#import "GiftController.h"
#import "CustomServerController.h"


#import "SYCustomServerViewController.h"
//#import "TestWebViewController.h"



@interface SSWL_PersonTabBarController ()<UITabBarControllerDelegate>

@end

@implementation SSWL_PersonTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViewController];
    
    
    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
    self.delegate = self;
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    SYLog(@"--------%@", item.title);

    if ([item.title isEqualToString:@"社区"]) {
        SYLog(@"____0____");

    }else if ([item.title isEqualToString:@"礼包"]){
        SYLog(@"____1____");

    }else if ([item.title isEqualToString:@"客服反馈"]){
        SYLog(@"____2____");

    }else if ([item.title isEqualToString:@"账号"]){
        SYLog(@"____3____");

    }
    
    
}

- (void)addViewController{
    //    self.selectedIndex = self.index;
    Weak_Self;
    float tabBarH = self.tabBar.height;
    
    //    self.delegate = self;
    /*
     ?token=%@
     , [SSWL_BasiceInfo sharedSSWL_BasiceInfo].token
     */
    /*
     * 给前端签名
     */
    NSDictionary *param = @{
                            @"token"          : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                            };
    NSString *signStr = [SSWL_PublicTool makeSignStringWithParams:param];
    
    ComViewController *comVC = [[ComViewController alloc] init];
    comVC.tabBarHight = tabBarH;
    comVC.requestUrl = SSWL_COM_Test;
    comVC.WebBlock = ^{
        if (_TabBarBlock) {
            _TabBarBlock();
        }
        [weakSelf goBackGame];
    };
    
    
    /*
     * AY_GiftTest_Html : 分享测试链接
     * AY_Gift_Html     : 正式礼包页面
     */
    GiftController *giftVC = [[GiftController alloc] init];
    giftVC.tabBarHight = tabBarH;
    giftVC.requestUrl = [NSString stringWithFormat:@"%@?platform=ios&token=%@&sign=%@", SSWL_Gift_Html, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken, signStr];
    giftVC.WebBlock = ^{
        if (_TabBarBlock) {
            _TabBarBlock();
        }
        [weakSelf goBackGame];

    };
    
    
    
    CustomServerController *csVC = [[CustomServerController alloc] init];
    csVC.tabBarHight = tabBarH;
    
    csVC.requestUrl = [NSString stringWithFormat:@"%@?platform=ios&token=%@&sign=%@", SSWL_CustomServer_Html, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken, signStr];
    csVC.WebBlock = ^{
        if (_TabBarBlock) {
            _TabBarBlock();
        }
        [weakSelf goBackGame];

    };
    
    
    
    BOOL isAuto = [SSWL_PublicTool isAuToLoginToUserChoose];
    int on;
    int change;
    if (isAuto) {
        on = 1;
    }else{
        on = 0;
    }
    AccountController *accVC = [[AccountController alloc] init];
    self.changeBind = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].changeBind;
    accVC.tabBarHight = tabBarH;
    self.changeBind = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].changeBind;
    if (self.changeBind) {
        change = 1;
    }else{
        change = 0;
    }
    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].changeBind = NO;
    accVC.requestUrl = [NSString stringWithFormat:@"%@?platform=ios&token=%@&sign=%@&isAutoLogin=%d&toBoundPhonePage=%d", SSWL_Account_Html, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken, signStr, on, change];
    
    accVC.WebBlock = ^{
        if (_TabBarBlock) {
            _TabBarBlock();
        }
        
        [weakSelf goBackGame];

    };
    
    
    [accVC.tabBarItem setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"o1" withType:@"png"]];
    accVC.tabBarItem.title = @"账号";
    
    
    [csVC.tabBarItem setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"o4" withType:@"png"]];
    csVC.tabBarItem.title = @"客服反馈";
    
    
    [giftVC.tabBarItem setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"o3" withType:@"png"]];
    giftVC.tabBarItem.title = @"礼包";
    
    [comVC.tabBarItem setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"o2" withType:@"png"]];
    comVC.tabBarItem.title = @"社区";
    
    
    //添加控制器
    self.viewControllers = @[comVC, giftVC, csVC, accVC];
    self.selectedIndex = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].selectedIndex;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


}

- (void)goBackGame{
    [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏前调入");
         //         [self.view updateConstraints];
        
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏后调入");
         self.view.frame = [[UIScreen mainScreen] bounds];
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

-(BOOL)shouldAutorotate
{
    if([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1){
        return NO;
    }
    if([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0){
        return YES;
    }
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1)    //竖屏有游戏
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0)    //横屏游戏
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
    
//    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
