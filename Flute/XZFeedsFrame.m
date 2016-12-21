//
//  XZFeedsFrame.m
//  Flute
//
//  Created by xia on 12/16/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZFeedsFrame.h"
#import "XZFeeds.h"
#import "WeiboAPI.h"


@implementation XZFeedsFrame
{
    CGFloat padding;
    CGFloat picPadding;
    CGFloat picWidth;
    CGFloat iconViewWidth;
    CGFloat iconViewHeight;
    CGFloat baseX;
    CGFloat baseY;
}

// setter
- (void)setFeeds:(XZFeeds *)feeds {
    _feeds = feeds;

    // 间距
    padding = 10;
    picPadding = 3;
    picWidth = (WIDTH - iconViewWidth - padding * 5) / 3;
    iconViewWidth = 30;
    iconViewHeight = 30;
    
    // 头像frame
    CGFloat iconViewX = padding;
    CGFloat iconViewY = padding;
    self.iconFrame = CGRectMake(iconViewX, iconViewY, iconViewWidth, iconViewHeight);
    baseX = CGRectGetMaxX(self.iconFrame) + padding;
    baseY = iconViewY;
    
    // 昵称的frame
    CGFloat nameLabelX = baseX;
    CGFloat nameLabelY = baseY;
    CGSize nameSize = [self sizeWithString:_feeds.name
                                      font:XZNameFont // 注意此处的font只是用来计算文本的高度，并不是对label.text设置属性
                                   maxSize:CGSizeMake(WIDTH - padding * 3 - iconViewWidth, MAXFLOAT)];
    CGFloat nameLabelWidth = nameSize.width;
    CGFloat nameLabelHeight = nameSize.height;
    self.nameFrame = CGRectMake(nameLabelX, nameLabelY, nameLabelWidth, nameLabelHeight);
    baseX = nameLabelX;
    baseY = CGRectGetMaxY(self.nameFrame) + padding;
    
    // 原文
    if (_feeds.text != nil) {
        CGFloat contentLabelX = baseX;
        CGFloat contentLabelY = baseY;
        CGSize contentSize = [self sizeWithString:_feeds.text
                                             font:XZTextFont
                                          maxSize:CGSizeMake(WIDTH - padding * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat contentLabelWidth = contentSize.width;
        CGFloat contentLabelHeight = contentSize.height;
        self.contentFrame = CGRectMake(contentLabelX, contentLabelY, contentLabelWidth, contentLabelHeight);
        baseY = CGRectGetMaxY(self.contentFrame) + padding;
    }
    
    // 原微博配图
    if (_feeds.thumbnailPic != nil) {
        if (self.feeds.picURLs == nil) { // 只有一张图
            self.picFrames = [NSMutableArray arrayWithCapacity:1];
            [self.picFrames addObject:
             [NSValue valueWithCGRect:CGRectMake(baseX,
                                                 baseY,
                                                 picWidth,
                                                 picWidth)]];
        } else { // 有多张图
            NSInteger count = [self.feeds.picURLs count];
            self.picFrames = [NSMutableArray arrayWithCapacity:count];
            for (int i = 0; i < count; i++) {
                if (i < 3) { // 第一行
                    self.picFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * i + picPadding * i,
                                                                            baseY,
                                                                            picWidth,
                                                                            picWidth)];
                } else if (i >= 3 && i < 6) { // 第二行
                    self.picFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * (i - 3),
                                                                            baseY + picPadding + picWidth,
                                                                            picWidth,
                                                                            picWidth)];
                    
                } else { // 第三行，配图最多三行
                    self.picFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * i,
                                                                            baseY + picPadding * 2 + picWidth * 2,
                                                                            picWidth,
                                                                            picWidth)];
                    
                }}
        }
        
        
        NSValue *value = self.picFrames.lastObject;
        baseY = CGRectGetMaxY(value.CGRectValue) + padding;
    }
    
    if (_feeds.retweetedStatuses != nil) {
        // 被转发微博昵称
        baseX += picPadding;
        CGFloat repostNameLabelX = baseX;
        CGSize repostNameSize = [self sizeWithString:_feeds.retweetedName
                                                font:XZNameFont
                                             maxSize:CGSizeMake(WIDTH - 5 - padding * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat repostNameLabelWidth = repostNameSize.width;
        CGFloat repostNameLabelHeight = repostNameSize.height;
        CGFloat repostNameLabelY = baseY + padding ;
        self.repostNameFrame = CGRectMake(repostNameLabelX, repostNameLabelY, repostNameLabelWidth, repostNameLabelHeight);
        baseY = CGRectGetMaxY(self.repostNameFrame) + padding;
        
        // 被转发微博文字
        CGFloat repostTextLabelX = baseX;
        CGFloat repostTextLabelY = baseY;
        CGSize repostTextSize = [self sizeWithString:_feeds.retweetedText
                                                font:XZTextFont
                                             maxSize:CGSizeMake(WIDTH - 5 - padding * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat repostTextLabelWidth = repostTextSize.width;
        CGFloat repostTextLabelHeight = repostTextSize.height;
        self.repostTextFrame = CGRectMake(repostTextLabelX, repostTextLabelY, repostTextLabelWidth, repostTextLabelHeight);
        baseY = CGRectGetMaxY(self.repostTextFrame) + padding;
        
        // 被转发微博转发数
        CGFloat repostLabelX = baseX;
        CGFloat repostLabelY = baseY;
        CGSize repostLabelSize = [self sizeWithString:[NSString stringWithFormat:@"转发(%ld) ",_feeds.retweetedRepostCounts]
                                                 font:XZTextFont
                                              maxSize:CGSizeMake(WIDTH - 5 - padding * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat repostLabelWidth = repostLabelSize.width;
        CGFloat repostLabelHeight = repostLabelSize.height;
        self.repostCountsFrame = CGRectMake(repostLabelX, repostLabelY, repostLabelWidth, repostLabelHeight);
        
        // 被转发微博评论数
        CGFloat commentLabelX = CGRectGetMaxX(self.repostCountsFrame);
        CGFloat commentLabelY = baseY;
        CGSize commentLabelSize = [self sizeWithString:[NSString stringWithFormat:@"| 评论(%ld)",_feeds.retweetedCommentCounts]
                                                  font:XZTextFont
                                               maxSize:CGSizeMake(WIDTH - 5 - padding * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat commentLabelWidth = commentLabelSize.width;
        CGFloat commentLabelHeight = commentLabelSize.height;
        self.repostCommentCountsFrame = CGRectMake(commentLabelX, commentLabelY, commentLabelWidth, commentLabelHeight);
        baseY = CGRectGetMaxY(self.repostCountsFrame);
        
        // 被转发微博配图
        if (self.feeds.retweetedThumbnailPic != nil) {
            baseY += padding;
            if (self.feeds.retweetedPicURLs == nil) { // 只有一张图
                self.repostPicFrames = [NSMutableArray arrayWithCapacity:1];
                [self.repostPicFrames addObject:
                 [NSValue valueWithCGRect:CGRectMake(baseX,
                                                     baseY,
                                                     picWidth,
                                                     picWidth)]];
            } else { // 有多张图
                NSInteger count = [self.feeds.retweetedPicURLs count];
                self.repostPicFrames = [NSMutableArray arrayWithCapacity:count];
                for (int i = 0; i < count; i++) {
                    if (i < 3) { // 第一行
                        self.repostPicFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * i + picPadding * i,
                                                                                      baseY,
                                                                                      picWidth,
                                                                                      picWidth)];
                    } else if (i >= 3 && i < 6) { // 第二行
                        self.repostPicFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * (i - 3),
                                                                                      baseY + picPadding + picWidth,
                                                                                      picWidth,
                                                                                      picWidth)];
                        
                    } else { // 第三行，配图最多三行
                        self.repostPicFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * i,
                                                                                      baseY + picPadding * 2 + picWidth * 2,
                                                                                      picWidth,
                                                                                      picWidth)];
                        
                    }}
            }
            NSValue *value = self.repostPicFrames.lastObject;
            baseY = CGRectGetMaxY(value.CGRectValue) + padding;
        }
    }

    // cell高度跟随内容自适应
    self.cellHeight = baseY;
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
