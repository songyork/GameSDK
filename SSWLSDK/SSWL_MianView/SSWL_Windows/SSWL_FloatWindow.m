//
//  SSWL_FloatWindow.m
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_FloatWindow.h"
#import "SSWL_FloatViewNavController.h"

@interface SSWL_FloatWindow ()
/* *rootViewController */
@property (nonatomic, strong)UIViewController *floatRootVC;
/* *悬浮窗按钮 */
@property (nonatomic ,strong) UIButton *mainBtn;
/* *是否展开悬浮窗 */
@property (nonatomic, assign) BOOL isShowDetail;

/* *初始位置 */
@property (nonatomic, assign) CGRect startFrame;

/* *btn宽度 */
@property (nonatomic, assign) NSInteger btnWidth;//

/* *点击btn展示详情 */
@property (nonatomic ,strong) UIImageView *contentView;

/* *详情页标题 */
@property (nonatomic ,strong) NSDictionary *titleDict;

/* *详情页图标 */
@property (nonatomic ,strong) NSArray *titleArr;

/* *详情页图标name */
@property (nonatomic ,strong) NSArray *titileNameArr;

/* *详情每个按钮的tag值 */
@property (nonatomic, assign) int btnTag;

/* *移动手势 */
@property (nonatomic ,strong) UIPanGestureRecognizer *moveGesture;

/* *重力感应 */
@property (nonatomic ,strong) CMMotionManager *montionManager;

//@property (nonatomic, assign) NSTimeInterval gyroUpdateInterval;

/* *Z轴方向的偏移量 */
@property (nonatomic, assign) double accz;

/* *隐藏悬浮窗 */
@property(nonatomic,assign)BOOL isHide;

/* *动画 */
@property(nonatomic,strong)CAAnimationGroup *animationGroup;

/* *动画方式 */
@property(nonatomic,strong)CAShapeLayer *circleShape;

/* *动画颜色 */
@property(nonatomic,strong)UIColor *animationColor;

/* *悬浮按钮图片 */
@property(nonatomic,strong)NSString *backImgName;


//@property (nonatomic ,strong) UIImageView *btnCentImg;

/* *记录mianBtn位移前的X */
@property (nonatomic, assign) double orginX;

/* *停留时间 */
@property (nonatomic, strong)dispatch_source_t stayTime;

/* *停留时间计数器 */
@property (nonatomic, assign) int stayNum;

/* *btnX */
@property (nonatomic, assign) double mainBtnX;

/* *btnY */
@property (nonatomic, assign) double mainBtnY;

/* *未读公告小红点 */
@property (nonatomic, strong) UIImageView *redPointView;

/* *rootView */
@property (nonatomic, strong) UIView *rootView;

@end

@implementation SSWL_FloatWindow

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame mainImageName:(NSString *)imgName titleArr:(NSArray *)titleArr startBtnTag:(int)btnTag animationColor:(UIColor *)color{
    if (self = [super initWithFrame:frame]) {
        //初始化属性
        _backImgName = imgName;
        _startFrame = frame;
        _btnWidth = frame.size.width;
        if (frame.size.width > 60) {
            _btnWidth = 50;
            _startFrame.size.width = 60;
            _startFrame.size.height = 60;
            
        }else if (frame.size.width == 0){
            _btnWidth = 0;
            _startFrame.size.width = 0;
            _startFrame.size.height = 0;
            
        }else{
            _btnWidth = 50;
            
        }
        //        _titleDict = titleDict;
        _titleArr = titleArr;
        _btnTag = btnTag;
        _animationColor = color;
        
        _isShowDetail = NO;
        _isHide = NO;
        self.titileNameArr = @[@"账号", @"礼包", @"客服", @"公告", @"安全令牌", @""];
        
        //UI
        self.backgroundColor = [UIColor clearColor];
        self.floatRootVC = [[UIViewController alloc] init];
        self.rootViewController = [[SSWL_FloatViewNavController alloc] initWithRootViewController:self.floatRootVC];
        self.rootViewController.view.backgroundColor = [UIColor clearColor];
        self.windowLevel = 0.9;
        self.alpha = 0.85;
        self.layer.cornerRadius = 26;
        self.layer.masksToBounds = YES;
        //        self.layer.borderColor = [UIColor colorWithRed:0.94 green:0.61 blue:0.30 alpha:1.00].CGColor;
        //        self.layer.borderWidth = 1;
        [self makeKeyAndVisible];
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl.length < 1) {
            [SSWL_PublicTool mainWindowAddSubViewWindow:self];
        }
        
        _mainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (_btnWidth == 0) {
            _mainBtn.frame = CGRectMake(0, 0, 0, 0);
        }else{
            _mainBtn.frame = CGRectMake(0, 0, 44, 50);
        }
        [_mainBtn setBackgroundColor:SYNOColor];
        
        [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
        [_mainBtn addTarget:self action:@selector(mainBtnClick) forControlEvents:UIControlEventTouchUpInside];
        if (_animationColor) {
            //7---添加长按雷达效果；
            //            [_mainBtn addTarget:self action:@selector(mainBtnTouchDown) forControlEvents:UIControlEventTouchDown];
        }
        //        Weak_Self;
        self.rootView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        
        
        _contentView = [UIImageView new];
        [_contentView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"bg_xf" withType:@"png"]];
        _contentView.userInteractionEnabled = YES;
        _contentView.frame = CGRectMake(8, (self.rootViewController.view.height - 40) / 2 +1, _btnWidth + _titleArr.count + 20, 40);
        
        _contentView.centerY = self.rootView.centerY + 5;
        [self.rootViewController.view addSubview:_contentView];
        _contentView.hidden = YES;
        
        
        [self.rootViewController.view addSubview:self.rootView];
        [self.rootView addSubview:self.mainBtn];
        self.mainBtn.center = self.rootView.center;
        //        _contentView.centerY = self.mainBtn.centerY;
        
        
        //1---给contentView添加按钮
        [self setContentViewBtns];
        
        //2---添加手势
        _moveGesture = [[UIPanGestureRecognizer alloc] init];
        [_moveGesture addTarget:self action:@selector(locationChange:)];
        _moveGesture.delaysTouchesBegan = YES;
        [self addGestureRecognizer:_moveGesture];
        
        //3---设备旋转的时候收回详情界面
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        //4---添加翻转隐藏悬浮窗；
        //开启陀螺仪感应器；
        //重力感应的设置
        //        [self accelerotionDataMethod];
        
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
        /**
         获取游戏基本信息
         
         @param isSuccess : 成功
         @param response : 参数
         @return nil
         */
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getGameInfoCompletion:^(BOOL isSuccess, id response) {
            if (isSuccess) {
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID = response[@"bbs_fid"];
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameName = response[@"app_name"];
            }else{
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID = @"0";
            }
        } failure:^(NSError *error) {
            
        }];
        
    }
    
    return self;
}

#pragma mark --- 1---给contentView添加按钮
-(void)setContentViewBtns
{
    int i = 0;
    for (NSString *key in _titleArr)
    {
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        UIImageView *img = [[UIImageView alloc] init];
        
        btn.frame = CGRectMake(i*(_btnWidth) + _btnWidth, 0, _btnWidth -25, _contentView.height);
        
        
        [btn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:key withType:@"png"] forState:UIControlStateNormal];
        //        btn.centerY = _contentView.centerY;
        btn.tag = _btnTag;
        
        // 则默认image在左，title在右
        // 改成image在上，title在下
        btn.titleEdgeInsets = UIEdgeInsetsMake(-10.0 , -[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:key withType:@"png"].size.width, -30.0, 0.0);
        
        btn.imageEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 17.0, -btn.titleLabel.width+6.0);
        btn.titleLabel.font = [UIFont systemFontOfSize: self.btnWidth/5];
        [btn setTitleColor:[UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1] forState:UIControlStateHighlighted];
        
        if (self.titleArr.count < 6) {
            if (i == 4) {
                //                btn.titleLabel.hidden = YES;
            }else{
                [btn setTitle:self.titileNameArr[i] forState:UIControlStateNormal];
                
            }
        }else{
            [btn setTitle:self.titileNameArr[i] forState:UIControlStateNormal];
            
        }
        
        
        [btn addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:btn];
        
        UIImageView *lineImageView = [[UIImageView alloc] init];
        [lineImageView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"xian" withType:@"png"]];
        lineImageView.frame = CGRectMake(i*(_btnWidth) + _btnWidth + btn.width + 12.5, (_contentView.height - (_contentView.height - 10)) / 2, 1, _contentView.height - 10);
        [_contentView addSubview:lineImageView];
        i++;
        _btnTag++;
        if (_btnTag == 101) {
            btn.imageEdgeInsets = UIEdgeInsetsMake(5.0, 3.0, 17.0, -btn.titleLabel.width+4.5);
            
        }
        if (_btnTag == 102) {
            btn.imageEdgeInsets = UIEdgeInsetsMake(5.0, 3.0, 17.0, -btn.titleLabel.width+4.5);
            
        }
        if (_btnTag == 104) {
            [btn addSubview:self.redPointView];
            [self.redPointView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(btn.mas_right).offset(-5);
                make.centerY.equalTo(btn.mas_top).offset(5);
                make.size.mas_equalTo(CGSizeMake(10, 10));
            }];
        }
        if (_btnTag == 105) {
            
            
            if (_titleArr.count < 6) {
                _contentView.frame = CGRectMake(8, (self.rootViewController.view.height - 40) / 2 +1, btn.x + btn.width + 20, 40);
                
                _contentView.centerY = self.rootView.centerY + 5;
                btn.frame = CGRectMake(btn.x, 0, 25, 25);
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                btn.centerY = _contentView.height / 2;
                lineImageView.frame = CGRectZero;
                lineImageView.hidden = YES;
            }else{
                btn.frame = CGRectMake(btn.x, 0, _contentView.height, _contentView.height);
                btn.titleEdgeInsets = UIEdgeInsetsMake(-5.0 , -[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:key withType:@"png"].size.width -5.0, -25.0, -5.0);
                btn.imageEdgeInsets = UIEdgeInsetsMake(4.0, 10.0, 16.0, -btn.titleLabel.width+10.0);
                lineImageView.frame = CGRectZero;
                lineImageView.hidden = YES;
            }
        }
        if (_btnTag == 106) {
            _contentView.frame = CGRectMake(8, (self.rootViewController.view.height - 40) / 2 +1, btn.x + btn.width + 20, 40);
            
            _contentView.centerY = self.rootView.centerY + 5;
            btn.frame = CGRectMake(btn.x, 0, 25, 25);
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            btn.centerY = _contentView.height / 2;
            lineImageView.frame = CGRectZero;
            lineImageView.hidden = YES;
            
        }
        
        
        
    }
}


#pragma mark --- 2---添加手势
-(void)locationChange:(UIPanGestureRecognizer *)p
{
    //获取移动的中心点坐标
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication].windows firstObject]];
    if(p.state == UIGestureRecognizerStateBegan)
    {
        [UIView animateWithDuration:0.3f animations:^{
            _mainBtn.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        } completion:^(BOOL finished) {
            _mainBtn.alpha = 1.0f;
        }];
        
        
        if (self.stayTime) {
            dispatch_source_cancel(_stayTime);
            
        }
        /*
         if (self.time) {
         dispatch_source_cancel(_time);
         
         }
         */
        self.rootView.frame = CGRectMake(0, 0, self.rootView.width, self.rootView.height);
        _mainBtn.center = self.rootView.center;
        
    }
    else if (p.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [p velocityInView:[[UIApplication sharedApplication].windows firstObject]];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 300;
        float slideFactor = 0.1 * slideMult;
        //        NSLog(@"%f  %f  %f  %f  %f",panPoint.x,panPoint.y,velocity.x,velocity.y,slideMult);
        CGPoint finalPoint = CGPointMake(p.view.center.x + (velocity.x * slideFactor),
                                         p.view.center.y + (velocity.y * slideFactor));
        
        if (!_isShowDetail)
        {
            //限制下最小、最大坐标，防止停靠在角落；
            finalPoint.x = MIN(MAX(finalPoint.x, 25), [[UIApplication sharedApplication].windows firstObject].bounds.size.width-25);
            finalPoint.y = MIN(MAX(finalPoint.y, 70), [[UIApplication sharedApplication].windows firstObject].bounds.size.height-70);
            
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                p.view.center = finalPoint;
                if (self.center.x == 25)
                {
                    [self performSelector:@selector(hideLeftFloat) withObject:nil afterDelay:0.3];
                    
                    
                }else if(self.center.x == [[UIApplication sharedApplication].windows firstObject].bounds.size.width-25)
                {
                    [self performSelector:@selector(hideRightFloat) withObject:nil afterDelay:0.3];
                }
                
            } completion:nil];
        }else
        {
            //限制下最小、最大坐标，防止停靠在角落；
            finalPoint.x = MIN(MAX(finalPoint.x, (_btnWidth+(5+_btnWidth)*_titleArr.count)/2), [[UIApplication sharedApplication].windows firstObject].bounds.size.width-(_btnWidth+(5+_btnWidth)*_titleArr.count)/2);
            finalPoint.y = MIN(MAX(finalPoint.y, 70), [[UIApplication sharedApplication].windows firstObject].bounds.size.height-70);
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                p.view.center = finalPoint;
            } completion:nil];
        }
    }
    else if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x, panPoint.y);
        
        if (self.center.x >25)
        {
            
            _mainBtn.frame = CGRectMake(0, 0, 45, 50);
            _mainBtn.center = self.rootView.center;
            
            //            _mainBtn.frame = CGRectMake(0, 0, 50, 50);
            if (_isShowDetail) {
                [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
                
            }else{
                [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
                
            }
        }else if(self.center.x < [[UIApplication sharedApplication].windows firstObject].bounds.size.width-25)
        {
            //            _mainBtn.frame = CGRectMake(0, 0, 50, 50);
            _mainBtn.frame = CGRectMake(0, 0, self.rootView.width - 13, self.rootView.height - 8);
            _mainBtn.center = self.rootView.center;
            if (_isShowDetail) {
                [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
                
            }else{
                [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
                
            }
        }
    }
}

-(void)hideLeftFloat
{
    
    [UIView animateWithDuration:0.5f animations:^{
        self.center = CGPointMake(-5, self.center.y);
        _mainBtn.center = self.rootView.center;
        
        //        _mainBtn.frame = CGRectMake(30, 0, 20, 50);
        //            [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"left_float" withType:@"png"] forState:UIControlStateNormal];
        [self animationForView:_mainBtn aroundToLeft:YES];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
    
    //    [UIView animateWithDuration:0.6 animations:^{
    //        self.center = CGPointMake(-50, self.center.y);
    //    } completion:^(BOOL finished) {
    //            }];
}

-(void)hideRightFloat
{
    [UIView animateWithDuration:0.5 animations:^{
        self.center = CGPointMake([[UIApplication sharedApplication].windows firstObject].bounds.size.width+5, self.center.y);
        _mainBtn.center = self.rootView.center;
        
        //        _mainBtn.frame = CGRectMake(0, 0, 20, 50);
        //            [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"right_float" withType:@"png"] forState:UIControlStateNormal];
        [self animationForView:_mainBtn aroundToLeft:NO];
        
    } completion:^(BOOL finished) {
        
    }];
    
    
    //    [UIView animateWithDuration:0.6 animations:^{
    //        self.center = CGPointMake([[UIApplication sharedApplication].windows firstObject].bounds.size.width+50, self.center.y);
    //    } completion:^(BOOL finished) {
    //            }];
}

- (void)animationForView:(UIButton *)view aroundToLeft:(BOOL)aroundToLeft{
    
    //    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    //    animation.fromValue = [NSNumber numberWithFloat: M_PI *0.5];
    //    animation.toValue =  [NSNumber numberWithFloat:0.f];
    //    animation.duration  = 0.5;
    //    animation.autoreverses = NO;
    //    animation.fillMode =kCAFillModeForwards;
    //    animation.repeatCount = 1; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    //    [view.layer addAnimation:animation forKey:nil];
    
    if (aroundToLeft) {
        view.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
    }else{
        view.transform =  CGAffineTransformMakeRotation(-90 * M_PI/180);
    }
    
    view.alpha = 0.7f;
    
    self.isHide = YES;
}


#pragma mark --- 3---设备旋转的时候收回详情界面
-(void)orientChange:(NSNotification *)notification
{
    _isShowDetail = NO;
    self.frame = CGRectMake(self.startFrame.origin.x, self.startFrame.origin.y, self.width, self.height);
//    self.rootView.frame = CGRectMake(0, 0, self.rootView.width, self.rootView.height);
//    //    _mainBtn.frame = self.frame;
//    //    self.rootView.centerY = _btnWidth / 2;
//    _mainBtn.frame = CGRectMake(0, 0, 45, 50);
//    _mainBtn.center = self.rootView.center;
//    [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
    _mainBtn.alpha = 1.f;
    _mainBtn.transform =  CGAffineTransformMakeRotation(0*M_PI/180);

    
    //判断屏幕方向
    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
    if ((int)duration == 1) {
        //竖屏
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0) {
            [self removeGestureRecognizer:_moveGesture];
        }else if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1){
            [self addGestureRecognizer:_moveGesture];
        }
    }else if ((int)duration == 2){
        //倒立竖屏
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0) {
            [self removeGestureRecognizer:_moveGesture];
        }else if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1){
            [self addGestureRecognizer:_moveGesture];
        }
    }else if ((int)duration == 3){
        //left:home键在右
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0) {
            [self addGestureRecognizer:_moveGesture];
        }else if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1){
            [self removeGestureRecognizer:_moveGesture];
        }
    }else if ((int)duration == 4){
        //right:home键在左
        if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0) {
            [self addGestureRecognizer:_moveGesture];
        }else if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1){
            [self removeGestureRecognizer:_moveGesture];
        }
    }
}


#pragma mark --- 5---点击主窗口浮标
-(void)mainBtnClick
{
    _isShowDetail = !_isShowDetail;
    _mainBtn.enabled = NO;
    if (self.center.x == Screen_Width+5)
    {
        
        [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
        float x = self.x - (self.btnWidth-20); //- (5+_btnWidth)*_titleDict.count;
        //_btnWidth+(5+_btnWidth)*_titleArr.count
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(x, self.y, self.rootView.width, self.rootView.height);
            
            
            _mainBtn.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
            _isShowDetail = NO;
            _orginX = x;
            _mainBtnX = x;
            _mainBtnY = self.y;
        } completion:^(BOOL finished) {
            _mainBtn.alpha = 1.0f;
            _mainBtn.frame = CGRectMake(0, 0, 45, 50);
            _mainBtn.center = self.rootView.center;
        }];
        //        [self timeForHiddenLOrR:1];
        [self stayTime5S];
        
    }
    if (self.center.x == -5) {
        
        
        [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
        float x = self.x + (self.btnWidth-20);
        
        [UIView animateWithDuration:0.5 animations:^{
            //60+(6+60)*_titleArr.count
            self.frame = CGRectMake(x, self.y, 60, 60);
            
            _mainBtn.transform =  CGAffineTransformMakeRotation(0*M_PI/180);
            
            _isShowDetail = NO;
            _orginX = x;
            _mainBtnX = x;
            _mainBtnY = self.y;
        } completion:^(BOOL finished) {
            _mainBtn.alpha = 1.0f;
            _mainBtn.frame = CGRectMake(0, 0, 45, 50);
            _mainBtn.center = self.rootView.center;
        }];
        
        //        [self timeForHiddenLOrR:0];
        
        [self stayTime5S];
        
    }
    
    
    
    if (_isShowDetail)
    {
        
        
        [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] checkGameNoticeCompletion:^(BOOL isSuccess, id respones) {
            if (isSuccess) {
                NSString *pointType = respones[@"data"][@"type"];
                
                SYLog(@"%@", pointType);
                if ([pointType boolValue]) {
                    self.redPointView.hidden = NO;
                }else{
                    self.redPointView.hidden = YES;
                }
            }else{
                
            }
        } failure:^(NSError *error) {
            
        }];
        
        _contentView.hidden = NO;
        
        if (self.stayTime) {
            dispatch_source_cancel(_stayTime);
            
        }
        
        
        [UIView animateWithDuration:0.5 animations:^{
            _orginX = self.x;
            if ((self.x + (_btnWidth + (5+_btnWidth)*_titleArr.count)) > Screen_Width) {
                self.frame = CGRectMake(Screen_Width - (_btnWidth+(5+_btnWidth)*_titleArr.count), self.y, _btnWidth+(5+_btnWidth)*_titleArr.count, 60);
                self.rootView.centerY = _btnWidth / 2 + 5;
                
            }else{
                self.frame = CGRectMake(self.x, self.y, _btnWidth+(5+_btnWidth)*_titleArr.count, 60);
                self.rootView.centerY = _btnWidth / 2 + 5;
            }
            
        }];
    }else
    {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
            self.frame = CGRectMake(_orginX, self.y, 60, 60);
            self.rootView.centerY = self.height / 2;
            //            _mainBtn.centerY = _btnWidth / 2;
        } completion:^(BOOL finished) {
            _contentView.hidden = YES;
            [_mainBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:_backImgName withType:@"png"] forState:UIControlStateNormal];
        }];
        [self stayTime5S];
    }
    _mainBtn.enabled = YES;
    
}

#pragma mark --- 6、回调方法
-(void)itemsClick:(id)sender
{
    [self mainBtnClick];
    UIButton *btn = (UIButton *)sender;
    
    self.backBlock(btn.tag);
}


#pragma mark --- 7、悬浮窗旋转方向
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)stayTime5S{
    Weak_Self;
    self.stayNum = 0;
    //获得队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //创建一个定时器
    self.stayTime = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    //设置时间间隔
    uint64_t interval = (uint64_t)(1.0* NSEC_PER_SEC);
    //设置定时器
    dispatch_source_set_timer(self.stayTime, start, interval, 0);
    
    //设置回调
    dispatch_source_set_event_handler(self.stayTime, ^{
        
        _stayNum++;
        SYLog(@"%d", _stayNum);
        
        if (_stayNum == 5) {
            if (!_isShowDetail) {
                dispatch_source_cancel(_stayTime);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (_mainBtnX < (Screen_Width / 2)) {
                        [weakSelf hideLeftFloat];
                    }else if (_mainBtnX >= (Screen_Width / 2)){
                        [weakSelf hideRightFloat];
                    }
                    
                    
                });
            }
            _stayNum = 0;
            _stayTime = nil; // 将 dispatch_source_t 置为nil
            
        }
        
        
        
        
    });
    
    
    //由于定时器默认是暂停的所以我们启动一下
    //启动定时器
    dispatch_resume(self.stayTime);
    
}

- (void)stopTiming{
    
    if (self.stayTime) {
        dispatch_source_cancel(self.stayTime);
        SYLog(@"--------定时器已取消--------");
    }
    
}

- (void)logSomething{
    SYLog(@"........");
}


- (void)stopTimeFotLOR:(int)lOR{
    //    dispatch_source_cancel(_time);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //设置界面的按钮显示 根据自己需求设置
        if (!_isShowDetail) {
            if (lOR == 0) {
                [self hideLeftFloat];
                
            }else if (lOR == 1){
                [self hideRightFloat];
            }
        }
        
    });
}


- (UIImageView *)redPointView{
    if (!_redPointView) {
        _redPointView = [[UIImageView alloc] init];
        [_redPointView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"Red_point" withType:@"png"]];
        self.redPointView.hidden = YES;
    }
    return _redPointView;
}



- (UIView *)rootView{
    if (!_rootView) {
        _rootView = [[UIView alloc] init];
        _rootView.backgroundColor = [UIColor clearColor];
    }
    return _rootView;
}

@end
