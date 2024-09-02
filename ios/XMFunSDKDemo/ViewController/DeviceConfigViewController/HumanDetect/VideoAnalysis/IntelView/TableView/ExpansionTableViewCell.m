//
//  ExpansionTableViewCell.m
//  XMEye
//
//  Created by 杨翔 on 2017/5/3.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "ExpansionTableViewCell.h"

@implementation ExpansionTableViewCell

-(UIButton *)ExpansionBtn{
    if (!_ExpansionBtn) {
        _ExpansionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 20)/2, 20, 20)];
        [_ExpansionBtn setBackgroundImage:[UIImage imageNamed:@"alarm_down.png"] forState:UIControlStateNormal];
    }
    return _ExpansionBtn;
}

-(UILabel *)textLab{
    if (!_textLab) {
        _textLab = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 200, self.frame.size.height - 10)];
    }
    return _textLab;
}

-(UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, (self.frame.size.height - 20)/2, 20, 20)];
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"ic_unselected.png"] forState:UIControlStateNormal];
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"ic_hook.png"] forState:UIControlStateSelected];
    }
    return _selectBtn;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configSubView];
    }
    return self;
}

-(void)configSubView{
    self.accessoryView = self.ExpansionBtn;
    [self addSubview:self.selectBtn];
    [self addSubview:self.textLab];
}
@end
