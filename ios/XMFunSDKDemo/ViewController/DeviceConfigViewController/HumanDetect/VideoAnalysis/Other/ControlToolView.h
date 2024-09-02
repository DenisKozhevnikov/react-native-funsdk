//
//  ControlToolView.h
//  Giga Admin
//
//  Created by P on 2019/11/25.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ControlToolViewDelegate <NSObject>

-(void)controlBtnTouchDownAction:(int)sender;
-(void)controlBtnTouchUpInsideAction:(int)sender;

-(void)controlBtnCancelAction;

@end

@interface ControlToolView : UIView

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIButton *PTZUpBtn;

@property (nonatomic, strong) UIButton *PTZDownBtn;

@property (nonatomic, strong) UIButton *PTZLeftBtn;

@property (nonatomic, strong) UIButton *PTZRightBtn;

@property (nonatomic, strong) UIImageView *PTZControlIV;

@property (nonatomic, strong) UIButton *leftPressBtn;  // 左击
@property (nonatomic, strong) UIButton *cancelPressBtn;  //退出
@property (nonatomic, strong) UIButton *rightPressBtn;  //右击

@property (nonatomic,weak) id <ControlToolViewDelegate> delgate;

@end

NS_ASSUME_NONNULL_END
