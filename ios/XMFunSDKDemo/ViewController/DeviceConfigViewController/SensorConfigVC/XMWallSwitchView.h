//
//  XMWallSwitchView.h
//  XWorld_General
//
//  Created by SaturdayNight on 2018/10/22.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMWallSwitchView : UIButton 

@property (nonatomic,strong) UIButton *btnOne;
@property (nonatomic,strong) UIButton *btnTwo;
@property (nonatomic,strong) UIButton *btnThree;

@property (nonatomic,copy) void (^WallSwitchClickedAction)(NSInteger index,BOOL selected);

@end

NS_ASSUME_NONNULL_END
