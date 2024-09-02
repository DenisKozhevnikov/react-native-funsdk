//
//  ItemTableviewCell.h
//  FunSDKDemo
//
//  Created by XM on 2018/11/7.
//  Copyright © 2018年 XM. All rights reserved.
//
typedef enum {
    cellTypeLabel = 0,
    cellTypeSwitch,
} cellType;
#import <UIKit/UIKit.h>

@interface ItemTableviewCell : UITableViewCell

//编码配置配置功能Lab
@property (nonatomic, strong) UILabel *Labeltext;

@property (nonatomic, strong) UISwitch *mySwitch;
@property (nonatomic, copy) void (^statusSwitchClicked)(BOOL on,int section,int row);

@property (nonatomic, assign) int mySection;
@property (nonatomic, assign) int myRow;

- (void)setCellType:(cellType)type;
@end
