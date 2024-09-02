//
//  JFBluetoothSearchResultCell.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/31.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFBluetoothSearchResultCell.h"

@interface JFBluetoothSearchResultCell ()
/** 分割线 */
@property (nonatomic, strong) UIView *lineView;
/** 设备名 */
@property (nonatomic, strong) UILabel *nameLab;
/** 设备icon */
@property (nonatomic, strong) UIImageView *devIconImgView;

@end

@implementation JFBluetoothSearchResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self cellSubviews];
    }
    return self;
}

- (void)cellSubviews{
    [self.contentView addSubview:self.devIconImgView];
    [self.contentView addSubview:self.nameLab];
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
    [self.devIconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lineView);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.contentView);
    }];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.devIconImgView.mas_right).offset(15);
        make.top.equalTo(self.contentView.mas_top).offset(15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
        make.width.mas_equalTo(10);
    }];
}
// MARK: - (void)jf_updateCellWithDevname:(NSString *)devName;
- (void)jf_updateCellWithDevname:(NSString *)devName{
    if(!ISLEGALSTR(devName)) return;
    self.nameLab.text = devName;
    CGSize size = [NSString getSizeWithContent:devName fontValue:15 weight:0];
    [self.nameLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width+1);
    }];
}

#pragma mark - lazy load
- (UIView *)lineView{
    if(!_lineView){
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = JFCommonColor_D5D5;
    }
    return _lineView;
}

- (UILabel *)nameLab{
    if(!_nameLab){
        _nameLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLab.textAlignment = NSTextAlignmentCenter;
        _nameLab.font = JF_Font(15.0);
    }
    return _nameLab;
}

- (UIImageView *)devIconImgView{
    if(!_devIconImgView){
        _devIconImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _devIconImgView.image = JF_Img(@"5G_Camera_Online");
    }
    return _devIconImgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
