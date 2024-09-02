//
//  DrawControl.h
//  XMEye
//
//  Created by XM on 2017/4/25.
//  Copyright © 2017年 Megatron. All rights reserved.
//
#define BackGroundColor [UIColor colorWithRed:0.314 green:0.486 blue:0.859 alpha:0.3]
#import <Foundation/Foundation.h>
#import "DefaultPoint.h"
#import "MathTool.h"
enum DrawType{
    DrawType_PEA_Line = 0,
    DrawType_PEA_Area,
    DrawType_OSC_Stay,
    DrawType_OSC_Move,
};

@protocol DrawControlDelegate <NSObject>

@optional
- (void)userChangedPoint;

@end
@interface DrawControl : NSObject
{
    
}

@property (nonatomic) enum DrawType drawType;
@property (nonatomic, strong) DefaultPoint *dPoint;

@property (nonatomic,assign) CGRect validFrame;               // 有效视图区域
@property (nonatomic,assign) DefaultPoint_Type firstPointType;       // 最开始的值 还原需要使用到
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) NSMutableArray *shedArray;//栈数组
@property (nonatomic) int changeIndex;//需要拖动改变坐标的点的索引
@property (nonatomic) enum ForbiddenDirection direction;//线段的方向

@property (nonatomic,weak) id<DrawControlDelegate>delegate;

-(NSMutableArray*)getDefaultPointArray:(DefaultPoint_Type)type;//读取默认图形的坐标
-(void)addPointCorrect:(CGPoint)point;//判断当前点击的点是否符合规则，符合规则的话加进数组
-(BOOL)checkLastPoint:(CGPoint)point;//判断当前点击的点是否是最后一个点
-(BOOL)checkPointInYetPoint:(CGPoint)point;//判断当前点击的点是否是在初始点位置
-(int)checkPointInAreaOrLine:(CGPoint)point;//判断点是否在多边形内或者线段区域内，用于拖动区域
-(void)changePoint:(CGPoint)point;//移动当前选择的点的位置
-(void)changeAllPoint:(CGSize)size;//移动当前区域的位置

//保存之前判断多边形是否自交叉
-(BOOL)checkGraphValidated;

//检测线段方向和选择方向是否一致
-(void)checkLineDirection;

-(UIColor*)getBackgroundColor;//获取背景颜色，默认为透明，选择区域外时为半透明色
-(UIColor*)getAreaColor;//获取填充颜色，默认为半透明，选择区域外时为透明色

-(UIColor*)getBeginPointColor;//获取起始点的颜色
-(UIColor*)getPointColor;//获取中间点的颜色

-(void)getDirection;//根据获取到的点坐标计算方向

-(void)getBeforeStep;
- (void)rollBackLastStep;//撤销回到上一步的操作
-(void)setStepMemory;
-(void)removeAllMemory;//清除所有操作记录
@end
