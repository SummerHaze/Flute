//
//  XZUserViewController.h
//  Flute
//
//  Created by xia on 19/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZFeedsViewController.h"

@class XZUserView;

@interface XZUserViewController : XZFeedsViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) XZUserView *userView;

@property (nonatomic) NSString *selectedUserName;

@end
