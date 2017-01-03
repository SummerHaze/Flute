//
//  XZDBOperation.h
//  Flute
//
//  Created by xia on 12/18/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZDBOperation : NSObject

// 判断DBPath目录下是否有weibo.db，没有则创建
- (void)DBExistAtPath:(NSString *)DBPath;

// 判断DB中是否有数据
- (NSUInteger)dataExistInDB:(NSString *)DBPath;

// 从DB中取出制定条数的数据
- (NSArray *)fetchDataFromDB:(NSString *)DBPath usingSql:(NSString *)sql;

// 向DB中存储数据
- (BOOL)writeToDB:(NSString *)DBPath withData:(NSArray *)data;



@end
