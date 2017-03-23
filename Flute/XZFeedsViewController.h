//
//  XZFeedsViewController.h
//  Flute
//
//  Created by xia on 22/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZDataLoader.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "TTTAttributedLabel.h"

typedef NS_ENUM(NSInteger, XZFeedsRequestType) {
    XZFeedsRequestTypeFriendsTimeline,
    XZFeedsRequestTypeUserTimeline
};

@interface XZFeedsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic) XZDataLoader *dataLoader;

@property (nonatomic) UITableView *feedsTableView;

@property (nonatomic) NSMutableArray *feeds;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, copy) NSString *dbPath;

@property (nonatomic) XZFeedsRequestType type;

- (void)loadData;

@end
