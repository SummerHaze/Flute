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
#import "XZStatus.h"
#import "XZFeedsFrame.h"
#import "MJRefresh.h"
#import "XZDBOperation.h"

@interface XZHomeViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation XZHomeViewController
{
    XZLogin *login;
    XZFeedsFrame *feedsFrame;
    NSMutableArray *requestedHomeFeeds;
    NSMutableArray *cachedHomeFeeds;
    NSMutableArray *homeFeeds;
    NSMutableDictionary *feedsResponse;
    NSInteger pageNumber;
    CGPoint offset;
    XZDBOperation *dbOp;
    NSString *DBPath;
    
    NSUInteger sinceId; // 下拉刷新需要指定的参数，返回ID比sinceId（发布时间比sinceId晚）大的微博数据，默认为0
    NSUInteger maxId;  // 上拉刷新需要指定的参数，返回ID比maxId（发布时间比maxId早）小的微博数据，默认为0
}

- (void)configureSubviews {
    // 添加tableview
    self.tableView = [[UITableView alloc]initWithFrame:
                      CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    login = [XZLogin sharedInstance];
    
    homeFeeds = [[NSMutableArray alloc]init];
    requestedHomeFeeds = [[NSMutableArray alloc]init];
    
    pageNumber = 1;
    offset = CGPointZero;
    sinceID = 0;
    
    // 配置子视图
    [self configureSubviews];
    
    // 上拉刷新控件
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
   
    [self loadCachedHomePageData]; // 先加载缓存
//    [self requestHomePageData]; // 无论是否有缓存，立即刷新
}

// 上拉刷新触发
- (void)loadMore {
    pageNumber += 1;
    [self loadCachedHomePageData];
//    [self requestHomePageData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"homeViewController dealloc");
}

- (void)requestHomePageData {
    NSString *URLString = getFriendsTimeline;
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @FEEDS_COUNT,
                                 @"page": [NSNumber numberWithInteger:pageNumber],
                                 @"since_id": [NSNumber numberWithInteger:sinceId]};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URLString
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [self.tableView.mj_footer endRefreshing]; //  隐藏刷新控件
             NSLog(@">>>Request Home Page Success");
//             NSLog(@">>>Request Home Page Success: %@--%@",[responseObject class], responseObject);
             NSArray *statuses = [responseObject objectForKey:@"statuses"];
             NSInteger count = [statuses count];
             
             for (NSInteger i = 0; i < count; i++) {
                 XZStatus *feeds = [[XZStatus alloc]init];
                 feeds.statuses = statuses[i];
                 [requestedHomeFeeds addObject:feeds];
             }
             
             BOOL success = [dbOp writeToDB:DBPath withData:requestedHomeFeeds];
             
             homeFeeds = requestedHomeFeeds;
             [self.tableView reloadData];
             self.tableView.contentOffset = offset;
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [self.tableView.mj_footer endRefreshing];
             NSLog(@">>>Request Home Page Error: %@",error);
             pageNumber -= 1;
         }
     ];
}

- (void)loadCachedHomePageData {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cachePaths objectAtIndex:0];
    DBPath = [cacheDirectory stringByAppendingPathComponent:@"weibo.db"];
    
    dbOp = [[XZDBOperation alloc]init];
    
    if (pageNumber == 1) { // 首次加载，需要判断db是否存在，是否有缓存数据，并取出maxId
        [dbOp DBExistAtPath:DBPath];
        maxId = [dbOp dataExistInDB:DBPath];
        NSLog(@"maxId is: %ld", maxId);
    }
    
    if (maxId) { // 有缓存先读取缓存
        
//        NSString *sql = nil;
//        if (params[@"since_id"]) { // 下拉刷新
//            sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE idstr > %@ ORDER BY idstr DESC LIMIT 20;", params[@"since_id"]];
//        } else if (params[@"max_id"]) { // 上拉刷新
//            sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE idstr <= %@ ORDER BY idstr DESC LIMIT 20;", params[@"max_id"]];
//        }
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE id <= %ld ORDER BY id DESC LIMIT %d", maxId, FEEDS_COUNT + 1];
        cachedHomeFeeds = (NSMutableArray *)[dbOp fetchDataFromDB:DBPath usingSql:sql]; // 数组，内存字典
//        NSMutableArray *tmpFeeds = [NSMutableArray arrayWithCapacity:1];
        
        for (NSInteger i = 0; i < [cachedHomeFeeds count]; i++) {
            XZStatus *feeds = [[XZStatus alloc]init];
            feeds.statuses = cachedHomeFeeds[i]; // sinceID的获取没有这么粗暴！！！
//            sinceID = feeds.statusId;
            [homeFeeds addObject:feeds];
            if (i == [cachedHomeFeeds count] - 1) {
                maxId = feeds.statusId;
                NSLog(@"maxId's changed to: %ld", maxId);
            }
        }
        
        [self.tableView reloadData];
    }

}

//- (NSUInteger)loadMaxId {
//    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cacheDirectory = [cachePaths objectAtIndex:0];
//    DBPath = [cacheDirectory stringByAppendingPathComponent:@"weibo.db"];
//    
//    dbOp = [[XZDBOperation alloc]init];
//    [dbOp DBExistAtPath:DBPath];
//    
//    
//}

#pragma mark - Table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZFeedsCell *cell = [XZFeedsCell cellWithTableView:tableView];

    if ([homeFeeds count] != 0) {
        feedsFrame = [[XZFeedsFrame alloc]init];
        NSLog(@"current feed: %ld",indexPath.row);
        feedsFrame.feeds = homeFeeds[indexPath.row];
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
    NSInteger count = FEEDS_COUNT * MAX(pageNumber,1);
    if (!count) { // count为0时隐藏footer，这里体验再优化下
        self.tableView.mj_footer.hidden = YES;
    }
    return count;
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
        pageNumber += 1;
        [self requestHomePageData];
    }
}

#pragma mark - UIScrollView delegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    offset = self.tableView.contentOffset;
//    NSLog(@"offset: %f",offset.y);
//}

@end
