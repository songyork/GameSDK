//
//  AYZFNavigationVontroller.m
//  AYSDK
//
//  Created by SDK on 2017/12/22.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_ZFNavigationVontroller.h"

@interface SSWL_ZFNavigationVontroller ()

@end

@implementation SSWL_ZFNavigationVontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = YES;
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
//        if ([[UIDevice currentDevice].systemVersion floatValue] < 11.0){
//            return UIInterfaceOrientationMaskAllButUpsideDown;
//        }
//        return UIInterfaceOrientationMaskPortrait;

        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
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
