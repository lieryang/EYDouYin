//
//  EYZFPlayerViewController.m
//  EYDouYin
//
//  Created by 李二洋 on 2018/10/26.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import "EYZFPlayerViewController.h"

@class EYZFPlayerControlView;

@protocol EYZFPlayerControlViewDelegate<NSObject>
@optional
- (void)eyZFPlayerControlView:(EYZFPlayerControlView *)view didSelectedBackButton:(UIButton *)button;

@end

//控制播放层
@interface EYZFPlayerControlView() <ZFPlayerMediaControl>

@property (weak, nonatomic) id <EYZFPlayerControlViewDelegate>delegate;


@end

@implementation EYZFPlayerControlView

@synthesize player;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
        [backButton setImage:[UIImage imageNamed:@"common_arrow_left"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
    }
    return self;
}

- (void)tapBackButton:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(eyZFPlayerControlView:didSelectedBackButton:)]) {
        [self.delegate eyZFPlayerControlView:self didSelectedBackButton:button];
    }
}

@end

@interface EYZFPlayerViewController () <EYZFPlayerControlViewDelegate>

@property (nonatomic, strong) ZFPlayerController *playerController;

@end

@implementation EYZFPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupVideoView];
}

- (void)setupVideoView {
    /// 播放器相关
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    UIView *containerView = [[UIView alloc] initWithFrame:EYScreenBounds];
    containerView.backgroundColor = [UIColor blackColor];
    ZFPlayerController *playerController = [ZFPlayerController playerWithPlayerManager:playerManager containerView:containerView];
    playerController.assetURL = [NSURL URLWithString:@"http://video.chinlab.com/CLXXXYE1539069802307.mp4"];
    self.playerController = playerController;
    
    //竖屏进入
    [self.view insertSubview:containerView atIndex:0];
    [playerController enterPortraitFullScreen:NO animated:NO];
    
    //横屏进入
//    EYZFPlayerControlView *eyZFPlayerControlView = [[EYZFPlayerControlView alloc] initWithFrame:EYScreenBounds];
//    eyZFPlayerControlView.delegate = self;
//    playerController.controlView = eyZFPlayerControlView;
//    [self.playerController enterLandscapeFullScreen:UIInterfaceOrientationLandscapeRight animated:YES];
}

#pragma mark - EYZFPlayerControlViewDelegate
- (void)eyZFPlayerControlView:(EYZFPlayerControlView *)view didSelectedBackButton:(UIButton *)button {
    if (self.navigationController) {
        [self.playerController enterFullScreen:NO animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

