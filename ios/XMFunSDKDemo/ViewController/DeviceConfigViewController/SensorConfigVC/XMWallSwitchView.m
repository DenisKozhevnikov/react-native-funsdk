//
//  XMWallSwitchView.m
//  XWorld_General
//
//  Created by SaturdayNight on 2018/10/22.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import "XMWallSwitchView.h"
#import <Masonry/Masonry.h>

@implementation XMWallSwitchView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.btnOne];
        [self addSubview:self.btnTwo];
        [self addSubview:self.btnThree];
        
        [self myLayout];
    }
    
    return self;
}

- (void)myLayout{
    [self.btnOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(self.mas_height).multipliedBy(0.75);
        make.height.equalTo(self.mas_height).multipliedBy(1);
        make.centerY.equalTo(self);
    }];
    
    [self.btnTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnOne.mas_right).mas_offset(5);
        make.width.equalTo(self.mas_height).multipliedBy(0.75);
        make.height.equalTo(self.mas_height).multipliedBy(1);
        make.centerY.equalTo(self);
    }];
    
    [self.btnThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnTwo.mas_right).mas_offset(5);
        make.width.equalTo(self.mas_height).multipliedBy(0.75);
        make.height.equalTo(self.mas_height).multipliedBy(1);
        make.centerY.equalTo(self);
    }];
}

- (void)btnClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    if (self.WallSwitchClickedAction) {
        self.WallSwitchClickedAction(btn.tag, btn.selected);
    }
}

- (UIButton *)btnOne{
    if (!_btnOne) {
        _btnOne = [[UIButton alloc] init];
        _btnOne.tag = 1;
        [_btnOne setBackgroundImage:[UIImage imageNamed:@"wallswitch_off"] forState:UIControlStateNormal];
        [_btnOne setBackgroundImage:[UIImage imageNamed:@"wallswitch_on"] forState:UIControlStateSelected];
        [_btnOne addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnOne;
}

- (UIButton *)btnTwo{
    if (!_btnTwo) {
        _btnTwo = [[UIButton alloc] init];
        _btnTwo.tag = 2;
        [_btnTwo setBackgroundImage:[UIImage imageNamed:@"wallswitch_off"] forState:UIControlStateNormal];
        [_btnTwo setBackgroundImage:[UIImage imageNamed:@"wallswitch_on"] forState:UIControlStateSelected];
        [_btnTwo addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnTwo;
}

- (UIButton *)btnThree{
    if (!_btnThree) {
        _btnThree = [[UIButton alloc] init];
        _btnThree.tag = 3;
        [_btnThree setBackgroundImage:[UIImage imageNamed:@"wallswitch_off"] forState:UIControlStateNormal];
        [_btnThree setBackgroundImage:[UIImage imageNamed:@"wallswitch_on"] forState:UIControlStateSelected];
        [_btnThree addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnThree;
}

@end
