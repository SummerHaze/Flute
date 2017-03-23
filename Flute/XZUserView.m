//
//  XZUserView.m
//  Flute
//
//  Created by xia on 21/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZUserView.h"
#import "XZUserInfoView.h"
#import "WeiboAPI.h"
#import "Masonry.h"

@interface XZUserView()


@end

@implementation XZUserView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        // 配置scrollView
        self.userInfoView = [[XZUserInfoView alloc]init];
        [self addSubview:self.userInfoView];
        self.userInfoView.contentSize = CGSizeMake(kScreenWidth * 2, HEIGHT);
        self.userInfoView.backgroundColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
//        self.userInfoView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0); // 将内容区域上部分与scroll区域的间距减小64point
        
        // 配置pageControl
        self.pageControl = [[UIPageControl alloc]init];
        self.pageControl.numberOfPages = 2;
        [self addSubview:self.pageControl];
        
        // 配置segmentedControl
        NSArray *segmentArray = @[@"全部", @"原创", @"相册"];
        self.segment = [[UISegmentedControl alloc]initWithItems:segmentArray];
        self.segment.tintColor = [UIColor lightGrayColor];
        [self addSubview:self.segment];
        
    }
    return self;
}

- (void)layoutSubviews {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo([NSNumber numberWithInteger:HEIGHT]);
        make.width.equalTo([NSNumber numberWithInteger:kScreenWidth]); // 这里必须明确指定userInfoView的height和width，如果只指定与父view的约束关系，会导致frame计算为0，原因不确定
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.userInfoView);
        make.width.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userInfoView.mas_bottom);
        make.width.equalTo(self);
        make.height.equalTo(@30);
    }];
    
}



@end
