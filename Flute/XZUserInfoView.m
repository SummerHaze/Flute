//
//  XZUserInfoView.m
//  Flute
//
//  Created by xia on 19/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZUserInfoView.h"
#import "Masonry.h"
#import "WeiboAPI.h"
#import "XZUserProfile.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface XZUserInfoView()

//@property (nonatomic) UIView *containerView;
@property (nonatomic) UILabel *verifiedInfoLabel;
@property (nonatomic) UILabel *userDescriptionLabel;

@end

@implementation XZUserInfoView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        self.pagingEnabled = YES;
//        self.backgroundColor = [UIColor lightGrayColor];
        self.showsHorizontalScrollIndicator = NO;
        
        self.userProfile = [[XZUserProfile alloc]init];
//        self.containerView = [[UIView alloc]init];
//        self.containerView.backgroundColor = [UIColor greenColor];
//        [self addSubview:self.containerView];
        
        self.location = [[UILabel alloc]init];
        self.location.font = [UIFont systemFontOfSize:13];
        self.location.textColor = [UIColor whiteColor];
        [self addSubview: self.location];
        
        self.profile = [[UIImageView alloc]init];
        [self addSubview: self.profile];
        
        self.statuses = [[UIButton alloc]init];
        self.statuses.titleLabel.numberOfLines = 2;
        self.statuses.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.statuses setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview: self.statuses];
        
        self.friends = [[UIButton alloc]init];
        self.friends.titleLabel.numberOfLines = 2;
        self.friends.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.friends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview: self.friends];
        
        self.followers = [[UIButton alloc]init];
        self.followers.titleLabel.numberOfLines = 2;
        self.followers.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.followers setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview: self.followers];
        
        self.verifiedInfoLabel = [[UILabel alloc]init];
        self.verifiedInfoLabel.text = @"微博认证";
        self.verifiedInfoLabel.font = [UIFont systemFontOfSize:12];
        self.verifiedInfoLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.verifiedInfoLabel];
        
        self.userDescriptionLabel = [[UILabel alloc]init];
        self.userDescriptionLabel.text = @"个人简介";
        self.userDescriptionLabel.font = [UIFont systemFontOfSize:12];
        self.userDescriptionLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.userDescriptionLabel];
        
        self.verifiedInfo = [[UILabel alloc]init];
        self.verifiedInfo.numberOfLines = 0;
        self.verifiedInfo.font = [UIFont systemFontOfSize:13];
        self.verifiedInfo.textColor = [UIColor whiteColor];
        [self addSubview:self.verifiedInfo];
        
        self.userDescription = [[UILabel alloc]init];
        self.userDescription.numberOfLines = 0;
        self.userDescription.font = [UIFont systemFontOfSize:13];
        self.userDescription.textColor = [UIColor whiteColor];
        [self addSubview:self.userDescription];
    }
    return self;
}

- (void)layoutSubviews {
    self.location.text = self.userProfile.location;
    [self.location mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.centerX.equalTo(self);
    }];
    
    NSURL *imageUrl = [NSURL URLWithString:self.userProfile.profileImageUrl];
    [self.profile sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [self.profile mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.location.mas_bottom).offset(15);
        make.centerX.equalTo(self);
        make.height.width.equalTo(@80);
    }];
    
    [self.friends setTitle:self.userProfile.friends forState:UIControlStateNormal];
    [self.friends mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.profile.mas_bottom).offset(15);
    }];
    
    [self.statuses setTitle:self.userProfile.status forState:UIControlStateNormal];
    [self.statuses mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.friends);
        make.right.equalTo(self.friends.mas_left).offset(-60);
    }];
    
    [self.followers setTitle:self.userProfile.followers forState:UIControlStateNormal];
    [self.followers mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.friends);
        make.left.equalTo(self.friends.mas_right).offset(60);
    }];
    
    self.verifiedInfo.text = self.userProfile.verifiedInfo;
    [self.verifiedInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(kScreenWidth + 20);
    }];
    
    self.userDescription.text = self.userProfile.userDescription;
    [self.userDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifiedInfoLabel.mas_bottom).offset(30);
        make.left.equalTo(self.verifiedInfoLabel);
    }];
    
    NSInteger width = kScreenWidth - 20 * 2 - CGRectGetWidth(self.verifiedInfoLabel.frame) - 10;
    [self.verifiedInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifiedInfoLabel);
        make.left.equalTo(self.verifiedInfoLabel.mas_right).offset(10);
//        make.right.equalTo(self).offset(-20); // 相对于contentSize的位置关系
        make.width.equalTo([NSNumber numberWithInteger:width]);
    }];
    
    [self.userDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userDescriptionLabel);
        make.left.equalTo(self.userDescriptionLabel.mas_right).offset(10);
        make.width.equalTo(self.verifiedInfo);
    }];

}


@end
