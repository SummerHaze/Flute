//
//  XZDBOperation.h
//  Flute
//
//  Created by xia on 12/18/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZDBOperation : NSObject

// 判断DBPath目录下是否有对应DB，没有则创建
- (void)DBExistAtPath:(NSString *)DBPath name:(NSString *)DBName;

// 判断DB指定table中是否有数据
- (NSUInteger)dataExistInDB:(NSString *)DBPath andTable:(NSString *)table;

// 从DB中取出指定条数的数据
- (NSArray *)fetchDataFromDB:(NSString *)DBPath usingSql:(NSString *)sql;

// 向DB中存储数据
- (BOOL)writeUserTimelineToDB:(NSString *)DBPath withData:(NSArray *)data;
- (BOOL)writeFriendsTimelineToDB:(NSString *)DBPath withData:(NSArray *)data;

// 删除DB指定table中全部数据
- (BOOL)deleteFromDB:(NSString *)DBPath table:(NSString *)table;

@end
