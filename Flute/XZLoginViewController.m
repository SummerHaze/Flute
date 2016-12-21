//
//  XZLoginViewController.m
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZLoginViewController.h"
#import "XZLogin.h"
#import "XZHomeViewController.h"

@interface XZLoginViewController ()

@end

@implementation XZLoginViewController
{
    XZLogin *login;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    login = [XZLogin sharedInstance];
    
    self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *logIn = [[UIButton alloc]initWithFrame:CGRectMake(20, 50, 80, 20)];
    [logIn setTitle:@"微博账号登录" forState:UIControlStateNormal];
    [logIn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [logIn sizeToFit];
    [logIn addTarget:self action:@selector(loginUsingSDK) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *signup = [[UIButton alloc]initWithFrame:CGRectMake(20, 90, 80, 40)];
    [signup setTitle:@"微博账号注册" forState:UIControlStateNormal];
    [signup setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [signup sizeToFit];
    [signup addTarget:self action:@selector(signup) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *forget = [[UIButton alloc]initWithFrame:CGRectMake(20, 190, 80, 40)];
    [forget setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forget setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [forget addTarget:self action:@selector(forget) forControlEvents:UIControlEventTouchUpInside];
    [forget sizeToFit];
    
    [self.view addSubview:logIn];
    [self.view addSubview:signup];
    [self.view addSubview:forget];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginUsingSDK {
    [login authorizeWithSSO];
}


#pragma mark - WeiboSDK delegate

// 异步获取到鉴权接口的返回，不能保证
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
//    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) { // 取消登录不可以remove subview
        login.isLogin = YES;
        
        WBAuthorizeResponse *authorizeResponse = (WBAuthorizeResponse *)response;
        login.userID = authorizeResponse.userID;
        login.accessToken = authorizeResponse.accessToken;
        NSLog(@"login token: %@", login.accessToken);
        login.expirationDate = authorizeResponse.expirationDate;
        login.refreshToken = authorizeResponse.refreshToken;
    
        // 将登录成功结果存储在本地
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"isLogin"];
        [userDefaults setObject:login.accessToken forKey:@"accessToken"];
        [userDefaults setObject:login.expirationDate forKey:@"expirationDate"];
    
        [userDefaults synchronize];
    
        // 登录成功后触发homepage的刷新
        UITabBarController *tabBarController = (UITabBarController *)self.view.superview.nextResponder;
        UINavigationController *navigationController = tabBarController.childViewControllers[0];
        XZHomeViewController *homeViewController = (XZHomeViewController *)navigationController.topViewController;
        [homeViewController requestHomePageData];
    
        // 登录成功后，将loginViewController从顶层移除
//        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
//        [self.parentViewController dismissViewControllerAnimated:self completion:nil];
//    }
}

@end
