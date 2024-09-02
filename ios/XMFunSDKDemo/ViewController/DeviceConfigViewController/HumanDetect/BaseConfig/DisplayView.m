//
//  DisplayView.m
//  XMUtils
//
//  Created by liuguifang on 05/20/16.
//  Copyright (c) 2016 xiongmaitech. All rights reserved.
//

#import "DisplayView.h"
#import "UIView+Layout.h"


@implementation DisplayView

#pragma mark lazyLoad
- (UIImage *)stopImage{
    if (!_stopImage) {
        _stopImage = [UIImage imageNamed:@"btn_pause"];
    }
    return _stopImage;
}
- (UIImage *)playingImage{
    if (!_playingImage) {
        _playingImage = [UIImage imageNamed:@"new_play"];
    }
    return _playingImage;
}


+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)initControls{
    self.backColor = [UIColor blackColor];
    self.backgroundColor = self.backColor;
    self.layer.borderColor = [[UIColor greenColor] CGColor];
    self.layer.borderWidth = 0;
    
    self.ctlBtn = [[UIButton alloc] init];
    self.ctlBtn.backgroundColor = [UIColor clearColor];
    self.ctlBtn.userInteractionEnabled = YES;
//    [self.ctlBtn setBackgroundImage:self.playingImage forState:UIControlStateSelected];
//    [self.ctlBtn setBackgroundImage:self.stopImage forState:UIControlStateNormal];
    [self.ctlBtn setBackgroundImage:self.playingImage forState:UIControlStateNormal];

    self.ctlBtn.hidden = YES;
    
    [self.ctlBtn addTarget:self action:@selector(onCtlBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.ctlBtn];
    
    self.lableTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    self.lableTip.backgroundColor = [UIColor clearColor];
    self.lableTip.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.lableTip];
    
    _dispStatus = DisplayViewStatusStop;
    self.userInteractionEnabled = YES;
    
    if (self.activityIndicatorView == nil) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicatorView.hidesWhenStopped = YES;
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    [self addSubview:self.activityIndicatorView];
    
    self.labelStatus = [UILabel new];
    self.labelStatus.textColor = [UIColor whiteColor];
    self.labelStatus.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.labelStatus];
}

-(instancetype)initWithFrame:(CGRect)frame{
    id obj = [super initWithFrame:frame];
    [self initControls];
    return obj;
}

-(void)onCtlBtnClicked:(id)sender{

//    self.ctlBtn.selected = !self.ctlBtn.selected;
    if ( self.delegateCtl ) {
        //检查selector 存在不存在
        if (![self.delegateCtl respondsToSelector:@selector(displayView:ctlBtnClickedWithStatus:)] )
        {
            return;
        }
                
        [self.delegateCtl displayView:self ctlBtnClickedWithStatus:self.dispStatus];
    }
}


-(void)setDispStatus:(DisplayViewStatus)status{
    _dispStatus = status;

    switch ( status ) {
        case DisplayViewStatusStop:
            self.ctlBtn.hidden = NO;
//            self.ctlBtn.selected = YES;
            if (self.backImage && !self.layer.contents) {
                self.layer.contents = (__bridge id _Nullable)(self.backImage.CGImage);
            }
            [self.activityIndicatorView stopAnimating];
            [self.labelStatus setText:@""];//Video_Not_Found

              break;
        case DisplayViewStatusBuffering:
            [self setBackgroundColor:self.backColor];
            self.ctlBtn.hidden = YES;
            [self.activityIndicatorView startAnimating];
            [self.labelStatus setText:TS("waiting_buffering")];

             break;
        case DisplayViewStatusPlaying:
            [self setBackgroundColor:self.backColor];
            self.ctlBtn.hidden = YES;
//            self.ctlBtn.selected = NO;
            [self.activityIndicatorView stopAnimating];
            [self.labelStatus setText:@""];

            break;
        case DisplayViewStatusPause:
            self.ctlBtn.hidden = YES;
//            self.ctlBtn.selected = YES;
            [self.activityIndicatorView stopAnimating];
            [self.labelStatus setText:@""];
            break;
        case DisplayViewStatusRetrying:
        {
            self.ctlBtn.hidden = YES;//重试的时候控制按钮应该不显示
            [self.activityIndicatorView startAnimating];
            [self.labelStatus setText:TS("OpenError")];
        }
        case DisplayViewStatusNoVideo:
            self.ctlBtn.hidden = NO;
            //            self.ctlBtn.selected = YES;
            if (self.backImage && !self.layer.contents) {
                self.layer.contents = (__bridge id _Nullable)(self.backImage.CGImage);
            }
            [self.activityIndicatorView stopAnimating];
            [self.labelStatus setText:TS("Video_Not_Found")];//
            
            break;
        default:
            break;
    }
}

-(void)setBackImage:(UIImage *)backImage{
    _backImage = backImage;
}

-(void)setBackColor:(UIColor *)backColor{
    _backColor  = backColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.ctlBtn setTz_width:self.tz_width*0.15];
    [self.ctlBtn setTz_height:self.tz_width*0.15];
    [self.ctlBtn setTz_centerX:self.tz_width/2];
    [self.ctlBtn setTz_centerY:self.tz_height/2];

    [self.lableTip setTz_top:self.frame.size.height-self.lableTip.frame.size.height-2];
    [self.lableTip setTz_left:self.frame.size.width-self.lableTip.frame.size.width-2];
    self.activityIndicatorView.frame = CGRectMake(self.tz_width/2-18, self.tz_height/2-18, 37, 37);
    self.labelStatus.frame = CGRectMake(0, self.activityIndicatorView.frame.origin.y+40, self.frame.size.width, 20.);
}

@end
