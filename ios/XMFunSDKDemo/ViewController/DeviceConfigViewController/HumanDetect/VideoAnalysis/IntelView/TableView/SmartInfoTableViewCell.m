//
//  SmartInfoTableViewCell.m
//  XMEye
//
//  Created by 杨翔 on 2017/5/4.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "SmartInfoTableViewCell.h"

@implementation SmartInfoTableViewCell

-(UILabel *)textLab{
    if (!_textLab) {
        _textLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, self.frame.size.height - 10)];
    }
    return _textLab;
}



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configSubView];
    }
    return self;
}

-(void)configSubView{
    [self addSubview:self.textLab];
}

@end
