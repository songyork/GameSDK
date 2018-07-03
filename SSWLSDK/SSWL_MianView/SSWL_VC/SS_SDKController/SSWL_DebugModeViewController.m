//
//  SSWL_DebugModeViewController.m
//  SSWLSDK
//
//  Created by SDK on 2018/6/23.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_DebugModeViewController.h"
#import "SSWL_DebugButtonView.h"
#import "SSWL_DebugLoginView.h"
#import "sswl_DebugRegistView.h"
@interface SSWL_DebugModeViewController ()<UITextFieldDelegate, DebugLoginDelegate, DebugRegistDelegate>
{
    float _bgViewY;
}
@property (nonatomic, strong) SSWL_BGView *bgView;

@property (nonatomic, strong) SSWL_DebugButtonView *debugButtonView;

@property (nonatomic, strong) SSWL_DebugLoginView *debugLoginView;

@property (nonatomic, strong) SSWL_DebugRegistView *debugRegistView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation SSWL_DebugModeViewController

/*
 * 注销键盘的通知事件
 
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏前调入");
         CGPoint point = CGPointMake(Screen_Width / 2, Screen_Height / 2);
         self.bgView.center = point;
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏后调入");
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SYNOColor;

    
    [self createUIForView];
    
}

- (void)createUIForView {
    Weak_Self;
    [self.view addSubview:self.bgView];
    _bgViewY = self.bgView.y;

    [self.bgView addSubview:self.debugButtonView];
    self.debugButtonView.ButtonStatusBlock = ^(BOOL isLogin) {

        if (isLogin) {
            if (weakSelf.debugLoginView.x < 0) {
                [UIView animateWithDuration:.2f animations:^{

                    weakSelf.debugLoginView.x = 0;
                    weakSelf.debugRegistView.x = weakSelf.bgView.width;

                }];
            }
        }else{
            [UIView animateWithDuration:.2f animations:^{
                

                if (weakSelf.debugRegistView.x > weakSelf.bgView.width -1) {
                    weakSelf.debugRegistView.x = 0;
                    weakSelf.debugLoginView.x = -weakSelf.bgView.width;
                }
                
            }];
            
        }
        [weakSelf clearTextField];

    };
    [self.bgView addSubview:self.debugLoginView];
    
    self.debugLoginView.KeyboardHideBlock = ^(float originY, BOOL isHidden, NSTimeInterval animationDuration) {
    
        [weakSelf keyboradWillHidden:isHidden changeOriginY:originY duration:animationDuration];
    };
    self.debugLoginView.DebugBlock = self.DebugLoginBlock;
    
    
    
    [self.bgView addSubview:self.debugRegistView];
    self.debugRegistView.KeyboardHideBlock = ^(float originY, BOOL isHidden, NSTimeInterval animationDuration) {
        [weakSelf keyboradWillHidden:isHidden changeOriginY:originY duration:animationDuration];

    };
    self.debugRegistView.DebugBlock = self.DebugLoginBlock;
}


- (void)clearTextField {
    [self.debugRegistView clearTextField];
    [self.debugLoginView clearTextField];
}

- (void)debugLoginView:(UIView *)debugLoginView showHUDMessage:(NSString *)message {
    [SSWL_PublicTool showHUDWithViewController:self Text:message];
}

- (void)debugRegistView:(UIView *)debugRegistView showHUDMessage:(NSString *)message {
    [SSWL_PublicTool showHUDWithViewController:self Text:message];
}

- (void)keyboradWillHidden:(BOOL)hidden changeOriginY:(float)y duration:(NSTimeInterval)duration{
    
    self.bgView.y = _bgViewY;
    [UIView animateWithDuration:duration animations:^{
        self.bgView.frame = CGRectMake(self.bgView.x, self.bgView.y - y, self.bgView.width, self.bgView.height);
        //  - self.debugButtonView.height
        if (hidden) {
            self.bgView.center = self.view.center;
//            self.bgView.origin = CGPointMake(self.bgView.x, _bgViewY);
        }
    }];
    

}



- (SSWL_BGView *)bgView{
    if (!_bgView) {
        _bgView = [[SSWL_BGView alloc] initWithShowImage:NO showBGView:NO];
        _bgView.backgroundColor = SYWhiteColor;
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (SSWL_DebugButtonView *)debugButtonView {
    if (!_debugButtonView) {
        _debugButtonView = [[SSWL_DebugButtonView alloc] initWithFrame:CGRectMake(3, 10, self.bgView.width - 6, 40)];
    }
    return _debugButtonView;
}

- (SSWL_DebugLoginView *)debugLoginView{
    if (!_debugLoginView) {
        _debugLoginView = [[SSWL_DebugLoginView alloc] initWithFrame:CGRectMake(0, self.debugButtonView.y + self.debugButtonView.height, self.bgView.width, self.bgView.height - _debugLoginView.y)];
        _debugLoginView.delegate = self;
    }
    return _debugLoginView;
}

- (SSWL_DebugRegistView *)debugRegistView{
    if (!_debugRegistView) {
        _debugRegistView = [[SSWL_DebugRegistView alloc] initWithFrame:CGRectMake(self.view.width, self.debugButtonView.y + self.debugButtonView.height, self.bgView.width, self.bgView.height - _debugLoginView.y)];
        _debugRegistView.delegate = self;
    }
    return _debugRegistView;
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
