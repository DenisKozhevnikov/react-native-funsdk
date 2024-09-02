//
//  XMFileListCell.h
//  XWorld
//
//  Created by DingLin on 17/2/16.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMFileListCell : UICollectionViewCell

@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UIButton *circleBtn;
@property (nonatomic) UIButton *playBtn;
@property (nonatomic) UIButton *slowPlayBtn;
@property (nonatomic) UIButton *fastPlayBtn;
@property (nonatomic) UIImageView *thumbnailImageView;//缩略图
@property (nonatomic,assign) int indexRow;

@property (nonatomic, copy) void (^speedPlayBtnChangedAction)(NSInteger tag);
-(void)speedPlayBtnChanged:(UIButton *)sender;

@property (nonatomic, copy) void (^toggleCircleBtnChangedAction)(BOOL bSelected);
-(void)toggleCircleBtnChanged:(UIButton *)sender;

- (void)changeStatePlaying:(BOOL)playing;

-(void)hiddenSpeedBtn; //云事件界面先隐藏速度调节按钮

@end
