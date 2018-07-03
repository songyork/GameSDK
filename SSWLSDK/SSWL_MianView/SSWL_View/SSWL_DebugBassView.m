//
//  SSWL_DebugBassView.m
//  SSWLSDK
//
//  Created by SDK on 2018/6/27.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_DebugBassView.h"

@interface SSWL_DebugBassView ()
{
    int _heighToBottom;
    int _height;
    float _currentY;
}
@property (nonatomic ,strong) SSWL_ServiceAgreementView *serviceAgreementView;

@property (nonatomic, assign) BOOL isShowPassword;//是否展示密码

@property (nonatomic, strong) UIImageView *userImgView;//账号图片

@property (nonatomic, strong) UIImageView *passImgView;//密码图片

@property (nonatomic ,strong) UIButton *eyesBtn;//是否显示密码BTN

@property (nonatomic, strong) UIView *userTextBottomLine; // 账号底部线

@property (nonatomic, strong) UIView *passTextBottomLine; // 密码底部线

@property (nonatomic, assign) float viewY;//注册视图的Y值

@property (nonatomic, assign) float viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值

@property (nonatomic, assign) NSTimeInterval animationDuration;

@end
#define BassBtnColor [UIColor colorWithRed:0.21 green:0.40 blue:0.73 alpha:1.00]


@implementation SSWL_DebugBassView

/*
 * 注销键盘的通知事件
 
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
    
}

/*
- (id)init{
    if (self = [super init]) {
        [self setUpView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self setUpView];
        
    }
    return self;
}
 */

- (void)setUpView {
    self.backgroundColor = SYWhiteColor;
    self.isAgree = YES;
    _currentY = .0f;
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.userTextFiled];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.passTextField];
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [self createUIForView];
}

- (void)createUIForView{
    
    [self addSubview:self.userTextFiled];
    
    [self addSubview:self.passTextField];
    
    [self addSubview:self.userImgView];
    
    [self addSubview:self.passImgView];
    
    [self addSubview:self.eyesBtn];
    
    [self addSubview:self.userTextBottomLine];
    
    [self addSubview:self.passTextBottomLine];
    

    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_SE"]) {
        
        [self.userImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(30);
            make.left.equalTo(self).offset(21);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        [self.userTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.userImgView);
            make.left.equalTo(self.userImgView.mas_right).offset(5);
            make.height.mas_equalTo(@30);
            make.right.equalTo(self).offset(-21);
        }];
        
    }else{
        
        [self.userImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(30);
            make.left.equalTo(self).offset(41);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        [self.userTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.userImgView);
            make.left.equalTo(self.userImgView.mas_right).offset(5);
            make.height.mas_equalTo(@30);
            make.right.equalTo(self).offset(-41);
        }];
    }
    
    [self.userTextBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userTextFiled.mas_bottom).offset(5);
        make.left.equalTo(self.userImgView.mas_left);
        make.right.equalTo(self.userTextFiled.mas_right);
        make.height.mas_equalTo(@1);
    }];
    
    [self.passImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userTextBottomLine.mas_bottom).offset(30);
        make.left.equalTo(self.userImgView.mas_left);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.passTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.passImgView);
        make.left.equalTo(self.passImgView.mas_right).offset(5);
        make.right.equalTo(self.userTextBottomLine.mas_right).offset(-25);
    }];
    
    [self.eyesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.passTextField.mas_right).offset(5);
        make.right.equalTo(self.userTextBottomLine.mas_right);
        make.size.mas_equalTo(CGSizeMake(20, 15));
        make.centerY.equalTo(self.passImgView);
    }];
    
    [self.passTextBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passImgView.mas_bottom).offset(5);
        make.left.equalTo(self.passImgView.mas_left);
        make.right.equalTo(self.eyesBtn.mas_right);
        make.height.mas_equalTo(@1);
    }];
    
    
}


- (void)debugViewIsLogion {
    
    [self addSubview:self.loginBtn];

    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passTextBottomLine.mas_bottom).offset(35);
        make.left.and.right.equalTo(self.userTextBottomLine);
        make.height.mas_equalTo(@30);
    }];
}

- (void)debugViewIsRegist {
    

    [self addSubview:self.registBtn];

    [self addSubview:self.serviceAgreementView];
    Weak_Self;
    self.serviceAgreementView.AgreeBlock = ^(BOOL isAgree) {
        weakSelf.isAgree = isAgree;
    };
    
    [self.serviceAgreementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passTextBottomLine.mas_bottom).offset(20);
        make.left.and.right.equalTo(self.userTextBottomLine);
        make.height.mas_equalTo(20);
    }];
    
    [self.registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.serviceAgreementView.mas_bottom).offset(10);
        make.left.and.right.equalTo(self.userTextBottomLine);
        make.height.mas_equalTo(@30);
    }];
}

/*
 * 展示或者隐藏密码
 */
- (void)showClick:(id)sender{
    
    self.isShowPassword = !self.isShowPassword;
    if (self.isShowPassword) {
        [self.eyesBtn setImage:get_BundleImage(@"key_on") forState:UIControlStateNormal];
        self.passTextField.secureTextEntry = NO;
        
        SYLog(@"----显示密码");
        
    }else{
        [self.eyesBtn setImage:get_BundleImage(@"key_off") forState:UIControlStateNormal];
        self.passTextField.secureTextEntry = YES;
        
        SYLog(@"----不显示密码");
    }
    
    
}



- (void)clearTextField {
    self.userTextFiled.text = @"";
    self.passTextField.text = @"";
    
    if ([self.userTextFiled canResignFirstResponder]) {
        SYLog(@"[self.userTextFiled resignFirstResponder] : %d", [self.userTextFiled resignFirstResponder]);
        [self.userTextFiled resignFirstResponder];
    }
    if ([self.passTextField canResignFirstResponder]) {
        SYLog(@" [self.passTextField resignFirstResponder] : %d", [self.passTextField resignFirstResponder]);
        [self.passTextField resignFirstResponder];
    }
//    if (self.userTextFiled.isFirstResponder || self.passTextField.isFirstResponder) {
//        [self.userTextFiled resignFirstResponder];
//        [self.passTextField resignFirstResponder];
//
//
//    }else{
//        SYLog(@"no response");
//    }
   
}

- (void)changeHUDModeTips:(NSString *)tips {
    
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.label.text = tips;
    [self.HUD hideAnimated:YES afterDelay:1.0f];
    
}

- (void)sendSuperViewMessage:(NSString *)message {

//    if ([self.delegate respondsToSelector:@selector(debugRegistView:showHUDMessage:)]) {
//        [self.delegate debugRegistView:self showHUDMessage:message];
//    }

}

#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.userTextFiled) {
        [self.passTextField becomeFirstResponder];
    }
    if (textField == self.passTextField) {
        if (textField.isFirstResponder) {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.textFieldY = textField.y;
}

# pragma mark --------------------------------------------------------------- 输入框输入的文字限制
/*输入框输入的文字限制*/

-(void)textFieldEditChanged:(NSNotification *)obj{
    
    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.userTextFiled) {
        [self limitTextLengthFor:textField length:15];
    }
    if (textField == self.passTextField) {
        [self limitTextLengthFor:textField length:15];
    }
    
    
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


#pragma mark --- 监听键盘
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    
    
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _height = keyboardRect.size.height;
    //    SYLog(@"打印键盘的高度：%d",height);
    
    // 获取键盘弹出动画时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [animationDurationValue getValue:&duration];
    self.animationDuration = duration;
    
    
    //记录注册视图的Y和H值
    self.viewY = self.y;
    self.viewH = self.height;
    //    SYLog(@"viewY:%d__________viewH:%d", self.viewY, self.viewH);
    
    /*
     
     int textH = self.textFieldY + self.bgView.y + self.userTextFiled.height;
     int heighToBottom = (int)self.view.height - textH;
     
     if (height > heighToBottom) {
     int differHeight = height - heighToBottom + 30;
     self.bgView.frame = CGRectMake(self.bgView.x, self.bgView.y - differHeight, self.bgView.width, self.bgView.height);
     }
     
     */
    
    float textH = self.textFieldY + self.y + 50 + self.userTextFiled.height;
    _heighToBottom = Screen_Height - textH;
    int differHeight = _height - _heighToBottom + 30;
   
        if (_currentY != differHeight) {
            if (_height > _heighToBottom) {
                
                if (self.KeyboardHideBlock) {
                    _currentY = differHeight;
                    self.KeyboardHideBlock(abs(differHeight), NO, self.animationDuration);
                }
        }
    }
    
    
    
}

#pragma mark ----------------------------------------------回收键盘
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    
    
    // 获取键盘弹出动画时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [animationDurationValue getValue:&duration];
    self.animationDuration = duration;
    
    //    self.frame = CGRectMake(self.x, self.viewY, self.width, self.height);

    if (self.KeyboardHideBlock) {
        self.KeyboardHideBlock(fabsf(self.viewY), YES, self.animationDuration);
    }
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.userTextFiled.isFirstResponder || self.passTextField.isFirstResponder) {
        [self.userTextFiled resignFirstResponder];
        [self.passTextField resignFirstResponder];
    }
}


- (SSWL_ServiceAgreementView *)serviceAgreementView{
    if (!_serviceAgreementView) {
        _serviceAgreementView = [[SSWL_ServiceAgreementView alloc] init];
    }
    return _serviceAgreementView;
}

- (UIButton *)loginBtn{
    
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_loginBtn setTitle:@"进入游戏" forState:UIControlStateNormal];
        [_loginBtn setTitle:@"进入游戏" forState:UIControlStateHighlighted];
        
        [_loginBtn setBackgroundColor:BassBtnColor];
        _loginBtn.layer.cornerRadius = 15;
        _loginBtn.layer.masksToBounds = YES;
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.tag = 1000;
        
    }
    return _loginBtn;
}

- (UIButton *)registBtn{
    
    if (!_registBtn) {
        _registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_registBtn setTitle:@"立即注册" forState:UIControlStateNormal];
        [_registBtn setTitle:@"立即注册" forState:UIControlStateHighlighted];
        
        [_registBtn setBackgroundColor:BassBtnColor];
        _registBtn.layer.cornerRadius = 15;
        _registBtn.layer.masksToBounds = YES;
        [_registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_registBtn addTarget:self action:@selector(registClick:) forControlEvents:UIControlEventTouchUpInside];
        _registBtn.tag = 1001;
        
    }
    return _registBtn;
}

- (UIButton *)eyesBtn{
    if (!_eyesBtn) {
        _eyesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eyesBtn setImage:get_BundleImage(@"key_off") forState:UIControlStateNormal];
        [_eyesBtn addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _eyesBtn;
}

- (UIImageView *)userImgView{
    if (!_userImgView) {
        _userImgView = [[UIImageView alloc] init];
        [_userImgView setImage:get_BundleImage(@"id_01")];
        
        _userImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _userImgView;
}

- (UIImageView *)passImgView{
    
    if (!_passImgView) {
        _passImgView = [[UIImageView alloc] init];
        [_passImgView setImage:get_BundleImage(@"key")];
        _passImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _passImgView;
}

- (UITextField *)userTextFiled{
    if (!_userTextFiled) {
        _userTextFiled = [[UITextField alloc] init];
        _userTextFiled = [SSWL_PublicTool createUserNameTextFieldWithPlaceholder:@"账号(6-15个字母或数字)" clearButtonMode:UITextFieldViewModeAlways customClearButton:nil font:14.f keyboardType:UIKeyboardTypeDefault];
        _userTextFiled.delegate = self;
        
    }
    return _userTextFiled;
}

- (UITextField *)passTextField{
    if (!_passTextField) {
        _passTextField = [[UITextField alloc] init];
        _passTextField = [SSWL_PublicTool createPasswordTextFieldWithPlaceholder:@"密码(6-15个字母或数字)" clearButtonMode:UITextFieldViewModeNever font:14.f keyboardType:UIKeyboardTypeASCIICapable];
        _passTextField.delegate = self;
        
        
    }
    return _passTextField;
}


- (UIView *)userTextBottomLine {
    if (!_userTextBottomLine) {
        _userTextBottomLine = [[UIView alloc] init];
        _userTextBottomLine.backgroundColor = [UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1.00];
    }
    return _userTextBottomLine;
}

- (UIView *)passTextBottomLine {
    if (!_passTextBottomLine) {
        _passTextBottomLine = [[UIView alloc] init];
        _passTextBottomLine.backgroundColor = [UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1.00];
    }
    return _passTextBottomLine;
}

@end
