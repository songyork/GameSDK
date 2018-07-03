//
//  ServiceAgreementView.m
//  AYSDK
//
//  Created by songyan on 2018/1/28.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_ServiceAgreementView.h"
@interface SSWL_ServiceAgreementView()

@property (nonatomic ,strong) UIButton *agreeBtn;

@property (nonatomic ,strong) UILabel *noticeLabel;

@property (nonatomic ,strong) UILabel *agreementLabel;

@property (nonatomic, assign) BOOL isAgree;



@end

#define SubViewHeight self.frame.size.height

@implementation SSWL_ServiceAgreementView

- (id)init{
    if (self = [super init]) {
        self.isAgree = YES;
        [self createUI];
    }
    return self;
}


- (void)createUI{
    [self addSubview:self.agreeBtn];
    [self addSubview:self.noticeLabel];
    [self addSubview:self.agreementLabel];
}

- (void)layoutSubviews{
    
    CGSize noticeSize = [self.noticeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.noticeLabel.font} context:nil].size;
    
    CGSize agreementSize = [self.agreementLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.agreementLabel.font} context:nil].size;
    
    
    self.agreeBtn.frame = CGRectMake(0, 0, 20, SubViewHeight);
    self.noticeLabel.frame = CGRectMake(self.agreeBtn.width + 5, 0, noticeSize.width + 5, SubViewHeight);
    self.agreementLabel.frame = CGRectMake(self.noticeLabel.x + self.noticeLabel.width, 0, agreementSize.width + 5, SubViewHeight);
    
}

- (void)agreeClick{
    self.isAgree = !self.isAgree;
    if (self.isAgree) {
        [_agreeBtn setImage:get_BundleImage(@"select_yes") forState:UIControlStateNormal];
    }else{
        [_agreeBtn setImage:get_BundleImage(@"select_no") forState:UIControlStateNormal];
    }
    if (self.AgreeBlock) {
        self.AgreeBlock(self.isAgree);
    }
    
}

- (void)readAgreement:(UITapGestureRecognizer *)sender{
    
    NSString *urlString = @"http://syuser.shangshiwl.com/sswlxy.html";
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            if (success) {
                SYLog(@"-----yes------");
                
            }
        }];
    }
    
    /*
    NSURL *url = [NSURL URLWithString:[SDKInfo sharedSDKInfo].customerService];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            SYLog(@"%d", success);
        }];
    }
     */
}


- (UIButton *)agreeBtn{
    if (!_agreeBtn) {
        _agreeBtn = [SSWL_PublicTool createBtnWithButton:_agreeBtn buttonType:UIButtonTypeCustom frame:CGRectZero backgroundColor:nil image:nil normalTitle:nil selectedTitle:nil highlightTile:nil textAlignment:nil selected:NO titleNormalColor:nil titleSelectedColor:nil titleHighlightedColor:nil];
        [_agreeBtn setImage:get_BundleImage(@"select_yes") forState:UIControlStateNormal];
        [_agreeBtn addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeBtn;
}

- (UILabel *)noticeLabel{
    if (!_noticeLabel) {
        _noticeLabel = [[UILabel alloc] init];
        _noticeLabel.textColor = [UIColor blackColor];
        _noticeLabel.text = @"我已阅读并同意";
        _noticeLabel.textAlignment = 1;
        _noticeLabel.font = [UIFont systemFontOfSize:16];
    }
    return _noticeLabel;
}



- (UILabel *)agreementLabel{
    if (!_agreementLabel){
        _agreementLabel = [[UILabel alloc] init];
        _agreementLabel.textColor = [UIColor colorWithRed:0.93 green:0.31 blue:0.14 alpha:1];
        _agreementLabel.text = @"用户服务协议";
        _agreementLabel.textAlignment = 0;
        _agreementLabel.font = [UIFont systemFontOfSize:16];
        _agreementLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(readAgreement:)];
        [_agreementLabel addGestureRecognizer:tapGR];
    }
    return _agreementLabel;
}










@end
