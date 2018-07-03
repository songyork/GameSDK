//
//  AYUserManagerController.m
//  AYSDK
//
//  Created by songyan on 2017/8/28.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_UserManagerController.h"
#import "SSWL_BGView.h"
#import "SSWL_UserManager.h"
#import "SSWL_BindMobileViewController.h"
#import "SSWL_ModifyController.h"
#import "SSWL_PersonCenterWindow.h"
@interface SSWL_UserManagerController ()

@property (nonatomic ,strong) SSWL_BGView *bgView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic ,strong) UIImageView *logoImgView;

@property (nonatomic ,strong) UIButton *modifyPassword;

@property (nonatomic ,strong) UIButton *bindPhone;

@property (nonatomic ,strong) UIButton *signOut;

@property (nonatomic ,strong) UIButton *backBtn;

@property (nonatomic, assign) BOOL showMHud;

@property (nonatomic, assign) BOOL showBHud;

@property (nonatomic ,strong) SSWL_PersonCenterWindow *personCenterW;


/**
 * When I wrote this, only God and I understood what I was doing
 * Now, God only knows
 */


@end

@implementation SSWL_UserManagerController

/**
 *                                         ,s555SB@@&
 *                                      :9H####@@@@@Xi
 *                                     1@@@@@@@@@@@@@@8
 *                                   ,8@@@@@@@@@B@@@@@@8
 *                                  :B@@@@X3hi8Bs;B@@@@@Ah,
 *             ,8i                  r@@@B:     1S ,M@@@@@@#8;
 *            1AB35.i:               X@@8 .   SGhr ,A@@@@@@@@S
 *            1@h31MX8                18Hhh3i .i3r ,A@@@@@@@@@5
 *            ;@&i,58r5                 rGSS:     :B@@@@@@@@@@A
 *             1#i  . 9i                 hX.  .: .5@@@@@@@@@@@1
 *              sG1,  ,G53s.              9#Xi;hS5 3B@@@@@@@B1
 *               .h8h.,A@@@MXSs,           #@H1:    3ssSSX@1
 *               s ,@@@@@@@@@@@@Xhi,       r#@@X1s9M8    .GA981
 *               ,. rS8H#@@@@@@@@@@#HG51;.  .h31i;9@r    .8@@@@BS;i;
 *                .19AXXXAB@@@@@@@@@@@@@@#MHXG893hrX#XGGXM@@@@@@@@@@MS
 *                s@@MM@@@hsX#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&,
 *              :GB@#3G@@Brs ,1GM@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@B,
 *            .hM@@@#@@#MX 51  r;iSGAM@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8
 *          :3B@@@@@@@@@@@&9@h :Gs   .;sSXH@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:
 *      s&HA#@@@@@@@@@@@@@@M89A;.8S.       ,r3@@@@@@@@@@@@@@@@@@@@@@@@@@@r
 *   ,13B@@@@@@@@@@@@@@@@@@@5 5B3 ;.         ;@@@@@@@@@@@@@@@@@@@@@@@@@@@i
 *  5#@@#&@@@@@@@@@@@@@@@@@@9  .39:          ;@@@@@@@@@@@@@@@@@@@@@@@@@@@;
 *  9@@@X:MM@@@@@@@@@@@@@@@#;    ;31.         H@@@@@@@@@@@@@@@@@@@@@@@@@@:
 *   SH#@B9.rM@@@@@@@@@@@@@B       :.         3@@@@@@@@@@@@@@@@@@@@@@@@@@5
 *     ,:.   9@@@@@@@@@@@#HB5                 .M@@@@@@@@@@@@@@@@@@@@@@@@@B
 *           ,ssirhSM@&1;i19911i,.             s@@@@@@@@@@@@@@@@@@@@@@@@@@S
 *              ,,,rHAri1h1rh&@#353Sh:          8@@@@@@@@@@@@@@@@@@@@@@@@@#:
 *            .A3hH@#5S553&@@#h   i:i9S          #@@@@@@@@@@@@@@@@@@@@@@@@@A.
 *
 *
 *    疼不疼!
 */





- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bgView];
    [self craeteUI];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)craeteUI{
    
    
    [self.bgView addSubview:self.logoImgView];
    
    [self.bgView addSubview:self.backBtn];
    
    [self.bgView addSubview:self.modifyPassword];

    if (![[SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser isEqualToString:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber]){
        [self.bgView addSubview:self.bindPhone];

    }
    
    
    
    [self.bgView addSubview:self.signOut];
    
    
    [self bgViewLayoutSubView];
    
}



- (void)bgViewLayoutSubView{
    
    Weak_Self;
    
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bgView).offset(25);
        //        make.left.equalTo(weakSelf.BGView).offset(120);
        //        make.right.equalTo(weakSelf.BGView).offset(-120);
        make.centerX.equalTo(weakSelf.bgView);
        make.size.mas_equalTo(CGSizeMake(150, 30));
        //        make.height.mas_equalTo(30);
    }];
    

    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.bgView).offset(20);
        make.centerY.equalTo(weakSelf.logoImgView).offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    
    
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5S"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5C"] || [[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_5"]) {
        
        
        [self.modifyPassword mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(27);
            make.left.equalTo(weakSelf.bgView).offset(20);
            make.right.equalTo(weakSelf.bgView).offset(-20);
            make.height.mas_equalTo(30);
        }];
        
        
        
        
    }else{
        [self.modifyPassword mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.logoImgView.mas_bottom).offset(27);
            make.left.equalTo(weakSelf.bgView).offset(41);
            make.right.equalTo(weakSelf.bgView).offset(-41);
            make.height.mas_equalTo(30);
        }];
        
        
        
    }
    
    if (![[SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser isEqualToString:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber]){
        
        [self.bindPhone mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.modifyPassword.mas_bottom).offset(20);
            make.left.and.right.equalTo(weakSelf.modifyPassword);
            make.height.mas_equalTo(30);
        }];
        [self.signOut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.bindPhone.mas_bottom).offset(46);
            make.left.and.right.equalTo(weakSelf.modifyPassword);
            
            make.height.mas_equalTo(30);
        }];
    }else{
     
        [self.signOut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.modifyPassword.mas_bottom).offset(46);
            make.left.and.right.equalTo(weakSelf.modifyPassword);
            make.height.mas_equalTo(30);
        }];
    }
    
   
  
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.showMHud) {
        [self showHUDWithText:@"修改成功"];
        self.showMHud = NO;
    }
    if (self.showBHud) {
        [self showHUDWithText:@"绑定成功"];
        self.showBHud = NO;
    }
}

- (void)showHUDWithText:(NSString *)text{
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.label.text = text;
    [self.HUD hideAnimated:YES afterDelay:1];
    //    self.HUD.hidden = YES;
    //    [self.HUD removeFromSuperview];
    //    self.HUD = nil;
    
}

#pragma mark ----------------------------------------------Click

- (void)modify:(id)sender{
    Weak_Self;
    SYLog(@"-----------修改密码");

    SSWL_ModifyController *mVC = [[SSWL_ModifyController alloc] init];
    mVC.HudHiddenBlock = ^(BOOL isShow) {
        weakSelf.showMHud = isShow;
    };
    [self.navigationController pushViewController:mVC animated:YES];
}

- (void)bind:(id)sender{
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone) {
        SYLog(@"-----------改绑手机");

        [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] changeBindMobilPhone];
    }else{
        Weak_Self;
        SYLog(@"-----------绑定手机");

        SSWL_BindMobileViewController *bindVC = [[SSWL_BindMobileViewController alloc] init];
        bindVC.HudHiddenBlock = ^(BOOL isShow) {
            weakSelf.showBHud = isShow;
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = isShow;
            [weakSelf.bindPhone setTitle:@"改绑手机" forState:UIControlStateNormal];
            [weakSelf.bindPhone setTitle:@"改绑手机" forState:UIControlStateHighlighted];
        };
        [self.navigationController pushViewController:bindVC animated:YES];

    }

}

- (void)signOutClick:(id)sender{
    SYLog(@"-----------退出登录");
    Weak_Self;
    [SSWL_PublicTool showAlertToViewController:self alertControllerTitle:@"提示" alertControllerMessage:@"是否退出游戏" alertCancelTitle:@"取消" alertReportTitle:@"是的" cancelHandler:nil reportHandler:^(UIAlertAction * _Nonnull action) {
        [weakSelf SignOutGame];
    } completion:nil];
    
 
}



- (void)backClick{
    SYLog(@"-----------返回");
    if (self.block) {
        self.block();
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
    }];

}


- (void)SignOutGame{
    if (self.block) {
        self.block();
    }
    
    /**
     * 注册通知,退出时发送通知
     */
    NSDictionary *dic = @{
                          @"isOut" : @YES,
                          };
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:SSWL_SignOutGame object:@"isOut" userInfo:dic];
    //    [center postNotificationName:@"signOutGame" object:@"yes"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] destroyFloatWindow];
    }];
}

#pragma mark ----------------------------------------------懒加载



- (UIButton *)backBtn{
    if (!_backBtn) {        
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //         _backBtn.backgroundColor = [UIColor redColor];
//        [_backBtn setTitle:@" 返回" forState:UIControlStateNormal];
//        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn setImage:get_BundleImage(@"back") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _backBtn;
}

- (UIButton *)signOut{
    if (!_signOut) {
        _signOut = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_signOut setBackgroundImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"an_z1" withType:@"png"] forState:UIControlStateNormal];
//        [_signOut setBackgroundImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"an_z2" withType:@"png"] forState:UIControlStateHighlighted];
        
        [_signOut setBackgroundColor:button_Color];
        _signOut.layer.cornerRadius = 15;
        _signOut.layer.masksToBounds = YES;
        
        [_signOut setTitle:@"退出登录" forState:UIControlStateNormal];
        [_signOut setTitle:@"退出登录" forState:UIControlStateHighlighted];
            
       
        
        [_signOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signOut setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_signOut addTarget:self action:@selector(signOutClick:) forControlEvents:UIControlEventTouchUpInside];
        _signOut.tag = 1002;
    }
    return _signOut;
}


- (UIButton *)bindPhone{
    if (!_bindPhone) {
        _bindPhone = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_bindPhone setBackgroundImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"an_z1" withType:@"png"] forState:UIControlStateNormal];
//        [_bindPhone setBackgroundImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"an_z2" withType:@"png"] forState:UIControlStateHighlighted];
        [_bindPhone setBackgroundColor:button_Color];
        _bindPhone.layer.cornerRadius = 15;
        _bindPhone.layer.masksToBounds = YES;
        /**
         * 更换button的边框颜色...
         * 这里用不到,就是无聊了.
         * 写着好玩
         *
         */
//        _bindPhone.layer.borderColor = [UIColor cyanColor].CGColor;
        
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone) {
            [_bindPhone setTitle:@"改绑手机" forState:UIControlStateNormal];
            [_bindPhone setTitle:@"改绑手机" forState:UIControlStateHighlighted];

        }else{
            [_bindPhone setTitle:@"绑定手机" forState:UIControlStateNormal];
            [_bindPhone setTitle:@"绑定手机" forState:UIControlStateHighlighted];

        }
        
        
        
        [_bindPhone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bindPhone setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_bindPhone addTarget:self action:@selector(bind:) forControlEvents:UIControlEventTouchUpInside];
        _bindPhone.tag = 1001;
    }
    return _bindPhone;
}



- (UIButton *)modifyPassword{
    if (!_modifyPassword) {
        _modifyPassword = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_modifyPassword setBackgroundImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"an_z1" withType:@"png"] forState:UIControlStateNormal];
//        [_modifyPassword setBackgroundImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"an_z2" withType:@"png"] forState:UIControlStateHighlighted];
        
        [_modifyPassword setBackgroundColor:button_Color];
        _modifyPassword.layer.cornerRadius = 15;
        _modifyPassword.layer.masksToBounds = YES;

        
        [_modifyPassword setTitle:@"修改密码" forState:UIControlStateNormal];
        [_modifyPassword setTitle:@"修改密码" forState:UIControlStateHighlighted];
            
        
        
        [_modifyPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_modifyPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_modifyPassword addTarget:self action:@selector(modify:) forControlEvents:UIControlEventTouchUpInside];
        _modifyPassword.tag = 1000;
    }
    return _modifyPassword;
}



- (UIImageView *)logoImgView{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] init];
        
        
        [_logoImgView setImage:get_SSWL_Logo];
            
       
    }
    return _logoImgView;
}



- (SSWL_BGView *)bgView{
    if (!_bgView) {
        _bgView = [[SSWL_BGView alloc] initWithShowImage:NO showBGView:NO];
        _bgView.backgroundColor = [UIColor whiteColor];
        if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser isEqualToString:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber]) {
            _bgView.height -= 50;
        }
    }
    return _bgView;
}



/**
 *          .,:,,,                                        .::,,,::.
 *        .::::,,;;,                                  .,;;:,,....:i:
 *        :i,.::::,;i:.      ....,,:::::::::,....   .;i:,.  ......;i.
 *        :;..:::;::::i;,,:::;:,,,,,,,,,,..,.,,:::iri:. .,:irsr:,.;i.
 *        ;;..,::::;;;;ri,,,.                    ..,,:;s1s1ssrr;,.;r,
 *        :;. ,::;ii;:,     . ...................     .;iirri;;;,,;i,
 *        ,i. .;ri:.   ... ............................  .,,:;:,,,;i:
 *        :s,.;r:... ....................................... .::;::s;
 *        ,1r::. .............,,,.,,:,,........................,;iir;
 *        ,s;...........     ..::.,;:,,.          ...............,;1s
 *       :i,..,.              .,:,,::,.          .......... .......;1,
 *      ir,....:rrssr;:,       ,,.,::.     .r5S9989398G95hr;. ....,.:s,
 *     ;r,..,s9855513XHAG3i   .,,,,,,,.  ,S931,.,,.;s;s&BHHA8s.,..,..:r:
 *    :r;..rGGh,  :SAG;;G@BS:.,,,,,,,,,.r83:      hHH1sXMBHHHM3..,,,,.ir.
 *   ,si,.1GS,   sBMAAX&MBMB5,,,,,,:,,.:&8       3@HXHBMBHBBH#X,.,,,,,,rr
 *   ;1:,,SH:   .A@&&B#&8H#BS,,,,,,,,,.,5XS,     3@MHABM&59M#As..,,,,:,is,
 *  .rr,,,;9&1   hBHHBB&8AMGr,,,,,,,,,,,:h&&9s;   r9&BMHBHMB9:  . .,,,,;ri.
 *  :1:....:5&XSi;r8BMBHHA9r:,......,,,,:ii19GG88899XHHH&GSr.      ...,:rs.
 *  ;s.     .:sS8G8GG889hi.        ....,,:;:,.:irssrriii:,.        ...,,i1,
 *  ;1,         ..,....,,isssi;,        .,,.                      ....,.i1,
 *  ;h:               i9HHBMBBHAX9:         .                     ...,,,rs,
 *  ,1i..            :A#MBBBBMHB##s                             ....,,,;si.
 *  .r1,..        ,..;3BMBBBHBB#Bh.     ..                    ....,,,,,i1;
 *   :h;..       .,..;,1XBMMMMBXs,.,, .. :: ,.               ....,,,,,,ss.
 *    ih: ..    .;;;, ;;:s58A3i,..    ,. ,.:,,.             ...,,,,,:,s1,
 *    .s1,....   .,;sh,  ,iSAXs;.    ,.  ,,.i85            ...,,,,,,:i1;
 *     .rh: ...     rXG9XBBM#M#MHAX3hss13&&HHXr         .....,,,,,,,ih;
 *      .s5: .....    i598X&&A&AAAAAA&XG851r:       ........,,,,:,,sh;
 *      . ihr, ...  .         ..                    ........,,,,,;11:.
 *         ,s1i. ...  ..,,,..,,,.,,.,,.,..       ........,,.,,.;s5i.
 *          .:s1r,......................       ..............;shs,
 *          . .:shr:.  ....                 ..............,ishs.
 *              .,issr;,... ...........................,is1s;.
 *                 .,is1si;:,....................,:;ir1sr;,
 *                    ..:isssssrrii;::::::;;iirsssssr;:..
 *                         .,::iiirsssssssssrri;;:.
 */


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
