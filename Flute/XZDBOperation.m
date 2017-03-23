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

#pragma mark - DB是否存在，是否有数据

- (void)DBExistAtPath:(NSString *)DBPath name:(NSString *)DBName {
    NSFileManager *fm = [NSFileManager defaultManager];
 
    if (![fm fileExistsAtPath:DBPath]) {
        NSError *error;
        NSString *resourcePath = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",DBName] ofType:@"db"];
        if([fm copyItemAtPath:resourcePath toPath:DBPath error:&error]) {
            NSLog(@"创建DB成功：%@.db", DBName);
        };
    } else {
        NSLog(@"path中已存在：%@.db, 不重复创建", DBName);
    }
}

// 判断DB指定TABLE中是否有数据，有则返回maxId
- (NSUInteger)dataExistInDB:(NSString *)DBPath andTable:(NSString *)table {
    FMDatabase *db = [FMDatabase databaseWithPath:DBPath];

    if (![db open]) {
        db = nil;
        NSLog(@"检查是否有缓存——打开DB失败");
        return 0;
    } else {
        NSString *query = [NSString stringWithFormat:@"SELECT id FROM %@ ORDER BY id DESC LIMIT 1", table];
        FMResultSet *s = [db executeQuery:query];
        if ([s next] == NO) {
            NSLog(@"%@表中无数据", table);
            [db close];
            return 0;
        } else {
            NSUInteger maxId = [s longForColumn:@"ID"];
            NSLog(@"%@表中有数据, maxId为: %ld", table, (unsigned long)maxId);
            [db close];
            return maxId;
        }
    }
}

#pragma mark - 从DB中读取数据

- (NSArray *)fetchDataFromDB:(NSString *)DBPath usingSql:(NSString *)sql {
    FMDatabase *db = [FMDatabase databaseWithPath:DBPath];
    
    if (![db open]) {
        db = nil;
        NSLog(@"读取DB——打开DB失败");
        return nil;
    } else {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
        FMResultSet *s = [db executeQuery:sql];
        while ([s next]) {
            NSData *data = [s objectForColumnName:@"STATUS"];
            NSDictionary *status = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [results addObject:status];
        }
        [db close];
        return results;
    }
}

#pragma mark - 向DB中写数据

- (BOOL)writeTimelineToDB:(NSString *)DBPath usingSQL:(NSString *)sql withData:(NSArray *)data {
    FMDatabase *db = [FMDatabase databaseWithPath:DBPath];
    if (![db open]) {
        db = nil;
        NSLog(@"写DB——打开DB失败");
        return NO;
    }
    
    // 确保待写入的数据不为空
    if ((data != nil) && ([data count] != 0)) {
        for (XZStatus *item in data) {
            // 如果有主键重复的条目则忽略，不重复写入
            NSData *statusData = [NSKeyedArchiver archivedDataWithRootObject:item.statuses];
            if (![db executeUpdate:sql
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

- (BOOL)writeFriendsTimelineToDB:(NSString *)DBPath withData:(NSArray *)data {
    NSString *sql = @"INSERT OR IGNORE INTO friendsTimelines (ID, IDSTR, STATUS) VALUES(:id,:idstr,:status)";
    return [self writeTimelineToDB:DBPath usingSQL:sql withData:data];
}

- (BOOL)writeUserTimelineToDB:(NSString *)DBPath withData:(NSArray *)data {
    NSString *sql = @"INSERT OR IGNORE INTO userTimelines (ID, IDSTR, STATUS) VALUES(:id,:idstr,:status)";
    return [self writeTimelineToDB:DBPath usingSQL:sql withData:data];
}

#pragma mark - 清空指定TABLE中的数据

- (BOOL)deleteFromDB:(NSString *)DBPath table:(NSString *)table {
    FMDatabase *db = [FMDatabase databaseWithPath:DBPath];
    if (![db open]) {
        db = nil;
        NSLog(@"清空DB——打开DB失败");
        return NO;
    }
    
    NSString *delete = [NSString stringWithFormat:@"DELETE FROM %@", table];
    if ([db executeUpdate:delete]) {
        NSLog(@"清空DB——成功");
        
        [db close];
        
        return YES;
    } else {
        NSLog(@"清空DB——失败");
        return NO;
    }
    
}

@end
