//
//  XZHomeViewController.h
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZDataLoader.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface XZHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UIScrollViewDelegate>

@property (nonatomic) XZDataLoader *dataLoader;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *homeFeeds;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic) NSString *dbPath;

@end
