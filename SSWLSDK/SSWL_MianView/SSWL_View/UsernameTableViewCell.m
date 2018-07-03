//
//  UsernameTableViewCell.m
//  AYSDK
//
//  Created by songyan on 2018/1/30.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "UsernameTableViewCell.h"
@interface UsernameTableViewCell()

@property (nonatomic ,strong) UILabel *userNameLab;

@property (nonatomic ,strong) UIButton *deleteBtn;

@property (nonatomic ,strong) UIImageView *userImgView;


@end
@implementation UsernameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
        [self addSubview:self.userImgView];
        
        
        [self addSubview:self.userNameLab];
        
    
        [self addSubview:self.deleteBtn];
        
        
    }
    return self;
}

- (void)layoutSubview{
    Weak_Self;
    [self.userImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(10);
        make.centerY.equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.userNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.userImgView.mas_right).offset(10);
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf).offset(-30);
        make.height.mas_equalTo(20);
    }];
    if ([self.userNameLab.text isEqualToString:[KeyChainWrapper load:SSWL_UserName_Fast]]){
       
        self.deleteBtn.hidden = YES;
        self.deleteBtn.frame = CGRectZero;
        
    }else{
        self.deleteBtn.hidden = NO;
        
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf).offset(-10);
            make.centerY.equalTo(weakSelf);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
       
    }

   
}

- (void)setModel:(SSWL_UserModel *)model{
    _model = model;
    self.userNameLab.text = _model.userName;
    [self layoutSubview];

}

- (void)deleteClick:(UIButton *)sender{
    
    NSMutableArray *usernameArr = [KeyChainWrapper load:SSWLUsernameKey];
    NSMutableDictionary *passwordDict = [KeyChainWrapper load:SSWLPasswordKey];
    NSMutableDictionary *tokenDict = [KeyChainWrapper load:SYMobilTokenKey];
    if ([usernameArr containsObject:self.userNameLab.text]) {
        [passwordDict removeObjectForKey:self.userNameLab.text];
        [tokenDict removeObjectForKey:self.userNameLab.text];
        [usernameArr removeObject:self.userNameLab.text];
        
        [KeyChainWrapper save:SSWLUsernameKey data:usernameArr];
        [KeyChainWrapper save:SSWLPasswordKey data:passwordDict];
        [KeyChainWrapper save:SYMobilTokenKey data:tokenDict];
        
        if ([self.delegate respondsToSelector:@selector(cell:deleteUsernameInfoIsDone:deleteUsername:)]) {
            [self.delegate cell:self deleteUsernameInfoIsDone:YES deleteUsername:self.model.userName];
        }
        
    }else{
        if ([self.delegate respondsToSelector:@selector(cell:deleteUsernameInfoIsDone: deleteUsername:)]) {
            [self.delegate cell:self deleteUsernameInfoIsDone:NO deleteUsername:@""];
        }
    }
}


- (UILabel *)userNameLab{
    if (!_userNameLab) {
        _userNameLab = [[UILabel alloc] init];
        _userNameLab.textAlignment = 1;
        _userNameLab.font = [UIFont systemFontOfSize:14];
    }
    return _userNameLab;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"delete" withType:@"png"] forState:UIControlStateNormal];
        [_deleteBtn setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"delete" withType:@"png"] forState:UIControlStateHighlighted];
        [_deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (UIImageView *)userImgView{
    if (!_userImgView) {
        _userImgView = [[UIImageView alloc] init];
        [_userImgView setImage:[SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"id_01" withType:@"png"]];
    }
    return _userImgView;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
