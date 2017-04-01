//
//  XZImageViewController.h
//  Flute
//
//  Created by xia on 27/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) NSURL *imageUrl; // 用户点中的image url
@property (nonatomic, copy) NSArray *imageUrls;

@end
