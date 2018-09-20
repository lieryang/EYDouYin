//
//  EYHomeWorksViewController.m
//  EYDouYin
//
//  Created by 李二洋 on 2018/9/18.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import "EYHomeWorksViewController.h"

@interface EYHomeWorksViewController ()

@end

@implementation EYHomeWorksViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor redColor];

    id<UIGestureRecognizerDelegate> target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    [self.view addGestureRecognizer:pan];

    [UIApplication sharedApplication].statusBarHidden = NO;
}

@end