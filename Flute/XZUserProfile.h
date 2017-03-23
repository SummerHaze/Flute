//
//  XZUserProfile.h
//  Flute
//
//  Created by xia on 20/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZUserProfile : NSObject

@property (nonatomic, copy) NSDictionary *userProfileDic;

//@property (nonatomic, copy) NSString *gender; // 性别
@property (nonatomic, copy) NSString *location; // 位置
@property (nonatomic, copy) NSString *profileImageUrl; // 头像url
@property (nonatomic, copy) NSString *status; // 微博
@property (nonatomic, copy) NSString *friends; // 关注
@property (nonatomic, copy) NSString *followers; // 粉丝
@property (nonatomic, copy) NSString *verifiedInfo; // 认证信息
@property (nonatomic, copy) NSString *userDescription; // 个人简介

@end
