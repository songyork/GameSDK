//
//  LZJViewController.m
//  SSWLSDK
//
//  Created by SDK on 2018/6/1.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "LZJViewController.h"

@interface LZJViewController ()

@end

@implementation LZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = SYNOColor;
    
    UIImageView *lzjImage = [[UIImageView alloc] init];
    [lzjImage setImage:get_BundleImage(@"LZJ")];
    CGSize imageSize = get_BundleImage(@"LZJ").size;
    lzjImage.size = imageSize;
    lzjImage.userInteractionEnabled = YES;
    [self.view addSubview:lzjImage];
    [lzjImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
    }];
    
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressClick:)];
    //用几个手指触屏，默认1
    longPressGesture.numberOfTouchesRequired = 1;
    //设置最短长按时间，单位为秒（默认0.5）
    longPressGesture.minimumPressDuration = .5f;
    //设置手势识别期间所允许的手势可移动范围
    longPressGesture.allowableMovement = 10;
    [lzjImage addGestureRecognizer:longPressGesture];
}

- (void)longPressClick:(UILongPressGestureRecognizer *)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.LZJBlock) {
            self.LZJBlock();
        }
    }];
    
    
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
