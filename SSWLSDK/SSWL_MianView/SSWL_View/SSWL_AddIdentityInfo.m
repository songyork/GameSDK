//
//  AddIdentityInfo.m
//  AYSDK
//
//  Created by songyan on 2018/1/30.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_AddIdentityInfo.h"

@interface SSWL_AddIdentityInfo()<UITextFieldDelegate>
{
    CGSize _noticeSize;
    BOOL _isNeedMandatory;
    UIViewController *_viewController;
    float _idY;
}
//,UITableViewDelegate,UITableViewDataSource
@property (nonatomic, strong) UIImageView *logoImgView;//logo

@property (nonatomic, strong) UIView *nameBorderView;//账号边框

@property (nonatomic, strong) UIView *identityBorderView;//身份证边框

@property (nonatomic ,strong) UIView *selectorBorderView;// 选择边框

@property (nonatomic, strong) UITextField *nameTextFiled;//账号

@property (nonatomic, strong) UITextField *identityTextFiled;//账号

@property (nonatomic ,strong) UILabel *noticeLabel;// 公告label

@property (nonatomic ,strong) UILabel *inputTypeLabel;// 输入类型label

@property (nonatomic ,strong) UILabel *selectorLabel;// 选择类型label

@property (nonatomic ,strong) UIButton *closeBtn; //关闭

@property (nonatomic ,strong) UIButton *arrowBtn;//箭头

@property (nonatomic ,strong) UIButton *submitBtn;// 提交

@property (nonatomic ,strong) UIButton *cancelBtn; // 取消

@property (nonatomic ,strong) UIButton *switchUserBtn;// 切换账号

@property (nonatomic ,strong) UITableView *tableView;//

@property (nonatomic, assign) int viewY;//注册视图的Y值

@property (nonatomic, assign) int viewH;//注册视图的height值

@property (nonatomic, assign) int textFieldY;//textField的height值

@end

@implementation SSWL_AddIdentityInfo

/*
 * 注销键盘的通知事件
 
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
    
}

- (id)initIfNeedMandatoryBindIdInfo:(BOOL)isNeedMandatory viewController:(UIViewController *)viewController{
    if (self = [super init]) {
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
        self.backgroundColor = SYWhiteColor;
        _isNeedMandatory = isNeedMandatory;
        _viewController = viewController;
        [self createUI];
        
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
        
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
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.nameTextFiled];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.identityTextFiled];

    }
    return self;
}

- (void)createUI{
    [self addSubview:self.logoImgView];
    [self addSubview:self.noticeLabel];
    [self addSubview:self.nameBorderView];
    [self addSubview:self.nameTextFiled];
    /*
    [self addSubview:self.selectorBorderView];
    [self addSubview:self.inputTypeLabel];
    [self addSubview:self.selectorLabel];
    [self addSubview:self.arrowBtn];
     */
    [self addSubview:self.identityBorderView];
    [self addSubview:self.identityTextFiled];
    if (!_isNeedMandatory) {
        [self addSubview:self.cancelBtn];
    }
    [self addSubview:self.closeBtn];

    [self addSubview:self.submitBtn];
    [self addSubview:self.switchUserBtn];
    [self layoutSubview];
}

- (void)layoutSubview{
    Weak_Self;
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(15);
        make.centerX.equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(125, 30));
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.logoImgView);
        make.right.equalTo(weakSelf).offset(-10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    _noticeSize = [self.noticeLabel.text boundingRectWithSize:CGSizeMake(self.width - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.noticeLabel.font} context:nil].size;
    [self.noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(10);
        make.left.equalTo(weakSelf).offset(20);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - 40, _noticeSize.height + 20));
    }];
    
    [self.nameBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.noticeLabel.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.noticeLabel);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - 40, 40));
    }];
    
    [self.nameTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.nameBorderView);
        make.left.equalTo(weakSelf.nameBorderView.mas_left).offset(15);
        make.right.equalTo(weakSelf.nameBorderView.mas_right).offset(-15);
        make.height.mas_equalTo(30);
    }];
    
    [self.identityBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameBorderView.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.nameBorderView);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - 40, 40));
    }];
    
    [self.identityTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.identityBorderView);
        make.left.equalTo(weakSelf.identityBorderView.mas_left).offset(15);
        make.right.equalTo(weakSelf.identityBorderView.mas_right).offset(-15);
        make.height.mas_equalTo(30);
    }];
    
    /*
    [self.selectorBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameBorderView.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.nameBorderView);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - 40, 40));
    }];
    
    [self.selectorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.selectorBorderView);
        make.size.mas_equalTo(CGSizeMake(weakSelf.width - ((weakSelf.width - 40) / 3), 30));
    }];
    
    [self.inputTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.selectorBorderView);
        make.left.equalTo(weakSelf.nameBorderView.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake((weakSelf.width - 40) / 3, 30));
    }];
    */
    if (_isNeedMandatory) {
        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.identityBorderView.mas_bottom).offset(15);
            make.right.equalTo(weakSelf.identityBorderView);
            make.size.mas_equalTo(CGSizeMake((weakSelf.width - 40), 30));
        }];
    }else{
        
        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.identityBorderView.mas_bottom).offset(15);
            make.right.equalTo(weakSelf.identityBorderView);
            make.size.mas_equalTo(CGSizeMake((weakSelf.width - 40) / 2 - 10, 30));
        }];
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.submitBtn);
            make.left.equalTo(weakSelf.identityBorderView);
            make.size.mas_equalTo(CGSizeMake((weakSelf.width - 40) / 2 - 10, 30));
        }];

    }
}

#pragma mark ----------------------------------------------click

- (void)submitClick{
    SYLog(@"------------提交");
    if (self.nameTextFiled.text.length < 1 || self.identityTextFiled.text.length < 15) {
        [SSWL_PublicTool showHUDWithViewController:_viewController Text:@"请按规定填写身份信息"];
        return;
    }else{
        //a-zA-Z0-9
        NSString *regex = @"^([\u4E00-\u9FA5]+)$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isEmpty = [SSWL_PublicTool isEmpty:self.nameTextFiled.text];
        if(![pred evaluateWithObject:self.nameTextFiled.text] || isEmpty) {
            [SSWL_PublicTool showHUDWithViewController:_viewController Text:@"请按规定填写身份信息"];
            return;
        }
        
    }
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] verifyIdcardWithName:self.nameTextFiled.text idCard:self.identityTextFiled.text completion:^(BOOL isSuccess, id  _Nullable respones) {
        if (isSuccess) {
           [weakSelf getAddIdentityInfoViewClickStates:ViewIsClickSubmit];
        }else{
           [SSWL_PublicTool showHUDWithViewController:_viewController Text:respones[@"msg"]];
        }
    } failure:^(NSError * _Nullable error) {
        [SSWL_PublicTool showHUDWithViewController:_viewController Text:@"网络异常"];
    }];
    
    
}

- (void)cencelClick{
    SYLog(@"------------取消");
    
    [self getAddIdentityInfoViewClickStates:ViewIsClickCancel];
}

- (void)closeClick{
    SYLog(@"------------关闭");
   
    [self getAddIdentityInfoViewClickStates:ViewIsClickClose];

}

- (void)getAddIdentityInfoViewClickStates:(AddIdentityInfoViewClickStates)addViewStates{
    if (self.addIdentityInfoViewBlock) {
        self.addIdentityInfoViewBlock(addViewStates);
    }
    
}

- (void)arrowClick{
    SYLog(@"------------箭头");
}

- (void)switchUserClick{
    SYLog(@"------------切换");
}


#pragma mark ----------------------------------------------UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.nameTextFiled || textField == self.identityTextFiled) {
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
    if (textField == self.nameTextFiled) {
        [self limitTextLengthFor:textField length:15];
    }
    if (textField == self.identityTextFiled) {
        [self limitTextLengthFor:textField length:18];
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
    
    // 获取键盘弹出动画时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    
    //记录注册视图的Y和H值
    self.viewY = self.y;
    self.viewH = self.height;
    SYLog(@"viewY:%d__________viewH:%d", self.viewY, self.viewH);
    
    int textH = 0;
    
    if (self.nameTextFiled.isFirstResponder) {
        textH = self.textFieldY + self.y + self.nameBorderView.height;
    }
    if (self.identityTextFiled.isFirstResponder) {
        textH = self.textFieldY + self.y + self.identityBorderView.height;

    }
    int heighToBottom = (int)Screen_Height - textH;
    
    if (height > heighToBottom) {
        int differHeight = height - heighToBottom;
        self.frame = CGRectMake(self.x, self.y - differHeight, self.width, self.height);
    }
}

#pragma mark ----------------------------------------------回收键盘
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    
    
    // 获取键盘弹出动画时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (self.identityTextFiled.isFirstResponder) {
//        self.center =;
        self.frame = CGRectMake(self.x, self.viewY, self.width, self.height);
        self.centerX = Screen_Width / 2;
        self.centerY = Screen_Height / 2;
    }else{
        self.frame = CGRectMake(self.x, self.viewY, self.width, self.height);
        self.centerX = Screen_Width / 2;
        self.centerY = Screen_Height / 2;
    }
    
    
}




- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
    
}




- (UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn setTitle:@"提交" forState:UIControlStateHighlighted];
        
        [_submitBtn setBackgroundColor:button_Color];
        _submitBtn.layer.cornerRadius = 15;
        _submitBtn.layer.masksToBounds = YES;
        
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_submitBtn addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateHighlighted];
        
        [_cancelBtn setBackgroundColor:code_Color];
        _cancelBtn.layer.cornerRadius = 15;
        _cancelBtn.layer.masksToBounds = YES;
        
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_cancelBtn addTarget:self action:@selector(cencelClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}


- (UIButton *)switchUserBtn{
    if (!_switchUserBtn) {
        _switchUserBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [_switchUserBtn setTitle:@"切换账号" forState:UIControlStateNormal];
        [_switchUserBtn setTitle:@"切换账号" forState:UIControlStateHighlighted];
        
        [_switchUserBtn setBackgroundColor:SYNOColor];
        [_switchUserBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_switchUserBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_switchUserBtn addTarget:self action:@selector(switchUserClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchUserBtn;
}

- (UIButton *)arrowBtn{
    if (!_arrowBtn) {
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_arrowBtn addTarget:self action:@selector(arrowClick) forControlEvents:UIControlEventTouchUpInside];
        [_arrowBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"arrow" withType:@"png"] forState:UIControlStateNormal];
        
    }
    return _arrowBtn;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"close" withType:@"png"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (UIView *)nameBorderView{
    
    if (!_nameBorderView) {
        _nameBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]
        _nameBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _nameBorderView.backgroundColor = [UIColor whiteColor];
        
        _nameBorderView.layer.borderWidth = 1.0f;
        _nameBorderView.layer.masksToBounds = YES;
        _nameBorderView.layer.cornerRadius = 20;
        
    }
    
    return _nameBorderView;
}

- (UIView *)identityBorderView{
    
    if (!_identityBorderView) {
        _identityBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]
        _identityBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _identityBorderView.backgroundColor = [UIColor whiteColor];
        
        _identityBorderView.layer.borderWidth = 1.0f;
        _identityBorderView.layer.masksToBounds = YES;
        _identityBorderView.layer.cornerRadius = 20;
        
    }
    
    return _identityBorderView;
}

- (UIView *)selectorBorderView{
    
    if (!_selectorBorderView) {
        _selectorBorderView = [[UIView alloc] init];
        //[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]
        _selectorBorderView.layer.borderColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1].CGColor;
        _selectorBorderView.backgroundColor = [UIColor whiteColor];
        
        _selectorBorderView.layer.borderWidth = 1.0f;
        _selectorBorderView.layer.masksToBounds = YES;
        _selectorBorderView.layer.cornerRadius = 20;
        
    }
    
    return _selectorBorderView;
}

- (UITextField *)nameTextFiled{
    if (!_nameTextFiled) {
        _nameTextFiled = [[UITextField alloc] init];
//        _nameTextFiled.translatesAutoresizingMaskIntoConstraints = NO;
        _nameTextFiled.placeholder =  @"请输入姓名, 如: 张三";
        _nameTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextFiled.font = [UIFont systemFontOfSize:14];
        _nameTextFiled.keyboardType = UIKeyboardTypeDefault;
        _nameTextFiled.delegate = self;
        //        self.passTextField.secureTextEntry = YES;
        _nameTextFiled.returnKeyType = UIReturnKeyDone;
        _nameTextFiled.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _nameTextFiled;
}

- (UITextField *)identityTextFiled{
    if (!_identityTextFiled) {
        _identityTextFiled = [[UITextField alloc] init];
        _identityTextFiled.placeholder =  @"输入身份证号码";
        _identityTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _identityTextFiled.font = [UIFont systemFontOfSize:14];
        _identityTextFiled.keyboardType = UIKeyboardTypeDefault;
        _identityTextFiled.delegate = self;
        //        self.passTextField.secureTextEntry = YES;
        _identityTextFiled.returnKeyType = UIReturnKeyDone;
        _identityTextFiled.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _identityTextFiled;
}

- (UILabel *)noticeLabel{
    if (!_noticeLabel) {
        _noticeLabel = [[UILabel alloc] init];
        _noticeLabel.numberOfLines = 0;
        _noticeLabel.textAlignment = 0;
        _noticeLabel.textColor = [UIColor grayColor];
        _noticeLabel.font = [UIFont systemFontOfSize:14];
        _noticeLabel.text = @"按文化部《网络游戏管理暂行办法》要求，网络游戏用户需进行实名认证，请先实名认证后再进入游戏。";
    }
    return _noticeLabel;
}

- (UILabel *)inputTypeLabel{
    if (!_inputTypeLabel) {
        _inputTypeLabel = [[UILabel alloc] init];
        _inputTypeLabel.numberOfLines = 0;
        _inputTypeLabel.textAlignment = 1;
        _inputTypeLabel.text = @"证件类型";
        _inputTypeLabel.textColor = [UIColor blackColor];
        _inputTypeLabel.font = [UIFont systemFontOfSize:18];
        _inputTypeLabel.backgroundColor = [UIColor redColor];
    }
    return _inputTypeLabel;
}

- (UILabel *)selectorLabel{
    if (!_selectorLabel) {
        _selectorLabel = [[UILabel alloc] init];
        _selectorLabel.numberOfLines = 0;
        _selectorLabel.textAlignment = 1;
        _selectorLabel.textColor = [UIColor blackColor];
        _selectorLabel.font = [UIFont systemFontOfSize:14];
        _selectorLabel.text = @"";
        _selectorLabel.alpha = 0.5f;
        _selectorLabel.backgroundColor = [UIColor yellowColor];

    }
    return _selectorLabel;
}




- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        [_logoImgView setImage:get_SSWL_Logo];
    }
    return _logoImgView;
}

@end
