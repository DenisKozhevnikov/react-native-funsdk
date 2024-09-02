//
//  FlipManager.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/8/17.
//  Copyright © 2020 wujiangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 门锁翻转配置
 */

@interface FlipManager : NSObject
@property (nonatomic,copy) NSString *devID;

//MARK:获取翻转配置
-(void)getFlipInfo;
//MARK:设置翻转配置
-(void)setFlip;

@end

NS_ASSUME_NONNULL_END
