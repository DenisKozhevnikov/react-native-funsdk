//
//  DefaultPoint.m
//  XMEye
//
//  Created by XM on 2017/5/4.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "DefaultPoint.h"

@implementation DefaultPoint


-(NSMutableArray*)getPointArray:(DefaultPoint_Type)type
{
    self.type = type;
    if (type == DefaultPoint_Type_LeftToRight || type == DefaultPoint_Type_RightToLeft || type == DefaultPoint_Type_Mutual) {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-80, SCREEN_WIDTH/2.0+80);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+80, SCREEN_WIDTH/2.0-80);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point1], nil];
    
        return array;
    }
    else if (type == DefaultPoint_Type_Thr) //应用场景
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_WIDTH/2.0-50);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0-60, SCREEN_WIDTH/2.0+60);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+60, SCREEN_WIDTH/2.0+60);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], nil];
        return array;
    }else if (type == DefaultPoint_Type_Four) //应用场景
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-50, SCREEN_WIDTH/2.0-30);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+50, SCREEN_WIDTH/2.0-30);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+50, SCREEN_WIDTH/2.0+30);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-50, SCREEN_WIDTH/2.0+30);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }else if (type == DefaultPoint_Type_Five) //应用场景
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-60, SCREEN_WIDTH/2.0-15);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_WIDTH/2.0-60);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+60, SCREEN_WIDTH/2.0-15);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0+45, SCREEN_WIDTH/2.0+45);
        CGPoint point5 = CGPointMake(SCREEN_WIDTH/2.0-45, SCREEN_WIDTH/2.0+45);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], [NSValue valueWithCGPoint:point5], nil];
        return array;
    }else if (type == DefaultPoint_Type_L) //应用场景
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-60, SCREEN_WIDTH/2.0-60);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0-30, SCREEN_WIDTH/2.0-60);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0-30, SCREEN_WIDTH/2.0+30);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0+60, SCREEN_WIDTH/2.0+30);
        CGPoint point5 = CGPointMake(SCREEN_WIDTH/2.0+60, SCREEN_WIDTH/2.0+60);
        CGPoint point6 = CGPointMake(SCREEN_WIDTH/2.0-60, SCREEN_WIDTH/2.0+60);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], [NSValue valueWithCGPoint:point5], [NSValue valueWithCGPoint:point6], nil];
        return array;
    }else if (type == DefaultPoint_Type_C) //应用场景
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-50, SCREEN_WIDTH/2.0-50);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+50, SCREEN_WIDTH/2.0-50);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+50, SCREEN_WIDTH/2.0-20);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_WIDTH/2.0-20);
        CGPoint point5 = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_WIDTH/2.0+20);
        CGPoint point6 = CGPointMake(SCREEN_WIDTH/2.0+50, SCREEN_WIDTH/2.0+20);
        CGPoint point7 = CGPointMake(SCREEN_WIDTH/2.0+50, SCREEN_WIDTH/2.0+50);
        CGPoint point8 = CGPointMake(SCREEN_WIDTH/2.0-50, SCREEN_WIDTH/2.0+50);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], [NSValue valueWithCGPoint:point5], [NSValue valueWithCGPoint:point6], [NSValue valueWithCGPoint:point7], [NSValue valueWithCGPoint:point8], nil];
        return array;
    }else if (type == DefaultPoint_Type_Carport) //车库滞留
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-50, SCREEN_WIDTH/2.0-50);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+50, SCREEN_WIDTH/2.0-50);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+80, SCREEN_WIDTH/2.0+50);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-80, SCREEN_WIDTH/2.0+50);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }else if (type == DefaultPoint_Type_NO_PARKING) //禁止停车
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-30, SCREEN_WIDTH/2.0-60);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+30, SCREEN_WIDTH/2.0-60);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+100, SCREEN_WIDTH/2.0+60);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-30, SCREEN_WIDTH/2.0+60);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }else if (type == DefaultPoint_Type_Corridor) //走廊
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-30, SCREEN_WIDTH/2.0-80);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+30, SCREEN_WIDTH/2.0-80);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+60, SCREEN_WIDTH/2.0+80);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-60, SCREEN_WIDTH/2.0+80);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }
    else if (type == DefaultPoint_Type_Jewelry) //珠宝首饰
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-20, SCREEN_WIDTH/2.0-30);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+20, SCREEN_WIDTH/2.0-30);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+60, SCREEN_WIDTH/2.0+30);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-60, SCREEN_WIDTH/2.0+30);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }else if (type == DefaultPoint_Type_Baby_Room) //宝宝房
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-100, SCREEN_WIDTH/2.0-80);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+100, SCREEN_WIDTH/2.0-80);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+100, SCREEN_WIDTH/2.0+80);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-100, SCREEN_WIDTH/2.0+80);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }else if (type == DefaultPoint_Type_sanctum) //书房
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-80, SCREEN_WIDTH/2.0-100);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+80, SCREEN_WIDTH/2.0-100);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+80, SCREEN_WIDTH/2.0-20);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-80, SCREEN_WIDTH/2.0-20);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }
    else if (type == DefaultPoint_Type_Area_Custom || type == DefaultPoint_Type_Stay_Custom || type == DefaultPoint_Type_Move_Custom)
    {
        CGPoint point1 = CGPointMake(SCREEN_WIDTH/2.0-80, SCREEN_WIDTH/2.0-50);
        CGPoint point2 = CGPointMake(SCREEN_WIDTH/2.0+80, SCREEN_WIDTH/2.0-50);
        CGPoint point3 = CGPointMake(SCREEN_WIDTH/2.0+80, SCREEN_WIDTH/2.0+50);
        CGPoint point4 = CGPointMake(SCREEN_WIDTH/2.0-80, SCREEN_WIDTH/2.0+50);
        NSMutableArray *array = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], nil];
        return array;
    }
    return [[NSMutableArray alloc] initWithCapacity:0];
}
@end
