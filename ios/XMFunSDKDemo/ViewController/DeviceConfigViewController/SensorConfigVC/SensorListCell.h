//
//  SensorListCell.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/3/25.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SensorSwitchStatueCallBack)(int statue,int indexRow);
NS_ASSUME_NONNULL_BEGIN

@interface SensorListCell : UITableViewCell

@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UISwitch *statueSwitch;
@property (nonatomic,assign) NSInteger indexRow;

@property (nonatomic,copy) SensorSwitchStatueCallBack statueAction;

- (void)listenStatue:(SensorSwitchStatueCallBack)action;

@end

NS_ASSUME_NONNULL_END
