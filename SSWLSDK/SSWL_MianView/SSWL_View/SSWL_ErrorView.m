//
//  ErrorView.m
//  AYSDK
//
//  Created by SDK on 2017/10/16.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SSWL_ErrorView.h"

@interface SSWL_ErrorView ()
@property (nonatomic, strong) UIImageView *noNetImgView;

@property (nonatomic, strong) UILabel *netTipsLabel;

@end

@implementation SSWL_ErrorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initForErrorView];
        self.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        self.noNetImgView.frame = CGRectMake(0, 0, 115, 95);
        CGPoint centerPoint = CGPointMake(self.centerX, self.centerY - 100);
        self.noNetImgView.center = centerPoint;
        self.netTipsLabel.frame = CGRectMake(0, 0, self.noNetImgView.width + 100, 40);
        self.netTipsLabel.centerX = self.noNetImgView.centerX;
        self.netTipsLabel.centerY = self.noNetImgView.centerY + 70;
       
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame tipsText:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initForErrorView];
        self.frame = frame;
        self.noNetImgView.frame = CGRectMake(0, 0, 115, 95);
        CGPoint centerPoint = CGPointMake(frame.size.width / 2, self.centerY - 80);
        self.noNetImgView.center = centerPoint;
        self.netTipsLabel.frame = CGRectMake(0, 0, frame.size.width, 40);
        self.netTipsLabel.centerX = self.noNetImgView.centerX;
        self.netTipsLabel.centerY = self.noNetImgView.centerY + 70;
        if (text.length > 1) {
            self.netTipsLabel.text = text;
        }

    }
    return self;
}


- (void)initForErrorView{
    self.noNetImgView = [[UIImageView alloc] init];
    [self.noNetImgView setImage:get_BundleImage(@"noNet")];
    [self addSubview:self.noNetImgView];
    
    self.netTipsLabel = [[UILabel alloc] init];
   
    self.netTipsLabel.numberOfLines = 0;
    self.netTipsLabel.text = @"数据获取失败 \n 请检查网络后,点击重新加载";
    self.netTipsLabel.textAlignment = 1;
    self.netTipsLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.netTipsLabel];

}

@end
