//
//  SYSaveTouristInfo.m
//  AYSDK
//
//  Created by SDK on 2018/1/22.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SYSaveTouristInfo.h"
#import <Photos/Photos.h>

@interface SYSaveTouristInfo ()


/**
 logo
 */
@property (nonatomic, strong) UIImageView *logoImageView;


/**
 游戏名 :
 */
@property (nonatomic, strong) UILabel *gameNameLabel;


/**
 用户名 :
 */
@property (nonatomic, strong) UILabel *userNameLabel;


/**
 密码 :
 */
@property (nonatomic, strong) UILabel *passwordLabel;


/**
 游戏名label
 */
@property (nonatomic, strong) UILabel *gameNameLab;

/**
 游客账号label
 */
@property (nonatomic, strong) UILabel *userNameLab;


/**
 游客密码label
 */
@property (nonatomic, strong) UILabel *passwordLab;


/**
 保存账号信息btn
 */
@property (nonatomic, strong) UIButton *saveInfoBtn;


/**
 取消btn
 */
@property (nonatomic, strong) UIButton *cancelBtn;


/**
 HUD
 */
@property (nonatomic, strong) MBProgressHUD *HUD;

/**
 游戏名String
 */
@property (nonatomic, copy) NSString *gameNameString;


/**
 记录viewcontroller
 */
@property (nonatomic, strong) UIViewController *vc;



@end

@implementation SYSaveTouristInfo

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithViewController:(UIViewController *)viewController{
    self = [super init];
    if (self) {
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
        CGPoint point = CGPointMake(Screen_Width / 2, Screen_Height / 2);
        self.center = point;
        self.vc = viewController;
        [self getBasiceInfoForGame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController *)viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.vc = viewController;
        
        [self getBasiceInfoForGame];
    }
    return self;
}

- (void)getBasiceInfoForGame{
    
    Weak_Self;
    
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.vc.view animated:YES];
    self.HUD.mode = MBProgressHUDModeIndeterminate;   //选择不同类型的mode；
    _HUD.label.text = @"Loading..." ;
    
    /**
     获取游戏基本信息
     
     @param isSuccess : 成功
     @param response : 参数
     @return nil
     */
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getGameInfoCompletion:^(BOOL isSuccess, id response) {
        
        if (isSuccess) {
            
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameName = response[@"data"][@"app_name"];
            weakSelf.gameNameString = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameName;
            [weakSelf.HUD hideAnimated:YES];
            [self createTouristInfoView];
        }else{
                weakSelf.HUD.mode = MBProgressHUDModeText;
                weakSelf.HUD.label.text = @"网络异常";
                [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];
                if (self.buttonBlock) {
                    self.buttonBlock(LoadResourceError);
                }
        }
    } failure:^(NSError *error) {
        weakSelf.HUD.mode = MBProgressHUDModeText;
        weakSelf.HUD.label.text = @"网络异常";
        [weakSelf.HUD hideAnimated:YES afterDelay:1.0f];

        if (self.buttonBlock) {
            self.buttonBlock(LoadResourceError);
        }
    }];
}

- (void)showHUDForLoadDoneWithMessage:(NSString *)message{
    if (message.length > 1){
       
        
    }else{
       
        
    }
}

- (void)createTouristInfoView{
    
    
    self.backgroundColor = SYWhiteColor;
    
    [self addSubview:self.logoImageView];
    
    [self addSubview:self.gameNameLabel];
    
    [self addSubview:self.userNameLabel];
    
    [self addSubview:self.passwordLabel];
    
    [self addSubview:self.gameNameLab];
    
    [self addSubview:self.userNameLab];
    
    [self addSubview:self.passwordLab];
    
    [self addSubview:self.saveInfoBtn];
    
    [self addSubview:self.cancelBtn];
    
    [self layoutView];
}

- (void)layoutView{
    
    Weak_Self;
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(30);
        make.centerX.equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    [self.gameNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.logoImageView.mas_bottom).offset(25);
        make.left.equalTo(weakSelf).offset(40);
        make.size.mas_equalTo(CGSizeMake(85, 20));
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.gameNameLabel.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.gameNameLabel);
        make.size.mas_equalTo(CGSizeMake(55, 20));
    }];
    
    [self.passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.userNameLabel.mas_bottom).offset(20);
        make.left.equalTo(weakSelf.userNameLabel);
        make.size.equalTo(weakSelf.userNameLabel);
    }];
    
    [self.gameNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.gameNameLabel);
        make.left.equalTo(weakSelf.gameNameLabel.mas_right).offset(10);
        make.right.equalTo(weakSelf).offset(-40);
    }];
    
    [self.userNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.userNameLabel);
        make.left.equalTo(weakSelf.gameNameLab).offset(10);
        make.right.equalTo(weakSelf).offset(-40);
    }];
    
    [self.passwordLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.passwordLabel);
        make.left.equalTo(weakSelf.gameNameLab).offset(10);
        make.right.equalTo(weakSelf).offset(-40);
    }];
    
    [self.saveInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordLabel.mas_bottom).offset(25);
        make.left.equalTo(weakSelf).offset(40);
        make.size.mas_equalTo(CGSizeMake((weakSelf.width - 80 - 20) /2, 30));
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.saveInfoBtn);
        make.right.equalTo(weakSelf).offset(-40);
        make.size.equalTo(weakSelf.saveInfoBtn);
    }];
    
    
    /*
    self.userNameLab.frame = CGRectMake(12, 50, self.width - 24, 22);
    
    self.passwordLab.frame = CGRectMake(12, 87, self.width - 24, 22);
    
    self.cancelBtn.frame = CGRectMake(12, (self.passwordLab.y + self.passwordLab.height) + 15, self.passwordLab.width /2 - 10, 30);
    
    self.saveInfoBtn.frame = CGRectMake(self.cancelBtn.x + self.cancelBtn.width + 20, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
    */
}

- (void)btnClick:(UIButton *)sender{
    
    if (sender.tag == 100) {
        SYLog(@"保存图片");
        
        UIImage *screenImage = [self captureScreenForView:self];
        
        if (screenImage) {
         
            [self loadImageFinished:screenImage];
        }
    }else{
        SYLog(@"取消");
        if (self.buttonBlock) {
            self.buttonBlock(SaveCancel);
        }
        
    }
    
}

- (UIImage *)captureScreenForView:(UIView *)currentView {
    UIGraphicsBeginImageContextWithOptions(currentView.bounds.size, NO, 0.0);
    
    [currentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  viewImage;
}


- (void)loadImageFinished:(UIImage *)image
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        SYLog(@"%@", req);
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        SYLog(@"success = %d, error = %@", success, error);
        if (success) {
            if (self.buttonBlock) {
               self.buttonBlock(SaveSuccess);
            }
            

        }
        if (error) {
            
            if (self.buttonBlock) {
                self.buttonBlock(SaveFailure);
            }
            
//            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isAllow"]) {
//
//                NSString *gameName = [NSString stringWithFormat:@"%@想访问您的相册,是否允许?(设置完毕请再次点击'保存')", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameName];
//                [SSWL_PublicTool showAlertToViewController:self.vc alertControllerTitle:@"提示" alertControllerMessage:gameName alertCancelTitle:@"取消" alertReportTitle:@"去设置" cancelHandler:^(UIAlertAction * _Nonnull action) {
//
//                } reportHandler:^(UIAlertAction * _Nonnull action) {
//                    [self goToSetting];
//                } completion:^{
//
//                }];
//            }else{
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAllow"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//
//            }
           
            
           
        }
        
    }];
}


- (void)goToSetting{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark ------------------------------------------------lazy init


- (UIImageView *)logoImageView{
    
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:get_SSWL_Logo];
    }
    return _logoImageView;
}


- (UILabel *)gameNameLabel{
    
    if (!_gameNameLabel) {
        _gameNameLabel = [[UILabel alloc] init];
        _gameNameLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1];
        _gameNameLabel.textAlignment = 0;
        _gameNameLabel.font = [UIFont systemFontOfSize:16];
        _gameNameLabel.text = @"游戏名称:";
    }
    return _gameNameLabel;
}

- (UILabel *)userNameLabel{
    
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1];
        _userNameLabel.textAlignment = 0;
        _userNameLabel.font = [UIFont systemFontOfSize:16];
        _userNameLabel.text = @"账号:";
    }
    return _userNameLabel;
}

- (UILabel *)passwordLabel{
    
    if (!_passwordLabel) {
        _passwordLabel = [[UILabel alloc] init];
        _passwordLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1];
        _passwordLabel.textAlignment = 0;
        _passwordLabel.font = [UIFont systemFontOfSize:16];
        _passwordLabel.text = @"密码:";
    }
    return _passwordLabel;
}


- (UILabel *)gameNameLab{
    if (!_gameNameLab) {
        _gameNameLab = [[UILabel alloc] init];
        _gameNameLab.text = self.gameNameString;
        _gameNameLab.font = [UIFont systemFontOfSize:18];
        _gameNameLab.textAlignment = 1;
    }
    return _gameNameLab;
}

- (UILabel *)userNameLab{
    if (!_userNameLab) {
        _userNameLab = [[UILabel alloc] init];
        _userNameLab.text = [KeyChainWrapper load:SSWL_UserName_Fast];
        _userNameLab.font = [UIFont systemFontOfSize:18];
        _userNameLab.textAlignment = 1;
    }
    return _userNameLab;
}

- (UILabel *)passwordLab{
    if (!_passwordLab) {
        _passwordLab = [[UILabel alloc] init];
        _passwordLab.text = [KeyChainWrapper load:SSWL_Password_Fast];
        _passwordLab.font = [UIFont systemFontOfSize:18];
        _passwordLab.textAlignment = 1;
    }
    return _passwordLab;
}

- (UIButton *)saveInfoBtn{
    if (!_saveInfoBtn) {
        _saveInfoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_saveInfoBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveInfoBtn setTitle:@"保存" forState:UIControlStateHighlighted];
        [_saveInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_saveInfoBtn setBackgroundColor:button_Color];
        _saveInfoBtn.layer.cornerRadius = 15;
        _saveInfoBtn.layer.masksToBounds = YES;

        _saveInfoBtn.tag = 100;
        [_saveInfoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveInfoBtn;
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"关闭" forState:UIControlStateHighlighted];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_cancelBtn setBackgroundColor:code_Color];
        _cancelBtn.layer.cornerRadius = 15;
        _cancelBtn.layer.masksToBounds = YES;

        _cancelBtn.tag = 101;
        [_cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
/*
 
 [SS_PublicTool showAlertToViewController:self alertControllerTitle:nil alertControllerMessage:@"屏幕截图已保存到相册,请妥善保管" alertCancelTitle:@"好的" alertReportTitle:nil cancelHandler:^(UIAlertAction * _Nonnull action) {

 } reportHandler:nil completion:^{

 }];
 
 - (instancetype)init
 {
 self = [super init];
 if (self) {
 
 if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo] directionNumber] == 0) {
 if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel isEqualToString:@"iPhone_5"]){
 self.frame = CGRectMake(0, 0, 300, 280);
 
 }else{
 self.frame = CGRectMake(0, 0, 325, 280);
 
 }
 }else{
 if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].deviceModel isEqualToString:@"iPhone_5"]){
 self.frame = CGRectMake(0, 0, 300, 280);
 
 }else{
 self.frame = CGRectMake(0, 0, 325, 280);
 
 }
 
 }
 CGPoint point = CGPointMake(Screen_Width / 2, Screen_Height / 2);
 self.center = point;
 
 [self getBasiceInfoForGame];
 }
 return self;s
 }
 
 
 - (instancetype)initWithFrame:(CGRect)frame
 {
 self = [super initWithFrame:frame];
 if (self) {
 self.frame = frame;
 [self getBasiceInfoForGame];
 }
 return self;
 }
 */
@end
