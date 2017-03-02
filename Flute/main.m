//
//  main.m
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
//    // name1 is a point to const NSString. name1中的地址可变，但指向的值不可变
//    const NSString *name1 = @"哈哈哈";
//    NSString const *name2 = @"哈哈哈"; // 意义同上
//    name1 = @"嘻嘻嘻"; // 不报错，name1中的地址变更，指向了“嘻嘻嘻”对象的地址
//    
//    // name3 is a const pointer to NSString. name3中的地址不可变，但指向的值可变
//    // 定义常量，不希望被改变，应该采用这种写法
//    NSString * const name3 = @"哈哈哈";
//    name3 = @"嘻嘻嘻"; // 报错
}
