//
//  XMLinkWallSwitchCell.h
//  XWorld_General
//
//  Created by SaturdayNight on 2018/10/22.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMWallSwitchView.h"
#import "SensorDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMLinkWallSwitchCell : UITableViewCell

@property (nonatomic, copy) void (^longPressAction)(XMLinkWallSwitchCell *cell);
@property (nonatomic,copy) void (^WallSwitchClickedAction)(NSInteger index,BOOL selected);

@property (nonatomic, copy) XMWallSwitchView *wallSwitchView;

- (void)configureCellWithModel:(SensorDeviceModel *)linkDev;

@end

NS_ASSUME_NONNULL_END
