//
//  AlarmSwitchCell.m
//  XWorld
//
//  Created by admin on 2017/3/3.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "AlarmSwitchCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"

@implementation AlarmSwitchCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeUI];
        
        [self.toggleSwitch addTarget:self action:@selector(toggleSwitchStateChanged:) forControlEvents:UIControlEventValueChanged];

    }

    return self;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

-(UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = [UIColor lightGrayColor];
        _detailLabel.numberOfLines = 2;
        _detailLabel.font = [UIFont systemFontOfSize:13];
    }
    return _detailLabel;
}

-(UISwitch *)toggleSwitch {
    if (!_toggleSwitch) {
        _toggleSwitch = [[UISwitch alloc] init];
        _toggleSwitch.onTintColor = [UIColor redColor];
        
        _toggleSwitch.onTintColor = [UIColor colorWithHex:0xef4c33];
        
    }
    
    return _toggleSwitch;
}

-(void)toggleSwitchStateChanged:(UISwitch *) sender{
    if (self.toggleSwitchStateChangedAction) {
        self.toggleSwitchStateChangedAction(sender.on);
    }
}

-(void)makeUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.toggleSwitch];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(@10);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.right.equalTo(self.contentView).offset(-70);
    }];
    
    [self.toggleSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.contentView);
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
