//
//  XZUserProfile.m
//  Flute
//
//  Created by xia on 20/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZUserProfile.h"

@implementation XZUserProfile

// 微博ID
//- (NSString *)gender {
//    NSString *gender = [self.userInfo objectForKey:@"gender"];
//    if ([gender isEqualToString:@"m"]) {
//        return @"男";
//    } else if ([gender isEqualToString:@"f"]) {
//        return @"女";
//    } else {
//        return @"未知";
//    }
//}

- (NSString *)location {
    NSString *gender = [self.userProfileDic objectForKey:@"gender"];
//    NSLog(@"gender: %@", gender);
    NSString *genderTransformed = [[NSString alloc]init];
    if ([gender isEqualToString:@"m"]) {
        genderTransformed = @"男";
    } else if ([gender isEqualToString:@"f"]) {
        genderTransformed = @"女";
    } else {
        genderTransformed = @"";
    }
    NSString *location = [self.userProfileDic objectForKey:@"location"] ? : @"";
    return [NSString stringWithFormat:@"%@  %@", genderTransformed, location];
}

- (NSString *)profileImageUrl {
    return [self.userProfileDic objectForKey:@"avatar_large"];
}

- (NSString *)status {
    NSInteger statusCount = [[self.userProfileDic objectForKey:@"statuses_count"] integerValue] ? : 0;
    return [NSString stringWithFormat:@"%ld\n微博", (long)statusCount];
}

- (NSString *)friends {
    NSInteger friendsCount = [[self.userProfileDic objectForKey:@"friends_count"] integerValue] ? : 0;
    return [NSString stringWithFormat:@"%ld\n关注", (long)friendsCount];
}

- (NSString *)followers {
    NSInteger followersCount = [[self.userProfileDic objectForKey:@"followers_count"] integerValue] ? : 0;
    return [NSString stringWithFormat:@"%ld\n粉丝", (long)followersCount];
}

- (NSString *)verifiedInfo {
    return [self.userProfileDic objectForKey:@"verified_reason"];
}

- (NSString *)userDescription {
    return [self.userProfileDic objectForKey:@"description"];
}

@end
