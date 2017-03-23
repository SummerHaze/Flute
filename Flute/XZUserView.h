//
//  XZUserView.h
//  Flute
//
//  Created by xia on 21/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZUserInfoView;

@interface XZUserView : UIView

@property (nonatomic) XZUserInfoView *userInfoView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UISegmentedControl *segment;

@end
