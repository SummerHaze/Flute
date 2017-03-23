//
//  XZDataLoader.h
//  Flute
//
//  Created by xia on 21/02/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZDBOperation.h"

@interface XZDataLoader : NSObject

@property (nonatomic) XZDBOperation *dbOperation;

typedef void (^CompletionBlock)(BOOL success, id responseObject);

// 网络请求数据
- (void)requestDataFromNetworkOfURL:(NSString *)url
                      withParamters:(NSDictionary *)parameters
                         completion:(CompletionBlock)block;

// 网络请求用户profile
- (void)requestUserProfile:(NSString *)name
                completion:(CompletionBlock)block;

// 网络请求用户feeds
- (void)requestUserTimelineWithUserId:(NSUInteger)userId
                           orUserName:(NSString *)name
                             andMaxId:(NSUInteger)maxId
                           completion:(CompletionBlock)block;

// 网络请求所有好友feeds
- (void)requestFriendsTimelineWithSinceId:(NSUInteger)sinceId
                                  orMaxId:(NSUInteger)maxId
                               completion:(CompletionBlock)block;

// 网络请求批量的用户微博id
- (void)requestFriendsTimelineIDsWithSinceId:(NSUInteger)sinceId
                                     orMaxId:(NSUInteger)maxId
                                  completion:(CompletionBlock)block;

// 从本地DB加载FriendsTimeline
- (NSArray *)loadFriendsTimelineFromLocalDBAtPath:(NSString *)dbPath
                                        withMaxId:(NSUInteger)maxId
                                    andPageNumber:(NSUInteger)pageNumber;

// 从本地DB加载UserTimeline
- (NSArray *)loadUserTimelineFromLocalDBAtPath:(NSString *)dbPath
                                     withMaxId:(NSUInteger)maxId
                                 andPageNumber:(NSUInteger)pageNumber;

@end
