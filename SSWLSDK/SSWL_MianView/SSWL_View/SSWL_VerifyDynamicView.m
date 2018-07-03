//
//  VerifyDynamicView.m
//  AYSDK
//
//  Created by SDK on 2017/11/14.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_VerifyDynamicView.h"

@interface SSWL_VerifyDynamicView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *bgImage;

@property (nonatomic, strong) UIImageView *logoImage;

@property (nonatomic, strong) UILabel *verifyTitle;

@property (nonatomic, strong) UIView *verifyBorderView;//身份证边框

@property (nonatomic, strong) UIButton *verifyBtn;

@property (nonatomic, strong) UIButton *cancelBtn;
@end

@implementation SSWL_VerifyDynamicView


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];

}

- (instancetype)init
{
    self = [super init];
    if (self) {
       
        [self setUpVerifyDynamicView];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       // self = [[UIView alloc] initWithFrame:frame];
               [self setUpVerifyDynamicView];
    }
    return self;
}



- (void)setUpVerifyDynamicView{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.verifyTextField];

    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo] directionNumber] == 0) {
        if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"]){
            self.frame = CGRectMake(0, 0, 300, 280);
            
        }else{
            self.frame = CGRectMake(0, 0, 325, 280);
            
        }
    }else{
        if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"]){
            self.frame = CGRectMake(0, 0, 300, 280);
            
        }else{
            self.frame = CGRectMake(0, 0, 325, 280);
            
        }
        
    }
    
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];

//    [self addSubview:self.bgImage];

    [self addSubview:self.logoImage];
    [self addSubview:self.verifyTitle];
    [self addSubview:self.verifyBtn];
    [self addSubview:self.cancelBtn];
    [self addSubview:self.verifyBorderView];
    [self addSubview:self.verifyTextField];

    [self layoutSubviews];
}





- (void)layoutSubviews{
    Weak_Self;
    
    [self.logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(30);  
        make.centerX.equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    [self.verifyTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.logoImage.mas_bottom).offset(30);
        make.left.equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width, 20));
    }];
    
    [self.verifyBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.verifyTitle.mas_bottom).offset(30);
        make.left.equalTo(weakSelf).offset(20);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - 40, 40));
    }];
    
    [self.verifyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.center.equalTo(weakSelf.BGView);
        make.center.equalTo(weakSelf.verifyBorderView);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - 60, 30));
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.verifyBorderView.mas_bottom).offset(30);
        make.left.equalTo(weakSelf.verifyBorderView.mas_left);
        make.size.mas_equalTo(CGSizeMake((weakSelf.width - 40) / 2 - 5, 40));
    }];
    [self.verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.verifyBorderView.mas_bottom).offset(30);
        make.right.equalTo(weakSelf.verifyBorderView.mas_right);
        make.size.mas_equalTo(CGSizeMake((weakSelf.width - 40) / 2 - 5, 40));
    }];
}


- (void)cancelClick{
    SYLog(@"------取消");
    [self.verifyTextField resignFirstResponder];
    if (self.BtnBlock) {
        self.BtnBlock(NO, @{@"msg"  :   @"销毁页面"});
    }
}


- (void)verifyClick{
    Weak_Self;
    SYLog(@"------验证");
    [self.verifyTextField resignFirstResponder];

    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] verifyDynamicPasswordWithKey:self.verifyTextField.text completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
            if (weakSelf.BtnBlock) {
                weakSelf.BtnBlock(isSuccess, respones);
            }
        }else{
            if (weakSelf.BtnBlock) {
                weakSelf.BtnBlock(isSuccess, respones);
            }
        }
    } failure:^(NSError *error) {
        
    }];

}


- (UIImageView *)logoImage{
    if (!_logoImage) {
        _logoImage = [[UIImageView alloc] init];
        [_logoImage setImage:get_SSWL_Logo];
    }
    return _logoImage;
}

- (UIImageView *)bgImage{
    if (!_bgImage) {
        _bgImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [_bgImage setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"k_bg" withType:@"png"]];
        
    }
    return _bgImage;
}


- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateHighlighted];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_cancelBtn setBackgroundColor:button_Color];
        _cancelBtn.layer.cornerRadius = 20;
        _cancelBtn.layer.masksToBounds = YES;
        [_cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];

    }
    return _cancelBtn;
}

- (UIButton *)verifyBtn{
    if (!_verifyBtn) {
        _verifyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_verifyBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_verifyBtn setTitle:@"确定" forState:UIControlStateHighlighted];
        [_verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_verifyBtn setBackgroundColor:button_Color];
        _verifyBtn.layer.cornerRadius = 20;
        _verifyBtn.layer.masksToBounds = YES;
        [_verifyBtn addTarget:self action:@selector(verifyClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _verifyBtn;
}

- (UILabel *)verifyTitle{
    if (!_verifyTitle) {
        _verifyTitle = [[UILabel alloc] init];
        _verifyTitle.numberOfLines = 0;
        _verifyTitle.text = @"请输入游戏安全令牌动态密码";
        _verifyTitle.textAlignment = 1;
        _verifyTitle.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1];
        _verifyTitle.font = [UIFont systemFontOfSize:18];
        
    }
    
    return _verifyTitle;
}


- (UITextField *)verifyTextField{
    if (!_verifyTextField) {
        _verifyTextField = [[UITextField alloc] init];//
        // self.verifyTextField.center = self.BGView.center;
        _verifyTextField.backgroundColor = [UIColor whiteColor];
        _verifyTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _verifyTextField.textAlignment = 1;
        _verifyTextField.placeholder =  @"请输入动态密码";
        _verifyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _verifyTextField.font = [UIFont systemFontOfSize:14];
        _verifyTextField.keyboardType = UIKeyboardTypeNumberPad;
        _verifyTextField.delegate = self;
        //        self.passTextField.secureTextEntry = YES;
        _verifyTextField.returnKeyType = UIReturnKeyDone;
        _verifyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        //[_verifyDynamicView addSubview:self.verifyTextField];
        
    }
    return _verifyTextField;
}


- (UIView *)verifyBorderView{
    
    if (!_verifyBorderView) {
        _verifyBorderView = [[UIView alloc] init];
        _verifyBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _verifyBorderView.backgroundColor = [UIColor whiteColor];
        
        _verifyBorderView.layer.borderWidth = 1.0f;
        _verifyBorderView.layer.masksToBounds = YES;
        _verifyBorderView.layer.cornerRadius = 20;
        
    }
    
    return _verifyBorderView;
}

- (void)addTapBlock:(void (^)(UIButton *))block{
    
    
    
}

- (void)verifyClick:(UIButton *)sender{
    
   
    
}
#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    
    return YES;
}


# pragma mark --------------------------------------------------------------- 输入框输入的文字限制
/*输入框输入的文字限制*/

-(void)textFieldEditChanged:(NSNotification *)obj{
    
    UITextField *textField = (UITextField *)obj.object;
   [self limitTextLengthFor:textField length:6];
    
    
}


- (void)limitTextLengthFor:(UITextField *)textField length:(NSInteger)maxLength{
    NSString *toBeString = textField.text;
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > maxLength)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:maxLength];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:maxLength];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
}


@end
