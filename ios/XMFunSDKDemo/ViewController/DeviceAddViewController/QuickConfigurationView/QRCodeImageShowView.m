//
//  QRCodeImageShowView.m
//  FunSDKDemo
//
//  Created by P on 2020/8/11.
//  Copyright © 2020 P. All rights reserved.
//

#import "QRCodeImageShowView.h"

@implementation QRCodeImageShowView
{
    UIImageView *qrImageView;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
        
        int w = frame.size.width;       // 背景图的宽高
        int h = frame.size.height;
        
        qrImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth*0.9, ScreenWidth*0.9)];
        [self addSubview:qrImageView];
        [qrImageView setCenter:CGPointMake(w/2, h/2)];
        
        UITapGestureRecognizer* singleRecognizer= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(single)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:singleRecognizer];
        
    }
    return self;
}

-(void)single
{
    if (self.disMissSelfView) {
        self.disMissSelfView();
    }
}

-(void)setQrCodeImage:(UIImage *)qrCodeImage
{
    [qrImageView setImage:qrCodeImage];
}
@end
