//
//  XZImageViewController.m
//  Flute
//
//  Created by xia on 27/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZImageViewController.h"
#import "Masonry.h"
#import "WeiboAPI.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "XZScrollView.h"
#import "XZFeedsCell.h"

const float initHeight = 300.0f;
const float imagePadding = 30.0f;
const float kWidthAddingPadding = 375 + imagePadding;

@interface XZImageViewController ()

@property (nonatomic) XZScrollView *scrollView;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSMutableArray *imageViews; // 存储imageView

@end

@implementation XZImageViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    [self prefersStatusBarHidden]; // 隐藏状态栏
    
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 3;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.containerView];
    
    if (self.imageUrls && [self.imageUrls count]) {
        __block CGFloat maxHeight = 0;
        for (int i = 0; i < [self.imageUrls count]; i++) {
            CGFloat positionX = kWidthAddingPadding * i;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(positionX,
                                                                                  (kScreenHeight - initHeight) / 2.0, kScreenWidth,
                                                                                  initHeight)];
            [self.containerView addSubview:imageView];
            [self.imageViews addObject:imageView];
            
            [imageView sd_setImageWithURL:self.imageUrls[i] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                CGFloat imageHeight = [self adjustImageHeight:image inImageView:imageView];
                if (maxHeight < imageHeight) {
                    maxHeight = imageHeight;
                }
                
                if (imageHeight >= kScreenHeight) {
                    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.scrollView);
                        make.height.equalTo([NSNumber numberWithFloat:imageHeight]);
                        make.width.equalTo([NSNumber numberWithFloat:kScreenWidth]);
                        make.left.equalTo(self.scrollView).offset(kWidthAddingPadding * i);
                    }];
                } else {
                    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.equalTo(self.scrollView);
                        make. height.equalTo([NSNumber numberWithFloat:imageHeight]);
                        make.width.equalTo([NSNumber numberWithFloat:kScreenWidth]);
                        make.left.equalTo(self.scrollView).offset(kWidthAddingPadding * i);
                    }];
                }
            }];
            
        }
        
        if (maxHeight) {
            self.scrollView.contentSize = CGSizeMake(kWidthAddingPadding * [self.imageUrls count], maxHeight);
            self.scrollView.directionalLockEnabled = YES;
            self.containerView.frame = CGRectMake(0, 0, kWidthAddingPadding * [self.imageUrls count], maxHeight);
        }
    }
    
    // 配置pageControl
    self.pageControl.numberOfPages = [self.imageUrls count];
    self.pageControl.currentPage = [self.imageUrls indexOfObject:self.imageUrl];
    [self.pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl]; // pageControl是添加在self.view上，而不是self.scrollView上
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@30);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.scrollView setContentOffset:CGPointMake(kWidthAddingPadding * self.pageControl.currentPage, 0) animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method

// 将图片居中，等比放大到imageView中显示
- (CGFloat)adjustImageHeight:(UIImage *)image inImageView:(UIImageView *)imageView {
    if (image && image.size.height != 0 && image.size.width != 0) {
        return image.size.height *  imageView.frame.size.width / image.size.width;
    } else {
        NSLog(@"图片为空，或尺寸为0，加载失败");
        return 0;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Event response

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// pageControl变更时，滑动UIScrollView到对应页面
- (void)pageControlChanged:(UIPageControl *)sender {
    int page = (int)sender.currentPage;
    [self.scrollView setContentOffset:CGPointMake(page * kWidthAddingPadding, 0) animated:YES];
    UIImageView *imageView = self.imageViews[page];
    self.scrollView.contentSize = CGSizeMake(kWidthAddingPadding * [self.imageUrls count], imageView.frame.size.height);
}

#pragma mark - UIScrollView delegate

// UIScrollView上的放大操作
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
}

// UIScrollView滑动时，变更对应的pageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x / kWidthAddingPadding;
    
    if (page != self.pageControl.currentPage) {
        self.pageControl.currentPage = page;
        UIImageView *imageView = self.imageViews[page];
        
        self.scrollView.contentSize = CGSizeMake(kWidthAddingPadding * [self.imageUrls count], imageView.frame.size.height);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == 0) {
        scrollView.pagingEnabled = YES; // 左右横划时分页
        [scrollView scrollsToTop];
    } else {
//        scrollView.pagingEnabled = NO; // 上下滑动时不分页
    }
}

#pragma mark - getter and setter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[XZScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width + imagePadding, self.view.frame.size.height)];
        _scrollView.contentSize = CGSizeMake(kWidthAddingPadding,kScreenHeight);
        _scrollView.backgroundColor = [UIColor blackColor];
    }
    return _scrollView;
}

//- (UIImageView *)imageView {
//    if (!_imageView) {
//        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (kScreenHeight - initHeight) / 2.0, kScreenWidth, initHeight)];
////        _imageView.userInteractionEnabled = NO;
//    }
//    return _imageView;
//}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
    }
    return _pageControl;
}

- (NSArray *)imageUrls {
    if (!_imageUrls) {
//        _imageUrls = [[NSArray alloc]init];
        
        // 获取同一个feed中的其他imageUrl
        if (self.imageUrl) {
            NSInteger index = 0;
            for (int i = 0; i <  [XZImageUrls count]; i++) {
                NSArray *arr = XZImageUrls[i];
                if ([arr containsObject:self.imageUrl]) {
                    index = i; // 这里还要对不同的feeds，同样的转发内容，同样的图片url做判断，先放着
                    break;
                }
            }
            _imageUrls = XZImageUrls[index];
        }
    }
    return _imageUrls;
}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return _imageViews;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidthAddingPadding * [self.imageUrls count], kScreenHeight)];
    }
    return _containerView;
}

@end

