//
//  EYHomeItemView.m
//  EYDouYin
//
//  Created by 李二洋 on 2018/8/26.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import "EYHomeItemView.h"
#import "EYHomeInfoView.h"
#import "EYHomeSharedView.h"

@interface EYHomeItemView() <EYHomeSharedViewDelegate>

@property (weak, nonatomic) IBOutlet EYHomeInfoView *homeInfoView;
@property (weak, nonatomic) IBOutlet EYHomeSharedView *homeSharedView;

@end

@implementation EYHomeItemView

#pragma mark - 初始化方法
+ (instancetype)homeItemView {
    EYHomeItemView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([EYHomeItemView class]) owner:nil options:nil] lastObject];
    view.frame = EYScreenBounds;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.homeSharedView.delegate = self;
}

#pragma mark - EYHomeSharedViewDelegate
- (void)homeSharedView:(EYHomeSharedView *)view didSeletedButton:(EYHomeSharedViewButtonType)buttonType {
    switch (buttonType) {
        case EYHomeSharedViewButtonTypeHead: {
            EYLog(@"头像");
            break;
        }case EYHomeSharedViewButtonTypelike: {
            EYLog(@"点赞");
            break;
        }case EYHomeSharedViewButtonTypeComments: {
            EYLog(@"评论");
            break;
        }case EYHomeSharedViewButtonTypeShare: {
            EYLog(@"分享");
            break;
        }
        default:
            break;
    }
}

@end
