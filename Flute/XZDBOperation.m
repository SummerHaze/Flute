//
//  XZDBOperation.m
//  Flute
//
//  Created by xia on 12/18/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZDBOperation.h"
#import <FMDB/FMDB.h>
#import "XZStatus.h"

@implementation XZDBOperation

- (void)DBExistAtPath:(NSString *)DBPath {
    NSFileManager *fm = [NSFileManager defaultManager];
 
    if (![fm fileExistsAtPath:DBPath]) {
        NSError *error;
        NSString *resourcePath = [[NSBundle mainBundle]pathForResource:@"weibo" ofType:@"db"];
        if([fm copyItemAtPath:resourcePath toPath:DBPath error:&error]) {
            NSLog(@"创建weibo.db成功");
        };
    } else {
        NSLog(@"path中已存在weibo.db，不重复创建");
    }
}

// 判断DB中是否有数据，有则返回maxId
- (NSUInteger)dataExistInDB:(NSString *)DBPath {
    FMDatabase *db = [FMDatabase databaseWithPath:DBPath];

    if (![db open]) {
        db = nil;
        NSLog(@"检查是否有缓存——打开DB失败");
        return 0;
    } else {
        NSString *query = @"SELECT id FROM status ORDER BY id DESC LIMIT 1";
        FMResultSet *s = [db executeQuery:query];
        if ([s next] == NO) {
            NSLog(@"status表中无数据");
            [db close];
            return 0;
        } else {
            NSUInteger maxId = [s longForColumn:@"ID"];
            NSLog(@"status表中有数据, maxId为: %ld", maxId);
            [db close];
            return maxId;
        }
    }
}

// 从DB中取出数据，每次取20条
- (NSArray *)fetchDataFromDB:(NSString *)DBPath usingSql:(NSString *)sql {
    FMDatabase *db = [FMDatabase databaseWithPath:DBPath];
    
    if (![db open]) {
        db = nil;
        NSLog(@"读取DB——打开DB失败");
        return nil;
    } else {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
//        NSString *query = @"SELECT * FROM status WHERE LIMIT 20";
        FMResultSet *s = [db executeQuery:sql];
        while ([s next]) {
//            XZStatus *item = [[XZStatus alloc]init];
//            item.statusId = [s longForColumn:@"ID"];
//            item.statusIdStr = [s stringForColumn:@"IDSTR"];
//            item.statuses = (NSDictionary *)[s dataForColumn:@"STATUS"];
            NSData *data = [s objectForColumnName:@"STATUS"];
            NSDictionary *status = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [results addObject:status];
        }
        [db close];
        return results;
    }
}

// 向DB中存储数据
- (BOOL)writeToDB:(NSString *)DBPath withData:(NSArray *)data {
    FMDatabase *db = [FMDatabase databaseWithPath:DBPath];
    if (![db open]) {
        db = nil;
        NSLog(@"写DB——打开DB失败");
        return NO;
    }

    // 确保待写入的数据不为空
    if ((data != nil) && ([data count] != 0)) {
        for (XZStatus *item in data) {
            NSString *insert = @"INSERT OR IGNORE INTO status (ID, IDSTR, STATUS) VALUES(:id,:idstr,:status)"; // 如果有主键重复的条目则忽略，不重复写入
            NSData *statusData = [NSKeyedArchiver archivedDataWithRootObject:item.statuses];
            if (![db executeUpdate:insert
              withArgumentsInArray:@[[NSNumber numberWithUnsignedInteger:item.statusId],
                                     item.statusIdStr,
                                     statusData]]) {
                NSLog(@"写DB——写入失败");
                return NO;
            }
        }
        NSLog(@"写DB——写入成功");
        [db close];
        return YES;
    } else {
        NSLog(@"写DB——输入为空");
        return NO;
    }
}

@end
