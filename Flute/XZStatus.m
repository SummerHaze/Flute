//
//  XZStatus.m
//  Flute
//
//  Created by xia on 12/16/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZStatus.h"

@implementation XZStatus

#pragma mark - 原发微博信息

// 微博ID
- (NSUInteger)statusId {
    NSNumber *statusId = [self.statuses objectForKey:@"id"];
    return statusId.unsignedIntegerValue;
}

// 字符串型微博ID
- (NSString *)statusIdStr {
    return [self.statuses objectForKey:@"idstr"];
}

// 微博正文
- (NSString *)text {
    return [self.statuses objectForKey:@"text"];
}

// 正文配图地址
- (NSString *)thumbnailPic {
    return [self.statuses objectForKey:@"thumbnail_pic"];
}

// 正文中多张配图时的url
- (NSArray *)picURLs {
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:1];
    NSArray *urlArray = [self.statuses objectForKey:@"pic_urls"];
    for (NSDictionary *dict in urlArray) {
        NSString *url = [dict objectForKey:@"thumbnail_pic"];
        [urls addObject:url];
    }
    return urls;
}

// 用户信息
- (NSDictionary *)user {
    return [self.statuses objectForKey:@"user"];
}

// 用户昵称
- (NSString *)name {
    return [self.user objectForKey:@"name"];
}

// 用户头像
- (NSString *)icon {
    return [self.user objectForKey:@"profile_image_url"];
}

#pragma mark - 被转发微博信息

// 被转发微博信息
- (NSDictionary *)retweetedStatuses {
    return [self.statuses objectForKey:@"retweeted_status"];
}

// 被转发微博正文
- (NSString *)retweetedText {
    return [self.retweetedStatuses objectForKey:@"text"];
}

// 被转发微博配图地址
- (NSString *)retweetedThumbnailPic {
    return [self.retweetedStatuses objectForKey:@"thumbnail_pic"];
}

// 被转发微博多张配图时的url
- (NSArray *)retweetedPicURLs {
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:1];
    NSArray *urlArray = [self.retweetedStatuses objectForKey:@"pic_urls"];
    for (NSDictionary *dict in urlArray) {
        NSString *url = [dict objectForKey:@"thumbnail_pic"];
        [urls addObject:url];
    }
    return urls;
}

// 被转发微博用户信息
- (NSDictionary *)retweetedUser {
    return [self.retweetedStatuses objectForKey:@"user"];
}

// 被转发微博用户昵称
- (NSString *)retweetedName {
    return [self.retweetedUser objectForKey:@"name"];
}

// 被转发微博转发数
- (NSInteger)retweetedRepostCounts {
    NSNumber *repost = [self.retweetedStatuses objectForKey:@"reposts_count"];
    return repost.integerValue;
}

// 被转发微博评论数
- (NSInteger)retweetedCommentCounts {
    NSNumber *comment = [self.retweetedStatuses objectForKey:@"comments_count"];
    return comment.integerValue;
}


@end
