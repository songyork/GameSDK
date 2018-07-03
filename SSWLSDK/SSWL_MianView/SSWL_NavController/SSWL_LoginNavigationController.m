//
//  LoginNavigationController.m
//  LZWSDKTemplate
//
//  Created by songyork on 2017/6/5.
//  Copyright © 2017年 songyork. All rights reserved.
//

#import "SSWL_LoginNavigationController.h"

@interface SSWL_LoginNavigationController ()

@end

@implementation SSWL_LoginNavigationController

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
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;;
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
