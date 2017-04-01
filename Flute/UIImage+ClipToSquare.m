//
//  UIImage+ClipToSquare.m
//  Flute
//
//  Created by xia on 28/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "UIImage+ClipToSquare.h"

@implementation UIImage (ClipToSquare)

// 以图片center为center，将图片裁剪成正方形
+ (UIImage *)clipToSquareOfImage:(UIImage *)image {
    // 图片原始size
    CGSize imageSize = image.size;
    CGFloat width, height, positionX, positionY;
    
    if (imageSize.height >= imageSize.width) {
        width = height = imageSize.width;
        positionX = 0;
        positionY = (imageSize.height - height) / 2.0;
    } else {
        width = height = imageSize.height;
        positionX = (imageSize.width - width) / 2.0;
        positionY = 0;
    }
    
//    CGSize size = CGSizeMake(width, height);
    CGRect rect = CGRectMake(positionX, positionY, width, height);
    
//    // 设置当前的context尺寸
//    UIGraphicsBeginImageContext(size);
//    
//    // 将image按照指定位置，绘制在context上
//    [image drawInRect: rect];
//    
//    // 从当前context中创建一个改变大小后的图片
//    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    // 使当前的context出堆栈
//    UIGraphicsEndImageContext()
    
    //将UIImage转换成CGImageRef
    CGImageRef sourceImageRef = [image CGImage];
    
    //按照给定的矩形区域进行剪裁
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    
    //将CGImageRef转换成UIImage
    UIImage *clipImage = [UIImage imageWithCGImage:newImageRef];
    
    // 将clipImage保存到本地Library-caches目录，debug用
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *path = [NSString stringWithFormat:@"%@/123.jpg", [paths objectAtIndex:0]];
//    NSData *data = UIImageJPEGRepresentation(clipImage, (CGFloat)1.0);
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager createFileAtPath:path contents:data attributes:nil];
    
    return clipImage;
    
}


@end
