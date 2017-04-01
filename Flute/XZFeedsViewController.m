//
//  XZFeedsViewController.m
//  Flute
//
//  Created by xia on 22/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZFeedsViewController.h"
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
#import "XZImageViewController.h"
#import "XZImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString *identifier = @"FeedsCell";
static NSString *friendsTimelinesTable = @"friendsTimelines";
static NSString *userTimelinesTable = @"userTimelines";
static NSString *dbName = @"weibo";
static NSString *userName = @"sumha201";

@interface XZFeedsViewController ()

@property (nonatomic) XZLogin *login;
@property (nonatomic, assign) NSUInteger maxId;

@end

@implementation XZFeedsViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置子视图
    [self configureSubviews];
    
    // 初始化实例变量
    self.tabBarController.delegate = self; // 开启点击tabBar整体刷新

    //加载数据
    [self.dataLoader.dbOperation DBExistAtPath:self.dbPath name:dbName]; // 没有DB则创建之
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageTouched:)
                                                 name:XZImageViewPressedNotification
                                               object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public methods
- (void)loadData {
    // 根据请求type，判断从哪个table中取缓存数据
    if (self.pageNumber == 1) {
        if (self.type == XZFeedsRequestTypeFriendsTimeline) {
            self.maxId = [self.dataLoader.dbOperation dataExistInDB:self.dbPath andTable:friendsTimelinesTable]; // 如果DB中有数据，取出最新item的id，即maxId
        } else if (self.type == XZFeedsRequestTypeUserTimeline) {
            self.maxId = [self.dataLoader.dbOperation dataExistInDB:self.dbPath andTable:userTimelinesTable];
        }
    }
    
    if (self.maxId) { // 本地有缓存
        [self loadFromLocalCache:self.type];
    } else { // 本地无缓存
        [self requestFromNetworkWithMaxId:1 type:self.type withDeletingDB:NO];
    }
}

#pragma mark - private methods

- (void)configureSubviews {
    // 添加tableview
    self.feedsTableView.delegate = self;
    self.feedsTableView.dataSource = self;
    [self.view addSubview:self.feedsTableView];
    
    // 上拉刷新控件
    __weak __typeof(self) weakSelf = self;
    self.feedsTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadByDraggingUp];
    }];
    
    // 下拉刷新控件
    self.feedsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadByDraggingDown];
    }];
}

// 下拉刷新触发，需要清空DB
- (void)loadByDraggingDown {
    self.pageNumber = 1;
    [self.feeds removeAllObjects];
    [self requestFromNetworkWithMaxId:1 type:self.type withDeletingDB:YES];
}

// 上拉刷新触发，不需要清空DB
- (void)loadByDraggingUp {
    self.pageNumber += 1;
    [self loadData];
}

// 从本地缓存加载数据
- (void)loadFromLocalCache:(XZFeedsRequestType)type {
    NSMutableArray *caches;
    if (type == XZFeedsRequestTypeFriendsTimeline) {
        caches = [NSMutableArray arrayWithArray:[self.dataLoader loadFriendsTimelineFromLocalDBAtPath:self.dbPath withMaxId:self.maxId andPageNumber:self.pageNumber]];
    } else if (type == XZFeedsRequestTypeUserTimeline) {
        caches = [NSMutableArray arrayWithArray:[self.dataLoader loadUserTimelineFromLocalDBAtPath:self.dbPath withMaxId:self.maxId andPageNumber:self.pageNumber]];
    }
    
    if ([caches count] >= self.pageNumber * FEEDS_COUNT) { // 本地有缓存
        NSLog(@"本地有缓存，加载");
        XZStatus *status = caches.lastObject;
        self.maxId = status.statusId;
        NSLog(@"loadCache>>> maxId's changed to: %ld", (unsigned long)self.maxId);
        
        [self.feeds addObjectsFromArray:caches];
        [self.feedsTableView reloadData];
        [self.feedsTableView.mj_footer endRefreshing]; // 隐藏刷新控件
        [self.feedsTableView.mj_header endRefreshing];
    } else { // 本地缓存已经读取完毕，没有更多，网络加载
        NSLog(@"本地无缓存，从网络拉取");
        [self requestFromNetworkWithMaxId:self.maxId type:self.type withDeletingDB:NO];
    }
}

// 从网络加载数据
- (void)requestFromNetworkWithMaxId:(NSUInteger)maxId
                               type:(XZFeedsRequestType)type
                     withDeletingDB:(BOOL)delete {
    __weak typeof(self) weakSelf = self; // 避免block内的强引用循环
    if (type == XZFeedsRequestTypeFriendsTimeline) {
        [self.dataLoader requestFriendsTimelineWithSinceId:0 orMaxId:maxId completion:^(BOOL success, id responseObject) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (success == YES) {
                NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
                NSArray *statuses = [responseObject objectForKey:@"statuses"];
                NSLog(@"XZFeedsViewController--request statuses count: %lu", (unsigned long)[statuses count]);
                
                if (statuses.count && statuses.count % 5 == 0) { // 返回数据不能为空，且必须是5的倍数（有些时候后台返回4条数据，原因未知）
                    NSUInteger maxIdChanged = 1;
                    
                    // 处理responseObject
                    for (NSInteger i = 0; i < [statuses count]; i++) {
                        XZStatus *feeds = [[XZStatus alloc]init];
                        feeds.statuses = statuses[i];
                        [results addObject:feeds];
                        
                        if (i == [statuses count] - 1) {
                            maxIdChanged = feeds.statusId;
                            NSLog(@"request>>> maxId‘s changed to: %ld", (unsigned long)maxIdChanged);
                        }
                    }
                    [self.feeds addObjectsFromArray:results];
                    
                    [strongSelf.feedsTableView reloadData];
                    [strongSelf.feedsTableView.mj_footer endRefreshing]; // 隐藏刷新控件
                    [strongSelf.feedsTableView.mj_header endRefreshing];
                    
                    self.maxId = maxIdChanged;
                    
                    // 清空DB中原有的数据，下拉刷新才需要
                    if (delete == YES) {
                        BOOL success= [strongSelf.dataLoader.dbOperation deleteFromDB:self.dbPath table:friendsTimelinesTable];
                        if (success) {
                            NSLog(@"直接从网络拉取，清空数据库成功");
                        }
                    }
                    
                    // 请求成功要向DB写缓存
                    [strongSelf.dataLoader.dbOperation writeFriendsTimelineToDB:self.dbPath withData:results];
                } else { // 返回数据为空时容错处理
                    [strongSelf.feedsTableView.mj_footer endRefreshing]; // 隐藏刷新控件
                    [strongSelf.feedsTableView.mj_header endRefreshing];
                    strongSelf.pageNumber -= 1;
                }
            }
            else {
                [strongSelf.feedsTableView.mj_header endRefreshing];
                [strongSelf.feedsTableView.mj_footer endRefreshing];
                strongSelf.pageNumber -= 1;
            }
        }];
    } else if (type == XZFeedsRequestTypeUserTimeline) {
        [self.dataLoader requestUserTimelineWithUserId:0 orUserName:userName andMaxId:maxId completion:^(BOOL success, id responseObject) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (success == YES) {
                NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
                NSArray *statuses = [responseObject objectForKey:@"statuses"];
                
                if (statuses.count) { // 可能返回数据为空
                    NSUInteger maxIdChanged = 1;
                    
                    // 处理responseObject
                    for (NSInteger i = 0; i < [statuses count]; i++) {
                        XZStatus *feeds = [[XZStatus alloc]init];
                        feeds.statuses = statuses[i];
                        [results addObject:feeds];
                        
                        if (i == [statuses count] - 1) {
                            maxIdChanged = feeds.statusId;
                            NSLog(@"request>>> maxId‘s changed to: %ld", (unsigned long)maxIdChanged);
                        }
                    }
                    [self.feeds addObjectsFromArray:results];
                    
                    [strongSelf.feedsTableView reloadData];
                    [strongSelf.feedsTableView.mj_footer endRefreshing]; // 隐藏刷新控件
                    [strongSelf.feedsTableView.mj_header endRefreshing];
                    
                    self.maxId = maxIdChanged;
                    
                    // 清空DB中原有的数据，下拉刷新才需要
                    if (delete == YES) {
                        BOOL success= [strongSelf.dataLoader.dbOperation deleteFromDB:self.dbPath table:userTimelinesTable];
                        if (success) {
                            NSLog(@"直接从网络拉取，清空数据库成功");
                        }
                    }
                    
                    // 请求成功要向DB写缓存
                    [strongSelf.dataLoader.dbOperation writeUserTimelineToDB:self.dbPath withData:results];
                } else { // userTimeline只允许返回5条，上拉刷新后返回数据为空，容错处理
                    [strongSelf.feedsTableView.mj_footer endRefreshing]; // 隐藏刷新控件
                    [strongSelf.feedsTableView.mj_header endRefreshing];
                    strongSelf.pageNumber -= 1;
                }
            }
            else {
                [strongSelf.feedsTableView.mj_header endRefreshing];
                [strongSelf.feedsTableView.mj_footer endRefreshing];
                strongSelf.pageNumber -= 1;
            }
        }];
    }

}

// 放大显示图片
- (void)imageTouched:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSURL *thumbnailUrl = [userInfo objectForKey:@"imageUrl"]; // 拿到的是小图Url
    
//    // 转换成中图url
//    NSString *thumbString = [thumbnailUrl absoluteString];
//    NSString *middleString;
//    if ([thumbString containsString:@"thumbnail"]) {
//        middleString = [thumbString stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
//    }
//    NSURL *middleUrl = [NSURL URLWithString:middleString];
    
    XZImageViewController *vc = [[XZImageViewController alloc] init];
    vc.imageUrl = thumbnailUrl;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"cellForRowAtIndexPath: %ld", (long)indexPath.row);
    XZFeedsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if ([self.feeds count] == FEEDS_COUNT * self.pageNumber) {
        cell.status = self.feeds[indexPath.row];
        
        cell.contentLabel.delegate = self;
        cell.contentLabel.userInteractionEnabled = YES;
        cell.repostTextLabel.delegate = self;
        cell.repostTextLabel.userInteractionEnabled = YES;
        
        return cell;
    } else {
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.feeds count] == FEEDS_COUNT * self.pageNumber) {
        CGFloat height = [tableView fd_heightForCellWithIdentifier:identifier
                                                  cacheByIndexPath:indexPath
                                                     configuration:^(XZFeedsCell *cell)
                          {
                              cell.status = self.feeds[indexPath.row]; // 配置Cell的数据源，与cellForRowAtIndexPath干的事一致
                          }];
        return height;
    } else {
        return 0;
    }
}

- (void)configureCell:(XZFeedsCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.status = self.feeds[indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = FEEDS_COUNT * self.pageNumber;
    
    if (!count) { // count为0时隐藏footer，这里体验再优化下
        self.feedsTableView.mj_footer.hidden = YES;
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
        [self.feedsTableView setContentOffset:CGPointMake(0, -64) animated:YES];
        [self.feedsTableView.mj_header beginRefreshing];
        
        //#ifdef DEBUG_CACHE
        //        NSLog(@"手动点击tabBar不触发页面刷新");
        //        [self.tableView reloadData];
        //#else
        //        NSLog(@"手动点击tabBar触发页面刷新");
        //        [self requestHomePageData];
        //#endif
        
    }
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    NSString *str = [label.text substringWithRange:result.range];
    NSLog(@"selected checking result: %@", str);
    
    if ([str hasPrefix:@"@"]) { // 跳转用户个人主页
        XZUserViewController *user = [[XZUserViewController alloc]init];
        user.selectedUserName = [str substringFromIndex:1];
        user.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:user animated:YES];
    } else if([str hasPrefix:@"#"]) { // 跳转话题搜索页
        XZTopicViewController *topic = [[XZTopicViewController alloc]init];
        topic.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:topic animated:YES];
    }
}

#pragma mark - getters and setters

- (NSUInteger)maxId {
    if (!_maxId) {
        _maxId = 1;
    }
    return _maxId;
}

- (NSInteger)pageNumber {
    if (!_pageNumber) {
        _pageNumber = 1;
    }
    return _pageNumber;
}

- (NSMutableArray *)feeds {
    if (!_feeds) {
        _feeds = [NSMutableArray arrayWithCapacity:1];
    }
    return _feeds;
}

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

- (NSString *)dbPath {
    if (!_dbPath) {
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [cachePaths objectAtIndex:0];
        _dbPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", dbName]];
    }
    return _dbPath;
}

- (UITableView *)feedsTableView {
    if (!_feedsTableView) {
        _feedsTableView = [[UITableView alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//       _feedsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 375, 667)];
        [_feedsTableView registerClass:[XZFeedsCell class] forCellReuseIdentifier:identifier];
        _feedsTableView.fd_debugLogEnabled = NO;
        
    }
    return _feedsTableView;
}


@end
