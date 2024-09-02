//
//  RealPlayControlViewController.h
//  Giga Admin
//
//  Created by P on 2019/11/22.
//  Copyright © 2019 Megatron. All rights reserved.
//
/*
 *远程控制界面
 *
 *
 */
//
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RealPlayControlViewController : BaseViewController

@property(nonatomic,strong)NSString *devMac;
@property(nonatomic)int allChannelNum;

@end

NS_ASSUME_NONNULL_END
