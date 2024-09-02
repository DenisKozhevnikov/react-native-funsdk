//
//  VoiceTimeSwitchCell.h
//  FunSDKDemo
//
//  Created by plf on 2023/6/2.
//  Copyright © 2023 plf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceTimeSwitchCell : UITableViewCell

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UISwitch *toggleSwitch;
@property (nonatomic, copy) void (^toggleSwitchStateChangedAction)(BOOL);
@end

NS_ASSUME_NONNULL_END
