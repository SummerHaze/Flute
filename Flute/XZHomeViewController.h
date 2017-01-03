//
//  XZHomeViewController.h
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UIScrollViewDelegate>

//@property (nonatomic, strong) UITableView *tableView;

- (void)requestHomePageData;

@end
