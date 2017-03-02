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

@interface XZDataLoader()


@end

@implementation XZDataLoader

#pragma mark - getter

- (XZDBOperation *)dbOperation {
    if (!_dbOperation) {
        _dbOperation = [[XZDBOperation alloc]init];

    }
    return _dbOperation;
}

#pragma mark - Load data from network

- (void)requestHomePageDataWithSinceId:(NSUInteger)sinceId
                               orMaxId:(NSUInteger)maxId
                            completion:(LoadBlock)block {
    NSString *URLString = GetFriendsTimeline;
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @FEEDS_COUNT,
//                                 @"page": [NSNumber numberWithInteger:pageNumber],
                                 @"since_id": [NSNumber numberWithInteger:sinceId],
                                 @"max_id": [NSNumber numberWithInteger:maxId - 1]};
    
    NSMutableArray *requestFeeds = [NSMutableArray arrayWithCapacity:1];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URLString
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSLog(@">>>Request Home Page Success");
             NSArray *statuses = [responseObject objectForKey:@"statuses"];
             NSInteger count = [statuses count];
             NSUInteger maxIdChanged = 1;
             
             for (NSInteger i = 0; i < count; i++) {
                 XZStatus *feeds = [[XZStatus alloc]init];
                 feeds.statuses = statuses[i];
                 [requestFeeds addObject:feeds];
                 
                 if (i == count - 1) {
                     maxIdChanged = feeds.statusId;
                     NSLog(@"request>>> maxId‘s changed to: %ld", (unsigned long)maxId);
                 }
             }
             
             block(YES, requestFeeds, maxIdChanged);
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             block(NO, nil, 0);
             NSLog(@">>>Request Home Page Error: %@",error);
         }
     ];
}

#pragma mark - Load data from local DB

- (NSArray *)loadCachedHomePageDataFromPath:(NSString *)dbPath withMaxId:(NSUInteger)maxId andPageNumber:(NSUInteger)pageNumber {
    NSString *sql;
    if (pageNumber == 1) {
        sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE id <= %ld ORDER BY id DESC LIMIT %d", (unsigned long)maxId, FEEDS_COUNT];
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE id < %ld ORDER BY id DESC LIMIT %d", (unsigned long)maxId, FEEDS_COUNT];
    }
    NSLog(@"sql: %@", sql);
    
    NSMutableArray *cachedHomeFeeds = (NSMutableArray *)[self.dbOperation fetchDataFromDB:dbPath usingSql:sql]; // 数组，内存字典
    NSInteger count = MIN([cachedHomeFeeds count], FEEDS_COUNT); // 缓存数据可能不够一页
    
    if (count == 0) {
        NSLog(@"本地无缓存");
        return nil;
    } else {
        NSLog(@"本地有缓存, 加载");
        NSMutableArray *caches = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger i = 0; i < count; i++) {
            XZStatus *feeds = [[XZStatus alloc]init];
            feeds.statuses = cachedHomeFeeds[i];
            [caches addObject:feeds];
        }
        return caches;
    }
}

- (void)requestFriendsTimelineIDsWithSinceId:(NSUInteger)sinceId
                                          orMaxId:(NSUInteger)maxId
                                       completion:(LoadBlock)block {
    NSString *URLString = GetFriendsTimelineIDs;
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @20,  // 返回最新的20条微博ID
                                 @"since_id": [NSNumber numberWithInteger:sinceId],
                                 @"max_id": [NSNumber numberWithInteger:maxId - 1]};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URLString
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@">>>Request FriendsTimelineIDs Success");
             NSArray *friendsTimelineIDs = [responseObject objectForKey:@"statuses"];
             NSNumber *totalNumber = [responseObject objectForKey:@"total_number"];
             __unused NSInteger count = totalNumber.integerValue; // 总feeds条数，截止时间点为？
             
             block(YES, friendsTimelineIDs, 1);
    }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             block(NO, nil, 1);
             NSLog(@">>>Request FriendsTimelineIDs Error: %@",error);
    }];
}

@end
