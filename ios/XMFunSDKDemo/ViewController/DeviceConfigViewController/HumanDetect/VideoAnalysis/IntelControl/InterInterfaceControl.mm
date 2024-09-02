//
//  InterInterfaceControl.m
//  XMEye
//
//  Created by XM on 2017/4/22.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "InterInterfaceControl.h"
#import "Detect_Analyze.h"
#import "SVProgressHUD.h"
#import "DeviceConfig.h"
#import "MessageUI.h"

#define SCALEWIDEH 8194.0
@interface InterInterfaceControl () <DeviceConfigDelegate>
{
    Detect_Analyze Analyze;
}
@end

@implementation InterInterfaceControl

-(id)init
{
    self = [super init];
    if (self) {
        _intelData = [[IntelData alloc] init];
    }
    return self;
}

-(void)getAnalyzeData
{
    [SVProgressHUD show];
    Analyze.SetName(JK_Detect_Analyze);
    DeviceConfig* cfg = [[DeviceConfig alloc] initWithJObject:&Analyze];
    cfg.devId = self.devID;
    cfg.channel = -1;
    cfg.isSet = NO;
    cfg.delegate = self;
    [self requestGetConfig:cfg];
}

-(void)saveAnalyzeConfig
{
    [SVProgressHUD showWithStatus:TS("Saving") maskType:SVProgressHUDMaskTypeBlack];
    
    //当前算法配置
    Analyze.Enable = _intelData.AnalyzeEnable;
    Analyze.mEventHandler.RecordEnable = _intelData.AnalyzeEnable;
    Analyze.ModuleType = _intelData.ModuleType;
    
    //PEA配置
    Analyze.mRuleConfig.mPEARule.PerimeterEnable = _intelData.PerimeterEnable;//周线警戒开关
    Analyze.mRuleConfig.mPEARule.TripWireEnable = _intelData.TripWireEnable; //单线警戒开关
    Analyze.mRuleConfig.mPEARule.ShowRule = _intelData.PeaShowRule;  //显示规则
    Analyze.mRuleConfig.mPEARule.ShowTrace = _intelData.PeaShowTrace;  //显示踪迹
    Analyze.mRuleConfig.mPEARule.ShowTrack = _intelData.PeaShowRule;
    Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.DirectionLimit = _intelData.DirectionLimit; //周线警戒方向
    if (Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire.Size()>0) {//单线警戒方向
        Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].IsDoubleDir = _intelData.IsDoubleDir;
        Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].Valid = _intelData.PeaShowRule;
    }
    //OSC配置
    Analyze.mRuleConfig.mOSCRule.AbandumEnable = _intelData.AbandumEnable;
    Analyze.mRuleConfig.mOSCRule.StolenEnable = _intelData.StolenEnable;
    Analyze.mRuleConfig.mOSCRule.ShowRule = _intelData.OscShowRule;
    Analyze.mRuleConfig.mOSCRule.ShowTrace = _intelData.OscShowTrace;
    Analyze.mRuleConfig.mOSCRule.ShowTrack = _intelData.OscShowRule;
    //设置是否显示规则
    Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs[0].Valid = _intelData.OscShowRule;
    Analyze.mRuleConfig.mOSCRule.mNoParkingRule.SpclRgs[0].Valid = _intelData.OscShowRule;
    Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs[0].Valid = _intelData.OscShowRule;
    
    //场景变换检测
    Analyze.mRuleConfig.mAVDRule.ChangeEnable = _intelData.ChangeEnable;
    //人为干扰检测
    Analyze.mRuleConfig.mAVDRule.InterfereEnable = _intelData.InterfereEnable;
    //画面冻结检测
    Analyze.mRuleConfig.mAVDRule.FreezeEnable = _intelData.FreezeEnable;
    //信号缺失检测
    Analyze.mRuleConfig.mAVDRule.NosignalEnable = _intelData.NosignalEnable;
    
    DeviceConfig *cfg = [DeviceConfig initWith:self.devID Channel:-1 GetSet:2 Resutl:&Analyze Delegate:self];
    [self requestSetConfig:cfg];
}

-(void)getConfig:(DeviceConfig *)config result:(int)result{
    if ( result >=0 ) {
        [SVProgressHUD dismiss];
        //智能分析开关
        _intelData.AnalyzeEnable = Analyze.Enable.Value();
        //智能分析算法
        _intelData.ModuleType = Analyze.ModuleType.Value();
        
        
        //警戒级别
        _intelData.PeaLevel = Analyze.mRuleConfig.mPEARule.Level.Value();
        //显示规则
        _intelData.PeaShowRule = Analyze.mRuleConfig.mPEARule.ShowRule.Value();
        //显示轨迹
        _intelData.PeaShowTrace = Analyze.mRuleConfig.mPEARule.ShowTrace.Value();
        
        //周线警戒开关
        _intelData.PerimeterEnable = Analyze.mRuleConfig.mPEARule.PerimeterEnable.Value();
        //周线警戒方向
        _intelData.DirectionLimit = Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.DirectionLimit.Value();
        //周线警戒点数组
        _intelData.PerimeterArray = [[self getAnalyzePointArray:DrawType_PEA_Area] mutableCopy];
        
        //单线警戒开关
        _intelData.TripWireEnable = Analyze.mRuleConfig.mPEARule.TripWireEnable.Value();
        //单线警戒是否是双向
        if (Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire.Size()>0) {
            _intelData.IsDoubleDir = Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].IsDoubleDir.Value();
        }
        //单线警戒点数组
        _intelData.TripWireArray = [[self getAnalyzePointArray:DrawType_PEA_Line] mutableCopy];
        
        
        //警戒级别
        _intelData.OscLevel = Analyze.mRuleConfig.mOSCRule.Level.Value();
        //显示规则
        _intelData.OscShowRule = Analyze.mRuleConfig.mOSCRule.ShowRule.Value();
        //显示轨迹
        _intelData.OscShowTrace = Analyze.mRuleConfig.mOSCRule.ShowTrace.Value();
        
        //物品滞留开关
        _intelData.AbandumEnable = Analyze.mRuleConfig.mOSCRule.AbandumEnable.Value();
        //物品滞留点数组
        _intelData.AbandumArray = [[self getAnalyzePointArray:DrawType_OSC_Stay] mutableCopy];
        
        //物品盗移开关
        _intelData.StolenEnable = Analyze.mRuleConfig.mOSCRule.StolenEnable.Value();
        //物品盗移点数组
        _intelData.StolenArray = [[self getAnalyzePointArray:DrawType_OSC_Move] mutableCopy];
        
        //场景变换检测
        _intelData.ChangeEnable = Analyze.mRuleConfig.mAVDRule.ChangeEnable.Value();
        //人为干扰检测
        _intelData.InterfereEnable = Analyze.mRuleConfig.mAVDRule.InterfereEnable.Value();
        //画面冻结检测
        _intelData.FreezeEnable = Analyze.mRuleConfig.mAVDRule.FreezeEnable.Value();
        //信号缺失检测
        _intelData.NosignalEnable = Analyze.mRuleConfig.mAVDRule.NosignalEnable.Value();
        
        if ([self.delegate respondsToSelector:@selector(InterInterfaceControlGetResultDelegate:)]) {
            [self.delegate InterInterfaceControlGetResultDelegate:result];
        }
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

- (void)setConfig:(DeviceConfig *)config result:(int)result {
    if (result >= 0) {
        [SVProgressHUD  showSuccessWithStatus:TS("Save_Success")];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

//获取区域警戒点数组
-(NSMutableArray*)getAnalyzePointArray:(DrawType)type
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    switch (type) {
        case DrawType_PEA_Line:
        {
            [self getTripWireData:array];
        }
            break;
        case DrawType_PEA_Area:
        {
            [self getPerimeterData:array];
        }
            break;
        case DrawType_OSC_Move:
        {
            [self getStolenRuleData:array];
        }
            break;
        case DrawType_OSC_Stay:
        {
            [self getAbandumData:array];
        }
            break;
        default:
            break;
    }
    return array;
}
//获取区域警戒数组
-(void)getPerimeterData:(NSMutableArray*)array
{
    for (int i = 0; i< Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.mBoundary.PointNum.Value(); i++) {
        float x = Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.mBoundary.Points[i].x.Value();
        float y = Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.mBoundary.Points[i].y.Value();
        CGPoint point = CGPointMake(x/SCALEWIDEH*SCREEN_WIDTH, y/SCALEWIDEH*SCREEN_WIDTH);
        [array addObject:[NSValue valueWithCGPoint:point]];
    }
}
//获取单线警戒数组
-(void)getTripWireData:(NSMutableArray*)array
{
    if (Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire.Size() >0 ) {
        float xStart = Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mStartPt.x.Value();
        float yStart = Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mStartPt.y.Value();
        CGPoint pStart = CGPointMake(xStart/SCALEWIDEH*SCREEN_WIDTH, yStart/SCALEWIDEH*SCREEN_WIDTH);
        float xEnd = Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mEndPt.x.Value();
        float yEnd = Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mEndPt.y.Value();
        CGPoint pEnd = CGPointMake(xEnd/SCALEWIDEH*SCREEN_WIDTH, yEnd/SCALEWIDEH*SCREEN_WIDTH);
        [array addObject:[NSValue valueWithCGPoint:pStart]];
        [array addObject:[NSValue valueWithCGPoint:pEnd]];
    }
}

//获取物品滞留数组
-(void)getAbandumData:(NSMutableArray*)array
{
    if (Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs.Size() > 0 ) {
        for (int i =0; i< Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs[0].mOscRg.PointNu.Value(); i++) {
            float x = Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs[0].mOscRg.Points[i].x.Value();
            float y = Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs[0].mOscRg.Points[i].y.Value();
            CGPoint point = CGPointMake(x/SCALEWIDEH*SCREEN_WIDTH, y/SCALEWIDEH*SCREEN_WIDTH);
            [array addObject:[NSValue valueWithCGPoint:point]];
        }
    }
}
//获取物品盗移数组
-(void)getStolenRuleData:(NSMutableArray*)array
{
    if (Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs.Size() > 0 ) {
        for (int i =0; i< Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs[0].mOscRg.PointNu.Value(); i++) {
            float x = Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs[0].mOscRg.Points[i].x.Value();
            float y = Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs[0].mOscRg.Points[i].y.Value();
            CGPoint point = CGPointMake(x/SCALEWIDEH*SCREEN_WIDTH, y/SCALEWIDEH*SCREEN_WIDTH);
            [array addObject:[NSValue valueWithCGPoint:point]];
        }
    }
}
#pragma mark - 保存点数组到json文件中
-(void)setAnalyzePointArrayWithType:(DrawType)type
{
    if (type == DrawType_PEA_Line) {
        [self setPEA_LinePointArray];
    }
    if (type == DrawType_PEA_Area) {
        [self setPEA_AreaPointArray];
    }
    if (type == DrawType_OSC_Move) {
        [self setOSC_MovePointArray];
    }
    if (type == DrawType_OSC_Stay) {
        [self setOSC_StayPointArray];
    }
}
//设置单线警戒点坐标数组
-(void)setPEA_LinePointArray
{
    if (Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire.Size() == 0 || _intelData.TripWireArray.count != 2) {
        [self showJson_Parse_F];
        return;
    }
    CGPoint point = [[_intelData.TripWireArray objectAtIndex:0] CGPointValue];
    int xStart = point.x/SCREEN_WIDTH *SCALEWIDEH;
    int yStart = point.y/SCREEN_WIDTH *SCALEWIDEH;
    Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mStartPt.x = xStart;
    Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mStartPt.y = yStart;
    
    CGPoint point1 = [[_intelData.TripWireArray objectAtIndex:1] CGPointValue];
    int xEnd = point1.x/SCREEN_WIDTH *SCALEWIDEH;
    int yEnd = point1.y/SCREEN_WIDTH *SCALEWIDEH;
    Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mEndPt.x = xEnd;
    Analyze.mRuleConfig.mPEARule.mTripWireRule.TripWire[0].mLine.mEndPt.y = yEnd;
}
//设置区域警戒点坐标数组
-(void)setPEA_AreaPointArray
{
    if (_intelData.StolenArray.count < 3) {
        [self showJson_Parse_F];
        return;
    }
    _intelData.PeaPointNu = [_intelData.PerimeterArray count];
    Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.mBoundary.PointNum = _intelData.PeaPointNu;
    for (int i =0; i< _intelData.PerimeterArray.count; i++) {
        CGPoint point = [[_intelData.PerimeterArray objectAtIndex:i] CGPointValue];
        int x = point.x/SCREEN_WIDTH *SCALEWIDEH;
        int y = point.y/SCREEN_WIDTH *SCALEWIDEH;
        Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.mBoundary.Points[i].x = x;
        Analyze.mRuleConfig.mPEARule.mPerimeterRule.mLimitPara.mBoundary.Points[i].y = y;
    }
}
//设置物品盗移点坐标数组
-(void)setOSC_MovePointArray
{
    if (Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs.Size() == 0  || _intelData.StolenArray.count < 4) {
        [self showJson_Parse_F];
        return;
    }
    _intelData.PeaPointNu = [_intelData.StolenArray count];
    Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs[0].mOscRg.PointNu = _intelData.PeaPointNu;
    for (int i =0; i< _intelData.StolenArray.count; i++) {
        CGPoint point = [[_intelData.StolenArray objectAtIndex:i] CGPointValue];
        int x = point.x/SCREEN_WIDTH *SCALEWIDEH;
        int y = point.y/SCREEN_WIDTH *SCALEWIDEH;
        Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs[0].mOscRg.Points[i].x = x;
        Analyze.mRuleConfig.mOSCRule.mStolenRule.SpclRgs[0].mOscRg.Points[i].y = y;
    }
}
//设置物品滞留点坐标数组
-(void)setOSC_StayPointArray
{
    if (Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs.Size() == 0 || _intelData.AbandumArray.count < 4) {
        [self showJson_Parse_F];
        return;
    }
    _intelData.PeaPointNu = [_intelData.AbandumArray count];
    Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs[0].mOscRg.PointNu = _intelData.PeaPointNu;
    for (int i =0; i< _intelData.AbandumArray.count; i++) {
        CGPoint point = [[_intelData.AbandumArray objectAtIndex:i] CGPointValue];
        int x = point.x/SCREEN_WIDTH *SCALEWIDEH;
        int y = point.y/SCREEN_WIDTH *SCALEWIDEH;
        Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs[0].mOscRg.Points[i].x = x;
        Analyze.mRuleConfig.mOSCRule.mAbandumRule.SpclRgs[0].mOscRg.Points[i].y = y;
    }
}

-(void)showJson_Parse_F
{
    [SVProgressHUD showErrorWithStatus:TS("Json_Parse_F")];
}

@end
