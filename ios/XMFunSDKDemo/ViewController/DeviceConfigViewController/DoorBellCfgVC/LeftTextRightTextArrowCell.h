//
//  LeftTextRightTextArrowCell.h
//  XWorld_General
//
//  Created by Tony Stark on 13/08/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LeftTextRightTextArrowCell : UICollectionViewCell

//左侧标题
@property (nonatomic,strong) UILabel *lbLeft;
//右侧内容
@property (nonatomic,strong) UILabel *lbRight;
//右侧箭头图标
@property (nonatomic,strong) UIImageView *imgArrow;
//底部分割线
@property (nonatomic,strong) UIView *lineBottom;

@end

NS_ASSUME_NONNULL_END
