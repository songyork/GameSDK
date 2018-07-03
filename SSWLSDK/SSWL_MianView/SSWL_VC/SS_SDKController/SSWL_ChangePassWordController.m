//
//  ChangePassWordController.m
//  AYSDK
//
//  Created by 松炎 on 2017/7/29.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_ChangePassWordController.h"

@interface SSWL_ChangePassWordController ()<UITextFieldDelegate>

@property (nonatomic ,strong) SSWL_BGView  *bgView;//背景

@property(nonatomic,strong)MBProgressHUD *hudOne;

@property (nonatomic ,strong) UIImageView *logoImgView;//logo

@property (nonatomic ,strong) UILabel *tipsLab;//提示

@property (nonatomic ,strong) UITextField *passwordTextField;//密码输入框

@property (nonatomic, strong) UIImageView *passwordImgView;//账号图片

@property (nonatomic, strong) UIButton *sureBtn;//确定

@property (nonatomic, strong) UIButton *backBtn;//返回

@property (nonatomic ,strong) UIButton *eyesBtn;//是否显示密码BTN

@property (nonatomic, strong) UIView *passwordBorderView;//输入框边框

@property (nonatomic, strong) UILabel *passwordLineLab;//分割线

@property (nonatomic, assign) BOOL isShowPassword;//是否显示密码

@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值


@end

@implementation SSWL_ChangePassWordController
/*
 * 注销键盘的通知事件
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.passwordTextField];
    
    [self.view addSubview:self.bgView];
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo] directionNumber] == 0) {
        self.bgView.frame = CGRectMake(0, 0, Screen_Width / 2,300);
        self.bgView.center = self.view.center;
    }else{
        self.bgView.frame = CGRectMake(20, 0, Screen_Width - 40, 300);
        self.bgView.centerY = self.view.centerY;
        
    }
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    
    [self createUI];

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
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)createUI{
    
    [self.bgView addSubview:self.logoImgView];
    
    [self.bgView addSubview:self.backBtn];
    
    [self.bgView addSubview:self.passwordBorderView];
    
    [self.bgView addSubview:self.passwordImgView];
    
    [self.bgView addSubview:self.passwordLineLab];
    
    [self.bgView addSubview:self.passwordTextField];
    
    [self.bgView addSubview:self.eyesBtn];
    
    [self.bgView addSubview:self.sureBtn];
    
    [self.bgView addSubview:self.tipsLab];
    
    [self layoutSubview];

}


- (void)layoutSubview{
    Weak_Self;
    //约束
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bgView).offset(25);
//        make.left.equalTo(weakSelf.bgView).offset(50);
//        make.right.equalTo(weakSelf.bgView).offset(-50);
        make.size.mas_equalTo(CGSizeMake(150, 30));

        make.centerX.equalTo(weakSelf.bgView);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.bgView).offset(10);
        make.centerY.equalTo(weakSelf.logoImgView).offset(0);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    CGSize tipsSize = [self.tipsLab.text boundingRectWithSize:CGSizeMake(self.bgView.width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tipsLab.font} context:nil].size;

    [self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(30);
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.height.mas_equalTo(tipsSize.height + 5);
    }];
    
    [self.passwordBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.tipsLab.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.height.mas_equalTo(@40);
    }];
    
    [self.passwordImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passwordBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.passwordBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.passwordLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordBorderView.mas_top).offset(5);
        make.bottom.equalTo(weakSelf.passwordBorderView.mas_bottom).offset(-5);
        make.left.equalTo(weakSelf.passwordImgView.mas_right).offset(10);
        make.width.mas_equalTo(@1);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passwordLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.passwordBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.passwordBorderView.mas_right).offset(-40);
    }];
    
    [self.eyesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.passwordTextField.mas_right).offset(5);
        make.right.equalTo(weakSelf.passwordBorderView.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(20, 15));
        make.centerY.equalTo(weakSelf.passwordBorderView);
    }];
    
    
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordBorderView.mas_bottom).offset(30);
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.height.mas_equalTo(@40);

    }];
}

#pragma mark ----------------------------------------------Click

- (void)showClick:(id)sender{
    self.isShowPassword = !self.isShowPassword;
    if (self.isShowPassword) {
        [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_on" withType:@"png"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
        
        SYLog(@"----显示密码");
        
    }else{
        [self.eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
        
        SYLog(@"----不显示密码");
    }
}

- (void)sureClick:(id)sender{
    Weak_Self;
    if (self.passwordTextField.text.length < 6) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"密码最少6个字符"];
        return;
    }
    /*正则表达式判断是否有中文(屌不屌)*/
    NSString *regex = @"^([\u4E00-\u9FA5]+)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isEmpty = [SSWL_PublicTool isEmpty:self.passwordTextField.text];
    //![pred evaluateWithObject:self.passTextField.text] ||
    
    /*
     * 判断中文和空格
     *
     */
    if([pred evaluateWithObject:self.passwordTextField.text] || isEmpty) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请按正确格式填写密码"];
        self.passwordTextField.text = @"";
        [self.passwordTextField resignFirstResponder];
        return;
    }
    

    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] changePassword:self.passwordTextField.text phoneNum:self.phoneNum code:self.code completion:^(BOOL isSuccess, id respones) {
        if (isSuccess) {
//            SYLog(@"-------respones:%@", respones);
            [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"修改成功"];
            BOOL firstOpen = [SSWL_PublicTool getCurrenFirstOpen];
            if (firstOpen) {
                [weakSelf.navigationController popToViewController:weakSelf.navigationController.childViewControllers[weakSelf.navigationController.childViewControllers.count - 3] animated:NO];
            }else{
                [weakSelf.navigationController popToRootViewControllerAnimated:NO];
            }
        }else{
//            SYLog(@"-------respones:%@", respones);

        }
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)backClick{
    
    [self.navigationController popViewControllerAnimated:YES];
   
}


#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.passwordTextField) {
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



/*当用户开始输入时进入监听*/
-(void)textFieldEditChanged:(NSNotification *)obj{

    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.passwordTextField) {
        [self limitTextLengthFor:textField length:15];
    }
    
    
}

/*监听用户的键盘和候选字*/
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
    int height = keyboardRect.size.height;
    //    SYLog(@"打印键盘的高度：%d",height);
    
    //记录注册视图的Y和H值
    self.viewY = self.bgView.y;
    self.viewH = self.bgView.height;
    SYLog(@"viewY:%d__________viewH:%d", self.viewY, self.viewH);
    
    int textH = self.textFieldY + self.bgView.y + self.passwordTextField.height;
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
}



#pragma mark ----------------------------------------------懒加载

- (UIButton *)eyesBtn{
    if (!_eyesBtn) {
        _eyesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eyesBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"key_off" withType:@"png"] forState:UIControlStateNormal];
        [_eyesBtn addTarget:self action:@selector(showClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _eyesBtn;
}
- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an_z1" withType:@"png"] forState:UIControlStateNormal];
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an_z2" withType:@"png"] forState:UIControlStateHighlighted];
        [_sureBtn setBackgroundColor:button_Color];
        _sureBtn.layer.cornerRadius = 20;
        _sureBtn.layer.masksToBounds = YES;
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn setTitle:@"确定" forState:UIControlStateHighlighted];
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
        [_backBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"back" withType:@"png"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backBtn;
}

- (SSWL_BGView *)bgView{
    if (!_bgView) {
        _bgView = [[SSWL_BGView alloc] initWithShowImage:NO showBGView:NO];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIView *)passwordBorderView{
    
    if (!_passwordBorderView) {
        _passwordBorderView = [[UIView alloc] init];
        _passwordBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _passwordBorderView.layer.borderWidth = 2;
        _passwordBorderView.layer.masksToBounds = YES;
        _passwordBorderView.layer.cornerRadius = 20;
        
    }
    
    return _passwordBorderView;
}
- (UILabel *)passwordLineLab{
    if (!_passwordLineLab) {
        _passwordLineLab = [[UILabel alloc] init];
        _passwordLineLab.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
    }
    return _passwordLineLab;
}
 
- (UILabel *)tipsLab{
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] init];
        _tipsLab.text = [NSString stringWithFormat:@"温馨提示:您的账号是%@,您可以选择使用账号或者手机号登录", self.account];
        _tipsLab.textColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
        _tipsLab = [SSWL_PublicTool changeTextColor:[UIColor colorWithRed:0.18 green:0.55 blue:0.91 alpha:1.00] ChangeTitle:self.account Titile:_tipsLab.text ToLabel:_tipsLab];

        _tipsLab.textAlignment = 0;
        _tipsLab.numberOfLines = 0;
        _tipsLab.font = [UIFont systemFontOfSize:16];
    }
    return _tipsLab;
}
- (UIImageView *)passwordImgView{
    
    if (!_passwordImgView) {
        _passwordImgView = [[UIImageView alloc] init];
        [_passwordImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"tb_pwd" withType:@"png"]];
        _passwordImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _passwordImgView;
}

- (UITextField *)passwordTextField{
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.placeholder =  @"请输入新密码";
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.font = [UIFont systemFontOfSize:14];
        _passwordTextField.keyboardType = UIKeyboardTypeNamePhonePad;
        _passwordTextField.delegate = self;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _passwordTextField;
}

- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        [_logoImgView setImage:get_SSWL_Logo];
//        [_logoImgView setImage:set_BundleImage(@"sswlLogo")];
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
