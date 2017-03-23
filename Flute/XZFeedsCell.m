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
#import "TTTAttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation XZFeedsCell

static NSString *identifier = @"FeedsCell";

static inline NSRegularExpression * UserRegularExpression() {
    static NSRegularExpression *_userRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userRegularExpression = [[NSRegularExpression alloc]
                                  initWithPattern:@"@([\u4e00-\u9fa5]|[0-9]|[a-zA-Z]|_|-)+"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil]; // 用户昵称只支持汉字、中英文、数字、下划线、中划线
    });
    
    return _userRegularExpression;
}

static inline NSRegularExpression * TopicRegularExpression() {
    static NSRegularExpression *_topicRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _topicRegularExpression = [[NSRegularExpression alloc]
                                   initWithPattern:@"#[^#]+#" // 注意规避#xx##yy#这种话题情况
                                   options:NSRegularExpressionCaseInsensitive
                                   error:nil]; // 话题以#开头并结尾
    });
    
    return _topicRegularExpression;
}

// 初始化cell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
//    [self configureSubViews];
    return self;
}

#pragma mark - Setter
// 为各个子控件赋值，并根据不同数据源隐藏多余的控件
- (void)setStatus:(XZStatus *)status {
    [self configureSubViews];
    [self configureData:status];
    [self configureConstraints:status];
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [self configureConstraints:self.status];
//}

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
    self.contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
    self.repostTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.repostTextLabel.numberOfLines = 0;
    self.repostTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
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

- (void)configureData:(XZStatus *)status {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:status.icon]
                     placeholderImage:nil];
    
    self.nameLabel.text = status.name;
    
    // 已经在frame上判断过，这里是否可以不重复判断？不确定先这样写着。
    if (status.text != nil) {
        [self transformFromString:status.text inLabel:self.contentLabel];
    }
    
    // 原微博
    if (status.thumbnailPic != nil) {
        if ([status.picURLs count] == 1) { // 只有一张配图
            UIImageView *imageView = self.picViews[0];
            [imageView sd_setImageWithURL:[NSURL URLWithString:status.thumbnailPic]
                             placeholderImage:nil];
            
            for (int i = 8; i > 2; i--) {
                [self.picViews removeLastObject];
            }
        } else { // 多张配图
            NSInteger count = [status.picURLs count];
            for (int i = 0; i < count; i++) {
                UIImageView *imageView = self.picViews[i];
                [imageView sd_setImageWithURL:[NSURL URLWithString:status.picURLs[i]]
                             placeholderImage:nil];
            }
            
            count = ceil(count / 3.0) * 3;
            
            for (NSInteger i = 8; i > count - 1; i--) {
                [self.picViews removeLastObject];
            }
        }
    } else {
        // 原博没有配图，隐藏掉所有imageView
        [self.picViews removeAllObjects];
    }
    
    // 被转发微博
    if (status.retweetedStatuses != nil) {
        self.repostNameLabel.text = [NSString stringWithFormat:@"%@ :", status.retweetedName];
//        self.repostTextLabel.text = status.retweetedText;
        [self transformFromString:status.retweetedText inLabel:self.repostTextLabel];
        self.repostLabel.text = [NSString stringWithFormat:@"转发(%ld) ",(long)status.retweetedRepostCounts];
        self.commentLabel.text = [NSString stringWithFormat:@"| 评论(%ld)",(long)status.retweetedCommentCounts];
        if (status.retweetedThumbnailPic != nil) {
            if ([status.retweetedPicURLs count]== 1) { // 只有一张配图
                UIImageView *imageView = self.repostPicViews[0];
                [imageView sd_setImageWithURL:[NSURL URLWithString:status.retweetedThumbnailPic]
                             placeholderImage:nil];
                
                for (int i = 8; i > 2; i--) {
                    [self.repostPicViews removeLastObject];
                }
            } else { // 多张配图
                NSInteger count = [status.retweetedPicURLs count];
                
                for (int i = 0; i < count; i++) {
                    UIImageView *imageView = self.repostPicViews[i];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:status.retweetedPicURLs[i]]
                                 placeholderImage:nil];
                }
                
                count = ceil(count / 3.0) * 3;
                
                for (NSInteger i = 8; i > count - 1; i--) {
                    [self.repostPicViews removeLastObject];
                }
            
            }
        } else { // 无配图
            [self.repostPicViews removeAllObjects];
        }
    } else { // 没有转发微博
        [self.repostBackgroundView removeFromSuperview];
    }
}


// 标识text中的@用户和#话题
- (void)transformFromString:(NSString *)str inLabel:(TTTAttributedLabel *)label{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    NSRegularExpression *topicRegular = TopicRegularExpression();
    NSRegularExpression *userRegular = UserRegularExpression();
    
    // 使用正则匹配目标字符串，所匹配到的结果存入array
    NSArray *topicMatches = [topicRegular matchesInString:str
                                                  options:0
                                                    range:NSMakeRange(0, [str length])];
    NSArray *userMatches = [userRegular matchesInString:str
                                                options:0
                                                  range:NSMakeRange(0, [str length])];

    // 遍历结果
    for(NSTextCheckingResult *match in topicMatches) {
        NSRange range = [match range];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
    }

    for(NSTextCheckingResult *match in userMatches) {
        NSRange range = [match range];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
//        NSString *mStr = [str substringWithRange:range];
//        NSLog(@"%@", mStr);
    }
    
    // 要先设置text，再addLink，点击效果才能正常生效
    [label setText:attrStr];
    
    // 遍历结果
    for(NSTextCheckingResult *match in topicMatches) {
        [label addLinkWithTextCheckingResult:match];
    }
    
    for(NSTextCheckingResult *match in userMatches) {
//        NSRange range = [match range];
//        NSURL *url = [NSURL URLWithString:[str substringWithRange:range]];
        [label addLinkWithTextCheckingResult:match];
    }
}


// 为各子控件添加约束
- (void)configureConstraints:(XZStatus *)status {
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
    if ([self.picViews count]) {
        [self configurePicConstaints:self.picViews leftAndUpAllign:self.contentLabel backgroundView:self.contentView];
    }
    
    // 没有转发其他微博
    if (status.retweetedStatuses == nil) {
        if ([self.picViews count]) { // 正文有配图
            [self.picViews.lastObject mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView).offset(-PADDING_TEN);
            }];
        } else { // 正文没配图
            [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView).offset(-PADDING_TEN);
            }];
        }
    } else { // 有转发其他微博
        if ([self.picViews count]) { // 正文有配图
            UIImageView *imageView = self.picViews.lastObject;
            [self.repostBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentLabel.mas_left);
                make.top.equalTo(imageView.mas_bottom).offset(PADDING_FIVE);
                make.width.equalTo([NSNumber numberWithInt:self.contentLabel.preferredMaxLayoutWidth]);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-PADDING_TEN);
            }];
        } else { // 正文没配图
            [self.repostBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentLabel.mas_left);
                make.top.equalTo(self.contentLabel.mas_bottom).offset(PADDING_FIVE);
                make.width.equalTo([NSNumber numberWithInt:self.contentLabel.preferredMaxLayoutWidth]);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-PADDING_TEN);
            }];
        }
        
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
        }];
        
        // 被转发的原博评论数添加约束
        [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.repostLabel.mas_right).offset(PADDING_FIVE);
            make.top.equalTo(self.repostLabel.mas_top);
        }];
        
        // 被转发的原博配图
        if ([self.repostPicViews count]) { // 被转发微博有配图
            [self configurePicConstaints:self.repostPicViews leftAndUpAllign:self.repostLabel backgroundView:self.repostBackgroundView];
        } else {
            [self.repostLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.repostBackgroundView.mas_bottom).offset(-PADDING_FIVE);
            }];
        }
    }
}

- (void)configurePicConstaints:(NSMutableArray *)picImageViews leftAndUpAllign:(UIView *)allignView backgroundView:(UIView *)backgroundView {
    
    NSInteger count = [picImageViews count];

    UIImageView *imageView0 = picImageViews[0];
    UIImageView *imageView1 = picImageViews[1];
    UIImageView *imageView2 = picImageViews[2];
    
    [imageView0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(allignView.mas_left); // 首行首个左侧，与转发label左侧、第2行／第3行首个元素左侧对齐
        make.top.equalTo(allignView.mas_bottom).offset(PADDING_FIVE); // 首行首个顶部，与转发label底部，间隔PADDING_FIVE
        make.top.equalTo(@[imageView1.mas_top, imageView2.mas_top]); // 首行首个顶部，与首行第2个／第3个顶部对齐
        make.height.equalTo(imageView0.mas_width);
        make.height.equalTo(@[imageView1.mas_height, imageView2.mas_height]);
        make.width.equalTo(@[imageView1.mas_width, imageView2.mas_width]); // 所有view等高等宽
    }];
    
    [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView0.mas_right).offset(PADDING_FIVE); // 首行第2个左侧，与首行第1个右侧，间隔PADDING_FIVE
    }];
    
    [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView1.mas_right).offset(PADDING_FIVE); // 首行第3个左侧，与首行第2个右侧，间隔PADDING_FIVE
        make.right.equalTo(backgroundView.mas_right).offset(-PADDING_FIVE); // 首行第3个右侧，与backgroundView的右侧，间隔－PADDING_FIVE
    }];
    
    if (count == 3) {
        [imageView2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(backgroundView.mas_bottom).offset(-PADDING_FIVE);
        }];
    }
    
    if (count >= 6) {
        UIImageView *imageView3 = picImageViews[3];
        UIImageView *imageView4 = picImageViews[4];
        UIImageView *imageView5 = picImageViews[5];
        
        [imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView0); // 首行首个左侧，与转发label左侧、第2行／第3行首个元素左侧对齐
            make.top.equalTo(imageView0.mas_bottom).offset(PADDING_FIVE); // 第2行首个的顶部，与首行首个的底部，间隔PADDING_FIVE
            make.top.equalTo(@[imageView4.mas_top, imageView5.mas_top]); // 第2行首个的顶部，与第2行第2/3个的顶部对齐
            make.height.equalTo(@[imageView0.mas_height, imageView4.mas_height, imageView5.mas_height]);
            make.width.equalTo(@[imageView0.mas_width, imageView4.mas_width, imageView5.mas_width]); // 所有view等高等宽
        }];
        
        [imageView4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView1.mas_left);
        }];
        
        [imageView5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView2.mas_left);
            make.right.equalTo(backgroundView.mas_right).offset(-PADDING_FIVE); // 首行第3个右侧，与backgroundView的右侧，间隔－PADDING_FIVE
        }];
        
        if (count == 6) {
            [imageView5 mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(backgroundView.mas_bottom).offset(-PADDING_FIVE);
            }];
        }
        
        if (count == 9) {
            UIImageView *imageView6 = picImageViews[6];
            UIImageView *imageView7 = picImageViews[7];
            UIImageView *imageView8 = picImageViews[8];
            
            [imageView6 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(imageView0); // 首行首个左侧，与转发label左侧、第2行／第3行首个元素左侧对齐
                make.top.equalTo(imageView3.mas_bottom).offset(PADDING_FIVE); // 第2行首个的顶部，与首行首个的底部，间隔PADDING_FIVE
                make.top.equalTo(@[imageView7.mas_top, imageView8.mas_top]); // 第2行首个的顶部，与第2行第2/3个的顶部对齐
                make.height.equalTo(@[imageView0.mas_height, imageView7.mas_height, imageView8.mas_height]);
                make.width.equalTo(@[imageView0.mas_width, imageView7.mas_width, imageView8.mas_width]); // 所有view等高等宽
            }];
            
            [imageView7 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(imageView1.mas_left);
            }];
            
            [imageView8 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(imageView2.mas_left);
                make.right.equalTo(backgroundView.mas_right).offset(-PADDING_FIVE); // 首行第3个右侧，与backgroundView的右侧，间隔－PADDING_FIVE
                make.bottom.equalTo(backgroundView.mas_bottom).offset(-PADDING_FIVE); // 第3行首个的底部，与背景view的底部，间隔PADDING_FIVE
            }];
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

/**
 计算文本高度
 
 @param str 待计算文本
 @param font 文本字体
 @param maxSize 最大范围
 @return 文本占用的实际高度
 */
- (CGSize)sizeWithString:(NSMutableAttributedString *)str font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *dict = @{NSFontAttributeName: font};
    NSString *innerStr;
    
    if ([str isKindOfClass:NSMutableAttributedString.class]) {
        innerStr = [str string];
    } else {
        innerStr = (NSString *)str;
    }
    
    CGSize size = [innerStr boundingRectWithSize:maxSize
                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:dict
                                    context:nil].size;
    return size;
}



@end
