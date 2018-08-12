//
//  EYRootViewController.m
//  EYDouYin
//
//  Created by 李二洋 on 2018/7/22.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import "EYRootViewController.h"
#import "EYFindViewController.h"
#import "EYTabBarController.h"
#import "EYNavigationController.h"

@interface EYRootViewController ()

@end

@implementation EYRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:EYScreenBounds];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    //左面view
    EYFindViewController * findViewController = [[EYFindViewController alloc] init];
    findViewController.view.frame = CGRectMake(0, 0, EYScreenWidth, EYScreenHeight);
    EYNavigationController *findNaviController = [[EYNavigationController alloc] initWithRootViewController:findViewController];
    
    [scrollView addSubview:findNaviController.view];
    [self addChildViewController:findNaviController];
    
    //主 view
    EYTabBarController * tabbarController = [[EYTabBarController alloc] init];
    tabbarController.view.frame = CGRectMake(EYScreenWidth, 0, EYScreenWidth, EYScreenHeight);
    [scrollView addSubview:tabbarController.view];
    [self addChildViewController:tabbarController];
    
    scrollView.contentSize = CGSizeMake(EYScreenWidth * 2, EYScreenHeight);
    [scrollView setContentOffset:CGPointMake(EYScreenWidth, 0)];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{//控制EYTabBarController的方向
    return UIInterfaceOrientationMaskPortrait;
}

@end
