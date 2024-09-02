//
//  XMFileListCell.m
//  XWorld
//
//  Created by DingLin on 17/2/16.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "XMFileListCell.h"
#import <Masonry/Masonry.h>
@interface XMFileListCell ()



@end

@implementation XMFileListCell





-(instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {        
        self.circleBtn.hidden = YES;
        
        [self.contentView addSubview:self.thumbnailImageView];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.playBtn];
        [self.contentView addSubview:self.circleBtn];
        [self.contentView addSubview:self.slowPlayBtn];
        [self.contentView addSubview:self.fastPlayBtn];

        [self.thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.contentView);
            make.height.equalTo(@24);
            make.top.equalTo(self.thumbnailImageView);
            make.centerX.equalTo(self.thumbnailImageView);
        }];
        
        if (@available(iOS 9,*)) {
            [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@32);
                make.height.equalTo(@32);
                make.center.equalTo(self.thumbnailImageView);
            }];
            [self.slowPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@24);
                make.height.equalTo(@24);
                make.centerY.equalTo(self.playBtn);
                make.left.equalTo(self.contentView).offset(5);
            }];
            [self.fastPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@24);
                make.height.equalTo(@24);
                make.centerY.equalTo(self.playBtn);
                make.right.equalTo(self.contentView).offset(-5);
            }];
        }else{
            [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@24);
                make.height.equalTo(@24);
                make.center.equalTo(self.thumbnailImageView);
            }];
            [self.slowPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@30);
                make.height.equalTo(@30);
                make.centerY.equalTo(self.playBtn);
                make.right.equalTo(self.playBtn.mas_left).offset(-10);
            }];
            [self.fastPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@30);
                make.height.equalTo(@30);
                make.centerY.equalTo(self.playBtn);
                make.left.equalTo(self.playBtn.mas_right).offset(10);
            }];
        }
        [self.circleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView);

        }];
        
        [self.circleBtn addTarget:self action:@selector(toggleCircleBtnChanged:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

-(void)hiddenSpeedBtn
{
    [self.slowPlayBtn removeFromSuperview];
    [self.fastPlayBtn removeFromSuperview];
}

-(UIImageView *)thumbnailImageView {
    if (!_thumbnailImageView) {
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.image = [UIImage imageNamed:@"CameraTableViewCell-bg"];
    }

    return _thumbnailImageView;
}

-(UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [_timeLabel setTextColor:[UIColor whiteColor]];
        [_timeLabel setFont:[UIFont systemFontOfSize:9]];
        _timeLabel.numberOfLines = 0;
        _timeLabel.text = @"";
    }

    return _timeLabel;
}

-(UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        _playBtn.userInteractionEnabled = NO;
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
    }
    return _playBtn;
}
-(UIButton *)slowPlayBtn {
    if (!_slowPlayBtn) {
        _slowPlayBtn = [[UIButton alloc] init];
        _slowPlayBtn.hidden = YES;
        [_slowPlayBtn setImage:[UIImage imageNamed:@"ic_video_slowplay"] forState:UIControlStateNormal];
        [_slowPlayBtn addTarget:self action:@selector(speedPlayBtnChanged:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _slowPlayBtn;
}
-(UIButton *)fastPlayBtn {
    if (!_fastPlayBtn) {
        _fastPlayBtn = [[UIButton alloc] init];
        _fastPlayBtn.hidden = YES;
        _fastPlayBtn.tag = 123;
        [_fastPlayBtn setImage:[UIImage imageNamed:@"ic_video_fastplay"] forState:UIControlStateNormal];
        [_fastPlayBtn addTarget:self action:@selector(speedPlayBtnChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fastPlayBtn;
}
-(UIButton *)circleBtn {
//    if (!_circleBtn) {
//        _circleBtn = [[UIButton alloc] initWithStyle:@"AlbumCollecViewCellCheck"];
//    }
    return _circleBtn;
}

-(void)toggleCircleBtnChanged:(UIButton *)sender {
    BOOL bSelected = sender.selected;//任务是否正在运行
    
    //点击按钮开启或者关闭任务
    if (bSelected) {
        //关闭任务
        
        
        
        
    } else {
        //开启任务
        
        
        
    }
    
    if (self.toggleCircleBtnChangedAction) {
        self.toggleCircleBtnChangedAction(bSelected);
    }
    
    sender.selected = !bSelected;

}
-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.slowPlayBtn.hidden = !selected;
    self.fastPlayBtn.hidden = !selected;
    
    if (selected) {
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
    }else{
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)changeStatePlaying:(BOOL)playing{
    if (playing) {
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
    }else{
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
    }
}

-(void)speedPlayBtnChanged:(UIButton *)sender {
    self.speedPlayBtnChangedAction(sender.tag);
}
@end
