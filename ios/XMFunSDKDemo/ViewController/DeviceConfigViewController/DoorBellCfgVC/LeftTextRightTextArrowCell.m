//
//  LeftTextRightTextArrowCell.m
//  XWorld_General
//
//  Created by Tony Stark on 13/08/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "LeftTextRightTextArrowCell.h"
#import <Masonry/Masonry.h>

@implementation LeftTextRightTextArrowCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.lbLeft];
        [self addSubview:self.lbRight];
        [self addSubview:self.imgArrow];
        [self addSubview:self.lineBottom];
        
        [self.lbLeft mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(20);
            make.centerY.equalTo(self);
            make.width.equalTo(@120);
            make.height.equalTo(@30);
        }];
        
        [self.lbRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.equalTo(@30);
            make.width.equalTo(@160);
            make.right.equalTo(self.imgArrow.mas_left);
        }];
        
        [self.imgArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).mas_offset(0);
            make.centerY.equalTo(self);
            make.width.equalTo(@25);
            make.height.equalTo(@25);
        }];
        
        [self.lineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(20);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@1);
        }];
    }
    
    return self;
}

//MARK: - LazyLoad
- (UILabel *)lbLeft{
    if (!_lbLeft) {
        _lbLeft = [[UILabel alloc] init];
        _lbLeft.textColor = [UIColor blackColor];
        _lbLeft.font = [UIFont systemFontOfSize:17];
    }
    
    return _lbLeft;
}

- (UILabel *)lbRight{
    if (!_lbRight) {
        _lbRight = [[UILabel alloc] init];
        _lbRight.textColor = [UIColor lightGrayColor];
        _lbRight.font = [UIFont systemFontOfSize:17];
        _lbRight.textAlignment = NSTextAlignmentRight;
    }
    
    return _lbRight;
}

- (UIImageView *)imgArrow{
    if (!_imgArrow) {
        _imgArrow = [[UIImageView alloc] init];
        _imgArrow.image = [UIImage imageNamed:@"arrow_right"];
    }
    
    return _imgArrow;
}

- (UIView *)lineBottom{
    if (!_lineBottom) {
        _lineBottom = [[UIView alloc] init];
        _lineBottom.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    }
    
    return _lineBottom;
}

@end
