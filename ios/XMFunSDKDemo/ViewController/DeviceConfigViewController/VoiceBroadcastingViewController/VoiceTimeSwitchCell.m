//
//  VoiceTimeSwitchCell.m
//  FunSDKDemo
//
//  Created by plf on 2023/6/2.
//  Copyright © 2023 plf. All rights reserved.
//

#import "VoiceTimeSwitchCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"

@implementation VoiceTimeSwitchCell

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
    [self.contentView addSubview:self.toggleSwitch];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.centerY.equalTo(self.contentView);
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

}

@end
