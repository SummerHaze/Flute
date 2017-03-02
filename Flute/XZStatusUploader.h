//
//  XZStatusUploader.h
//  Flute
//
//  Created by xia on 23/02/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZStatusUploader : NSObject

@property (nonatomic, copy) NSString *statusText;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longtitude;

typedef void (^uploadBlock)(BOOL success);

- (void)updloadStatusWithPic:(NSData *)pic
                  withStatus:(NSString *)status
                withLatitude:(float)latitude
               andLongtitude:(float)longtitude
                  completion:(uploadBlock)block;

- (void)updloadStatus:(NSString *)status
         withLatitude:(float)latitude
        andLongtitude:(float)longtitude
           completion:(uploadBlock)block;

@end
