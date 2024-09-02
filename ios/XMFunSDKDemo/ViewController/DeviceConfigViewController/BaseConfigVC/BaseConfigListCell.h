//
//  BaseConfigListCell.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/6.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int,BaseConfigListCellStyle) {
    BaseConfigListCellStyleNone,
    BaseConfigListCellStyleSwitch,
    BaseConfigListCellStyleSlider,
};

NS_ASSUME_NONNULL_BEGIN
@protocol BaseConfigListCellDelegate <NSObject>

@optional
- (void)switchValueChanged:(BOOL)enable row:(int)row section:(int)section;
- (void)sliderValueChanged:(float)value row:(int)row section:(int)section;
- (void)sliderValueStopChangeRow:(int)row section:(int)section;

@end

@interface BaseConfigListCell : UITableViewCell

@property (nonatomic,weak) id<BaseConfigListCellDelegate>delegate;

@property (nonatomic,assign) BaseConfigListCellStyle curStyle;
@property (nonatomic,assign) int row;
@property (nonatomic,assign) int section;
@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UILabel *lbDetail;
@property (nonatomic,strong) UISwitch *mySwitch;
@property (nonatomic,strong) UISlider *slider;

- (void)changeStyle:(BaseConfigListCellStyle)style;

@end

NS_ASSUME_NONNULL_END
