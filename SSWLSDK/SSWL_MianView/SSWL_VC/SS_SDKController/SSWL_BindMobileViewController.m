//
//  AYBindMobileViewController.m
//  AYSDK
//
//  Created by songyan on 2017/8/29.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_BindMobileViewController.h"
#import "SSWL_CustomerServiceViewController.h"


@interface SSWL_BindMobileViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) SSWL_BGView *bgView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) NSDictionary *responesParam;//请求下来的参数

@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic, strong) UIImageView *phoneImgView;//账号图片

@property (nonatomic, strong) UIImageView *codeImgView;//密码图片

@property (nonatomic, strong) UITextField *phoneNumTextField;//账号

@property (nonatomic, strong) UITextField *codeTextField;//密码

@property (nonatomic, strong) UIButton *sureBtn;//确定

@property (nonatomic, strong) UIButton *getCodeBtn;//获取验证码

@property (nonatomic, strong) UIButton *backBtn;//返回

@property (nonatomic ,strong) UIButton *onlineServiceBtn;

@property (nonatomic, strong) UIView *phoneBorderView;//输入框边框

@property (nonatomic, strong) UIView *codeBorderView;//

@property (nonatomic, strong) UILabel *phoneLineLab;//分割线

@property (nonatomic, strong) UILabel *codeLineLab;//分割线

@property (nonatomic ,strong) UILabel *tipsLab;//提示

@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值

@property(nonatomic,strong)NSTimer *telCodeTimer;//验证码倒计时

@property(nonatomic,assign)NSInteger timerNumber;//倒计时时间

@property (nonatomic ,copy) NSString *account;//账号

//@property (nonatomic ,copy) NSString *code;//短信验证码


@end

@implementation SSWL_BindMobileViewController


/*
 * 注销键盘的通知事件
 
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.phoneNumTextField];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.codeTextField];
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [self createUI];
}


- (void)createUI{
    
    [self.view addSubview:self.bgView];
    
    [self.bgView addSubview:self.logoImgView];
    
    [self.bgView addSubview:self.phoneBorderView];
    
    [self.bgView addSubview:self.phoneImgView];
    
    [self.bgView addSubview:self.phoneLineLab];
    
    [self.bgView addSubview:self.phoneNumTextField];
    
    [self.bgView addSubview:self.codeBorderView];
    
    [self.bgView addSubview:self.codeImgView];
    
    [self.bgView addSubview:self.codeImgView];
    
    [self.bgView addSubview:self.codeLineLab];
    
    [self.bgView addSubview:self.codeTextField];
    
    [self.bgView addSubview:self.getCodeBtn];
    
    [self.bgView addSubview:self.tipsLab];
    
    [self.bgView addSubview:self.sureBtn];
    
    [self.bgView addSubview:self.backBtn];

    [self.bgView addSubview:self.onlineServiceBtn];
    
    [self layoutSubView];
}



- (void)layoutSubView{
    Weak_Self;
    //约束
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
    
  
    [self.phoneBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(30);
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.height.mas_equalTo(40);
    }];

    
    
    [self.phoneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.phoneBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.phoneBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.phoneLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.phoneBorderView.mas_top).offset(5);
        make.bottom.equalTo(weakSelf.phoneBorderView.mas_bottom).offset(-5);
        make.left.equalTo(weakSelf.phoneImgView.mas_right).offset(10);
        make.width.mas_equalTo(1);
    }];
    
    [self.phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.phoneLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.phoneBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.phoneBorderView.mas_right).offset(-30);
    }];
    
    
    [self.getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.phoneBorderView.mas_bottom).offset(15);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.size.mas_equalTo(CGSizeMake(74, 30));
//        make.centerY.equalTo(weakSelf.codeBorderView);
    }];
    
    [self.codeBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.phoneBorderView);
        make.right.equalTo(weakSelf.getCodeBtn.mas_left).offset(-15);
        make.centerY.equalTo(weakSelf.getCodeBtn);
        make.height.mas_equalTo(@40);
    }];
    
    [self.codeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.codeBorderView.mas_left).offset(10);
        make.centerY.equalTo(weakSelf.codeBorderView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.codeLineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.codeBorderView.mas_top).offset(5);
        make.bottom.equalTo(weakSelf.codeBorderView.mas_bottom).offset(-5);
        make.left.equalTo(weakSelf.codeImgView.mas_right).offset(10);
        make.width.mas_equalTo(@1);
    }];
    
    [self.codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.codeLineLab.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.codeBorderView);
        make.height.mas_equalTo(@30);
        make.right.equalTo(weakSelf.getCodeBtn.mas_left).offset(-5);
    }];

    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.codeBorderView.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.phoneBorderView);
        make.right.equalTo(weakSelf.phoneBorderView);
        make.height.mas_equalTo(30);
    }];
    
   
}



- (void)currentTime{
    //*** 2、开启计时器
    if (!_telCodeTimer) {
        _timerNumber = 60;
        _telCodeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getTelCodeBtn) userInfo:nil repeats:YES];
        [_telCodeTimer fire];
    }
    
}


-(void)getTelCodeBtn{
    _timerNumber -- ;
    if (_timerNumber == 0) {
        
        [_telCodeTimer invalidate];
        _telCodeTimer = nil;
        [self.getCodeBtn setBackgroundColor:code_Color];
        [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.getCodeBtn.enabled = YES;
        
    }else{
        [self.getCodeBtn setBackgroundColor:[UIColor grayColor]];
        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"(%lds)",(long)_timerNumber] forState:0];
        self.getCodeBtn.enabled = NO;
        
    }
}


#pragma mark ----------------------------------------------Click


- (void)sureClick:(id)sender{
    Weak_Self;
    
    BOOL isTel = [SSWL_PublicTool isValidateTel:self.phoneNumTextField.text];
    if (self.phoneNumTextField.text.length < 1){
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写手机号码"];
        return;
    }
    
    if (!isTel) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写正确的手机号码"];
        
        return;
    }
    if (self.codeTextField.text.length < 1) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写验证码"];
        return;
    }

      [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] bindMobileWithToken:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken code:self.codeTextField.text phoneNumber:self.phoneNumTextField.text completion:^(BOOL isSuccess, id respones) {
          if (isSuccess) {
//              SYLog(@"---------respones:%@", respones);
              if (weakSelf.HudHiddenBlock) {
                  weakSelf.HudHiddenBlock(YES);
              }
              [weakSelf.navigationController popViewControllerAnimated:YES];
          }else{
              [SSWL_PublicTool showHUDWithViewController:weakSelf Text:respones[@"msg"]];

          }
      } failure:^(NSError *error) {
          
      }];
    
}




/*
 * 获取验证码
 */
- (void)getClick:(id)sender{
    Weak_Self;
    
    BOOL isTel = [SSWL_PublicTool isValidateTel:self.phoneNumTextField.text];
    if (isTel) {
        SYLog(@"获取验证码");

        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] bindPhoneSmsWithPhoneNumber:self.phoneNumTextField.text completion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
//                SYLog(@"-------respones:%@", respones);
                [weakSelf currentTime];
            }else{
//                SYLog(@"-------respones:%@", respones);
                //882136
                [SSWL_PublicTool showHUDWithViewController:weakSelf Text:respones[@"msg"]];
                
            }
        } failure:^(NSError *error) {
            
        }];
        
    }else{
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请填写正确的手机号码"];
    }
}


- (void)backClick
{
    SYLog(@"返回");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onlineServiceClick{
    SSWL_CustomerServiceViewController *csVC = [[SSWL_CustomerServiceViewController alloc] init];
    [self presentViewController:csVC animated:YES completion:^{
        
    }];
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
    
    int textH = self.textFieldY + self.bgView.y + self.phoneNumTextField.height;
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







#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.phoneNumTextField || textField == self.codeTextField) {
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

-(void)textFieldEditChanged:(NSNotification *)obj{
    
    
    NSString *regex = @"^([0-9]+)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isEmpty = [SSWL_PublicTool isEmpty:self.phoneNumTextField.text];
    if ((self.phoneNumTextField.text.length > 0) || (self.codeTextField.text.length > 0)) {
        if ([self.phoneNumTextField isFirstResponder]) {
            if(![pred evaluateWithObject:self.phoneNumTextField.text] || isEmpty) {
                [SSWL_PublicTool showHUDWithViewController:self Text:@"请按正确格式输入手机号码"];
                self.phoneNumTextField.text = @"";
                [self.phoneNumTextField resignFirstResponder];
                return;
            }
            
        }
        
        
        if ([self.codeTextField isFirstResponder]) {
            if (![pred evaluateWithObject:self.codeTextField.text] || isEmpty) {
                [SSWL_PublicTool showHUDWithViewController:self Text:@"请按正确格式输入验证码"];
                self.codeTextField.text = @"";
                [self.codeTextField resignFirstResponder];
                return;
                
            }
        }
        
    }
    
    
    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.phoneNumTextField) {
        [self limitTextLengthFor:textField length:11];
    }
    if (textField == self.codeTextField) {
        [self limitTextLengthFor:textField length:10];
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








#pragma mark ----------------------------------------------懒加载

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an_z1" withType:@"png"] forState:UIControlStateNormal];
//        [_sureBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"an_z2" withType:@"png"] forState:UIControlStateHighlighted];
        [_sureBtn setBackgroundColor:button_Color];
        _sureBtn.layer.cornerRadius = 15;
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

- (UIButton *)getCodeBtn{
    if (!_getCodeBtn) {
        _getCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_getCodeBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"jhma" withType:@"png"] forState:UIControlStateNormal];
//        [_getCodeBtn setBackgroundImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"jhma_2" withType:@"png"] forState:UIControlStateHighlighted];
        _getCodeBtn.backgroundColor = code_Color;
//        _getCodeBtn.layer.borderColor = [UIColor colorWithRed:0.97 green:0.56 blue:0.16 alpha:1].CGColor;
//        _getCodeBtn.layer.borderWidth = 1;
        _getCodeBtn.layer.cornerRadius = 15;
        _getCodeBtn.layer.masksToBounds = YES;
//        [_getCodeBtn setTitleColor:[UIColor colorWithRed:0.18 green:0.55 blue:0.91 alpha:1.00] forState:UIControlStateNormal];
        _getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//        [_getCodeBtn setTitle:@"获取验证码" forState:UIControlStateHighlighted];
        _getCodeBtn.enabled = YES;
        [_getCodeBtn addTarget:self action:@selector(getClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _getCodeBtn;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"back" withType:@"png"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backBtn;
}

- (UIButton *)onlineServiceBtn{
    if (!_onlineServiceBtn) {
        _onlineServiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_onlineServiceBtn setImage:get_BundleImage(@"zxkf") forState:UIControlStateNormal];
        [_onlineServiceBtn addTarget:self action:@selector(onlineServiceClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _onlineServiceBtn;
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

- (UIView *)phoneBorderView{
    
    if (!_phoneBorderView) {
        _phoneBorderView = [[UIView alloc] init];
        _phoneBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _phoneBorderView.layer.borderWidth = 2;
        _phoneBorderView.layer.masksToBounds = YES;
        _phoneBorderView.layer.cornerRadius = 20;
        
    }
    
    return _phoneBorderView;
}


- (UIView *)codeBorderView{
    if (!_codeBorderView) {
        _codeBorderView = [[UIView alloc] init];
        _codeBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _codeBorderView.layer.borderWidth = 2;
        _codeBorderView.layer.masksToBounds = YES;
        _codeBorderView.layer.cornerRadius = 20;
        
    }
    
    return _codeBorderView;
}

- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        [_logoImgView setImage:get_SSWL_Logo];
    }
    return _logoImgView;
}

- (UIImageView *)phoneImgView{
    if (!_phoneImgView) {
        _phoneImgView = [[UIImageView alloc] init];
        [_phoneImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"tb_phone" withType:@"png"]];
        _phoneImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _phoneImgView;
}

- (UIImageView *)codeImgView{
    
    if (!_codeImgView) {
        _codeImgView = [[UIImageView alloc] init];
        [_codeImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"tb_pwd" withType:@"png"]];
        _codeImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _codeImgView;
}

- (UITextField *)phoneNumTextField{
    if (!_phoneNumTextField) {
        _phoneNumTextField = [[UITextField alloc] init];
        _phoneNumTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneNumTextField.placeholder =  @"请输入手机号";
        _phoneNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNumTextField.font = [UIFont systemFontOfSize:14];
        _phoneNumTextField.keyboardType = UIKeyboardTypeNamePhonePad;
        _phoneNumTextField.delegate = self;
        //        self.passTextField.secureTextEntry = YES;
        _phoneNumTextField.returnKeyType = UIReturnKeyDone;
        _phoneNumTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _phoneNumTextField;
}

- (UITextField *)codeTextField{
    if (!_codeTextField) {
        _codeTextField = [[UITextField alloc] init];
        _codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _codeTextField.placeholder =  @"请输入验证码";
        //    self.codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _codeTextField.font = [UIFont systemFontOfSize:14];
        _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _codeTextField.delegate = self;
        
        _codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _codeTextField.returnKeyType = UIReturnKeyDone;
    }
    return _codeTextField;
}

- (UILabel *)phoneLineLab{
    if (!_phoneLineLab) {
        _phoneLineLab = [[UILabel alloc] init];
        _phoneLineLab.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
    }
    return _phoneLineLab;
}

- (UILabel *)codeLineLab{
    if (!_codeLineLab) {
        _codeLineLab = [[UILabel alloc] init];
        _codeLineLab.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0];
    }
    return _codeLineLab;
}

- (UILabel *)tipsLab{
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] init];
        
//
        NSString *text = @"提示:未绑定手机用户找回密码请点击";
        _tipsLab.textColor = [UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1];
        _tipsLab.font = [UIFont systemFontOfSize:12];
        _tipsLab.text = text;
//        _tipsLab = [SSWL_PublicTool changeTextColor:[UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1.0] ChangeTitle:@"您的账号为:" Titile:_tipsLab.text ToLabel:_tipsLab];
        _tipsLab.textAlignment = 1;
        
    }
    return _tipsLab;
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
