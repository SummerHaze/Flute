//
//  XZUserInfoView.h
//  Flute
//
//  Created by xia on 19/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZUserProfile;

@interface XZUserInfoView : UIScrollView

//@property (nonatomic) UILabel *gender; // 性别
@property (nonatomic) UILabel *location; // 位置
@property (nonatomic) UIImageView *profile; // 头像
@property (nonatomic) UIButton *followers; // 粉丝数
@property (nonatomic) UIButton *friends; // 关注数
@property (nonatomic) UIButton *statuses; // 微博数
@property (nonatomic) UILabel *verifiedInfo; // 认证
@property (nonatomic) UILabel *userDescription; // 个人简介

@property (nonatomic) XZUserProfile *userProfile;

@end
