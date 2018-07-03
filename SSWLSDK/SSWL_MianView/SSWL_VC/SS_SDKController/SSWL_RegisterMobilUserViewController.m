//
//  RegisterMobilUserViewController.m
//  AYSDK
//
//  Created by songyan on 2018/1/26.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_RegisterMobilUserViewController.h"
#import "SSWL_GetCodeForMessageViewController.h"
#import "SSWL_LoginForPhoneViewController.h"

@interface SSWL_RegisterMobilUserViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) SSWL_BGView *bgView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic ,strong) UILabel *areaLabel;

@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic ,strong) UIView *phoneBorderView;

@property (nonatomic, strong) UITextField *phoneNumTextField;//账号

@property (nonatomic ,strong) UIButton *nextStepBtn;

@property (nonatomic ,strong) UIButton *backBtn;


@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值

@end

@implementation SSWL_RegisterMobilUserViewController

/*
 * 注销键盘的通知事件
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
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
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [self.view addSubview:self.bgView];
    [self createUI];
}

- (void)createUI{
    [self.bgView addSubview:self.logoImgView];
    
    [self.bgView addSubview:self.backBtn];
    
    [self.bgView addSubview:self.phoneBorderView];
    
    [self.bgView addSubview:self.nextStepBtn];
    
    [self.phoneBorderView addSubview:self.phoneNumTextField];
    
    [self.phoneBorderView addSubview:self.areaLabel];
    
    [self layoutSubviews];
}


- (void)layoutSubviews{
    Weak_Self;
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bgView).offset(30);
        make.size.mas_equalTo(CGSizeMake(150, 30));
        make.centerX.equalTo(weakSelf.bgView);
        
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.centerY.equalTo(weakSelf.logoImgView);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    
    [self.phoneBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(40);
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    [self.nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.phoneBorderView.mas_bottom).offset(30);
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.right.equalTo(weakSelf.bgView).offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    [self.areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.phoneBorderView);
        make.left.equalTo(weakSelf.phoneBorderView.mas_left).offset(5);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    [self.phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.phoneBorderView);
        make.left.equalTo(weakSelf.areaLabel.mas_right).offset(5);
        make.right.equalTo(weakSelf.phoneBorderView.mas_right).offset(-10);
        make.height.mas_equalTo(30);
    }];
    
   
}


- (void)nextStepClick{
    
    Weak_Self;
    if (![SSWL_PublicTool isValidateTel:self.phoneNumTextField.text]) {
        [SSWL_PublicTool showHUDWithViewController:self Text:@"请输入正确的手机号码"];
        return;
    }
    NSInteger userType;
    if ([SSWL_PublicTool isValidateTel:self.phoneNumTextField.text]) {

        userType = 1;
    }else{
//        [PublicTool showHUDWithViewController:self Text:@"格式错误"];
        userType = 0;
    }
    
    /*
     code=0, 账号已经存在
     code=-1, 账号不存在
     code=-2,  

     */
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkIfTheUserExistsWithUserName:self.phoneNumTextField.text userType:userType completion:^(BOOL isSuccess, id  _Nullable response) {
        NSInteger code = [response[@"code"] integerValue];
        #pragma mark ----------------------------------------------强制进入注册流程
//        code = -1;
        switch (code) {
            case 0:
            {
                SSWL_LoginForPhoneViewController *phoneVC = [[SSWL_LoginForPhoneViewController alloc] init];
                phoneVC.isPush = YES;
                phoneVC.usernameString = self.phoneNumTextField.text;
                phoneVC.block = weakSelf.MobilRegisterBlock;
                phoneVC.isOnline = YES;
                [weakSelf.navigationController pushViewController:phoneVC animated:NO];
            }
                break;
                
            case -1:
            {
                SSWL_GetCodeForMessageViewController *regPhoneVC = [[SSWL_GetCodeForMessageViewController alloc] init];
                regPhoneVC.getMessageType = RegistPhoneUser;
                regPhoneVC.accountString = self.phoneNumTextField.text;
                regPhoneVC.GetMessageBlock = self.MobilRegisterBlock;
                [self.navigationController pushViewController:regPhoneVC animated:NO];
            }
                break;
                
            case -2:
            {
                [SSWL_PublicTool showHUDWithViewController:weakSelf Text:@"手机号已绑定用户"];
            }
                break;
                
            default:
                break;
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.phoneNumTextField.isFirstResponder) {
        [self.phoneNumTextField resignFirstResponder];
    }
    
}



#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.phoneNumTextField) {
        if (textField.isFirstResponder) {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.textFieldY = self.phoneBorderView.y;
}


# pragma mark --------------------------------------------------------------- 输入框输入的文字限制

-(void)textFieldEditChanged:(NSNotification *)obj{
    
    
//    NSString *regex = @"^([0-9]+)$";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isEmpty = [SSWL_PublicTool isEmpty:self.phoneNumTextField.text];
    if ((self.phoneNumTextField.text.length > 0)) {
        if ([self.phoneNumTextField isFirstResponder]) {
            if(isEmpty) {
                [SSWL_PublicTool showHUDWithViewController:self Text:@"请按正确格式输入手机号码"];
                self.phoneNumTextField.text = @"";
                [self.phoneNumTextField resignFirstResponder];
                return;
            }
            
        }
  
    }
    
    
    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.phoneNumTextField) {
        [self limitTextLengthFor:textField length:11];
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
    int height = keyboardRect.size.height;
    //    SYLog(@"打印键盘的高度：%d",height);
    
    //记录注册视图的Y和H值
    self.viewY = self.bgView.y;
    self.viewH = self.bgView.height;
    SYLog(@"viewY:%d__________viewH:%d", self.viewY, self.viewH);
    
    int textH = self.textFieldY + self.bgView.y + self.phoneBorderView.height;
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




- (UILabel *)areaLabel{
    if (!_areaLabel) {
        _areaLabel = [[UILabel alloc] init];
        _areaLabel.text = @"+86";
        _areaLabel.font = [UIFont systemFontOfSize:18];
        _areaLabel.textAlignment = 1;
//        _areaLabel.backgroundColor = [UIColor yellowColor];
    }
    return _areaLabel;
    
}

- (UIButton *)nextStepBtn{
    if (!_nextStepBtn) {
        _nextStepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextStepBtn setBackgroundColor:button_Color];
        _nextStepBtn.layer.cornerRadius = 20;
        _nextStepBtn.layer.masksToBounds = YES;
        [_nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextStepBtn setTitle:@"下一步" forState:UIControlStateHighlighted];
//        [_backBtn setImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"back" withType:@"png"] forState:UIControlStateNormal];
        [_nextStepBtn addTarget:self action:@selector(nextStepClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextStepBtn;
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
        _bgView.backgroundColor = SYWhiteColor;
        _bgView.height = 265;
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIView *)phoneBorderView{
    
    if (!_phoneBorderView) {
        _phoneBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]
        _phoneBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _phoneBorderView.layer.borderWidth = 1;
        _phoneBorderView.layer.masksToBounds = YES;
        _phoneBorderView.layer.cornerRadius = 20;
        _phoneBorderView.backgroundColor = [UIColor whiteColor];
        _phoneBorderView.userInteractionEnabled = YES;
    }
    
    return _phoneBorderView;
}

- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        [_logoImgView setImage:get_SSWL_Logo];
    }
    return _logoImgView;
}


- (UITextField *)phoneNumTextField{
    if (!_phoneNumTextField) {
        _phoneNumTextField = [[UITextField alloc] init];
//        _phoneNumTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneNumTextField.placeholder =  @"请输入手机号";
        _phoneNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNumTextField.font = [UIFont systemFontOfSize:14];
        _phoneNumTextField.keyboardType = UIKeyboardTypeNamePhonePad;
        _phoneNumTextField.delegate = self;
        //        self.passTextField.secureTextEntry = YES;
        _phoneNumTextField.returnKeyType = UIReturnKeyDone;
        _phoneNumTextField.autocorrectionType = UITextAutocorrectionTypeNo;
//        _phoneNumTextField.backgroundColor = [UIColor redColor];
    }
    return _phoneNumTextField;
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
