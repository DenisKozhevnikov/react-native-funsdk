//
//  MathTool.m
//  XMEye
//
//  Created by XM on 2017/5/13.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "MathTool.h"

@implementation MathTool


#pragma mark - 计算当前单线的警戒方向
+(int)getdirectionBegin:(CGPoint)point1 end:(CGPoint)point2
{
    int x1,x2,y1,y2;
    x1 = point1.x;
    y1 = point1.y;
    x2 = point2.x;
    y2 = point2.y;
    int height = abs(y2 - y1);
    int width  = abs(x2 - x1);
    int m_directionType;
    if(height == 0)
    {
        m_directionType = 1;
    }
    else if(width == 0){
        m_directionType = 2;
    }
    else{
        int radio  = height * 100 / width; //为了保持精度，将高乘上100
        if(radio > 58) //如果警戒线与水平方向成都角度小于30度(tan 30°= 0.58)
        {
            m_directionType = 2;
        }
        else{
            m_directionType = 1;
        }
    }
    if(m_directionType == 2){
        if((x1 > x2 && y1 > y2) || (x1 < x2 && y1 < y2))
        {
            if(y1 > y2){
                return RIGHT_TO_LEFT;
            }else
            {
                return LEFT_TO_RIGHT;
            }
        }
        else{
            if(y1 > y2){
                return LEFT_TO_RIGHT;
            }
            else{
                return RIGHT_TO_LEFT;
            }
        }
    }
    else if(m_directionType == 1)
    {
        if(x1 > x2){
            return DOWN_TO_UP;
        }else
        {
            return UP_TO_DOWN;
        }
    }
    return BOTH_SIDES;
}

//计算点到直线的最短距离，x3y3是点，另外两个连接成直线
+(int)CalDisX:(float)x1 Y:(float)y1 X:(float)x2 Y:(float)y2 X:(float)x3 Y:(float)y3
{
    double px = x2 - x1;
    double py = y2 - y1;
    double som = px * px + py * py;
    double u = ((x3 - x1) * px + (y3 - y1) * py) / som;
    if (u > 1) {
        u = 1;
    }
    if (u < 0) {
        u = 0;
    }
    //the closest point
    double x = x1 + u * px;
    double y = y1 + u * py;
    double dx = x - x3;
    double dy = y - y3;
    double dist = sqrt(dx*dx + dy*dy);
    return dist;
}

/**
 * 判断两条线段是否相交，参见如下
 */
double min(double x,double y)
{
    return x<y?x:y;
}
double max(double x,double y)
{
    return x>y?x:y;
}
bool onsegment(CGPoint pi,CGPoint pj,CGPoint pk) //判断点pk是否在线段pi pj上
{
    if(min(pi.x,pj.x)<=pk.x&&pk.x<=max(pi.x,pj.x))
    {
        if(min(pi.y,pj.y)<=pk.y&&pk.y<=max(pi.y,pj.y))
        {
            return true;
        }
    }
    return false;
}
double direction(CGPoint pi,CGPoint pj,CGPoint pk) //计算向量pkpi和向量pjpi的叉积
{
    return (pi.x-pk.x)*(pi.y-pj.y)-(pi.y-pk.y)*(pi.x-pj.x);
}
+(BOOL)judgep1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 //判断线段p1p2和p3p4是否相交
{
    double d1 = direction(p3,p4,p1);
    double d2 = direction(p3,p4,p2);
    double d3 = direction(p1,p2,p3);
    double d4 = direction(p1,p2,p4);
    if(d1*d2<0&&d3*d4<0)
        return true;
    if(d1==0&&onsegment(p3,p4,p1))
        return true;
    if(d2==0&&onsegment(p3,p4,p2))
        return true;
    if(d3==0&&onsegment(p1,p2,p3))
        return true;
    if(d4==0&&onsegment(p1,p2,p4))
        return true;
    return false;
}
@end
