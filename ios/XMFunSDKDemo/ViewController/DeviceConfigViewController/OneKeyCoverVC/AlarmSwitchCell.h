//
//  AlarmSwitchCell.h
//  XWorld
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmSwitchCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UISwitch *toggleSwitch;
@property (nonatomic, copy) void (^toggleSwitchStateChangedAction)(BOOL);


@end
