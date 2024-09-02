//
//  InterInterfaceControl.h
//  XMEye
//
//  Created by XM on 2017/4/22.
//  Copyright © 2017年 Megatron. All rights reserved.
//
#import "CYFunSDKObject.h"
//#import "Detect_Analyze_ConfigType.h"
#import "DrawControl.h"
#import "IntelData.h"

@protocol InterInterfaceControlDelegate <NSObject>
@optional
-(void)InterInterfaceControlGetResultDelegate:(BOOL)result;
-(void)InterInterfaceControlSetResultDelegate;//设置之后需要提示重启
@end

@interface InterInterfaceControl : CYFunSDKObject

@property (nonatomic, strong) NSString *devID;      // 设备id
@property (nonatomic) int channelNum;       // 选中通道号
@property (nonatomic, strong) IntelData *intelData;
@property (nonatomic, assign) id <InterInterfaceControlDelegate> delegate;

@property (nonatomic,assign) int alarmDirection;
@property (nonatomic,assign) int alarmPointNum;

-(void)getAnalyzeData;
-(void)saveAnalyzeConfig;
-(void)setAnalyzePointArrayWithType:(DrawType)type;

@end
