//
//  ControlToolView.m
//  Giga Admin
//
//  Created by P on 2019/11/25.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "ControlToolView.h"

@implementation ControlToolView
{
    CGRect viewFrame;
    
    NSTimer* timer;
    
    int tempNum;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        viewFrame = frame;
        [self configSubView];
    }
    return self;
}

-(UIImageView *)PTZControlIV{
    if (!_PTZControlIV) {
        _PTZControlIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 120, 120)];
        _PTZControlIV.center = CGPointMake(CGRectGetWidth(viewFrame) * 0.5, _PTZControlIV.center.y);
        _PTZControlIV.image = [UIImage imageNamed:@"btn_control_normal.png"];
        _PTZControlIV.userInteractionEnabled = YES;
    }
    return _PTZControlIV;
}

-(UIButton *)PTZUpBtn{
    if (!_PTZUpBtn) {
        _PTZUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
        _PTZUpBtn.backgroundColor = [UIColor clearColor];
        _PTZUpBtn.tag = 0;
        [_PTZUpBtn addTarget:self action:@selector(TouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_PTZUpBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchCancel];
        [_PTZUpBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _PTZUpBtn;
}

-(UIButton *)PTZDownBtn{
    if (!_PTZDownBtn) {
        _PTZDownBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 80, 40, 40)];
        _PTZDownBtn.backgroundColor = [UIColor clearColor];
        _PTZDownBtn.tag = 1;
        [_PTZDownBtn addTarget:self action:@selector(TouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_PTZDownBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchCancel];
        [_PTZDownBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _PTZDownBtn;
}

-(UIButton *)PTZLeftBtn{
    if (!_PTZLeftBtn) {
        _PTZLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 40, 40)];
        _PTZLeftBtn.backgroundColor = [UIColor clearColor];
        _PTZLeftBtn.tag = 2;
        [_PTZLeftBtn addTarget:self action:@selector(TouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_PTZLeftBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchCancel];
        [_PTZLeftBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _PTZLeftBtn;
}

-(UIButton *)PTZRightBtn{
    if (!_PTZRightBtn) {
        _PTZRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, 40, 40, 40)];
        _PTZRightBtn.backgroundColor = [UIColor clearColor];
        _PTZRightBtn.tag = 3;
        [_PTZRightBtn addTarget:self action:@selector(TouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_PTZRightBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchCancel];
        [_PTZRightBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _PTZRightBtn;
}

//-(UIButton *)closeBtn{
//    if (!_closeBtn) {
//        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50,10 , 40, 40)];
//        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
//        [_closeBtn addTarget:self action:@selector(removeTheView:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _closeBtn;
//}

-(UIButton *)leftPressBtn{
    if (!_leftPressBtn) {
        _leftPressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (viewFrame.size.height-150)/2+150-20, 80, 40)];
        [_leftPressBtn  setTitle:TS("TR_Left_Click") forState:UIControlStateNormal];
        _leftPressBtn.tag = 4;
        [_leftPressBtn setBackgroundColor:[UIColor colorWithRed:145.0/255 green:219.0/255 blue:107.0/255 alpha:1.0f]];
        [_leftPressBtn addTarget:self action:@selector(TouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_leftPressBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchCancel];
        [_leftPressBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftPressBtn;
}

-(UIButton *)rightPressBtn{
    if (!_rightPressBtn) {
        _rightPressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,(viewFrame.size.height-150)/2+150-20 , 80, 40)];
        [_rightPressBtn  setTitle:TS("TR_Right_Click") forState:UIControlStateNormal];
        _rightPressBtn.tag = 5;
        [_rightPressBtn setBackgroundColor:[UIColor colorWithRed:145.0/255 green:219.0/255 blue:107.0/255 alpha:1.0f]];
        [_rightPressBtn addTarget:self action:@selector(TouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_rightPressBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchCancel];
        [_rightPressBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rightPressBtn;
}

-(UIButton *)cancelPressBtn{
    if (!_cancelPressBtn) {
        _cancelPressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,(viewFrame.size.height-150)/2+150-20 , 80, 40)];
        [_cancelPressBtn  setTitle:TS("TR_ESC_Click") forState:UIControlStateNormal];
        _cancelPressBtn.tag = 6;
        [_cancelPressBtn setBackgroundColor:[UIColor colorWithRed:145.0/255 green:219.0/255 blue:107.0/255 alpha:1.0f]];
        [_cancelPressBtn addTarget:self action:@selector(TouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_cancelPressBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchCancel];
        [_cancelPressBtn addTarget:self action:@selector(TouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelPressBtn;
}


-(void)configSubView{
//    [self addSubview:self.closeBtn];
    [self addSubview:self.PTZControlIV];
    [self.PTZControlIV addSubview:self.PTZUpBtn];
    [self.PTZControlIV addSubview:self.PTZDownBtn];
    [self.PTZControlIV addSubview:self.PTZLeftBtn];
    [self.PTZControlIV addSubview:self.PTZRightBtn];
    [self addSubview:self.leftPressBtn];
    [self addSubview:self.rightPressBtn];
    [self addSubview:self.cancelPressBtn];
    
    [self.leftPressBtn setCenter:CGPointMake(CGRectGetWidth(viewFrame)/4, self.leftPressBtn.center.y)];
    
    [self.rightPressBtn setCenter:CGPointMake(CGRectGetWidth(viewFrame)/4*3, self.rightPressBtn.center.y)];
    
    [self.cancelPressBtn setCenter:CGPointMake(CGRectGetWidth(viewFrame)/4*2, self.cancelPressBtn.center.y)];
    
}

-(void)cancelAction
{
    if (self.delgate && [self.delgate respondsToSelector:@selector(controlBtnCancelAction)]) {
        [self.delgate controlBtnCancelAction];
    }
    
}


#pragma mark - 点击云台控制的按钮
-(void)TouchDownAction:(UIButton *)sender{
    
    tempNum = sender.tag;
    
    switch (sender.tag) {
        case 0:
            _PTZControlIV.image = [UIImage imageNamed:@"btn_control_up.png"];
            break;
        case 1:
            _PTZControlIV.image = [UIImage imageNamed:@"btn_control_down.png"];
            break;
        case 2:
            _PTZControlIV.image = [UIImage imageNamed:@"btn_control_left.png"];
            break;
        case 3:
            _PTZControlIV.image = [UIImage imageNamed:@"btn_control_right.png"];
            break;
        default:
            break;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _PTZControlIV.image = [UIImage imageNamed:@"btn_control_normal.png"];
    });
   
    if (self.delgate && [self.delgate respondsToSelector:@selector(controlBtnTouchDownAction:)]) {
        [self.delgate controlBtnTouchDownAction:sender.tag];
    }
    
    if (sender.tag == 0||sender.tag == 1||sender.tag == 2||sender.tag ==3)
    {
        if (!timer)
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(Timered) userInfo:nil repeats:YES];
            [timer setFireDate:[NSDate distantPast]];
        }
    }
}

-(void)Timered
{
    if (self.delgate && [self.delgate respondsToSelector:@selector(controlBtnTouchDownAction:)]) {
        [self.delgate controlBtnTouchDownAction:tempNum];
    }
    
    NSLog(@"chufa le");
}

#pragma mark - 抬起云台控制的按钮
-(void)TouchUpInsideAction:(UIButton *)sender{
    
    if (sender.tag == 0||sender.tag == 1||sender.tag == 2||sender.tag ==3)
    {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }
    
    
    
    if (self.delgate && [self.delgate respondsToSelector:@selector(controlBtnTouchUpInsideAction:)]) {
        [self.delgate controlBtnTouchUpInsideAction:sender.tag];
    }
}

//-(void)removeTheView:(UIButton *)sender{
//    [self removeFromSuperview];
//}

@end
