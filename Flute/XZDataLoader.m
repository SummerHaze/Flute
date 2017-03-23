//
//  XZDataLoader.m
//  Flute
//
//  Created by xia on 21/02/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZDataLoader.h"
#import "XZDBOperation.h"
#import "WeiboAPI.h"
#import <AFNetworking/AFNetworking.h>
#import "XZStatus.h"
#import "XZUserProfile.h"

@interface XZDataLoader()

@property (nonatomic) AFHTTPSessionManager *manager;

@end

@implementation XZDataLoader

#pragma mark - getter

- (XZDBOperation *)dbOperation {
    if (!_dbOperation) {
        _dbOperation = [[XZDBOperation alloc]init];

    }
    return _dbOperation;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

#pragma mark - 从网络请求

// 网络请求数据
- (void)requestDataFromNetworkOfURL:(NSString *)url
                      withParamters:(NSDictionary *)parameters
                         completion:(CompletionBlock)block {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask * task, id responseObject) {
             NSLog(@">>>Request Success: %@", url);
             block(YES, responseObject);
    }
         failure:^(NSURLSessionDataTask * task, NSError * error) {
             NSLog(@">>>Request Fail: %@", url);
             block(NO, nil);
    }];
}

// 网络请求用户信息
- (void)requestUserProfile:(NSString *)name completion:(CompletionBlock)block {
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"screen_name": name};
    [self requestDataFromNetworkOfURL:GetUserProfile
                        withParamters:parameters
                           completion:^(BOOL success, id responseObject) {
                               if (success) {
                                   block(YES, responseObject);
                               } else {
                                   block(NO, nil);
                               }
                           }];
}

// 网络请求好友feeds
- (void)requestFriendsTimelineWithSinceId:(NSUInteger)sinceId
                                  orMaxId:(NSUInteger)maxId
                               completion:(CompletionBlock)block {
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @FEEDS_COUNT,
                                 @"since_id": [NSNumber numberWithInteger:sinceId],
                                 @"max_id": [NSNumber numberWithInteger:maxId - 1]};
    
    [self requestDataFromNetworkOfURL:GetFriendsTimeline
                        withParamters:parameters
                           completion:^(BOOL success, id responseObject) {
                               if (success) {
                                   block(YES, responseObject);
                               } else {
                                   block(NO, nil);
                               }
    }];
}

- (void)requestUserTimelineWithUserId:(NSUInteger)userId
                           orUserName:(NSString *)name
                             andMaxId:(NSUInteger)maxId
                            completion:(CompletionBlock)block {
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"screen_name": name,
                                 @"count": @FEEDS_COUNT,
                                 @"max_id": @(maxId - 1)};
    
    [self requestDataFromNetworkOfURL:GetUserTimeline
                        withParamters:parameters
                           completion:^(BOOL success, id responseObject) {
                               if (success) {
                                   block(YES, responseObject);
                               } else {
                                   block(NO, nil);
                               }
                           }];
}

- (void)requestFriendsTimelineIDsWithSinceId:(NSUInteger)sinceId
                                          orMaxId:(NSUInteger)maxId
                                       completion:(CompletionBlock)block {
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @20,  // 返回最新的20条微博ID
                                 @"since_id": [NSNumber numberWithInteger:sinceId],
                                 @"max_id": @(maxId - 1)};
    
    [self requestDataFromNetworkOfURL:GetFriendsTimelineIDs
                        withParamters:parameters
                           completion:^(BOOL success, id responseObject) {
                               if (success) {
                                   block(YES, responseObject);
                               } else {
                                   block(NO, nil);
                               }
                           }];
//    [manager GET:URLString
//      parameters:parameters
//        progress:nil
//         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//             NSLog(@">>>Request FriendsTimelineIDs Success");
//             NSArray *friendsTimelineIDs = [responseObject objectForKey:@"statuses"];
//             NSNumber *totalNumber = [responseObject objectForKey:@"total_number"];
//             __unused NSInteger count = totalNumber.integerValue; // 总feeds条数，截止时间点为？
//             
//             block(YES, nil, friendsTimelineIDs, 1);
//    }
//         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//             block(NO, nil, nil, 1);
//             NSLog(@">>>Request FriendsTimelineIDs Error: %@",error);
//    }];
}

#pragma mark - 从本地数据库加载

- (NSArray *)loadTimelineFromLocalDBAtPath:(NSString *)dbPath usingSQL:(NSString *)sql {
    NSMutableArray *fetchResults = (NSMutableArray *)[self.dbOperation fetchDataFromDB:dbPath usingSql:sql]; // 数组，内存字典
    NSInteger count = MIN([fetchResults count], FEEDS_COUNT); // 缓存数据可能不够一页
    
    if (count == 0) {
        NSLog(@"本地无缓存");
        return nil;
    } else {
        NSLog(@"本地有缓存, 加载");
        NSMutableArray *caches = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger i = 0; i < count; i++) {
            XZStatus *feeds = [[XZStatus alloc]init];
            feeds.statuses = fetchResults[i];
            [caches addObject:feeds];
        }
        return caches;
    }
}

- (NSArray *)loadFriendsTimelineFromLocalDBAtPath:(NSString *)dbPath
                                        withMaxId:(NSUInteger)maxId
                                    andPageNumber:(NSUInteger)pageNumber {
    NSString *sql;
    if (pageNumber == 1) {
        sql = [NSString stringWithFormat:@"SELECT * FROM friendsTimelines WHERE id <= %ld ORDER BY id DESC LIMIT %d", (unsigned long)maxId, FEEDS_COUNT];
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM friendsTimelines WHERE id < %ld ORDER BY id DESC LIMIT %d", (unsigned long)maxId, FEEDS_COUNT];
    }
    NSLog(@"sql: %@", sql);
    
    return [self loadTimelineFromLocalDBAtPath:dbPath usingSQL:sql];
}

- (NSArray *)loadUserTimelineFromLocalDBAtPath:(NSString *)dbPath
                                        withMaxId:(NSUInteger)maxId
                                    andPageNumber:(NSUInteger)pageNumber {
    NSString *sql;
    if (pageNumber == 1) {
        sql = [NSString stringWithFormat:@"SELECT * FROM userTimelines WHERE id <= %ld ORDER BY id DESC LIMIT %d", (unsigned long)maxId, FEEDS_COUNT];
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM userTimelines WHERE id < %ld ORDER BY id DESC LIMIT %d", (unsigned long)maxId, FEEDS_COUNT];
    }
    NSLog(@"sql: %@", sql);
    
    return [self loadTimelineFromLocalDBAtPath:dbPath usingSQL:sql];
}

@end
