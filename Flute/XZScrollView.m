//
//  XZScrollView.m
//  Flute
//
//  Created by xia on 29/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZScrollView.h"

@implementation XZScrollView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    id responder = self.nextResponder;
    while (![responder isKindOfClass: [UIViewController class]] && ![responder isKindOfClass: [UIWindow class]])
    {
        responder = [responder nextResponder];
    }
    // 如果下一个响应对象是UIViewController，并且不是UIWindows对象，则该对象就是UIView的UIViewController
    if ([responder isKindOfClass: [UIViewController class]]) // 排除reponder是UIWindow的情况，不多余
    {
        // responder就是view所在的控制器
        [self.nextResponder.nextResponder touchesEnded:touches withEvent:event]; // 把事件传递给scrollView所在的UIViewController处理。
    }
    
}

//- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
//    NSLog(@"222--touches began");
//    return NO;
//}

@end
