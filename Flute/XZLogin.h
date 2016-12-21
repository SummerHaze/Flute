//
//  XZLogin.h
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface XZLogin : NSObject

@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, copy) NSString *refreshToken;

SingletonH(Login)

- (void)authorizeWithSSO;

@end
