//
//  XZStatus.h
//  Flute
//
//  Created by xia on 12/16/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZStatus : NSObject

// getFriendsTimeline最外层字段
@property (nonatomic) NSDictionary *statuses;

// 微博ID信息
@property (nonatomic, assign) NSUInteger statusId;
@property (nonatomic, copy) NSString *statusIdStr;

// 原发微博信息
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDictionary *user;
@property (nonatomic, copy) NSString *thumbnailPic;
@property (nonatomic, copy) NSArray *picURLs;

// 被转发微博信息
@property (nonatomic, copy) NSDictionary *retweetedStatuses;
@property (nonatomic, copy) NSString *retweetedName;
@property (nonatomic, copy) NSString *retweetedText;
@property (nonatomic, copy) NSDictionary *retweetedUser;
@property (nonatomic, assign) NSInteger retweetedRepostCounts;
@property (nonatomic, assign) NSInteger retweetedCommentCounts;
@property (nonatomic, copy) NSString *retweetedThumbnailPic;
@property (nonatomic, copy) NSArray *retweetedPicURLs;

@end
