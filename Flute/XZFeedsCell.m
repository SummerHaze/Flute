//
//  XZFeedsCell.m
//  Flute
//
//  Created by xia on 12/16/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZFeedsCell.h"
#import "XZFeedsFrame.h"
#import "XZStatus.h"
#import "WeiboAPI.h"

@implementation XZFeedsCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"FeedsCell";
    XZFeedsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[XZFeedsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

// 初始化cell，进行一次性的属性设置
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        return self;
    } else {
        return nil;
    }
}

#pragma mark - Setter

- (void)setFeedsFrame:(XZFeedsFrame *)feedsFrame {
    _feedsFrame = feedsFrame;
    
    [self configureRequiredViews];
    [self configureOptionalViews];
    
    [self configureCellData];
    [self configureCellFrame];
}

- (void)configureRequiredViews {
    // 头像
    self.iconView = [[UIImageView alloc]init];
    [self.contentView addSubview:self.iconView];
    
    // 昵称
    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.font = FONT_12;
    [self.contentView addSubview:self.nameLabel];
    
    // 正文
    self.contentLabel = [[UILabel alloc]init];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.font = FONT_13;
    [self.contentView addSubview:self.contentLabel];
}

- (void)configureOptionalViews {
    // 原微博配图
    if (self.feedsFrame.feeds.thumbnailPic != nil) {
        self.picViews = [NSMutableArray arrayWithCapacity:1];
        if (self.feedsFrame.feeds.picURLs == nil) { // 只有一张图
            UIImageView *imageView = [[UIImageView alloc]init];
            [self.contentView addSubview:imageView];
            [self.picViews addObject:imageView];
        } else { // 多张图
            NSInteger repostPicCounts = [self.feedsFrame.feeds.picURLs count];
            for (int i = 0; i < repostPicCounts; i++) {
                UIImageView *imageView = [[UIImageView alloc]init];
                [self.contentView addSubview:imageView];
                [self.picViews addObject:imageView];
            }
        }
    }
    
    // 有转发微博
    if (self.feedsFrame.feeds.retweetedStatuses != nil) {
        // 被转发的原博background view
        self.repostBackgroundView = [[UIView alloc]init];
        self.repostBackgroundView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        [self.contentView addSubview:self.repostBackgroundView];
        
        // 被转发的原博主昵称
        self.repostNameLabel = [[UILabel alloc]init];
        self.repostNameLabel.numberOfLines = 0;
        self.repostNameLabel.font = FONT_12;
        [self.repostBackgroundView addSubview:self.repostNameLabel];
        
        // 被转发的原博原文
        self.repostTextLabel = [[UILabel alloc]init];
        self.repostTextLabel.numberOfLines = 0;
        self.repostTextLabel.font = FONT_13;
        [self.repostBackgroundView addSubview:self.repostTextLabel];
        
        // 被转发的原博转发数
        self.repostLabel = [[UILabel alloc]init];
        self.repostLabel.numberOfLines = 1;
        self.repostLabel.font = FONT_13;
        [self.repostBackgroundView addSubview:self.repostLabel];
        
        // 被转发的原博评论数
        self.commentLabel = [[UILabel alloc]init];
        self.commentLabel.numberOfLines = 1;
        self.commentLabel.font = FONT_13;
        [self.repostBackgroundView addSubview:self.commentLabel];
        
        // 被转发的原博有配图
        if (self.feedsFrame.feeds.retweetedThumbnailPic != nil) {
            self.repostPicViews = [NSMutableArray arrayWithCapacity:1];
            if (self.feedsFrame.feeds.retweetedPicURLs == nil) { // 只有一张图
                UIImageView *imageView = [[UIImageView alloc]init];
                [self.repostBackgroundView addSubview:imageView];
                [self.repostPicViews addObject:imageView];
            } else { // 多张图
                NSInteger repostPicCounts = [self.feedsFrame.feeds.retweetedPicURLs count];
                for (int i = 0; i < repostPicCounts; i++) {
                    UIImageView *imageView = [[UIImageView alloc]init];
                    [self.repostBackgroundView addSubview:imageView];
                    [self.repostPicViews addObject:imageView];
                }
            }
        }
    }
}

// 配置cell的数据model
- (void)configureCellData {
    XZStatus *feeds = self.feedsFrame.feeds;
    
    NSURL *url = [NSURL URLWithString:feeds.icon];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    self.iconView.image = [UIImage imageWithData:data];
    self.nameLabel.text = feeds.name;
    
    // 已经在frame上判断过，这里是否可以不重复判断？不确定先这样写着。
    if (feeds.text != nil) {
        self.contentLabel.text = feeds.text;
    }
    
    if (feeds.thumbnailPic != nil) {
        if (feeds.picURLs == nil) { // 只有一张配图
            NSString *urlString = [NSString stringWithFormat:@"%@", feeds.thumbnailPic];
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            UIImageView *imageView = self.picViews[0];
            [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
        } else { // 多张配图
            for (int i = 0; i < [feeds.picURLs count]; i++) {
                NSString *urlString = [NSString stringWithFormat:@"%@", feeds.picURLs[i]];
                NSURL *url = [NSURL URLWithString:urlString];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                UIImageView *imageView = self.picViews[i];
                [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
            }
        }
    }
    
    if (feeds.retweetedStatuses != nil) {
        self.repostNameLabel.text = feeds.retweetedName;
        self.repostTextLabel.text = feeds.retweetedText;
        self.repostLabel.text = [NSString stringWithFormat:@"转发(%ld) ",(long)feeds.retweetedRepostCounts];
        self.commentLabel.text = [NSString stringWithFormat:@"| 评论(%ld)",(long)feeds.retweetedCommentCounts];
        
        if (feeds.retweetedThumbnailPic != nil) {
            if (feeds.retweetedPicURLs == nil) { // 只有一张配图
                NSString *urlString = [NSString stringWithFormat:@"%@", feeds.retweetedThumbnailPic];
                NSURL *url = [NSURL URLWithString:urlString];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                UIImageView *imageView = self.repostPicViews[0];
                [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
            } else { // 多张配图
                for (int i = 0; i < [feeds.retweetedPicURLs count]; i++) {
                    NSString *urlString = [NSString stringWithFormat:@"%@", feeds.retweetedPicURLs[i]];
                    NSURL *url = [NSURL URLWithString:urlString];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    
                    UIImageView *imageView = self.repostPicViews[i];
                    [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
                }
            }
        }
    }
}

// 配置cell的尺寸model
- (void)configureCellFrame {
    
    self.iconView.frame = self.feedsFrame.iconFrame;
    self.nameLabel.frame = self.feedsFrame.nameFrame;
    
    // 没有原创文字，则不展示该label
    if (self.contentLabel.text != nil) {
        self.contentLabel.frame = self.feedsFrame.contentFrame;
    }
    
    // 原文没配图，不展示该模块
    if ([self.picViews count] != 0) {
        for (int i = 0; i < [self.picViews count]; i++) {
            UIImageView *imageView = self.picViews[i];
            imageView.frame = [self.feedsFrame.picFrames[i] CGRectValue];
        }
    }
    
    // 没有转发内容，不展示该模块
    if (self.feedsFrame.feeds.retweetedStatuses != nil) {
        self.repostBackgroundView.frame = self.feedsFrame.repostBackgroundViewFrame;
        self.repostNameLabel.frame = self.feedsFrame.repostNameFrame;
        self.repostTextLabel.frame = self.feedsFrame.repostTextFrame;
        self.repostLabel.frame = self.feedsFrame.repostCountsFrame;
        self.commentLabel.frame = self.feedsFrame.repostCommentCountsFrame;
        
        if ([self.repostPicViews count] != 0) {
            for (int i = 0; i < [self.repostPicViews count]; i++) {
                UIImageView *imageView = self.repostPicViews[i];
                imageView.frame = [self.feedsFrame.repostPicFrames[i] CGRectValue];
            }
        }
    }
}

- (void)resetCellData {
    for (UIView *item in [self.contentView subviews]) {
        [item removeFromSuperview];
    }
}

// 复用cell前清理之
- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetCellData];
}

@end
