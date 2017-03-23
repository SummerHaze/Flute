//
//  XZUserViewController.m
//  Flute
//
//  Created by xia on 19/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZUserViewController.h"
#import "XZUserInfoView.h"
#import "Masonry.h"
#import "WeiboAPI.h"
#import "XZFeedsCell.h"
#import "XZUserView.h"
#import "XZDataLoader.h"
#import "XZUserProfile.h"
#import "XZStatus.h"
#import "UITableView+FDTemplateLayoutCell.h"

static NSString *identifier = @"FeedsCell";
static NSString *userName = @"sumha201";

@implementation XZUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.type = XZFeedsRequestTypeUserTimeline;
    [self loadData];
    
    self.navigationItem.title = self.selectedUserName;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.userView = [[XZUserView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, HEIGHT + 30)];
    self.feedsTableView.tableHeaderView = self.userView;
    
    self.userView.userInfoView.delegate = self;
    [self.userView.pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // 非App授权账号拉不到微博数等信息
    __weak typeof(self) weakSelf = self; // 避免block内的强引用循环
    [self.dataLoader requestUserProfile:userName completion:^(BOOL success, id responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success == YES) {
            NSLog(@"get user profile success");
            strongSelf.userView.userInfoView.userProfile.userProfileDic = responseObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.userView.userInfoView setNeedsLayout];
            });
        }
    }];
}

// pageControl变更时，滑动UIScrollView到对应页面
- (void)pageControlChanged:(UIPageControl *)sender {
    int page = (int)sender.currentPage;
    [self.userView.userInfoView setContentOffset:CGPointMake(page * CGRectGetWidth(self.userView.userInfoView.frame), 0) animated:YES];
}

#pragma mark - UIScrolView delegate
// UIScrollView滑动时，变更对应的pageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x / CGRectGetWidth(self.userView.userInfoView.frame);
    
    if (page != self.userView.pageControl.currentPage) {
        self.userView.pageControl.currentPage = page;
    }
}


@end
