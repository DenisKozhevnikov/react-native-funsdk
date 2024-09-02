//
//  BaseConfigListCell.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/6.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "BaseConfigListCell.h"
#import <Masonry/Masonry.h>

@implementation BaseConfigListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.lbTitle];
        [self addSubview:self.lbDetail];
        [self addSubview:self.mySwitch];
        [self addSubview:self.slider];
    }
    
    return self;
}

//MARK: - EventAction
- (void)switchValueChanged:(UISwitch *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchValueChanged:row:section:)]) {
        [self.delegate switchValueChanged:sender.on row:self.row section:self.section];
    }
}

//MAEK:
- (void)sliderValueChanged:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChanged:row:section:)]) {
        [self.delegate sliderValueChanged:sender.value row:self.row section:self.section];
    }
}

- (void)sliderValueStopChange{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueStopChangeRow:section:)]) {
        [self.delegate sliderValueStopChangeRow:self.row section:self.section];
    }
}

- (void)changeStyle:(BaseConfigListCellStyle)style{
    self.slider.hidden = YES;
    self.lbTitle.hidden = YES;
    self.lbDetail.hidden = YES;
    self.mySwitch.hidden = YES;
    
    if (style == BaseConfigListCellStyleNone) {
        
    }else if (style == BaseConfigListCellStyleSwitch){
        self.lbTitle.hidden = NO;
        self.lbDetail.hidden = NO;
        self.mySwitch.hidden = NO;
        
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(10);
            make.top.equalTo(self).mas_offset(5);
            make.right.equalTo(self.mySwitch.mas_left);
            make.height.mas_equalTo(30);
        }];
        
        [self.lbDetail mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(10);
            make.centerY.equalTo(self);
            make.right.equalTo(self.mySwitch.mas_left);
            make.height.mas_equalTo(30);
        }];
        
        [self.mySwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).mas_offset(-10);
        }];
    }else if (style == BaseConfigListCellStyleSlider){
        self.slider.hidden = NO;
        self.lbTitle.hidden = NO;
        
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(10);
            make.centerY.equalTo(self);
            make.width.equalTo(@120);
            make.height.mas_equalTo(30);
        }];
        
        [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).mas_offset(-10);
            make.left.equalTo(self.lbTitle.mas_right);
        }];
    }
}

//MARK: - LazyLoad
- (UILabel *)lbTitle{
    if (!_lbTitle) {
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = [UIFont systemFontOfSize:15];
    }
    
    return _lbTitle;
}

- (UILabel *)lbDetail{
    if (!_lbDetail) {
        _lbDetail = [[UILabel alloc] init];
        _lbDetail.font = [UIFont systemFontOfSize:10];
        _lbDetail.textColor = [UIColor lightGrayColor];
    }
    
    return _lbDetail;
}

- (UISwitch *)mySwitch{
    if (!_mySwitch) {
        _mySwitch = [[UISwitch alloc] init];
        _mySwitch.onTintColor = [UIColor orangeColor];
        [_mySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _mySwitch;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderValueStopChange) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    
    return _slider;
}

@end
