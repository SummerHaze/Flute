//
//  XZTopicViewController.m
//  Flute
//
//  Created by xia on 19/03/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZTopicViewController.h"
#import "Masonry.h"

@interface XZTopicViewController ()

@end

@implementation XZTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"话题";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]init];
    label.text = @"这里什么也没有\n接口权限申请没通过呢。。。";
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize: 16.0f];
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
