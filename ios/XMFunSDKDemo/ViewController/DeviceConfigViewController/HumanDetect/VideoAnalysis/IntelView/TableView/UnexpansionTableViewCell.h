//
//  UnexpansionTableViewCell.h
//  XMEye
//
//  Created by 杨翔 on 2017/5/3.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UnexpansionTableViewCellSwitchDelegate <NSObject>
-(void)AnalyzeValueChange:(UISwitch*)sender;
@end
@interface UnexpansionTableViewCell : UITableViewCell

@property (nonatomic) UISwitch *analySwitch;

@property (nonatomic, assign) id <UnexpansionTableViewCellSwitchDelegate> delegate;
@end
