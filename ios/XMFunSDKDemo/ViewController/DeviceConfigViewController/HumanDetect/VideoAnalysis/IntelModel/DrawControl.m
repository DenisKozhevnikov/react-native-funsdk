//
//  DrawControl.m
//  XMEye
//
//  Created by XM on 2017/4/25.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "DrawControl.h"
@implementation DrawControl

-(id)init
{
    self = [super init];
    if (self) {
        _pointArray = [[NSMutableArray alloc] initWithCapacity:0];
        _shedArray = [[NSMutableArray alloc] initWithCapacity:0];
        if (_dPoint == nil) {
            _dPoint = [[DefaultPoint alloc] init];
        }
    }
    return self;
}
#pragma mark - 读取默认图形的坐标
-(NSMutableArray*)getDefaultPointArray:(DefaultPoint_Type)type{
    if (self.dPoint.type == DefaultPoint_Type_LeftToRight ||
        self.dPoint.type == DefaultPoint_Type_RightToLeft ||
        self.dPoint.type == DefaultPoint_Type_Mutual) {
        _pointArray = [[_dPoint getPointArray:type] mutableCopy];
        return _pointArray;
    }else{
        _pointArray = [[_dPoint getPointArray:type] mutableCopy];
        return _pointArray;
    }
}
#pragma mark - 判断当前选中和点击的点的规则
//判断当前点击的点是否符合规则,如果点在原来的点上面，则不能加进数组
-(void)addPointCorrect:(CGPoint)point
{
    for (int i =0; i< self.pointArray.count; i++) {
        CGPoint beginPoint = [[self.pointArray objectAtIndex:i] CGPointValue];
        //如果当前点的位置原先已经点过，则不能加进数组
        if ([self checkpoint:beginPoint withPoint:point]) {
            return;
        }
    }
    [self.pointArray addObject:[NSValue valueWithCGPoint:point]];
}
//判断当前的点是否是最后一个点,用来闭合
-(BOOL)checkLastPoint:(CGPoint)point
{
    if (self.pointArray.count <=1) {
        //第一次取点
        return NO;
    }
    if (_drawType == DrawType_PEA_Line) {
        return [self checkPEA_Line:point];
    }
    if (_drawType == DrawType_PEA_Area) {
        return [self checkPEA_Area:point];
    }
    if (_drawType == DrawType_OSC_Stay) {
        return [self checkOSC_Area:point];
    }
    if (_drawType == DrawType_OSC_Move) {
        return [self checkOSC_Area:point];
    }
    return NO;
}
//判断是否点击在已经有点的位置，用来拖动点
-(BOOL)checkPointInYetPoint:(CGPoint)point
{
    for (int i =0; i< self.pointArray.count; i++) {
        CGPoint beginPoint = [[self.pointArray objectAtIndex:i] CGPointValue];
        if ([self checkpoint:beginPoint withPoint:point]) {
            _changeIndex = i;
            return YES;
        }
    }
    _changeIndex = -1;
    return NO;
}
//判断点是否在拖动区域内
-(int)checkPointInAreaOrLine:(CGPoint)point
{
    if (self.pointArray.count < 2) {
        return NO;
    }
    if (self.pointArray.count == 2 &&  _drawType == DrawType_PEA_Line) {
        //直线 计算点到直线最近的距离
        int distance = [self getDistance:point];
        if (distance<18)
            return 2;
    }else
    {    //计算是否是有效的多边形
        return [self checkPointInArea:point];
    }
    return 0;
}
//判断一个点是否在多边形内
-(int)checkPointInArea:(CGPoint)point
{
    CGMutablePathRef pathRef=CGPathCreateMutable();
    CGPoint beginPoint = [[self.pointArray objectAtIndex:0] CGPointValue];
    CGPathMoveToPoint(pathRef, NULL, beginPoint.x, beginPoint.y);
    for (int i =1; i< self.pointArray.count; i++) {
        CGPoint midPoint = [[self.pointArray objectAtIndex:i] CGPointValue];
        CGPathAddLineToPoint(pathRef, NULL, midPoint.x, midPoint.y);
    }
    CGPathCloseSubpath(pathRef);
    if (CGPathContainsPoint(pathRef, NULL, point, NO))
    {
        return 2;
    }
    return 0;
}
//比较两个点之间的距离，距离过近则认为是同一个点
-(BOOL)checkpoint:(CGPoint)beginPoint withPoint:(CGPoint)point
{
    if (fabs(beginPoint.x-point.x) <20 && fabs(beginPoint.y-point.y) <20) {
        return YES;
    }
    return NO;
}
//移动当前选择的点的位置
-(void)changePoint:(CGPoint)point
{
    // 限制点的位置 不能超出当前视图区域
    if (point.x < 0) {
        point.x = 0;
    }
    
    if (point.x > self.validFrame.size.width) {
        point.x = self.validFrame.size.width;
    }
    
    if (point.y < 0) {
        point.y = 0;
    }
    
    if (point.y > self.validFrame.size.height) {
        point.y = self.validFrame.size.height;
    }
    
    [self.pointArray replaceObjectAtIndex:_changeIndex withObject:[NSValue valueWithCGPoint:point]];
}
//移动当前区域的位置
-(void)changeAllPoint:(CGSize)size
{
    for (int i =0; i< self.pointArray.count; i++) {
        CGPoint point = [[self.pointArray objectAtIndex:i] CGPointValue];
        
        point.x = point.x+size.width;
        point.y = point.y+size.height;
        
        // 限制点的位置 不能超出当前视图区域
        if (point.x < 0) {
            point.x = 0;
        }
        
        if (point.x > self.validFrame.size.width) {
            point.x = self.validFrame.size.width;
        }
        
        if (point.y < 0) {
            point.y = 0;
        }
        
        if (point.y > self.validFrame.size.height) {
            point.y = self.validFrame.size.height;
        }
        
        [self.pointArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:point]];
    }
}
//判断当前的点是否符合PEA区域规则
-(BOOL)checkPEA_Area:(CGPoint)point
{
    CGPoint beginPoint = [[self.pointArray objectAtIndex:0] CGPointValue];
    if ([self checkpoint:beginPoint withPoint:point]) {
        if (self.pointArray.count>= 3) {
            return YES;
        }
        return NO;
    }
    if (self.pointArray.count >= 8) {
        //点数超出，连接到终点
        return YES;
    }
    return NO;
}
//判断当前的点是否符合PEA线规则
-(BOOL)checkPEA_Line:(CGPoint)point
{
    CGPoint beginPoint = [[self.pointArray objectAtIndex:0] CGPointValue];
    if ([self checkpoint:beginPoint withPoint:point]) {
        //两个点位置过近，不符合规则
        [self.pointArray removeLastObject];
        return NO;
    }
    if (self.pointArray.count == 2) {
        //如果已经选取了两个有效的点，返回yes
        return YES;
    }
    return NO;
}
//判断当前的点是否符合OSC物品看护规则
-(BOOL)checkOSC_Area:(CGPoint)point
{
    CGPoint beginPoint = [[self.pointArray objectAtIndex:0] CGPointValue];
    if ([self checkpoint:beginPoint withPoint:point]) {
        if (self.pointArray.count>= 4) {
            return YES;
        }
        return NO;
    }
    if (self.pointArray.count >= 8) {
        //点数超出，连接到终点
        return YES;
    }
    return NO;
}
//检测线段方向和选择方向是否一致
-(void)checkLineDirection
{
    //计算当前警戒线的方向
    int selectDirection = self.dPoint.type;
    if (selectDirection == (int)self.direction || selectDirection == 103) {
        
    }else{
        if (self.pointArray && self.pointArray.count == 2) {
            [self.pointArray insertObject:[self.pointArray lastObject] atIndex:0];
            [self.pointArray removeLastObject];
        }
    }
}
#pragma mark - 获取点和线以及区域的颜色
//获取背景颜色，默认为透明，选择区域外时为半透明色
-(UIColor*)getBackgroundColor
{
    return [UIColor clearColor];
}
//获取填充颜色，默认为半透明，选择区域外时为透明色
-(UIColor*)getAreaColor
{
    return BackGroundColor;
}
//获取起始点的颜色
-(UIColor*)getBeginPointColor
{
    return [UIColor colorWithRed:244/255.0 green:129/255.0 blue:4/255.0 alpha:.5];
}
//获取中间点的颜色
-(UIColor*)getPointColor
{
    return [UIColor colorWithRed:255/255.0 green:209/255.0 blue:89/255.0 alpha:.5];
}
//计算点到直线的最短距离
-(int)getDistance:(CGPoint)point
{
    if (self.pointArray.count != 2) {
        return 100000;
    }
    CGPoint beginPoint = [[self.pointArray objectAtIndex:0] CGPointValue];
    CGPoint endPoint = [[self.pointArray objectAtIndex:1] CGPointValue];
    return [MathTool CalDisX:beginPoint.x Y:beginPoint.y X:endPoint.x Y:endPoint.y X:point.x Y:point.y];
}
//判断多边形是否自交叉
-(BOOL)checkGraphValidated
{
    int max = [_pointArray count]-2;
    //多边形会交叉，最好在保存的时候进行判断
    for (int i=0; i< max; i++) {
        
        
        for (int j = i+1; j< max; j++) {
            CGPoint s1 = [[_pointArray objectAtIndex:i] CGPointValue];
            CGPoint e1 = [[_pointArray objectAtIndex:i+1] CGPointValue];
            CGPoint s2 = [[_pointArray objectAtIndex:j+1] CGPointValue];
            CGPoint e2 = [[_pointArray objectAtIndex:j+2] CGPointValue];
            BOOL result = [MathTool judgep1:s1 p2:e1 p3:s2 p4:e2];
            if (result) {
                return result;
            }
            
        }
    }
    return NO;
}
-(void)getDirection
{
    if (_pointArray &&_pointArray.count>=2) {
        CGPoint s1 = [[_pointArray objectAtIndex:0] CGPointValue];
        CGPoint e1 = [[_pointArray objectAtIndex:1] CGPointValue];
        int direction = [MathTool getdirectionBegin:s1 end:e1];
        if (direction == 101) {
            self.dPoint.type = DefaultPoint_Type_LeftToRight;
        }else if (direction == 102)
        {
            self.dPoint.type = DefaultPoint_Type_RightToLeft;
        }else
        {
            self.dPoint.type = DefaultPoint_Type_Mutual;
        }
    }
    
}
#pragma mark - 撤销回到上一步的操作
- (void)rollBackLastStep{
    if (_shedArray == nil || _shedArray.count == 0) {
        return;
    }
    
    if (_shedArray.count >= 2) {
        [_shedArray removeLastObject];
    }
    
    if (_shedArray.count != 0) {
        _pointArray = [[_shedArray lastObject] mutableCopy];
        return;
    }
}

// 还原所有操作 包括方向
-(void)getBeforeStep
{
    if (_shedArray == nil || _shedArray.count == 0) {
        return;
    }
    
    do {
        if (_shedArray.count >= 2) {
            [_shedArray removeLastObject];
        }
    } while (_shedArray.count >= 2);
    
    self.dPoint.type = self.firstPointType;
    if (_shedArray.count != 0) {
        _pointArray = [[_shedArray lastObject] mutableCopy];
        return;
    }
    _pointArray = [NSMutableArray array];
}
//记录每一步操作
-(void)setStepMemory
{
    if (_pointArray == nil) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(userChangedPoint)]) {
        [self.delegate userChangedPoint];
    }
    [_shedArray addObject:[_pointArray mutableCopy]];
}
//清除所有操作记录
-(void)removeAllMemory
{
    if (_shedArray == nil || _shedArray.count == 0) {
        return;
    }
    [_shedArray removeAllObjects];
}

- (void)setPointArray:(NSMutableArray *)pointArray{
    _pointArray = [pointArray mutableCopy];
}

@end
