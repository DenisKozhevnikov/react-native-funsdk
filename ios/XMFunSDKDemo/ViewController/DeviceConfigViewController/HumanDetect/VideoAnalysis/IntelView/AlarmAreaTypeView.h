//
//  AlarmAreaTypeView.h
//  XMEye
//
//  Created by 杨翔 on 2017/5/4.
//  Copyright © 2017年 Megatron. All rights reserved.
//
#import "DrawControl.h"
@protocol AlarmAreaTypeViewDelegate <NSObject>

#pragma mark - 还原选择应用场景
-(void)cancelSelectScene;

#pragma mark - 回滚到上一步
-(void)rollBackAction;

#pragma mark - 完成选择应用场景
-(void)compliteSelectScene;

#pragma mark - 选择警戒方向
-(void)selectAlarmOrientation;

#pragma mark - 选择应用场景
-(void)selectScenarios:(DefaultPoint_Type)type;

@end


#import <UIKit/UIKit.h>

@interface AlarmAreaTypeView : UIView

@property (nonatomic) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *btnRollBack;     // 步骤回退按钮
@property (nonatomic) UIButton *completeBtn;

@property (nonatomic) enum DrawType alarmType;

//场景选择
@property (nonatomic) UIScrollView *scenariosScrollView;

@property (nonatomic) id <AlarmAreaTypeViewDelegate> delegate;

@property (nonatomic) UIView *detailView;

@property (nonatomic, strong) NSMutableArray *directArray;

@property (nonatomic, strong) NSMutableArray *areaShapeArray;

//MARK:取消选中状态
- (void)unSelectedButton;

@end
