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
#import "Masonry.h"

@implementation XZFeedsCell

static NSString *identifier = @"FeedsCell";

// 初始化cell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        return self;
    } else {
        return nil;
    }
}

#pragma mark - Setter
// 为各个子控件赋值，并根据不同数据源隐藏多余的控件
- (void)setStatus:(XZStatus *)status {
    [self configureSubViews];
    [self configureData:status];
    [self configureConstraints];
}

// 添加子控件
- (void)configureSubViews {
    // 头像
    self.iconView = [[UIImageView alloc]init];
    [self.contentView addSubview:self.iconView];
    
    // 昵称
    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.font = FONT_13;
    [self.contentView addSubview:self.nameLabel];
    
    // 正文
    self.contentLabel = [[UILabel alloc]init];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.font = FONT_13;
    [self.contentView addSubview:self.contentLabel];
    
    // 配图
    self.picViews = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        [self.contentView addSubview:imageView];
        [self.picViews addObject:imageView];
    }

    // 被转发的原博背景view
    self.repostBackgroundView = [[UIView alloc]init];
    self.repostBackgroundView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    [self.contentView addSubview:self.repostBackgroundView];
    
    // 被转发的原博主昵称
    self.repostNameLabel = [[UILabel alloc]init];
    self.repostNameLabel.numberOfLines = 0;
    self.repostNameLabel.font = FONT_13;
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
    
    // 被转发的原博配图
    self.repostPicViews = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        [self.repostBackgroundView addSubview:imageView];
        [self.repostPicViews addObject:imageView];
    }
}

// 为各子控件添加约束
- (void)configureConstraints {
    // 头像添加约束
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(PADDING_TEN);
        make.top.equalTo(self.contentView.mas_top).offset(PADDING_TEN);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    // 昵称添加约束
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(PADDING_TEN);
        make.top.equalTo(self.iconView.mas_top);
        make.right.equalTo(self.contentView.mas_right).offset(-PADDING_TEN);
//        make.width.lessThanOrEqualTo(@200);
    }];
    
    // 正文
    // 手动设置label的文字的最大宽度(目的:为了能够计算label的高度,得到最真实的尺寸)
    self.contentLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 30 - 3 * PADDING_TEN;
    CGSize contentSize = [self sizeWithString:self.contentLabel.text
                                         font:FONT_13
                                      maxSize:CGSizeMake(self.contentLabel.preferredMaxLayoutWidth,MAXFLOAT)];
    // 约束
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(PADDING_FIVE);
        make.right.equalTo(self.contentView).offset(-PADDING_TEN);
        make.height.equalTo([NSNumber numberWithFloat:contentSize.height]);
    }];
    
    // 配图
    [self configurePicConstaints:self.picViews leftAndUpAllign:self.contentLabel backgroundView:nil];
    
    // 被转发的原博背景view添加约束
    [self.repostBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentLabel.mas_left);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(PADDING_FIVE);
        make.width.equalTo([NSNumber numberWithInt:self.contentLabel.preferredMaxLayoutWidth]);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-PADDING_TEN);
    }];
    
    // 被转发的原博主昵称添加约束
    [self.repostNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repostBackgroundView.mas_left).offset(PADDING_FIVE);
        make.top.equalTo(self.repostBackgroundView.mas_top).offset(PADDING_FIVE);
    }];
    
    // 被转发的原博原文
    // 手动设置label的文字的最大宽度(目的:为了能够计算label的高度,得到最真实的尺寸)
    self.repostTextLabel.preferredMaxLayoutWidth = self.contentLabel.preferredMaxLayoutWidth - PADDING_TEN;
    contentSize = [self sizeWithString:self.repostTextLabel.text
                                  font:FONT_13
                               maxSize:CGSizeMake(self.repostTextLabel.preferredMaxLayoutWidth,MAXFLOAT)];
    // 添加约束
    [self.repostTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repostNameLabel.mas_left);
        make.top.equalTo(self.repostNameLabel.mas_bottom).offset(PADDING_FIVE);
        make.right.equalTo(self.repostBackgroundView).offset(-PADDING_FIVE);
        make.height.equalTo([NSNumber numberWithFloat:contentSize.height]);
    }];
    
    // 被转发的原博转发数添加约束
    [self.repostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repostBackgroundView.mas_left).offset(PADDING_FIVE);
        make.top.equalTo(self.repostTextLabel.mas_bottom).offset(PADDING_FIVE);
//        make.bottom.equalTo(self.repostBackgroundView.mas_bottom).offset(-PADDING_FIVE);
    }];
    
    // 被转发的原博评论数添加约束
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repostLabel.mas_right).offset(PADDING_FIVE);
        make.top.equalTo(self.repostLabel.mas_top);
//        make.bottom.equalTo(self.repostBackgroundView.mas_bottom).offset(-PADDING_FIVE);
    }];
    
    // 被转发的原博配图
    [self configurePicConstaints:self.repostPicViews leftAndUpAllign:self.repostLabel backgroundView:self.repostBackgroundView];
 
}

- (void)configurePicConstaints:(NSArray *)picImageViews
                    leftAndUpAllign:(UIView *)allignView
                backgroundView:(UIView *)backgroundView {
    
    UIImageView *imageView0 = picImageViews[0];
    UIImageView *imageView1 = picImageViews[1];
    UIImageView *imageView2 = picImageViews[2];
    UIImageView *imageView3 = picImageViews[3];
    UIImageView *imageView4 = picImageViews[4];
    UIImageView *imageView5 = picImageViews[5];
    UIImageView *imageView6 = picImageViews[6];
    UIImageView *imageView7 = picImageViews[7];
    UIImageView *imageView8 = picImageViews[8];
    
    [imageView0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@[allignView.mas_left, imageView3, imageView6]); // 首行首个左侧，与转发label左侧、第2行／第3行首个元素左侧对齐
        make.top.equalTo(allignView.mas_bottom).offset(PADDING_FIVE); // 首行首个顶部，与转发label底部，间隔PADDING_FIVE
        make.top.equalTo(@[imageView1.mas_top, imageView2.mas_top]); // 首行首个顶部，与首行第2个／第3个顶部对齐
        make.height.equalTo(imageView0.mas_width);
        make.height.equalTo(@[imageView1.mas_height, imageView2.mas_height,
                              imageView3.mas_height, imageView4.mas_height, imageView5.mas_height,
                              imageView6.mas_height, imageView7.mas_height, imageView8.mas_height]);
        make.width.equalTo(@[imageView1.mas_width, imageView2.mas_width,
                             imageView3.mas_width, imageView4.mas_width, imageView5.mas_width,
                             imageView6.mas_width, imageView7.mas_width, imageView8.mas_width]); // 所有view等高等宽
    }];
    
    [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView0.mas_right).offset(PADDING_FIVE); // 首行第2个左侧，与首行第1个右侧，间隔PADDING_FIVE
    }];
    
    if ([backgroundView isKindOfClass:[self.repostBackgroundView class]]) {
        [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView1.mas_right).offset(PADDING_FIVE); // 首行第3个左侧，与首行第2个右侧，间隔PADDING_FIVE
            make.right.equalTo(backgroundView.mas_right).offset(-PADDING_FIVE); // 首行第3个右侧，与backgroundView的右侧，间隔－PADDING_FIVE
        }];
    } else {
        [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView1.mas_right).offset(PADDING_FIVE); // 首行第3个左侧，与首行第2个右侧，间隔PADDING_FIVE
            make.right.equalTo(self.contentView.mas_right).offset(-PADDING_FIVE); // 首行第3个右侧，与backgroundView的右侧，间隔－PADDING_FIVE
        }];
    }

    [imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView0.mas_bottom).offset(PADDING_FIVE); // 第2行首个的顶部，与首行首个的底部，间隔PADDING_FIVE
        make.top.equalTo(@[imageView4.mas_top, imageView5.mas_top]); // 第2行首个的顶部，与第2行第2/3个的顶部对齐
    }];
    
    [imageView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView1.mas_left); // 第2行第2个，左侧与第1行第2个左侧对齐
    }];
    
    [imageView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView2.mas_left); // 第2行第3个，左侧与第1行第3个左侧对齐
    }];
    
    if ([backgroundView isKindOfClass:[self.repostBackgroundView class]]) {
        [imageView6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView3.mas_bottom).offset(PADDING_FIVE); // 第3行首个的顶部，与第2行首个的底部，间隔PADDING_FIVE
            make.top.equalTo(@[imageView7.mas_top, imageView8.mas_top]); // 第2行首个的顶部，与同一行的另外两个的顶部对齐
            make.bottom.equalTo(self.repostBackgroundView.mas_bottom).offset(-PADDING_FIVE); // 第3行首个的底部，与背景view的底部，间隔PADDING_FIVE
        }];
    } else {
        [imageView6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView3.mas_bottom).offset(PADDING_FIVE); // 第3行首个的顶部，与第2行首个的底部，间隔PADDING_FIVE
            make.top.equalTo(@[imageView7.mas_top, imageView8.mas_top]); // 第2行首个的顶部，与同一行的另外两个的顶部对齐
        }];
    }

    
    [imageView7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView4.mas_left); // 第3行第2个，左侧与第2行第2个左侧对齐
    }];
    
    [imageView8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView5.mas_left); // 第3行第2个，左侧与第2行第2个左侧对齐
    }];

}

- (void)configureData:(XZStatus *)status{
    NSURL *url = [NSURL URLWithString:status.icon];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    self.iconView.image = [UIImage imageWithData:data];
    self.nameLabel.text = status.name;
    
    // 已经在frame上判断过，这里是否可以不重复判断？不确定先这样写着。
    if (status.text != nil) {
        self.contentLabel.text = status.text;
    }
    
    if (status.thumbnailPic != nil) {
        if (status.picURLs == nil) { // 只有一张配图
            NSString *urlString = [NSString stringWithFormat:@"%@", status.thumbnailPic];
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            UIImageView *imageView = self.picViews[0];
            [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
            
            for (int i = 1; i < 9; i++) {
                UIImageView *imageView = self.picViews[i];
                imageView.hidden = YES;
            }
        } else { // 多张配图
            for (int i = 0; i < [status.picURLs count]; i++) {
                NSString *urlString = [NSString stringWithFormat:@"%@", status.picURLs[i]];
                NSURL *url = [NSURL URLWithString:urlString];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                UIImageView *imageView = self.picViews[i];
                [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
            }
            
            for (int i = [status.picURLs count]; i < 9; i++) {
                UIImageView *imageView = self.picViews[i];
                imageView.hidden = YES;
            }
        }
    } else {
        // 原博没有配图，隐藏掉所有imageView
        for (int i = 0; i < 9; i++) {
            UIImageView *imageView = self.picViews[i];
            imageView.hidden = YES;
        }
    }
    
    if (status.retweetedStatuses != nil) {
        self.repostNameLabel.text = [NSString stringWithFormat:@"%@ :", status.retweetedName];
        self.repostTextLabel.text = status.retweetedText;
        self.repostLabel.text = [NSString stringWithFormat:@"转发(%ld) ",(long)status.retweetedRepostCounts];
        self.commentLabel.text = [NSString stringWithFormat:@"| 评论(%ld)",(long)status.retweetedCommentCounts];
        
        if (status.retweetedThumbnailPic != nil) {
            if (status.retweetedPicURLs == nil) { // 只有一张配图
                NSString *urlString = [NSString stringWithFormat:@"%@", status.retweetedThumbnailPic];
                NSURL *url = [NSURL URLWithString:urlString];
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                UIImageView *imageView = self.repostPicViews[0];
                [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
                
                for (int i = 1; i < 9; i++) {
                    UIImageView *imageView = self.repostPicViews[i];
                    imageView.hidden = YES;
                }
            } else { // 多张配图
                for (int i = 0; i < [status.retweetedPicURLs count]; i++) {
                    NSString *urlString = [NSString stringWithFormat:@"%@", status.retweetedPicURLs[i]];
                    NSURL *url = [NSURL URLWithString:urlString];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    
                    UIImageView *imageView = self.repostPicViews[i];
                    [imageView setImage:[UIImage imageWithData:data]]; // 给每张imageView设置图片数据
                }
                
                for (int i = [status.retweetedPicURLs count]; i < 9; i++) {
                    UIImageView *imageView = self.repostPicViews[i];
                    imageView.hidden = YES;
                }
            }
        }
    } else { // 没有转发微博
        self.repostBackgroundView.hidden = YES;
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

/**
 计算文本高度
 
 @param str 待计算文本
 @param font 文本字体
 @param maxSize 最大范围
 @return 文本占用的实际高度
 */
- (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *dict = @{NSFontAttributeName: font};
    CGSize size = [str boundingRectWithSize:maxSize
                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:dict
                                    context:nil].size;
    return size;
}



@end
