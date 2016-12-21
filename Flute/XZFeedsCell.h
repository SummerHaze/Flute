//
//  XZFeedsCell.h
//  Flute
//
//  Created by xia on 12/16/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XZFeedsFrame;

@interface XZFeedsCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;        // 头像
@property (nonatomic, strong) UILabel *nameLabel;           // 昵称
@property (nonatomic, strong) UILabel *contentLabel;        // 文字,此处用textLabel与其父类的属性名称冲突
@property (nonatomic, strong) NSMutableArray *picViews;     // 正文配图

@property (nonatomic, strong) UILabel *repostNameLabel;     // 被转发的原博昵称
@property (nonatomic, strong) UILabel *repostTextLabel;     // 被转发的原博文字
@property (nonatomic, strong) NSMutableArray *repostPicViews;  // 转发微博配图

//@property (nonatomic, strong) UILabel *attitudeLabel;     // 赞
@property (nonatomic, strong) UILabel *repostLabel;         // 转发
@property (nonatomic, strong) UILabel *commentLabel;        // 评论

@property (nonatomic, strong) XZFeedsFrame *feedsFrame;     // frame model


+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
