//
//  EYHomeSharedView.h
//  EYDouYin
//
//  Created by 李二洋 on 2018/8/31.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EYHomeSharedViewButtonType) {
    EYHomeSharedViewButtonTypeHead, //头像
    EYHomeSharedViewButtonTypelike, //点赞
    EYHomeSharedViewButtonTypeComments,//评论
    EYHomeSharedViewButtonTypeShare, //更多
};

@interface EYHomeSharedView : UIView

+ (instancetype)homeSharedView;

@end