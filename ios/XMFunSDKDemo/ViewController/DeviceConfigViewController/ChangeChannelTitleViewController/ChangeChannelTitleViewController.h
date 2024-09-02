//
//  ChangeChannelTitleViewController.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/10/24.
//  Copyright © 2020 wujiangbo. All rights reserved.
//
/**
 
修改设备通道名称
需要设备支持
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangeChannelTitleViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *channelArray; //设备通道数组
@property (nonatomic, strong) UITableView *channelTableV;

@property (nonatomic, copy) NSString *devID;

@end

NS_ASSUME_NONNULL_END
