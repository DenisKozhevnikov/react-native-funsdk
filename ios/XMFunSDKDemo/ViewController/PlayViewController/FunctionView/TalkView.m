//
//  TalkView.m
//  XMEye
//
//  Created by Wangchaoqun on 15/7/4.
//  Copyright (c) 2015年 Megatron. All rights reserved.
//

#import "TalkView.h"


@implementation TalkView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.talkSoundType = 0;
        
        self.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
        
        self.femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.femaleButton addTarget:self action:@selector(btnMaleClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.femaleButton.tag = 1;
        [self.femaleButton setTitle:TS("common_female") forState:UIControlStateNormal];
        [self.femaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.femaleButton setTitleColor:GlobalMainColor forState:UIControlStateSelected];
        [self addSubview:self.femaleButton];
        
        
        self.maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.maleButton addTarget:self action:@selector(btnMaleClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.maleButton.tag = 2;
        [self.maleButton setTitle:TS("common_male") forState:UIControlStateNormal];
        [self.maleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.maleButton setTitleColor:GlobalMainColor forState:UIControlStateSelected];
        [self addSubview:self.maleButton];
        
        
        
        self.talkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.talkButton setBackgroundImage:[UIImage imageNamed:TS("press_talk")] forState:UIControlStateNormal];
        [self.talkButton setBackgroundImage:[UIImage imageNamed:TS("press_talk_selected")] forState:UIControlStateHighlighted];
        [self.talkButton addTarget:self action:@selector(talkToOther:) forControlEvents:UIControlEventTouchDown];
        [self.talkButton addTarget:self action:@selector(cannelTalk:) forControlEvents:UIControlEventTouchUpInside];
        [self.talkButton addTarget:self action:@selector(cannelTalk:) forControlEvents:UIControlEventTouchUpOutside];
        self.talkButton.tag = 100;
        [self addSubview:self.talkButton];
        
        
        self.dTalkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dTalkButton setBackgroundImage:[UIImage imageNamed:TS("press_Doutalk")] forState:UIControlStateNormal];
        [self.dTalkButton setBackgroundImage:[UIImage imageNamed:TS("press_Doutalk_selected")] forState:UIControlStateHighlighted];
        [self.dTalkButton setBackgroundImage:[UIImage imageNamed:TS("press_Doutalk")] forState:UIControlStateNormal];
        [self.dTalkButton setBackgroundImage:[UIImage imageNamed:TS("press_Doutalk_selected")] forState:UIControlStateSelected];
        [self.dTalkButton addTarget:self action:@selector(talkToOther:) forControlEvents:UIControlEventTouchDown];
        [self.dTalkButton addTarget:self action:@selector(cannelTalk:) forControlEvents:UIControlEventTouchUpInside];
        [self.dTalkButton addTarget:self action:@selector(cannelTalk:) forControlEvents:UIControlEventTouchUpOutside];
        self.dTalkButton.tag = 200;
        [self addSubview:self.dTalkButton];
        
        self.cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cannelButton setBackgroundImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [self.cannelButton addTarget:self action:@selector(cannelTheView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cannelButton];
    }
    return self;
}

//显示视图
- (void)showTheView
{
    CGFloat width = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ?
                                             CGRectGetHeight(self.frame) - 10:
                                             CGRectGetWidth(self.frame) - 10;
    if (width> 80) {
        width = 80;
    }
    self.talkButton.frame = CGRectMake(0, 0, width, width);
    self.talkButton.center = CGPointMake(self.bounds.size.width / 4+20, self.bounds.size.height / 2+20);
    
    self.cannelButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 50, 0, 40, 40);
    
    self.dTalkButton.frame = self.talkButton.frame;
    self.dTalkButton.center = CGPointMake(self.bounds.size.width *3/ 4-20, self.bounds.size.height / 2+20);
    
    CGRect frame = self.frame;
    self.frame = CGRectOffset(frame, 0, frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = frame;
        self.cannelButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(openTalkView)]) {
            [self.delegate openTalkView];
        }
    }];
    
    
    self.femaleButton.frame = CGRectMake(40, 20, 60, 40);
    self.maleButton.frame = CGRectMake(120, 20, 60, 40);
    
    
}


//关闭视图
- (void)cannelTheView {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectOffset(self.frame, 0, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(closeTalkView)]) {
            [self.delegate closeTalkView];
        }
    }];
}

//打开通话
- (void)talkToOther:(id)sender {
    UIButton *button  = (UIButton*)sender;
    if (button.tag == 100) { //单向对讲
        button.highlighted = true;
        if ([self.delegate respondsToSelector:@selector(openTalk)]) {
            [self.delegate openTalk];
        }
    }else if (button.tag == 200) { //双向对讲
        //双向对讲按下时不做处理
    }
}

//关闭通话
- (void)cannelTalk:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.tag == 100) { //单向对讲
        button.highlighted = false;
        if ([self.delegate respondsToSelector:@selector(closeTalk)]) {
            [self.delegate closeTalk];
        }
    }else if (button.tag == 200) { //双向对讲
        if (button.isSelected == NO) {
            button.selected = YES;
            if ([self.delegate respondsToSelector:@selector(startDouTalk)]) {
                [self.delegate startDouTalk]; //开始双向对讲
            }
        }else if (button.isSelected == YES) {
            button.selected = NO;
            if ([self.delegate respondsToSelector:@selector(stopDouTalk)]) {
                [self.delegate stopDouTalk]; //结束双向对讲
            }
        }
    }
}

- (void)btnMaleClicked:(UIButton*)sender {
    if (sender.tag == 1) {
        sender.selected = !sender.selected;
        self.maleButton.selected = NO;
        self.talkSoundType = sender.tag;
    } else {
        sender.selected = !sender.selected;
        self.femaleButton.selected = NO;
        self.talkSoundType = sender.tag;
    }
    if (sender.selected == NO) {
        self.talkSoundType = 0;
    }
}

@end
