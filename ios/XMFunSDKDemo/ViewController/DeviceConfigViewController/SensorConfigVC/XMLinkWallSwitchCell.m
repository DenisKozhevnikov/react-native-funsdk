//
//  XMLinkWallSwitchCell.m
//  XWorld_General
//
//  Created by SaturdayNight on 2018/10/22.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import "XMLinkWallSwitchCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"
#import "UIView+WZLBadge.h"

@interface XMLinkWallSwitchCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation XMLinkWallSwitchCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeUI];
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:longPressGR];
        
    }
    return self;
}

-(void)makeUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.wallSwitchView];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self);
        make.height.equalTo(@40);
        make.width.equalTo(@40);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right);
        make.centerY.equalTo(self).offset(-5);
        make.height.equalTo(@24);
        make.width.equalTo(@200);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.bottom.equalTo(self).offset(-10);
        make.width.equalTo(@100);
    }];
    
    [self.wallSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40*3*0.75+10);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(40);
        make.right.equalTo(self).mas_offset(-20);
    }];
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
    }
    
    return _titleLabel;
}

-(UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.font = [UIFont systemFontOfSize:13];
        _detailLabel.textColor = [UIColor lightGrayColor];
    }
    
    return _detailLabel;
}

-(UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        
    }
    
    return _iconImageView;
}

- (XMWallSwitchView *)wallSwitchView{
    if (!_wallSwitchView) {
        _wallSwitchView = [[XMWallSwitchView alloc] init];
        __weak typeof(self) weakSelf = self;
        _wallSwitchView.WallSwitchClickedAction = ^(NSInteger index, BOOL selected) {
            if (weakSelf.WallSwitchClickedAction) {
                weakSelf.WallSwitchClickedAction(index, selected);
            }
        };
        
    }
    
    return _wallSwitchView;
}

-(void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded&&self.longPressAction) {
        self.longPressAction(self);
    }
}

- (void)configureCellWithModel:(SensorDeviceModel *)linkDev {
    self.titleLabel.text = [linkDev.dicListInfo objectForKey:@"DevName"];
    
    int online = linkDev.ifOnline ? 1 : 0;
    
    int unreadCount = 0;
    
    self.iconImageView.badgeBgColor = [UIColor redColor];
    [self.iconImageView showBadgeWithStyle:WBadgeStyleNumber value:unreadCount animationType:WBadgeAnimTypeNone];
    
    if (online) {
        [self.iconImageView setImage:[UIImage imageNamed:@"dev_wall_switch_on"]];
    } else {
        [self.iconImageView setImage:[UIImage imageNamed:@"dev_wall_switch"]];
    }
    
    // 刷新墙壁开关状态
    int mask = [[linkDev.dicStatusInfo objectForKey:@"DevStatus"] intValue];
    if ((mask & 1) == 1) {
        self.wallSwitchView.btnOne.selected = YES;
    }
    else{
        self.wallSwitchView.btnOne.selected = NO;
    }
    
    if ((mask & 2) == 2) {
        self.wallSwitchView.btnTwo.selected = YES;
    }
    else{
        self.wallSwitchView.btnTwo.selected = NO;
    }
    
    if ((mask & 4) == 4) {
        self.wallSwitchView.btnThree.selected = YES;
    }
    else{
        self.wallSwitchView.btnThree.selected = NO;
    }
}

@end
