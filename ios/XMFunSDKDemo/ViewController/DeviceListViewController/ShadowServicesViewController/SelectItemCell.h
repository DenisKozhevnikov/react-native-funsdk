//
//  SelectItemCell.h
//   
//
//  Created by Tony Stark on 2021/7/30.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectItemCell : UITableViewCell

@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UIView *bottomLine;
@property (nonatomic,strong) UIImageView *imageViewSelect;

@property (nonatomic,assign) BOOL ifSelected;

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent;

@end

NS_ASSUME_NONNULL_END
