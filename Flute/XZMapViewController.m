//
//  XZMapViewController.m
//  Flute
//
//  Created by xia on 23/02/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZMapViewController.h"
#import <MapKit/MapKit.h>

@interface XZMapViewController ()

@property (nonatomic) MKMapView *mapView;

@end

@implementation XZMapViewController
{
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBar];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, screenRect.size.width, screenRect.size.height - 64)];
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    
    [self startStandardUpdates];
    // Do any additional setup after loading the view.
}

- (void)configureNavigationBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, 44)];
    
    //创建UINavigationItem
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Editing"];
    [navigationBar pushNavigationItem: item animated:YES];
    [self.view addSubview: navigationBar];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    [item setTitle:@"Locating"];
    [item setRightBarButtonItem:rightButtonItem];
    
    [navigationBar setItems:[NSArray arrayWithObject: item]];
}

- (void)startStandardUpdates {
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        [locationManager requestWhenInUseAuthorization]; //使用中授权
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [locationManager requestWhenInUseAuthorization];
    }
    
    if(![CLLocationManager locationServicesEnabled]){
        NSLog(@"请开启定位:设置 > 隐私 > 位置 > 定位服务");
    }
    
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization]; // 永久授权
        [locationManager requestWhenInUseAuthorization]; //使用中授权
    }
    
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    [self dismissViewControllerAnimated:self completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
