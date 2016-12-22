//
//  XZFeedsFrame.h
//  Flute
//
//  Created by xia on 12/16/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XZFeeds.h"

@interface XZFeedsFrame : NSObject

@property (nonatomic, assign) CGRect iconFrame;
@property (nonatomic, assign) CGRect nameFrame;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, strong) NSMutableArray *picFrames;

@property (nonatomic, assign) CGRect repostBackgroungFrame;
@property (nonatomic, assign) CGRect repostNameFrame;
@property (nonatomic, assign) CGRect repostTextFrame;
@property (nonatomic, assign) CGRect repostCountsFrame;
@property (nonatomic, assign) CGRect repostCommentCountsFrame;
@property (nonatomic, strong) NSMutableArray *repostPicFrames;
//@property (nonatomic, assign) CGRect repostPicFrame;
//@property (nonatomic, assign) CGRect iconFrame;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, strong) XZFeeds *feeds;

@end
