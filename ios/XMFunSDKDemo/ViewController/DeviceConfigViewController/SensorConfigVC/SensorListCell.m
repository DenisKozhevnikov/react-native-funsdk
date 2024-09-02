//
//  SensorListCell.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/3/25.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "SensorListCell.h"
#import <Masonry/Masonry.h>

@implementation SensorListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.lbTitle];
        [self addSubview:self.statueSwitch];
        
        [self myLayout];
    }
    
    return self;
}

#pragma mark - Layout
- (void)myLayout{
    [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).mas_offset(20);
        make.width.equalTo(self).multipliedBy(0.6);
        make.height.equalTo(@40);
    }];
    
    [self.statueSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).mas_offset(-10);
    }];
}

#pragma mark - EventAction
- (void)statueSwitchClicked:(UISwitch *)mySwitch{
    if (self.statueAction) {
        self.statueAction(mySwitch.isOn ? 1 : 0, self.indexRow);
    }
}

- (void)listenStatue:(SensorSwitchStatueCallBack)action{
    self.statueAction = action;
}

#pragma mark - LazyLoad
- (UILabel *)lbTitle{
    if (!_lbTitle) {
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = [UIFont systemFontOfSize:18];
    }
    
    return _lbTitle;
}

- (UISwitch *)statueSwitch{
    if (!_statueSwitch) {
        _statueSwitch = [[UISwitch alloc] init];
        [_statueSwitch addTarget:self action:@selector(statueSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _statueSwitch;
}

@end
