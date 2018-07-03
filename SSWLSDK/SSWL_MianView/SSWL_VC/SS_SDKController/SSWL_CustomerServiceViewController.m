//
//  CustomerServiceViewController.m
//  DynamicSecurity
//
//  Created by SDK on 2017/11/6.
//  Copyright © 2017年 songyan. All rights reserved.
//

#import "SSWL_CustomerServiceViewController.h"

@interface SSWL_CustomerServiceViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (strong, nonatomic) UIProgressView *progressView;

@property (nonatomic, strong) UIButton *webBackBtn;

@property (nonatomic, strong) UIView *webBackgroundView;


@end

@implementation SSWL_CustomerServiceViewController
- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏前调入");
         self.view.frame = [[UIScreen mainScreen] bounds];
         self.webView.frame = [[UIScreen mainScreen] bounds];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         SYLog(@"转屏后调入");
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpWebView];


    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];

}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}




#pragma mark ------------------------------------------------Other method & Click
- (void)webBackClick{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}




- (void)setUpWebView{
    
    
    if (!self.webView) {
        self.webBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.webBackgroundView.backgroundColor = SYWhiteColor;
        [self.view addSubview:self.webBackgroundView];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        configuration.preferences = preferences;
        
       self.webView = [[WKWebView alloc] initWithFrame:CGRectMake( 0, 20, Screen_Width, Screen_Height)];
        self.webView.UIDelegate = self;
        self.webView.navigationDelegate = self;
//        self.webView.backgroundColor = [UIColor blueColor];
        NSString *requestUrl = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].customerService;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]]];
        self.webView.scrollView.bounces = NO;
        [self.webView sizeToFit];

        [self.view addSubview:self.webView];
        
        
        
        [self initProgressView];
        
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 62)];
        backView.backgroundColor = SYNOColor;
        [self.view addSubview:backView];
        [backView addSubview:self.webBackBtn];
        
       
        
        [self.webBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView).offset(5);
            make.top.equalTo(backView).offset(30);
            make.size.mas_equalTo(CGSizeMake(30, 21));
        }];
        
        
        
    }
    
    
}


- (void)initProgressView
{
    //    CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 2)];
    progressView.tintColor = [UIColor colorWithRed:0.62 green:0.74 blue:0.86 alpha:1.00];
    progressView.trackTintColor = [UIColor lightGrayColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
}

#pragma mark - KVO
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}




#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.webBackgroundView.backgroundColor = [UIColor colorWithRed:0.99 green:0.44 blue:0.42 alpha:1];
}

- (void)scrollsToBottomAnimated:(BOOL)animated
{
    CGFloat offset = self.webView.scrollView.contentSize.height - self.webView.scrollView.bounds.size.height;
    if (offset > 0)
    {
        [self.webView.scrollView setContentOffset:CGPointMake(0, offset) animated:animated];
    }
}

#pragma mark ------------------------------------------------Lazy & Init

- (UIButton *)webBackBtn{
    if (!_webBackBtn) {
        _webBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _webBackBtn.backgroundColor = SYNOColor;
        //         _backBtn.backgroundColor = [UIColor redColor];
        //        [_webBackBtn setTitle:@"< 返回" forState:UIControlStateNormal];
        //        [_webBackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_webBackBtn setImage:nil forState:UIControlStateNormal];
        [_webBackBtn addTarget:self action:@selector(webBackClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _webBackBtn;
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
