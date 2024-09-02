//
//  XMRadarView.m
//  HoMeYe
//
//  Created by coderXY on 2023/3/11.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "XMRadarView.h"

@interface XMRadarView ()
/** bluetooth_radar_search_icon */
@property (nonatomic, strong) UIImageView *imgView;
/** 是否正在动画中 */
@property (nonatomic, assign) BOOL isAnimating;
/**  */
@property (nonatomic, strong) CABasicAnimation* rotationAnimation;

@end

@implementation XMRadarView

- (void)setRadarImgName:(NSString *)radarImgName{
    _radarImgName = radarImgName;
    self.imgView.image = [[UIImage imageNamed:radarImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

//
- (void)beginAnimation{
    if(self.isAnimating){
        [self.imgView.layer removeAllAnimations];
    }
    self.isAnimating = YES;
    //
    self.rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    self.rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    self.rotationAnimation.duration = 1.5;
    self.rotationAnimation.cumulative = YES;
    self.rotationAnimation.repeatCount = HUGE_VALF;
    self.rotationAnimation.removedOnCompletion = NO;
    [self.imgView.layer addAnimation:self.rotationAnimation forKey:@"rotationAnimation"];
}
//
- (void)endAnimation{
    [self.imgView.layer removeAllAnimations];
    self.isAnimating = NO;
}

#pragma mark - private method
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self radarViewSubviews];
    }
    return self;
}

- (void)radarViewSubviews{
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
}

- (UIImageView *)imgView{
    if(!_imgView){
        _imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imgView;
}

@end
