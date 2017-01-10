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
//    XZFeedsFrame *feedsFrame;
    NSMutableArray *requestedHomeFeeds;
    NSMutableArray *cachedHomeFeeds;
    NSMutableArray *homeFeeds;
    NSMutableDictionary *feedsResponse;
    NSInteger pageNumber;
    CGFloat offsetY;
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
    
    // 上拉刷新控件
    __weak __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMore];
    }];
    
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
}

- (void)configureDB {
    dbOp = [[XZDBOperation alloc]init];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cachePaths objectAtIndex:0];
    DBPath = [cacheDirectory stringByAppendingPathComponent:@"weibo.db"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    
    login = [XZLogin sharedInstance];
    homeFeeds = [[NSMutableArray alloc]init];
    requestedHomeFeeds = [[NSMutableArray alloc]init];

    pageNumber = 1;
    offsetY = 0.0;
    sinceId = 0;
    maxId = 0;
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    // 配置数据库相关操作
    [self configureDB];
    
    // 配置子视图
    [self configureSubviews];
    
    
//    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
#ifdef DEBUG_CACHE
    [self loadCachedHomePageData]; // 先加载缓存
#else
    [self requestHomePageData]; // 无论是否有缓存，立即刷新
#endif
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey]CGPointValue];
//    NSLog(@"observe-contentOffset: %f", contentOffset.y);
//}


// 上拉刷新触发
- (void)loadMore {
    pageNumber += 1;
#ifdef DEBUG_CACHE
    [self loadCachedHomePageData];
#else
    [self requestHomePageData];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"homeViewController dealloc");
//    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)requestHomePageData {
    NSString *URLString = getFriendsTimeline;
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @FEEDS_COUNT,
                                 @"page": [NSNumber numberWithInteger:pageNumber],
                                 @"since_id": [NSNumber numberWithInteger:sinceId],
                                 @"max_id": [NSNumber numberWithInteger:maxId]};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URLString
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             
             NSLog(@">>>Request Home Page Success");
             NSArray *statuses = [responseObject objectForKey:@"statuses"];
             NSInteger count = [statuses count];
             
             for (NSInteger i = 0; i < count; i++) {
                 XZStatus *feeds = [[XZStatus alloc]init];
                 feeds.statuses = statuses[i];
                 [requestedHomeFeeds addObject:feeds];
                 [homeFeeds addObject:feeds];
             }
             
             // 请求成功要向DB写缓存
             BOOL success = [dbOp writeToDB:DBPath withData:requestedHomeFeeds];
             
//             homeFeeds = requestedHomeFeeds;
             [self.tableView setContentOffset:CGPointMake(0, offsetY)];
             [self.tableView reloadData];
             [self.tableView.mj_footer endRefreshing]; //  隐藏刷新控件
             
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [self.tableView.mj_footer endRefreshing];
             NSLog(@">>>Request Home Page Error: %@",error);
             pageNumber -= 1;
         }
     ];
}

- (void)loadCachedHomePageData {
    NSString *sql = @"";
    
    if (pageNumber == 1) { // 首次加载，需要判断db是否存在，是否有缓存数据，并取出maxId
        [dbOp DBExistAtPath:DBPath];
        maxId = [dbOp dataExistInDB:DBPath];
        NSLog(@"maxId is: %ld", maxId);
        
        if (maxId) { // 有缓存先读取缓存
//            sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE idstr > %@ ORDER BY idstr DESC LIMIT 20;", params[@"since_id"]];
//            sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE idstr <= %@ ORDER BY idstr DESC LIMIT 20;", params[@"max_id"]];
//        }
            
            sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE id <= %ld ORDER BY id DESC LIMIT %d", maxId, FEEDS_COUNT];
        }
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE id < %ld ORDER BY id DESC LIMIT %d", maxId, FEEDS_COUNT];
    }
    
    NSLog(@"sql: %@", sql);
    
    cachedHomeFeeds = (NSMutableArray *)[dbOp fetchDataFromDB:DBPath usingSql:sql]; // 数组，内存字典
    NSInteger count = MIN([cachedHomeFeeds count], FEEDS_COUNT); // 缓存数据可能不够一页
    
    if (count == 0) {
        NSLog(@"本地缓存已全部加载完毕, 向网络请求");
        [self requestHomePageData];
    } else {
        for (NSInteger i = 0; i < count; i++) {
            XZStatus *feeds = [[XZStatus alloc]init];
            feeds.statuses = cachedHomeFeeds[i];
//            sinceID = feeds.statusId;
            [homeFeeds addObject:feeds];
            if (i == count - 1) {
                maxId = feeds.statusId;
                NSLog(@"maxId's changed to: %ld", maxId);
            }
        }

        [self.tableView reloadData];
    }
    
    [self.tableView.mj_footer endRefreshing]; // 隐藏刷新控件
}

#pragma mark - Table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZFeedsCell *cell = [XZFeedsCell cellWithTableView:tableView];

    if ([homeFeeds count] != 0) {
        XZFeedsFrame *feedsFrame = [[XZFeedsFrame alloc]init];
        NSLog(@"current feed: %ld",indexPath.row);
        feedsFrame.feeds = homeFeeds[indexPath.row];
        cell.feedsFrame = feedsFrame;
        return cell;
    } else {
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZFeedsFrame *feedsFrame = [[XZFeedsFrame alloc]init];
    feedsFrame.feeds = homeFeeds[indexPath.row];
    NSLog(@"Row %ld Cell Heigh: %f", (long)indexPath.row, feedsFrame.cellHeight);
    return feedsFrame.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = FEEDS_COUNT * pageNumber;
    
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
//        pageNumber += 1;
        
#ifdef DEBUG_CACHE
        NSLog(@"手动点击tabBar不触发页面刷新");
        [self.tableView reloadData];
#else
        NSLog(@"手动点击tabBar触发页面刷新");
        [self requestHomePageData];
#endif
    }
}

#pragma mark - UIScrollView delegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    offsetY = self.tableView.contentOffset.y;
//    NSLog(@"222tableView ContentOffset : %f",self.tableView.contentOffset.y);
//    NSLog(@"333tableView ContentInset : %f, %f",self.tableView.contentInset.top, self.tableView.contentInset.bottom);
//    NSLog(@"444tableView ContentSize : %f, %f",self.tableView.contentSize.width, self.tableView.contentSize.height);
//}

@end
