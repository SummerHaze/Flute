//
//  XZFeedsFrame.m
//  Flute
//
//  Created by xia on 12/16/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZFeedsFrame.h"
#import "XZStatus.h"
#import "WeiboAPI.h"
#import <Masonry.h>

@implementation XZFeedsFrame
{
    CGFloat picWidth;
    CGFloat iconViewWidth;
    CGFloat iconViewHeight;
    CGFloat baseX;
    CGFloat baseY;
    
    CGFloat backgroundViewX;
    CGFloat backgroundViewY;
}

// setter
- (void)setFeeds:(XZStatus *)feeds {
    _feeds = feeds;

    // 固定长宽
    iconViewWidth = 30;
    iconViewHeight = 30;
    picWidth = (WIDTH - iconViewWidth - PADDING_TEN * 3 - PADDING_FIVE * 4) / 3;
    
    // 头像frame
    CGFloat iconViewX = PADDING_TEN;
    CGFloat iconViewY = PADDING_TEN;
    self.iconFrame = CGRectMake(iconViewX, iconViewY, iconViewWidth, iconViewHeight);
    baseX = CGRectGetMaxX(self.iconFrame) + PADDING_TEN;
    baseY = iconViewY;
    
    // 昵称的frame
    CGFloat nameLabelX = baseX;
    CGFloat nameLabelY = baseY;
    CGSize nameSize = [self sizeWithString:_feeds.name
                                      font:FONT_12 // 注意此处的font只是用来计算文本的高度，并不是对label.text设置属性
                                   maxSize:CGSizeMake(WIDTH - PADDING_TEN * 3 - iconViewWidth, MAXFLOAT)];
    CGFloat nameLabelWidth = nameSize.width;
    CGFloat nameLabelHeight = nameSize.height;
    self.nameFrame = CGRectMake(nameLabelX, nameLabelY, nameLabelWidth, nameLabelHeight);
    baseX = nameLabelX;
    baseY = CGRectGetMaxY(self.nameFrame) + PADDING_TEN;
    
    // 原文
    if (_feeds.text != nil) {
        CGFloat contentLabelX = baseX;
        CGFloat contentLabelY = baseY;
        CGSize contentSize = [self sizeWithString:_feeds.text
                                             font:FONT_13
                                          maxSize:CGSizeMake(WIDTH - PADDING_TEN * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat contentLabelWidth = contentSize.width;
        CGFloat contentLabelHeight = contentSize.height;
        self.contentFrame = CGRectMake(contentLabelX, contentLabelY, contentLabelWidth, contentLabelHeight);
        baseY = CGRectGetMaxY(self.contentFrame) + PADDING_TEN;
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
                    self.picFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * i + PADDING_FIVE * i,
                                                                            baseY,
                                                                            picWidth,
                                                                            picWidth)];
                } else if (i >= 3 && i < 6) { // 第二行
                    self.picFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * (i - 3) + PADDING_FIVE * (i - 3),
                                                                            baseY + PADDING_FIVE + picWidth,
                                                                            picWidth,
                                                                            picWidth)];
                    
                } else { // 第三行，配图最多三行
                    self.picFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * i + PADDING_FIVE * (i - 6),
                                                                            baseY + PADDING_FIVE * 2 + picWidth * 2,
                                                                            picWidth,
                                                                            picWidth)];
                    
                }}
        }
        
        
        NSValue *value = self.picFrames.lastObject;
        baseY = CGRectGetMaxY(value.CGRectValue) + PADDING_TEN;
    }
    
    if (_feeds.retweetedStatuses != nil) {
    
        backgroundViewX = baseX;
        backgroundViewY = baseY;
        
        // 被转发微博昵称
        baseX = PADDING_FIVE;
        CGFloat repostNameLabelX = baseX;
        CGSize repostNameSize = [self sizeWithString:_feeds.retweetedName
                                                font:FONT_12
                                             maxSize:CGSizeMake(WIDTH - 5 - PADDING_TEN * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat repostNameLabelWidth = repostNameSize.width;
        CGFloat repostNameLabelHeight = repostNameSize.height;
        CGFloat repostNameLabelY = PADDING_FIVE;
        self.repostNameFrame = CGRectMake(repostNameLabelX, repostNameLabelY, repostNameLabelWidth, repostNameLabelHeight);
        baseY = CGRectGetMaxY(self.repostNameFrame) + PADDING_TEN;
        
        // 被转发微博文字
        CGFloat repostTextLabelX = baseX;
        CGFloat repostTextLabelY = baseY;
        CGSize repostTextSize = [self sizeWithString:_feeds.retweetedText
                                                font:FONT_13
                                             maxSize:CGSizeMake(WIDTH - 5 - PADDING_TEN * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat repostTextLabelWidth = repostTextSize.width;
        CGFloat repostTextLabelHeight = repostTextSize.height;
        self.repostTextFrame = CGRectMake(repostTextLabelX, repostTextLabelY, repostTextLabelWidth, repostTextLabelHeight);
        baseY = CGRectGetMaxY(self.repostTextFrame) + PADDING_TEN;
        
        // 被转发微博转发数
        CGFloat repostLabelX = baseX;
        CGFloat repostLabelY = baseY;
        CGSize repostLabelSize = [self sizeWithString:[NSString stringWithFormat:@"转发(%ld) ",(long)_feeds.retweetedRepostCounts]
                                                 font:FONT_13
                                              maxSize:CGSizeMake(WIDTH - 5 - PADDING_TEN * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat repostLabelWidth = repostLabelSize.width;
        CGFloat repostLabelHeight = repostLabelSize.height;
        self.repostCountsFrame = CGRectMake(repostLabelX, repostLabelY, repostLabelWidth, repostLabelHeight);
        
        // 被转发微博评论数
        CGFloat commentLabelX = CGRectGetMaxX(self.repostCountsFrame);
        CGFloat commentLabelY = baseY;
        CGSize commentLabelSize = [self sizeWithString:[NSString stringWithFormat:@"| 评论(%ld)",(long)_feeds.retweetedCommentCounts]
                                                  font:FONT_13
                                               maxSize:CGSizeMake(WIDTH - 5 - PADDING_TEN * 3 - iconViewWidth, MAXFLOAT)];
        CGFloat commentLabelWidth = commentLabelSize.width;
        CGFloat commentLabelHeight = commentLabelSize.height;
        self.repostCommentCountsFrame = CGRectMake(commentLabelX, commentLabelY, commentLabelWidth, commentLabelHeight);
        baseY = CGRectGetMaxY(self.repostCountsFrame);
        
        // 被转发微博配图
        if (self.feeds.retweetedThumbnailPic != nil) {
            baseY += PADDING_TEN;
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
                        self.repostPicFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * i + PADDING_FIVE * i,
                                                                                      baseY,
                                                                                      picWidth,
                                                                                      picWidth)];
                    } else if (i >= 3 && i < 6) { // 第二行
                        self.repostPicFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * (i - 3) + PADDING_FIVE * (i - 3),
                                                                                      baseY + PADDING_FIVE + picWidth,
                                                                                      picWidth,
                                                                                      picWidth)];
                        
                    } else if (i >= 6 && i < 9) { // 第三行，配图最多三行
                        self.repostPicFrames[i] = [NSValue valueWithCGRect:CGRectMake(baseX + picWidth * (i - 6) + PADDING_FIVE * (i - 6),
                                                                                      baseY + PADDING_FIVE * 2 + picWidth * 2,
                                                                                      picWidth,
                                                                                      picWidth)];
                        
                    }}
            }
            NSValue *value = self.repostPicFrames.lastObject;
            baseY = CGRectGetMaxY(value.CGRectValue) + PADDING_TEN;
        }
        
        CGFloat backgroundWidth = WIDTH - PADDING_TEN * 3 - iconViewWidth;
        CGFloat backgroundHeight = baseY;
        self.repostBackgroundViewFrame = CGRectMake(backgroundViewX, backgroundViewY, backgroundWidth, backgroundHeight);
        baseY = backgroundHeight + backgroundViewY;
    }

    // cell高度跟随内容自适应
    self.cellHeight = baseY + PADDING_TEN;

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
