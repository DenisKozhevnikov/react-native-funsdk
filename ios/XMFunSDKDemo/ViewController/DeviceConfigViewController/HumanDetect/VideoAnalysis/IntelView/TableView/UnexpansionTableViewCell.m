//
//  UnexpansionTableViewCell.m
//  XMEye
//
//  Created by 杨翔 on 2017/5/3.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "UnexpansionTableViewCell.h"

@implementation UnexpansionTableViewCell

-(UISwitch *)analySwitch{
    if (!_analySwitch) {
        _analySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [_analySwitch addTarget:self action:@selector(AnalyzeValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _analySwitch;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configSubView];
    }
    return self;
}

-(void)configSubView{
    self.accessoryView = self.analySwitch;
}
-(void)AnalyzeValueChange:(UISwitch*)sender
{
    if ([self.delegate respondsToSelector:@selector(AnalyzeValueChange:)]) {
        [self.delegate AnalyzeValueChange:sender];
    }
}
@end
