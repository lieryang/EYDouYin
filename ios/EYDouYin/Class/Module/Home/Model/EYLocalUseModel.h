//
//  EYLocalUseModel.h
//  EYDouYin
//
//  Created by 李二洋 on 2019/8/13.
//  Copyright © 2019 李二洋. All rights reserved.
//  本地数据使用模型(方便界面显示)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EYLocalUseModel : NSObject

/**
 分组名称
 */
@property (copy, nonatomic) NSString *groupName;

/**
 具体信息数组
 */
@property (strong, nonatomic) NSArray <EYLocalUseModel *>*items;

/**
 标题
 */
@property (copy, nonatomic) NSString *title;

/**
 链接网址
 */
@property (copy, nonatomic) NSString *content_url;

/**
 是否加密
 */
@property (assign, nonatomic) BOOL lock;

/**
 开发语言
 */
@property (copy, nonatomic) NSString *language;

/**
 标题
 */
@property (copy, nonatomic) NSString *name;

/**
 控制器名称
 */
@property (copy, nonatomic) NSString *vcName;

@end

NS_ASSUME_NONNULL_END
