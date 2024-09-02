//
//  MyNavigationBar.m
//  XMEye
//
//  Created by Megatron on 12/5/14.
//  Copyright (c) 2014 Megatron. All rights reserved.
//

#import "MyNavigationBar.h"

@implementation MyNavigationBar

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.ifShow = NO;
        self.arrayRubbish = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    if (self.ifShow == YES) {
        if (self.arrayRubbish.count > 0) {
            for (int i = 0; i < self.arrayRubbish.count; i ++) {
                [[self.arrayRubbish objectAtIndex:i] removeFromSuperview];
            }
            [self.arrayRubbish removeAllObjects];
        }
        if (self.imgView != nil)
        {
            [self addSubview:self.imgView];
            [self.arrayRubbish addObject:self.imgView];
        }
        [self addSubview:self.titleLabel];
        [self.arrayRubbish addObject:self.titleLabel];
        if (self.titleImg != nil)
        {
            [self addSubview:self.titleImg];
        }
        if (self.btnLeft != nil) {
            [self addSubview:self.btnLeft];
            [self.arrayRubbish addObject:self.btnLeft];
        }
        if (self.btnRight != nil) {
            [self addSubview:self.btnRight];
            [self.arrayRubbish addObject:self.btnRight];
        }
        if (self.btnRank != nil) {
            [self addSubview:self.btnRank];
            [self.arrayRubbish addObject:self.btnRank];
        }
    }
}

-(void)showMyNavBar
{
    self.ifShow = YES;
    [self setNeedsDisplay];
}

@end
