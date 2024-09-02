//
//  PlayView.m
//  XMEye
//
//  Created by XM on 2018/7/21.
//  Copyright © 2018年 Megatron. All rights reserved.
//

#import "PlayView.h"

@implementation PlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    self.layer.borderWidth = 1.0;
    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _activityView.hidesWhenStopped = YES;
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self addSubview:_activityView];
    [self setTouchEvent];
    
    _activityView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.wifiStatus];
    
    NSLayoutConstraint *centerConstraintX = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerConstraintY = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    [self addConstraint:centerConstraintX];
    [self addConstraint:centerConstraintY];
    
    
    return self;
}
#pragma mark  刷新界面和图标
- (void)refreshView:(int)index {
    self.tag = index;
}
- (void)playViewBufferIng { //正在缓冲
    [self.activityView startAnimating];
}
- (void)playViewBufferEnd {//缓冲完成
    [self.activityView stopAnimating];
}
- (void)playViewBufferStop {//预览失败
    [self.activityView stopAnimating];
}

- (void)setFrameColor:(BOOL)select {
    if (select) {
        self.layer.borderColor = [UIColor redColor].CGColor;
    }else  {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)singleTap {
    if (self.playViewDelegate) {
        [self.playViewDelegate PlayViewSelected:self.tag];
    }
}

- (void)setTouchEvent {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    [self addGestureRecognizer:tap];
}

- (UIImageView *)wifiStatus{
    if (!_wifiStatus) {
        _wifiStatus = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"none"]];
        _wifiStatus.frame = CGRectMake(ScreenWidth-30, 30, 25, 25);
        _wifiStatus.contentMode = UIViewContentModeScaleAspectFit;
        _wifiStatus.hidden = YES;
    }
    return _wifiStatus;
}


+(Class)layerClass{
    return [CAEAGLLayer class];
}

@end
