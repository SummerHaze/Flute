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

typedef void (^LoadBlock)(BOOL success, NSArray *results, NSUInteger maxId);

// 从网络请求数据
- (void)requestHomePageDataWithSinceId:(NSUInteger)sinceId
                               orMaxId:(NSUInteger)maxId
                            completion:(LoadBlock)block;

// 从本地DB加载数据
- (NSArray *)loadCachedHomePageDataFromPath:(NSString *)dbPath
                                  withMaxId:(NSUInteger)maxId
                              andPageNumber:(NSUInteger)pageNumber;

// 获取用户微博timeline的id
- (void)requestFriendsTimelineIDsWithSinceId:(NSUInteger)sinceId
                                     orMaxId:(NSUInteger)maxId
                                  completion:(LoadBlock)block;

@end
