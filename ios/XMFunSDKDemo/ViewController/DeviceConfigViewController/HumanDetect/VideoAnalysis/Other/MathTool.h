//
//  MathTool.h
//  XMEye
//
//  Created by XM on 2017/5/13.
//  Copyright © 2017年 Megatron. All rights reserved.
//
enum ForbiddenDirection
{
    BOTH_SIDES = 103,    //双向
    LEFT_TO_RIGHT = 101, //左 -> 右
    UP_TO_DOWN    = 101, //上 -> 下
    RIGHT_TO_LEFT = 102, //右 -> 左
    DOWN_TO_UP    = 102, //下 -> 上
};
#import <Foundation/Foundation.h>

@interface MathTool : NSObject


#pragma mark - 计算当前单线的警戒方向
+(int)getdirectionBegin:(CGPoint)point1 end:(CGPoint)point2;
//计算点到直线的最短距离
+(int)CalDisX:(float)x1 Y:(float)y1 X:(float)x2 Y:(float)y2 X:(float)x3 Y:(float)y3;
//判断线段p1p2和p3p4是否相交
+(BOOL)judgep1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4;
@end
