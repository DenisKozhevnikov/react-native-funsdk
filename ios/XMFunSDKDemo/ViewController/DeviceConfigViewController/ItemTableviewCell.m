//
//  ItemTableviewCell.m
//  FunSDKDemo
//
//  Created by XM on 2018/11/7.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "ItemTableviewCell.h"

@implementation ItemTableviewCell
- (void)setCellType:(cellType)type {
        [self configSubView:type];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configSubView:cellTypeLabel];
    }
    return self;
}

- (void)configSubView:(cellType)type {
    if (type == cellTypeLabel) {
        [self.contentView addSubview:self.Labeltext];
    }else if (type == cellTypeSwitch) {
        [self.contentView addSubview:self.mySwitch];
        _Labeltext.hidden = YES;
    }
}
- (UILabel *)Labeltext {
    if (!_Labeltext) {
        _Labeltext = [[UILabel alloc] initWithFrame:CGRectMake(0,0, ScreenWidth-60, 44)];
        _Labeltext.textAlignment = NSTextAlignmentRight;
        _Labeltext.numberOfLines = 0;
        _Labeltext.lineBreakMode = NSLineBreakByWordWrapping;
    }
      _Labeltext.frame = CGRectMake(0,0, ScreenWidth-60, 44);
    return _Labeltext;
}
-(UISwitch *)mySwitch{
    if (!_mySwitch) {
        _mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth - 70, 7, 50, 30)];
        [_mySwitch addTarget:self action:@selector(switchValuChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _mySwitch;
}

-(void)switchValuChanged:(UISwitch *)sender {
    if (self.statusSwitchClicked) {
        self.statusSwitchClicked(sender.on,self.mySection,self.myRow);
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
