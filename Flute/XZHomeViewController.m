//
//  XZHomeViewController.m
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZHomeViewController.h"
#import "XZLogin.h"
#import "WeiboAPI.h"
#import "XZFeedsCell.h"
#import "XZStatus.h"
#import "MJRefresh.h"
#import "XZDBOperation.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "XZDataLoader.h"
#import "TTTAttributedLabel.h"
#import "XZUserViewController.h"
#import "XZTopicViewController.h"
#import "XZUserView.h"

@interface XZHomeViewController()

@property (nonatomic) XZLogin *login;

@end

@implementation XZHomeViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = XZFeedsRequestTypeFriendsTimeline;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"homeViewController dealloc");
}

@end
