//
//  SelectItemCell.m
//   
//
//  Created by Tony Stark on 2021/7/30.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "SelectItemCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"

@implementation SelectItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.lbTitle];
        [self.contentView addSubview:self.imageViewSelect];
        [self.contentView addSubview:self.bottomLine];
        
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(20);
            make.right.equalTo(self).mas_offset(-60);
            make.height.equalTo(@30);
            make.centerY.equalTo(self);
        }];
        
        [self.imageViewSelect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).mas_offset(-20);
            make.centerY.equalTo(self);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@1);
        }];
    }
    
    return self;
}

- (void)setIfSelected:(BOOL)ifSelected{
    _ifSelected = ifSelected;
    
    if (_ifSelected) {
        self.imageViewSelect.image = [UIImage imageNamed:@"SM_check_on"];
    }else{
        self.imageViewSelect.image = [UIImage imageNamed:@"SM_check_off"];
    }
}

//MARK: - LazyLoad
- (UILabel *)lbTitle{
    if (!_lbTitle) {
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = [UIFont systemFontOfSize:15];
        _lbTitle.textColor = [UIColor colorWithHexStr:@"#5A5A5A"];
    }
    
    return _lbTitle;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor colorWithHexStr:@"#EEEEEE"];
    }
    
    return _bottomLine;
}

- (UIImageView *)imageViewSelect{
    if (!_imageViewSelect) {
        _imageViewSelect = [[UIImageView alloc] init];
        _imageViewSelect.image = [UIImage imageNamed:@"SM_check_off"];
    }
    
    return _imageViewSelect;
}

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent{
    if (subtransparent){
        self.contentView.backgroundColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
        self.lbTitle.textColor = UIColor.whiteColor;
        self.bottomLine.backgroundColor = UIColor.whiteColor;
    }else{
        self.backgroundColor = UIColor.whiteColor;
        self.lbTitle.textColor = [UIColor colorWithHexStr:@"#5A5A5A"];
        self.bottomLine.backgroundColor = [UIColor colorWithHexStr:@"#EEEEEE"];
    }
}

@end
