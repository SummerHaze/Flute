//
//  XZStatusUploader.m
//  Flute
//
//  Created by xia on 23/02/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZStatusUploader.h"
#import "WeiboAPI.h"
#import <AFNetworking/AFNetworking.h>

@implementation XZStatusUploader

- (void)uploadStatusWithPic {
    
}

- (void)updloadStatus:(NSString *)status
         withLatitude:(float)latitude
        andLongtitude:(float)longtitude
           completion:(uploadBlock)block {
    [self updloadStatusWithPic:nil withStatus:status withLatitude:latitude andLongtitude:longtitude completion:^(BOOL success) {
        block(success);
    }];
}

- (void)updloadStatusWithPic:(NSData *)pic
                  withStatus:(NSString *)status
                withLatitude:(float)latitude
               andLongtitude:(float)longtitude
                  completion:(uploadBlock)block {
    NSString *URLString = PostStatus;
    NSDictionary *parameters = @{@"access_token": accessToken,
                                 @"status": status,
                                 @"lat": [NSNumber numberWithFloat:latitude],
                                 @"long": [NSNumber numberWithFloat:longtitude] };
    
    NSMutableArray *requestFeeds = [NSMutableArray arrayWithCapacity:1];
    //    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //    [manager POST:(nonnull NSString *)
    //       parameters:(nullable id)
    //         progress:^(NSProgress * _Nonnull uploadProgress) {
    //        <#code#>
    //    }
    //          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    //        <#code#>
    //    }
    //          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //        <#code#>
    //    }];
}

@end
