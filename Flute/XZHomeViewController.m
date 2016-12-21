//
//  XZHomeViewController.m
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZHomeViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "XZLogin.h"
#import "WeiboAPI.h"
#import "XZFeedsCell.h"
#import "XZFeeds.h"
#import "XZFeedsFrame.h"

@interface XZHomeViewController ()



@end

@implementation XZHomeViewController
{
    UITableView *tableView;
    XZLogin *login;
    XZFeedsFrame *feedsFrame;
//    XZFeeds *feeds;
    NSMutableArray *homePageFeeds;
    NSMutableDictionary *feedsResponse;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    login = [XZLogin sharedInstance];
    homePageFeeds = [[NSMutableArray alloc]init];
    
//    UIButton *logIn = [[UIButton alloc]initWithFrame:CGRectMake(20, 90, 80, 20)];
//    [logIn setTitle:@"加载好友动态" forState:UIControlStateNormal];
//    [logIn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [logIn sizeToFit];
//    [logIn addTarget:self action:@selector(requestHomePageData) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:logIn];
    
    // 添加tableview
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tableView.delegate = self;
    tableView.dataSource = self;
    
//    tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.view addSubview:tableView];
    
//    [tableView registerClass:[XZFeedsCell class] forCellReuseIdentifier:@"FeedsCell"];
    
//    [self requestHomePageData];
}

//- (void)viewWillAppear:(BOOL)animated {
//    if (login.isLogin == YES) {
//        [self requestHomePageData];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestHomePageData {
    NSString *URLString = getFriendsTimeline;
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @feedCount};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URLString
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSLog(@">>>Request Home Page Success");
//             NSLog(@">>>Request Home Page Success: %@--%@",[responseObject class], responseObject);
             NSArray *statuses = [responseObject objectForKey:@"statuses"];
             for (int i = 0; i < [statuses count]; i++) {
                 XZFeeds *feeds = [[XZFeeds alloc]init];
                 feeds.statuses = statuses[i];
                 [homePageFeeds addObject:feeds];
             }
             // 刷新界面
             [tableView reloadData];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@">>>Request Home Page Error: %@",error);
         }
     ];
}

#pragma mark - Table view datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZFeedsCell *cell = [XZFeedsCell cellWithTableView:tableView];
    if ([homePageFeeds count] != 0) {
        feedsFrame = [[XZFeedsFrame alloc]init];
        NSLog(@"current feed: %ld",indexPath.row);
        feedsFrame.feeds = homePageFeeds[indexPath.row];
        cell.feedsFrame = feedsFrame;
        return cell;
    } else {
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return feedsFrame.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feedCount;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TabBarController Delegate

// 手动点击tabBarItem也可以触发请求
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    UINavigationController *controller = (UINavigationController *)viewController;
    if ([controller.childViewControllers[0] isKindOfClass:[self class]]) {
        NSLog(@"手动点击tabBar触发页面刷新");
        [self requestHomePageData];
    }
}

@end
