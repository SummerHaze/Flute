//
//  XZLogin.m
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZLogin.h"
#import "WeiboSDK.h"
#import "Singleton.h"
#import "WeiboAPI.h"

@implementation XZLogin

SingletonM(Login)

- (void)authorizeWithSSO {
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    request.userInfo = nil;
    [WeiboSDK sendRequest:request];
}


@end
