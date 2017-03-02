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

@interface XZHomeViewController()

@property (nonatomic) XZLogin *login;

@end

@implementation XZHomeViewController
{
    NSMutableArray *_requestedHomeFeeds;
    NSMutableArray *_cachedHomeFeeds;
    NSMutableDictionary *_feedsResponse;
    NSUInteger _maxId;
    NSMutableArray *_friendsTimelineIDs;
}

static NSString *identifier = @"FeedsCell";

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // 配置子视图
    [self configureSubviews];
    
    // 初始化实例变量
    self.tabBarController.delegate = self;
    self.tableView.fd_debugLogEnabled = NO;
    _homeFeeds = [NSMutableArray arrayWithCapacity:1];
    _requestedHomeFeeds = [NSMutableArray arrayWithCapacity:1];
    _pageNumber = 1;
    _maxId = 0;
    
//    [self getFriendsTimelineIDs];
    
    //加载数据
    [self.dataLoader.dbOperation DBExistAtPath:self.dbPath]; // 没有DB则创建之
    _maxId = [self.dataLoader.dbOperation dataExistInDB:self.dbPath]; // 如果DB中有数据，取出最新item的id，即maxId
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"homeViewController dealloc");
}

#pragma mark - getter

- (XZLogin *)login {
    if (!_login) {
        _login = [XZLogin sharedInstance];
    }
    return _login;
}

- (XZDataLoader *)dataLoader {
    if (!_dataLoader) {
        _dataLoader = [[XZDataLoader alloc]init];
    }
    return _dataLoader;
}

#pragma mark - Load data from network or cache

- (NSString *)dbPath {
    if (!_dbPath) {
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [cachePaths objectAtIndex:0];
        _dbPath = [cacheDirectory stringByAppendingPathComponent:@"weibo.db"];
    }
    return _dbPath;
}

//- (void)getFriendsTimelineIDs {
//    [self.dataLoader requestFriendsTimelineIDsWithSinceId:0
//                                                  orMaxId:1
//                                             completion:^(BOOL success, NSArray *results) {
//                                                   if (success == YES) {
//                                                       _friendsTimelineIDs = [NSMutableArray arrayWithArray:results];
//                                                   }
//                                               }];
//}

- (void)loadData {
    if (_maxId) { // 本地有缓存
        [self loadFromLocalCache];
    } else { // 本地无缓存
        [self requestFromNetwork:1 withDeletingDB:NO];
    }
}

// 从本地缓存加载数据
- (void)loadFromLocalCache {
    NSMutableArray *cacheFeeds = [NSMutableArray arrayWithArray:
                                  [self.dataLoader loadCachedHomePageDataFromPath:self.dbPath
                                                                        withMaxId:_maxId
                                                                    andPageNumber:self.pageNumber
                                   ]];
    if ([cacheFeeds count]) { // 本地有缓存
        NSLog(@"本地有缓存，加载");
        XZStatus *status = cacheFeeds.lastObject;
        _maxId = status.statusId;
        NSLog(@"loadCache>>> maxId's changed to: %ld", (unsigned long)_maxId);
        
        [_homeFeeds addObjectsFromArray:cacheFeeds];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing]; // 隐藏刷新控件
        [self.tableView.mj_header endRefreshing];
    } else { // 本地缓存已经读取完毕，没有更多，网络加载
        NSLog(@"本地无缓存，从网络拉取");
        [self requestFromNetwork:_maxId withDeletingDB:NO];
    }
}

// 从网络加载数据
- (void)requestFromNetwork:(NSUInteger)MaxId withDeletingDB:(BOOL)delete {
    NSLog(@"直接从网络拉取");
    [self.dataLoader requestHomePageDataWithSinceId:0
                                            orMaxId:MaxId
                                         completion:^(BOOL success, NSArray *results, NSUInteger MaxIdChanded) {
        if (success == YES) {
            [_homeFeeds addObjectsFromArray:results];
            
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing]; // 隐藏刷新控件
            [self.tableView.mj_header endRefreshing];
            
            _maxId = MaxIdChanded;
            
            // 清空DB中原有的数据，下拉刷新才需要
            if (delete == YES) {
                BOOL success= [self.dataLoader.dbOperation deleteFromDB:self.dbPath];
                if (success) {
                    NSLog(@"直接从网络拉取，清空数据库成功");
                }
            }
            
            // 请求成功要向DB写缓存
            [self.dataLoader.dbOperation writeToDB:self.dbPath withData:results];
        } else {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            _pageNumber -= 1;
        }
    }];
}

#pragma mark - Configure subviews

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

// 下拉刷新触发，需要清空DB
- (void)loadByDraggingDown {
    _pageNumber = 1;
    [_homeFeeds removeAllObjects];
    [self requestFromNetwork:1 withDeletingDB:YES];
}

// 上拉刷新触发，不需要清空DB
- (void)loadByDraggingUp {
    _pageNumber += 1;
    [self loadData];
}


#pragma mark - Table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XZFeedsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    if ([_homeFeeds count] == FEEDS_COUNT * _pageNumber) {
        NSLog(@"current feed: %ld",(long)indexPath.row);
        cell.status = _homeFeeds[indexPath.row];
        return cell;
    } else {
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_homeFeeds count] == FEEDS_COUNT * _pageNumber) {
        CGFloat height = [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(XZFeedsCell *cell)
        {
            cell.status = _homeFeeds[indexPath.row]; // 配置Cell的数据源，与cellForRowAtIndexPath干的事一致
        }];
//        CGFloat height = [tableView fd_heightForCellWithIdentifier:identifier configuration:^(XZFeedsCell *cell)
//        {
//          cell.status = homeFeeds[indexPath.row]; // 配置Cell的数据源，与cellForRowAtIndexPath干的事一致
//        }];
        return height;
    } else {
        return 0;
    }
}

- (void)configureCell:(XZFeedsCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    cell.status = _homeFeeds[indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = FEEDS_COUNT * _pageNumber;
    
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
