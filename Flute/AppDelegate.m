//
//  AppDelegate.m
//  Flute
//
//  Created by xia on 12/15/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "AppDelegate.h"
#import "XZHomeViewController.h"
#import "XZSearchViewController.h"
#import "XZProfileViewController.h"
#import "XZLoginViewController.h"
#import "XZLogin.h"
#import "WeiboSDK.h"
#import "WeiboAPI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    XZLoginViewController *_loginViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 注册新浪微博SDK
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];
    
    // 页面构建
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    XZLogin *login = [XZLogin sharedInstance];
    login.isLogin = NO;
    
    // 初始化tabBar控制的几个主页面
    XZHomeViewController *homeViewController = [[XZHomeViewController alloc]init];
    homeViewController.tabBarItem=[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1000];
    XZSearchViewController *searchViewController = [[XZSearchViewController alloc]init];
    searchViewController.tabBarItem=[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1001];
    XZProfileViewController *profileViewController = [[XZProfileViewController alloc]init];
    profileViewController.tabBarItem=[[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemMore tag:1002];
    
    // 为每个页面添加导航栏
    UINavigationController *navHome = [[UINavigationController alloc]initWithRootViewController:homeViewController];
    UINavigationController *navSearch = [[UINavigationController alloc]initWithRootViewController:searchViewController];
    UINavigationController *navProfile = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    
    // 初始化并关联tabBarController
    self.tabBarController = [[UITabBarController alloc]init];
    [self.tabBarController addChildViewController:navHome];
    [self.tabBarController addChildViewController:navSearch];
    [self.tabBarController addChildViewController:navProfile];
    
    self.window.rootViewController = self.tabBarController;
    
    // 获取登录信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isLogin = [userDefaults objectForKey:@"isLogin"];
    // 登录过期逻辑待补充
    
    // 未登录显示登录页面
    if (!isLogin) {
        _loginViewController = [[XZLoginViewController alloc]init];
        [self.window.rootViewController.view addSubview:_loginViewController.view];
//        [self.window.rootViewController addChildViewController:_loginViewController];
//        [_loginViewController didMoveToParentViewController:self.window.rootViewController];
//        [self.window.rootViewController presentViewController:_loginViewController animated:NO completion:nil];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:_loginViewController];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WeiboSDK handleOpenURL:url delegate:_loginViewController];
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//    
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
