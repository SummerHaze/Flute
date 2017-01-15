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
#import "UITableView+FDTemplateLayoutCell.h"

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
    XZDBOperation *dbOp;
    NSString *DBPath;
    
//    NSUInteger _sinceId; // 下拉刷新需要指定的参数，返回ID比sinceId（发布时间比sinceId晚）大的微博数据，默认为0
//    NSUInteger _maxIdFromNetwork;  // 上拉刷新需要指定的参数，返回ID比maxId（发布时间比maxId早）小的微博数据，默认为0
//    NSUInteger _maxIdFromCache;
    NSUInteger _maxId;
}

static NSString *identifier = @"FeedsCell";

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    
    login = [XZLogin sharedInstance];
    homeFeeds = [NSMutableArray arrayWithCapacity:1];
    requestedHomeFeeds = [NSMutableArray arrayWithCapacity:1];

    pageNumber = 1;
    
    _maxId = 0;
//    _maxIdFromCache = 0;
//    _maxIdFromNetwork = 1; // 拉取小于或等于maxId的feeds，为了去掉等于而做的暂时兼容
    
    // 配置数据库相关操作
    [self configureDB];
    
    // 配置子视图
    [self configureSubviews];
    
    // 加载数据
    [self loadData];
    

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"homeViewController dealloc");
}

#pragma mark - Configure when viewDidLoad

- (void)configureSubviews {
    // 添加tableview
    self.tableView = [[UITableView alloc]initWithFrame:
                      CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[XZFeedsCell class] forCellReuseIdentifier:@"FeedsCell"];
    self.tableView.fd_debugLogEnabled = YES;
    
    [self.view addSubview:self.tableView];
    
    // 上拉刷新控件
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadByDraggingUp];
    }];
    
    // 下拉刷新控件
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadByDraggingDown];
    }];
}

- (void)configureDB {
    dbOp = [[XZDBOperation alloc]init];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cachePaths objectAtIndex:0];
    DBPath = [cacheDirectory stringByAppendingPathComponent:@"weibo.db"];
}

- (void)loadData {
    if (pageNumber == 1) { // 首次加载
        [dbOp DBExistAtPath:DBPath]; // 没有DB则创建之
        _maxId = [dbOp dataExistInDB:DBPath]; // 是否有数据，如果有取出最新item的id，即maxId
    }
    
    if (_maxId) {
        NSMutableArray *cacheFeeds = [NSMutableArray arrayWithArray:[self loadCachedHomePageDataWithMaxId:_maxId]];
        if ([cacheFeeds count]) { // 本地有缓存
            [homeFeeds addObjectsFromArray:cacheFeeds];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing]; // 隐藏刷新控件
            [self.tableView.mj_header endRefreshing];
        } else { // 本地缓存已经读取完毕，没有更多，网络加载
            [self requestHomePageDataWithSinceId:0 orMaxId:_maxId];
        }
    } else { // 本地无缓存
        [self requestHomePageDataWithSinceId:0 orMaxId:1];
    }

}

// 下拉刷新触发
- (void)loadByDraggingDown {
    pageNumber = 1;
    [homeFeeds removeAllObjects];
    [self requestHomePageDataWithSinceId:0 orMaxId:1];
}

// 上拉刷新触发
- (void)loadByDraggingUp {
    pageNumber += 1;
    [self loadData];
}

#pragma mark - Load data from local DB or network

- (void)requestHomePageDataWithSinceId:(NSUInteger)sinceId orMaxId:(NSUInteger)maxId {
    NSString *URLString = getFriendsTimeline;
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"count": @FEEDS_COUNT,
//                                 @"page": [NSNumber numberWithInteger:pageNumber],
                                 @"since_id": [NSNumber numberWithInteger:sinceId],
                                 @"max_id": [NSNumber numberWithInteger:maxId - 1]};
    
    NSMutableArray *requestFeeds = [NSMutableArray arrayWithCapacity:1];
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
                 [requestFeeds addObject:feeds];
                 
                 if (i == count - 1) {
                     _maxId = feeds.statusId;
                     NSLog(@"request>>> maxId‘s changed to: %ld", _maxId);
                 }
             }
             
             [homeFeeds addObjectsFromArray:requestFeeds];
             
             [self.tableView reloadData];
             [self.tableView.mj_footer endRefreshing]; // 隐藏刷新控件
             [self.tableView.mj_header endRefreshing];
             
             // 请求成功要向DB写缓存
             [dbOp writeToDB:DBPath withData:requestFeeds];
            
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [self.tableView.mj_header endRefreshing];
             [self.tableView.mj_footer endRefreshing];
             NSLog(@">>>Request Home Page Error: %@",error);
             pageNumber -= 1;
         }
     ];
}

- (NSArray *)loadCachedHomePageDataWithMaxId:(NSUInteger)maxId {
    NSString *sql;
    if (pageNumber == 1) {
        sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE id <= %ld ORDER BY id DESC LIMIT %d", maxId, FEEDS_COUNT];
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM status WHERE id < %ld ORDER BY id DESC LIMIT %d", maxId, FEEDS_COUNT];
    }
    NSLog(@"sql: %@", sql);
    
    cachedHomeFeeds = (NSMutableArray *)[dbOp fetchDataFromDB:DBPath usingSql:sql]; // 数组，内存字典
    NSInteger count = MIN([cachedHomeFeeds count], FEEDS_COUNT); // 缓存数据可能不够一页
    
    if (count == 0) {
        NSLog(@"本地无缓存");
        return nil;
    } else {
        NSLog(@"本地有缓存, 加载");
        NSMutableArray *caches = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger i = 0; i < count; i++) {
            XZStatus *feeds = [[XZStatus alloc]init];
            feeds.statuses = cachedHomeFeeds[i];
            [caches addObject:feeds];
            
            if (i == count - 1) {
                _maxId = feeds.statusId;
                NSLog(@"cached>>> maxId's changed to: %ld", _maxId);
            }
        }
        return caches;
    }
}

#pragma mark - Table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZFeedsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    if ([homeFeeds count] == FEEDS_COUNT * pageNumber) {
        NSLog(@"current feed: %ld",indexPath.row);
        cell.status = homeFeeds[indexPath.row];
        return cell;
    } else {
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    XZFeedsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if ([homeFeeds count] == FEEDS_COUNT * pageNumber) {
        CGFloat height = [tableView fd_heightForCellWithIdentifier:identifier configuration:^(XZFeedsCell *cell)
        {
            cell.status = homeFeeds[indexPath.row];
        }];
//        NSLog(@"caculated height: %f",height);
        return height;
    } else {
        return 0;
    }
    
}

- (void)configureCell:(XZFeedsCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    cell.status = homeFeeds[indexPath.row];
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
    
    typedef NS_ENUM(NSUInteger, ZOCMachineState) {
        ZOCMachineStateNone,
        ZOCMachineStateIdle,
        ZOCMachineStateRunning,
        ZOCMachineStatePaused
    };
}

#pragma mark - TabBarController Delegate

// 手动点击tabBarItem也可以触发请求
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    UINavigationController *controller = (UINavigationController *)viewController;
    if ([controller.childViewControllers[0] isKindOfClass:[self class]]) {
    
        NSLog(@"手动点击tabBar触发页面刷新");
        [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
        [self.tableView.mj_header beginRefreshing];
        
//#ifdef DEBUG_CACHE
//        NSLog(@"手动点击tabBar不触发页面刷新");
//        [self.tableView reloadData];
//#else
//        NSLog(@"手动点击tabBar触发页面刷新");
//        [self requestHomePageData];
//#endif

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
