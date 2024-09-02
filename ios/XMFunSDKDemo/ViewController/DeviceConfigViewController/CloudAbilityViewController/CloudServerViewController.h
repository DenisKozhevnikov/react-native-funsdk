//
//  CloudServerViewController.h
//  FunSDKDemo
//
//  Created by XM on 2019/1/3.
//  Copyright © 2019年 XM. All rights reserved.
//
/****
 
 云服务页面
 云服务网页上云存储、流量等相关功能需要app单独开通
 
 *****/

#import "BaseViewController.h"
#import "CloudPhotoViewController.h"
#import "CloudVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CloudServerViewController : BaseViewController
/*
 云服务网页
 云服务功能需要提交APP信息然后通过雄迈来开通，之后才能正常使用
 */
/*特殊页面跳转标志
流量       net.cellular
云增强     xmc.enhance
云智能     xmc.ais
云存储     xmc.css
阳光厨房   ext.aliele
 */
@property (nonatomic,copy) NSString *jumpSign;

@end

NS_ASSUME_NONNULL_END
