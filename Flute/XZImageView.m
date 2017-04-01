//
//  XZImageView.m
//  Flute
//
//  Created by xia on 27/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const XZImageViewPressedNotification = @"XZImageViewPressedNotification";

@implementation XZImageView
{
    NSDictionary *userInfo;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

// 重写父类的touches相关方法，响应用户点击
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    userInfo = @{@"imageUrl": [self sd_imageURL]};
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:XZImageViewPressedNotification
                                                        object:self
                                                      userInfo:userInfo];
}


@end
