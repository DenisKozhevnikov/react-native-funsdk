//
//  ExpansionTableViewCell.h
//  XMEye
//
//  Created by 杨翔 on 2017/5/3.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpansionTableViewCell : UITableViewCell

@property (nonatomic) UILabel *textLab;             //标题

@property (nonatomic) UIButton *ExpansionBtn;       //展开按钮

@property (nonatomic) UIButton *selectBtn;          //展开状态栏

@property (nonatomic) BOOL image;

@end
