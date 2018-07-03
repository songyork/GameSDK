//
//  SSWL_DebugButtonView.m
//  SSWLSDK
//
//  Created by SDK on 2018/6/23.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_DebugButtonView.h"

@interface SSWL_DebugButtonView ()

@property (nonatomic, strong) UILabel *loginLabel;

@property (nonatomic, strong) UILabel *registLabel;

@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, assign) BOOL selectedLogin;

@end

#define BorderColor [UIColor colorWithRed:0.21 green:0.40 blue:0.73 alpha:1.00]
#define NormalColor [UIColor colorWithRed:0.21 green:0.40 blue:0.73 alpha:1.00]
#define ShadowColor [UIColor colorWithRed:0.21 green:0.40 blue:0.73 alpha:1.00]
#define LabelWidth (self.width /2 -10)
#define LabelHeight (self.height -10)
#define ShadowWidth (self.width / 2 -6)
#define ShadowHeight (self.height -6)
@implementation SSWL_DebugButtonView

- (id)init {
    if (self = [super init]) {
        [self setUpView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self setUpView];
    }
    
    return self;
}

- (void)setUpView {
    self.layer.borderWidth = 1;
    self.layer.borderColor = BorderColor.CGColor;
    self.layer.cornerRadius = self.height / 2;
    self.layer.masksToBounds = YES;
    [self createUIForView];
    
}

- (void)createUIForView {
    
    [self addSubview:self.shadowView];

    
    [self addSubview:self.loginLabel];
    
    [self addSubview:self.registLabel];
    

}


- (void)transformStatusClick:(UITapGestureRecognizer *)sender {
    SYLog(@"点击了");
    
    if (sender.view.tag == 10000) {
        SYLog(@"登录");
        if (self.selectedLogin) {
            SYLog(@"无变化");
        }else{

            self.selectedLogin = YES;
            if (self.ButtonStatusBlock) {
                self.ButtonStatusBlock(YES);
            }
            [UIView animateWithDuration:.2f animations:^{
                //CATransform3DIdentity
                self.shadowView.transform = CGAffineTransformIdentity;
                self.loginLabel.textColor = SYWhiteColor;
                self.registLabel.textColor = NormalColor;
            }];
        }
    }else{
        SYLog(@"注册");

        if (!self.selectedLogin) {
            SYLog(@"无变化");
        }else{
            self.selectedLogin = NO;
            if (self.ButtonStatusBlock) {
                self.ButtonStatusBlock(NO);
            }
            [UIView animateWithDuration:.2f animations:^{
                self.shadowView.transform = CGAffineTransformTranslate(self.shadowView.transform, self.width / 2, 0);

                self.registLabel.textColor = SYWhiteColor;
                self.loginLabel.textColor = NormalColor;
            }];
            
        }
    }


    
    
   
    
}

- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ShadowWidth, ShadowHeight)];
        _shadowView.backgroundColor = ShadowColor;
        _shadowView.center = self.loginLabel.center;
        _shadowView.layer.cornerRadius = _shadowView.height / 2;
        _shadowView.layer.masksToBounds = YES;
        _shadowView.userInteractionEnabled = YES;
    }
    return _shadowView;
}

- (UILabel *)loginLabel {
    if (!_loginLabel) {
        _loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, LabelWidth, LabelHeight)];
        _loginLabel.backgroundColor = SYNOColor;
        _loginLabel.textAlignment = 1;
        _loginLabel.textColor = SYWhiteColor;
        _loginLabel.text = @"账号登录";
        _loginLabel.tag = 10000;
        self.selectedLogin = YES;
        _loginLabel.userInteractionEnabled = YES;
        [_loginLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transformStatusClick:)]];

    }
    return _loginLabel;
}

- (UILabel *)registLabel {
    if (!_registLabel) {
        _registLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width /2 + 5, 5, LabelWidth, LabelHeight)];
        _registLabel.backgroundColor = SYNOColor;
        _registLabel.textAlignment = 1;
        _registLabel.textColor = NormalColor;
        _registLabel.text = @"账号注册";
        _registLabel.tag = 10001;
        _registLabel.userInteractionEnabled = YES;
        [_registLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transformStatusClick:)]];
    }
    return _registLabel;
}

@end
