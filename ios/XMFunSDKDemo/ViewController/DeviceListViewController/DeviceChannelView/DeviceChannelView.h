//
//  DeviceChannelView.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/10/15.
//  Copyright © 2020 wujiangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceChannelView : UIView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) void(^confirmBtnClicked)(NSMutableArray *selectArray,NSString *devID);
@property (nonatomic, copy) void(^channelClicked)(ChannelObject *channel,NSString *devID);
@property (nonatomic, copy) void(^noTipsBtnClicked)();
@property (nonatomic, strong) NSMutableArray *channelArray; //设备通道数组
@property (nonatomic, strong) UITableView *channelTableV;

@property (nonatomic, strong) UIButton *noTipsBtn;  //不再显示按钮
@property (nonatomic, strong) UIButton *cannelBtn;  //取消按钮
@property (nonatomic, strong) UIButton *confirmBtn; //确定按钮

@property (nonatomic, copy) NSString *devID;
@end

NS_ASSUME_NONNULL_END
