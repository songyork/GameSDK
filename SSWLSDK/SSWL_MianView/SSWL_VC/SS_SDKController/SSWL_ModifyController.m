//
//  AYModifyController.m
//  AYSDK
//
//  Created by songyan on 2017/8/29.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_ModifyController.h"

@interface SSWL_ModifyController ()<UITextFieldDelegate>

@property (nonatomic ,strong) SSWL_BGView *bgView;

@property(nonatomic,strong)MBProgressHUD *HUD;

@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic, strong) UIImageView *oldPassImgView;//密码图片

@property (nonatomic, strong) UIImageView *passImgView;//密码图片

@property (nonatomic, strong) UIImageView *rePassImgView;//密码图片

@property (nonatomic, strong) UIButton *backBtn;//返回

@property (nonatomic ,strong) UIButton *sureBtn;//确定修改

@property (nonatomic ,strong) UIButton *oldEyesBtn;//是否显示密码BTN

@property (nonatomic ,strong) UIButton *eyesBtn;//是否显示密码BTN

@property (nonatomic ,strong) UIButton *reEyesBtn;//是否显示密码BTN


@property (nonatomic, strong) UIView *oldPassBorderView;//输入框边框

@property (nonatomic, strong) UIView *passBorderView;//输入框边框

@property (nonatomic, strong) UIView *rePassBorderView;//输入框边框

@property (nonatomic, strong) UITextField *oldPassTextField;//账号

@property (nonatomic, strong) UITextField *passTextField;//账号

@property (nonatomic, strong) UITextField *rePassTextField;//账号

@property (nonatomic, strong) UILabel *oldPassLineLab;//分割线

@property (nonatomic, strong) UILabel *passLineLab;//分割线

@property (nonatomic, strong) UILabel *rePassLineLab;//分割线

@property (nonatomic ,strong) UILabel *tipsLab;//提示

@property (nonatomic, assign) BOOL isShowOldPassword;//是否展示密码

@property (nonatomic, assign) BOOL isShowPassword;//是否展示密码

@property (nonatomic, assign) BOOL isShowRePassword;//是否展示密码


@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值



@end

@implementation SSWL_ModifyController


/*
 * 注销键盘的通知事件
 
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    self.view.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.oldPassImgView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.passTextField];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.rePassTextField];

    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    
    self.isShowPassword = NO;
    self.isShowOldPassword = NO;
    self.isShowRePassword = NO;
    
    
    [self.view addSubview:self.bgView];
    [self createUI];
}


- (void)createUI{
    
    [self.bgView addSubview:self.logoImgView];
    
    [self.bgView addSubview:self.oldPassImgView];
    
    [self.bgView addSubview:self.passImgView];
    
    [self.bgView addSubview:self.rePassImgView];
    
    [self.bgView addSubview:self.backBtn];
    
    [self.bgView addSubview:self.oldPassBorderView];
    
    [self.bgView addSubview:self.passBorderView];
    
    [self.bgView addSubview:self.rePassBorderView];
    
    [self.bgView addSubview:self.oldPassTextField];
    
    [self.bgView addSubview:self.passTextField];
    
    [self.bgView addSubview:self.rePassTextField];
    
    [self.bgView addSubview:self.oldPassLineLab];
    
    [self.bgView addSubview:self.passLineLab];
    
    [self.bgView addSubview:self.rePassLineLab];
    
    [self.bgView addSubview:self.tipsLab];
    
    [self.bgView addSubview:self.oldEyesBtn];
    
    [self.bgView addSubview:self.eyesBtn];
    
    [self.bgView addSubview:self.reEyesBtn];
    
    [self.bgView addSubview:self.sureBtn];
    
    [self layoutSubView];
}



- (void)layoutSubView{
    Weak_Self;
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bgView).offset(25);
        make.centerX.equalTo(weakSelf.bgView);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.centerY.equalTo(weakSelf.logoImgView).offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];

    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"]) {
        
        
        [self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(10);
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.height.mas_equalTo(20);
        }];
        
        
        
        
        
        
    }else{
        
        
        [self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(10);
            make.left.equalTo(weakSelf.bgView).offset(41);
            make.right.equalTo(weakSelf.bgView).offset(-41);
            make.height.mas_equalTo(20);
            
        }];
        
        
        
        
    }
    [self.oldPassBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.tipsLab.mas_bottom).offset(10);
        make.left.and.right.equalTo(weakSelf.tipsLab);
        make.height.mas_equalTo(35);
    }];
    
    [self.oldPassImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.oldPassBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.oldPassBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.oldPassLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.oldPassBorderView.mas_top).offset(8);
        make.bottom.equalTo(weakSelf.oldPassBorderView.mas_bottom).offset(-8);
        make.left.equalTo(weakSelf.oldPassImgView.mas_right).offset(10);
        make.width.mas_equalTo(1);
    }];
    
    [self.oldPassTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.oldPassLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.oldPassBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.oldPassBorderView.mas_right).offset(-30);
    }];
    
    [self.oldEyesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.oldPassTextField.mas_right).offset(5);
        make.right.equalTo(weakSelf.oldPassBorderView.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 15));
        make.centerY.equalTo(weakSelf.oldPassBorderView);
    }];
    
    [self.passBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.oldPassBorderView.mas_bottom).offset(14);
        make.left.and.right.equalTo(weakSelf.tipsLab);
        make.height.mas_equalTo(35);
    }];
    
    [self.passImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.passBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.passLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passBorderView.mas_top).offset(8);
        make.bottom.equalTo(weakSelf.passBorderView.mas_bottom).offset(-8);
        make.left.equalTo(weakSelf.passImgView.mas_right).offset(10);
        make.width.mas_equalTo(1);
    }];
    
    [self.passTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.passBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.passBorderView.mas_right).offset(-30);
    }];
    
    [self.eyesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passTextField.mas_right).offset(5);
        make.right.equalTo(weakSelf.passBorderView.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 15));
        make.centerY.equalTo(weakSelf.passBorderView);
    }];

    [self.rePassBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passBorderView.mas_bottom).offset(14);
        make.left.and.right.equalTo(weakSelf.tipsLab);
        make.height.mas_equalTo(35);
    }];
    
    [self.rePassImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.rePassBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.rePassBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.rePassLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.rePassBorderView.mas_top).offset(8);
        make.bottom.equalTo(weakSelf.rePassBorderView.mas_bottom).offset(-8);
        make.left.equalTo(weakSelf.rePassImgView.mas_right).offset(10);
        make.width.mas_equalTo(1);
    }];
    
    [self.rePassTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.rePassLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.rePassBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.rePassBorderView.mas_right).offset(-30);
    }];
    
    [self.reEyesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.rePassTextField.mas_right).offset(5);
        make.right.equalTo(weakSelf.rePassBorderView.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 15));
        make.centerY.equalTo(weakSelf.rePassBorderView);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.rePassBorderView.mas_bottom).offset(15);
        make.left.and.right.equalTo(weakSelf.rePassBorderView);
        make.height.mas_equalTo(30);
    }];
}


#pragma mark ----------------------------------------------Click

- (void)backClick
{
    SYLog(@"返回");
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)sureClick:(id)sender{
    Weak_Self;
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] modifyPasswordWithToken:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken oldPassword:self.oldPassTextField.text password:self.passTextField.text repasswrod:self.rePassTextField.text completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
            
            
            if (weakSelf.HudHiddenBlock) {
                weakSelf.HudHiddenBlock(YES);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];

            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
            
        }else{
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:respones[@"msg"]];

        }
    } failure:^(NSError *error) {
        
    }];
}


/*
 * 展示或者隐藏密码
 */
- (void)showClick:(UIButton *)sender{
    
    if (sender.tag == 101) {
        self.isShowOldPassword = !self.isShowOldPassword;
        if (self.isShowOldPassword) {
            [self.oldEyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_on" withType:@"png"] forState:UIControlStateNormal];
            self.oldPassTextField.secureTextEntry = NO;
            
            SYLog(@"----显示密码");
            
        }else{
            [self.oldEyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
            self.oldPassTextField.secureTextEntry = YES;
            
            SYLog(@"----不显示密码");
        }
    }else if (sender.tag == 100){
        self.isShowPassword = !self.isShowPassword;
       
        if (self.isShowPassword) {
            [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_on" withType:@"png"] forState:UIControlStateNormal];
            self.passTextField.secureTextEntry = NO;
            
            SYLog(@"----显示密码");
            
        }else{
            [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
            self.passTextField.secureTextEntry = YES;
            
            SYLog(@"----不显示密码");
        }

        
        
    }else if (sender.tag == 102){
        self.isShowRePassword = !self.isShowRePassword;
        if (self.isShowRePassword) {
            [self.reEyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_on" withType:@"png"] forState:UIControlStateNormal];
            self.rePassTextField.secureTextEntry = NO;
            SYLog(@"----显示密码");
        }else{
            [self.reEyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
            self.rePassTextField.secureTextEntry = YES;
            SYLog(@"----不显示密码");
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
    int height = keyboardRect.size.height;
    //    SYLog(@"打印键盘的高度：%d",height);
    
    //记录注册视图的Y和H值
    self.viewY = self.bgView.y;
    self.viewH = self.bgView.height;
    SYLog(@"viewY:%d__________viewH:%d", self.viewY, self.viewH);
    
    int textH = self.textFieldY + self.bgView.y + self.rePassTextField.height;
    int heighToBottom = (int)self.view.height - textH;
    
    if (height > heighToBottom) {
        int differHeight = height - heighToBottom + 30;
        self.bgView.frame = CGRectMake(self.bgView.x, self.bgView.y - differHeight, self.bgView.width, self.bgView.height);
    }
    
}

#pragma mark ----------------------------------------------回收键盘
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.bgView.frame = CGRectMake(self.bgView.x, self.viewY, self.bgView.width, self.bgView.height);
    self.bgView.center = self.view.center;
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
//    [self arrowClick:@"yes"];
    
}

#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.oldPassTextField || textField == self.passTextField || textField == self.rePassTextField) {
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
    [self limitTextLengthFor:textField length:15];
/*
    if (textField == self.oldPassTextField) {
        [self limitTextLengthFor:textField length:15];
    }
    if (textField == self.passTextField) {
        [self limitTextLengthFor:textField length:15];
    }
    if (textField == self.rePassTextField) {
        [self limitTextLengthFor:textField length:15];

    }
 */
    
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



- (UITextField *)creatTextField:(UITextField *)textField PlaceholderText:(NSString *)placeholderText SecureText:(BOOL)secureText{
    
    textField = [[UITextField alloc] init];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.placeholder =  placeholderText;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.font = [UIFont systemFontOfSize:14];
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.secureTextEntry = secureText;
    return textField;
}

- (UIView *)createView:(UIView *)view{
    view = [[UIView alloc] init];
    
    
    
    
    view.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
    view.layer.borderWidth = 1;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 15;
    return view;
}

- (UIButton *)createButton:(UIButton *)button{
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];

    
    return button;
}

- (UILabel *)createLabel:(UILabel *)label{
    label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
    return label;
}

- (UIImageView *)createImageView:(UIImageView *)imageView ImageName:(NSString *)imageName{
    imageView = [[UIImageView alloc] init];
    [imageView setImage:get_BundleImage(imageName)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

#pragma mark ---------------------------------------------- 懒加载
- (SSWL_BGView *)bgView{
    if (!_bgView) {
        _bgView = [[SSWL_BGView alloc] initWithShowImage:NO showBGView:NO];
        _bgView.height = 300;
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}


- (UIView *)oldPassBorderView{
    if (!_oldPassBorderView) {
        _oldPassBorderView = [self createView:_oldPassBorderView];
//        _oldPassBorderView.backgroundColor = [UIColor redColor];
    
    }
    return _oldPassBorderView;
}


- (UIView *)passBorderView{
    if (!_passBorderView) {
        _passBorderView = [self createView:_passBorderView];
    }
    return _passBorderView;
}

- (UIView *)rePassBorderView{
    if (!_rePassBorderView) {
        _rePassBorderView = [self createView:_rePassBorderView];
    }
    
    return _rePassBorderView;
}


- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an_z1" withType:@"png"] forState:UIControlStateNormal];
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an_z2" withType:@"png"] forState:UIControlStateHighlighted];
       [_sureBtn setBackgroundColor:button_Color];
        _sureBtn.layer.cornerRadius = 15;
        _sureBtn.layer.masksToBounds = YES;
        [_sureBtn setTitle:@"确认修改" forState:UIControlStateNormal];
        [_sureBtn setTitle:@"确认修改" forState:UIControlStateHighlighted];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_sureBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.tag = 1000;
    }
    return _sureBtn;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //         _backBtn.backgroundColor = [UIColor redColor];
//        [_backBtn setTitle:@" 返回" forState:UIControlStateNormal];
//        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"back" withType:@"png"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backBtn;
}

- (UIButton *)oldEyesBtn{
    if (!_oldEyesBtn) {
        self.isShowOldPassword = YES;
        _oldEyesBtn = [self createButton:_oldEyesBtn];
        _oldEyesBtn.tag = 101;
    }
    return _oldEyesBtn;
}

- (UIButton *)eyesBtn{
    if (!_eyesBtn) {
        _eyesBtn = [self createButton:_eyesBtn];
        _eyesBtn.tag = 100;
    }
    
    return _eyesBtn;
}

- (UIButton *)reEyesBtn{
    if (!_reEyesBtn) {
        _reEyesBtn = [self createButton:_reEyesBtn];
        _reEyesBtn.tag = 102;
    }
    return _reEyesBtn;
}

- (UITextField *)oldPassTextField{
    if (!_oldPassTextField) {
        _oldPassTextField = [self creatTextField:_oldPassTextField PlaceholderText:@"请输入当前密码" SecureText:YES];
    }
    return _oldPassTextField;
}

- (UITextField *)passTextField{
    if (!_passTextField) {
        _passTextField = [self creatTextField:_passTextField PlaceholderText:@"请输入新密码" SecureText:YES];
    }
    return _passTextField;
}

- (UITextField *)rePassTextField{
    if (!_rePassTextField) {
        _rePassTextField = [self creatTextField:_rePassTextField PlaceholderText:@"请再次输入新密码" SecureText:YES];
    }
    return _rePassTextField;
}


- (UILabel *)oldPassLineLab{
    if (!_oldPassLineLab) {
        _oldPassLineLab = [self createLabel:_oldPassLineLab];
    }
    return _oldPassLineLab;
}

- (UILabel *)passLineLab{
    if (!_passLineLab) {
        _passLineLab = [self createLabel:_passLineLab];
    }
    return _passLineLab;
}

- (UILabel *)rePassLineLab{
    if (!_rePassLineLab) {
        _rePassLineLab = [self createLabel:_rePassLineLab];
    }
    return _rePassLineLab;
}

- (UILabel *)tipsLab{
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] init];
        
        //
        NSString *text = [NSString stringWithFormat:@"您的账号为:%@", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].fastUserName];
        _tipsLab.textColor = [UIColor colorWithRed:0.18 green:0.55 blue:0.91 alpha:1.00];
        _tipsLab.font = [UIFont systemFontOfSize:16];
        _tipsLab.text = text;
        _tipsLab = [SSWL_PublicTool changeTextColor:[UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0] ChangeTitle:@"您的账号为:" Titile:_tipsLab.text ToLabel:_tipsLab];
        _tipsLab.textAlignment = 0;
        
    }
    return _tipsLab;
}


- (UIImageView *)oldPassImgView{
    if (!_oldPassImgView) {
        _oldPassImgView = [self createImageView:_oldPassImgView ImageName:@"key"];
    }
    return _oldPassImgView;
}

- (UIImageView *)passImgView{
    if (!_passImgView) {
        _passImgView = [self createImageView:_passImgView ImageName:@"tb_pwd"];
    }
    return _passImgView;
}

- (UIImageView *)rePassImgView{
    if (!_rePassImgView) {
        _rePassImgView = [self createImageView:_rePassImgView ImageName:@"tb_pwd"];
    }
    return _rePassImgView;
}

- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        [_logoImgView setImage:get_SSWL_Logo];
    }
    return _logoImgView;
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
