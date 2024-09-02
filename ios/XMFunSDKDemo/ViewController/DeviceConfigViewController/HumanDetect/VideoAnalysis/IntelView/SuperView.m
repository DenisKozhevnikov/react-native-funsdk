//
//  SuperView.m
//  XMEye
//
//  Created by XM on 2017/4/24.
//  Copyright © 2017年 Megatron. All rights reserved.
//
#define PI 3.14159265358979323846
#import "SuperView.h"

@interface SuperView () <DrawControlDelegate>



@end

@implementation SuperView
{
    BOOL draw_Dnd;//画线过程中的最后一个点
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    if (_control == nil) {
        _control = [[DrawControl alloc] init];
        _control.delegate = self;
        draw_Dnd = YES;
    }
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    UIPanGestureRecognizer *swipeTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeTap:)];
    [singleTap requireGestureRecognizerToFail:swipeTap];
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:swipeTap];
    return self;
}
//设置是大的智能分析类型，周界警戒，单线，盗移，滞留
-(void)setDrawType:(int)type
{
    draw_Dnd = YES;
    _control.drawType = type;
}
//设置场景，包括应用场景和自定义场景
-(void)setSelectSceneType:(DefaultPoint_Type)sceneType
{
    //自己选定场景，需要先把已经记录的撤销动作清除
    //[_control removeAllMemory];
    //自定义场景下draw_Dnd = NO; 应用场景下draw_Dnd = YES;
    [_control getDefaultPointArray:sceneType];
    [_control setStepMemory];
    self.lastType = sceneType;
    [self setNeedsDisplay];
}
//撤销，回到上一步
-(void)toTheBeforeStep
{
    //获取到上一步的点坐标
    [_control getBeforeStep];
    [self setNeedsDisplay];
}

-(void)removeAllStep{
    [self toTheBeforeStep];
//    if (self.lastType == DefaultPoint_Type_None) {
//
//        return;
//    }
//    //获取到上一步的点坐标
//    //自己选定场景，需要先把已经记录的撤销动作清除
//    [_control removeAllMemory];
//    //自定义场景下draw_Dnd = NO; 应用场景下draw_Dnd = YES;
//    [_control getDefaultPointArray:self.lastType];
//    [_control setStepMemory];
//    [self setNeedsDisplay];
}

//撤回上一步
-(void)rollBackLastStep{
    [_control rollBackLastStep];
    [self setNeedsDisplay];
}

-(void)singleTap:(UITapGestureRecognizer*)singleTap
{
    //先判断不是自定义场景的话，直接return
    if (!(_control.dPoint.type == DefaultPoint_Type_Line_Custom ||_control.dPoint.type == DefaultPoint_Type_Area_Custom ||_control.dPoint.type == DefaultPoint_Type_Stay_Custom ||_control.dPoint.type ==DefaultPoint_Type_Move_Custom)) {
        return;
    }
    //然后判断是不是自定义场景
    if (draw_Dnd == YES) {
        [_control.pointArray removeAllObjects];
        draw_Dnd = NO;
    }
    if (singleTap.state == UIGestureRecognizerStateEnded) {
        //判断当前点击的点是否符合规则，并且判断是否是最后一个点
        CGPoint point = [singleTap locationInView:self];
        //判断是否合乎规则，符合的话加进数组
        [_control addPointCorrect:point];
        [_control setStepMemory];
        draw_Dnd =[_control checkLastPoint:point];
        if (draw_Dnd == YES) {
            if ([self.delegate respondsToSelector:@selector(SuperViewSelectPointArray:)]) {
                [self.delegate SuperViewSelectPointArray:[_control.pointArray mutableCopy]];
            }
        }
        [self setNeedsDisplay];
    }
}
int changeGraph = 0;
CGPoint beginPoint;
-(void)swipeTap:(UIPanGestureRecognizer*)swipe
{
    
    if (swipe.state == UIGestureRecognizerStateBegan) {
        //判断当前状态是否可以拖动
        beginPoint = [swipe locationInView:self];
        //判断是否在点上 如果在点上就移动点
        if ([_control checkPointInYetPoint:beginPoint]) {
            changeGraph = 1;
        }else{ //不在点上判断是否在拖动有效区 拖动整个线条或者形状
            changeGraph = [_control checkPointInAreaOrLine:beginPoint];
        }
    }
    if (swipe.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [swipe locationInView:self];
        if (changeGraph == 0) {
            return;
        }else if (changeGraph == 1)
        {
            //如果可以拖动，则修改保存的点的坐标
            [_control changePoint:point];
        }else if (changeGraph == 2)
        {
            //拖动区域
            CGSize size = CGSizeMake(point.x-beginPoint.x, point.y-beginPoint.y);
            [_control changeAllPoint:size];
            beginPoint = point;
        }
        [self setNeedsDisplay];
    }
    if (swipe.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [swipe locationInView:self];
        if (changeGraph == 0) {
            return;
        }
        else if (changeGraph == 1)
        {
            //修改保存的点的坐标，最终保存进栈数据，可以撤销
            [_control changePoint:point];
        }else if (changeGraph == 2)
        {
            //拖动区域
            CGSize size = CGSizeMake(point.x-beginPoint.x, point.y-beginPoint.y);
            [_control changeAllPoint:size];
        }
        [_control setStepMemory];
        [self setNeedsDisplay];
    }
}

//MARK:Delegate
- (void)userChangedPoint{
    if (self.delegate && [self.delegate respondsToSelector:@selector(superViewUserChangedPoint)]) {
        [self.delegate superViewUserChangedPoint];
    }
}

-(void)drawRect:(CGRect)rect
{
    if (_control.pointArray.count == 0) {
        return;
    }
    //设置背景颜色
    [self setDrawRectColor:rect];
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //指定直线样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //直线宽度
    CGContextSetLineWidth(context, 1.0);
    //设置颜色
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    //CGContextSetRGBStrokeColor(context, 0.314, 0.486, 0.859, 1.0);
    //开始绘制
    CGContextBeginPath(context);
    //获取初始点
    CGPoint Begin = [[_control.pointArray objectAtIndex:0] CGPointValue];
    //在画布上面画当前点击的各个点
    [self drawPointInContext:context];
    //画笔移动到初始点
    CGContextMoveToPoint(context, Begin.x, Begin.y);
    //连接中间点
    for (int i =1; i< _control.pointArray.count; i++) {
        CGPoint point = [[_control.pointArray objectAtIndex:i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    if (draw_Dnd == YES/*已经是最后一个点*/) {
        //最后闭合到初始点
        CGContextAddLineToPoint(context, Begin.x, Begin.y);
        //多边形填充区域
        [self drawRegionInContext:context];
        [self addArrow:context];
    }
    //绘制完成
    CGContextStrokePath(context);
}

//在画布上面画当前点击的各个点
-(void)drawPointInContext:(CGContextRef)context
{
    CGPoint Begin = [[_control.pointArray objectAtIndex:0] CGPointValue];
    //初始点画出一个实心圆
    CGContextSetLineWidth(context, 1.0);
    UIColor*aColor = [_control getBeginPointColor];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    CGContextAddArc(context, Begin.x, Begin.y, 5, 0, 2*PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke);//绘制填充
    
    //画中间点
    for (int i =1; i< _control.pointArray.count; i++) {
        CGContextSetLineWidth(context, 1.0);
        CGPoint point = [[_control.pointArray objectAtIndex:i] CGPointValue];
        UIColor*aColor = [_control getPointColor];
        CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
        CGContextAddArc(context, point.x, point.y, 5, 0, 2*PI, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathFillStroke);//绘制填充
    }
}
    //设置背景颜色
-(void)setDrawRectColor:(CGRect)rect
{
    //根据当前的模式设置背景颜色
    [[_control getBackgroundColor] setFill];
    UIRectFill(rect);
}

//多边形填充区域
-(void)drawRegionInContext:(CGContextRef)context
{
    //闭合区域
    CGContextClosePath(context);
    //根据当前场景填充颜色
    [[_control getAreaColor] setFill];
    //开始填充渲染
    CGContextDrawPath(context, kCGPathFillStroke);
    
}
-(void)addArrow:(CGContextRef)context
{
    if (_control.drawType != DrawType_PEA_Line) {
        return;
    }
    //计算直线坐标和中心点
    CGPoint point1 = [[_control.pointArray objectAtIndex:0] CGPointValue];
    CGPoint point2 = [[_control.pointArray lastObject] CGPointValue];
    CGPoint point = CGPointMake((point1.x+point2.x)/2.0, (point1.y+point2.y)/2.0);
    //画箭头的直线部分
    double r = sqrt((point.x-point1.x)*(point.x-point1.x)+(point1.y-point.y)*(point1.y-point.y));//线条长度
    CGPoint beginPoint = CGPointMake(point.x-(10*(point1.y-point.y)/r), point.y-(10*(point.x-point1.x)/r));
    CGPoint endPoint = CGPointMake(point.x+(10*(point1.y-point.y)/r),point.y+(10*(point.x-point1.x)/r));
    CGContextMoveToPoint(context,beginPoint.x,beginPoint.y);
    CGContextAddLineToPoint(context,endPoint.x,endPoint.y);
    
    //计算当前警戒线的方向
    int selectDirection = _control.dPoint.type;
    _control.direction = [MathTool getdirectionBegin:beginPoint end:endPoint];
    
    
    // 根据点的位置和警戒线方向画箭头
       if (selectDirection == DefaultPoint_Type_LeftToRight) {
            //根据当前选择的方向和警戒线段画箭头的方向
            [self arrowDirection:context begin:endPoint end:beginPoint];
        }else if (selectDirection == DefaultPoint_Type_RightToLeft){
            //根据当前选择的方向和警戒线段画箭头的方向
            [self arrowDirection:context begin:beginPoint end:endPoint];
        }else{ //双向
            [self arrowDirection:context begin:endPoint end:beginPoint];
            [self arrowDirection:context begin:beginPoint end:endPoint];
        }
    
//    if (selectDirection == DefaultPoint_Type_LeftToRight) {
//        //根据当前选择的方向和警戒线段画箭头的方向
//        [self arrowDirection:context begin:endPoint end:beginPoint];
//    }else if (selectDirection == DefaultPoint_Type_RightToLeft){
//        //根据当前选择的方向和警戒线段画箭头的方向
//        [self arrowDirection:context begin:beginPoint end:endPoint];
//    }else{ //双向
//        [self arrowDirection:context begin:endPoint end:beginPoint];
//        [self arrowDirection:context begin:beginPoint end:endPoint];
//    }
//    if (selectDirection == DefaultPoint_Type_LeftToRight) {
//        //根据当前选择的方向和警戒线段画箭头的方向
//        if (_control.direction == LEFT_TO_RIGHT || _control.direction == UP_TO_DOWN) {//左-右，上-下
//            [self arrowDirection:context begin:beginPoint end:endPoint];
//        }
//        else if (_control.direction == RIGHT_TO_LEFT || _control.direction == DOWN_TO_UP)
//        {
//            [self arrowDirection:context begin:endPoint end:beginPoint];
//        }
//    }else if (selectDirection == DefaultPoint_Type_RightToLeft)
//    {    //根据当前选择的方向和警戒线段画箭头的方向
//        if (_control.direction == LEFT_TO_RIGHT || _control.direction == UP_TO_DOWN) {//左-右，上-下
//            [self arrowDirection:context begin:endPoint end:beginPoint];
//        }
//        else if (_control.direction == RIGHT_TO_LEFT || _control.direction == DOWN_TO_UP)
//        {
//            [self arrowDirection:context begin:beginPoint end:endPoint];
//        }
//    }else{ //双向
//        [self arrowDirection:context begin:endPoint end:beginPoint];
//        [self arrowDirection:context begin:beginPoint end:endPoint];
//    }


}

//从左上向右下
-(void)arrowDirection:(CGContextRef)context begin:(CGPoint)beginPoint end:(CGPoint)endPoint
{
    //画箭头部分
    CGContextMoveToPoint(context,endPoint.x,endPoint.y);
    //P1
    CGContextAddLineToPoint(context,endPoint.x-(10*(beginPoint.y-endPoint.y)/60),endPoint.y-(10*(endPoint.x-beginPoint.x)/60));
    //P3
    CGContextAddLineToPoint(context,endPoint.x+(20*(endPoint.x-beginPoint.x)/60), endPoint.y-(20*(beginPoint.y-endPoint.y)/60));
    //P2
    CGContextAddLineToPoint(context,endPoint.x+(10*(beginPoint.y-endPoint.y)/60),endPoint.y+(10*(endPoint.x-beginPoint.x)/60));
    
    CGContextAddLineToPoint(context, endPoint.x,endPoint.y);
    UIColor*aColor = [UIColor redColor];
    [aColor setFill];
    
    CGContextDrawPath(context,kCGPathFillStroke);
    CGContextStrokePath(context);
}
@end
