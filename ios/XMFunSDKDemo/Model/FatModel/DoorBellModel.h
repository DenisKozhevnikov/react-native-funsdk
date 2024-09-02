//
//  DoorBellModel.h
//  XWorld_General
//
//  Created by SaturdayNight on 12/10/2017.
//  Copyright © 2017 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoorBellModel : NSObject

@property (nonatomic,copy) void (^DoorBellEFunStateChangeSleep)(NSString *devMac,NSInteger time);  // 设备进入休眠状态 后面的是延时时间 刷新状态使用
@property (nonatomic,copy) void (^DoorBellEFunStateChangeWakeUp)(NSString *devMac); // 设备进入唤醒状态
@property (nonatomic,copy) void (^DoorBellLowBatteryTip)(NSString *devMac);         // 设备电量低提示

//设备在线状态刷新回调
@property (nonatomic,copy) void (^DoorBellRequestDeviceStateCallBack)(NSString *devID);

#pragma mark 处理多画面切换 设备睡眠
@property (nonatomic,strong) NSTimer *myTimerChange;
@property (nonatomic,assign) NSInteger countChange;
@property (nonatomic,strong) NSMutableDictionary *dicDevMacSleepChange;
@property (nonatomic,assign) BOOL ifChangeCounting;

#pragma mark  处理快速配置成功后 设备休眠
@property (nonatomic,strong) NSTimer *myTimerConfig;
@property (nonatomic,assign) NSInteger countConfig;
@property (nonatomic,strong) NSMutableDictionary *dicDevConfig;         // 快速配置后等待休眠的设备
@property (nonatomic,assign) BOOL ifConfigCounting;                     // 是否快速配置设备正在休眠倒计时

#pragma mark 处理退出播放 设备睡眠
@property (nonatomic,assign) int msgHandle;
@property (nonatomic,strong) NSTimer *myTimer;
@property (nonatomic,assign) NSInteger curCount;
@property (nonatomic,assign) BOOL ifCounting;
@property (nonatomic,strong) NSMutableDictionary *dicDevMacSleepWait;   // 等待休眠设备序列号
@property (nonatomic,strong) NSMutableDictionary *dicDevMacWorking;     // 正在运行设备序列号 （设备唤醒后，例如设备进入视频预览或者从设备列表直接进入设置界面，标记为正在运行的设备，以防被休眠）
@property (nonatomic,strong) NSMutableDictionary *dicDevMacSleepCountingAdd;    // 正在倒计时 加入的设备

#pragma mark 设备列表点击唤醒 设备休眠
@property (nonatomic,strong) NSTimer *myTimerDeviceListWakeUp;
@property (nonatomic,assign) NSInteger countDeviceListWakeUp;
@property (nonatomic,strong) NSMutableDictionary *dicDevMacSleepDeviceListWakeUp;

#pragma mark 记录不需要提示设备电量低的序列号
@property (nonatomic,strong) NSMutableDictionary *dicNoLongerPromptDevMac;

#pragma mark  记录设备电量
@property (nonatomic,strong) NSMutableDictionary *dicDoorBellBatteryInfo;

#pragma mark  主动上报设备处理
@property (nonatomic,strong) NSMutableDictionary <NSString *,NSString *>*dicUploadingDevice;   // 正在主动上报的设备
@property (nonatomic,copy) void (^DevUploadDataCallBack)(NSDictionary *state,NSString *devMac);          // 主动上报消息回调

@property (nonatomic,copy) NSString *requestBatteryStateDevMac;         // 主动请求电池状态的设备序列号（这里简单处理了，没有考虑多设备的情况）

@property (nonatomic,assign) int reqSeqNum;

+(DoorBellModel *)shareInstance;

#pragma mark - 处理退出播放 设备睡眠
-(void)beginCountDown;
-(void)cancelCountDown;

//MARK:加入休眠计划（直接进入预览或者设置界面时需要调用）
-(void)addDormantPlanDevice:(NSString *)devMac;

-(void)removeSleepDeviceWorking:(NSString *)devMac;
-(void)removeAllWorkingDevice;

#pragma mark - 处理多画面切换 设备睡眠
-(void)beginCountDownChange;
-(void)cancelCountDownChange;
-(void)addSleepDeviceChange:(NSString *)devMac;
-(void)removeAllDeviceChange;

#pragma mark - 处理快速配置成功后 设备休眠
-(void)beginCountDownConfig;
-(void)cancelCountDownConfig;
-(void)addSleepDeviceConfig:(NSString *)devMac;
-(void)removeAllDeviceConfig;

#pragma mark 设备列表点击唤醒 设备休眠
-(void)beginCountDownDeviceListWakeUp;
-(void)cancelCountDownDeviceListWakeUp;
-(void)addSleepDeviceDeviceListWakeUp:(NSString *)devMac;
-(void)removeAllDeviceDeviceListWakeUp;

#pragma mark - 记录设备电量
-(void)updateDeviceBatteryRecord;
-(void)setDevice:(NSString *)devID batteryNum:(int)battery;

#pragma mark - 主动请求电量
-(void)requestBatteryState:(NSString *)devMac needWakeUp:(BOOL)needWakeUp;
#pragma mark 屏蔽电量低提示（下次app启动后恢复）
-(void)addNoLongerPromptDevice:(NSString *)devMac;

#pragma mark - 设备主动上报
-(void)beginUploadData:(NSString *)devMac;
-(void)beginStopUploadData:(NSString *)devMac;
-(void)stopAllDeviceUpload;

#pragma mark - 门铃请求在线状态 （收到报警消息刷新状态后15s内 无操作 需要再次请求状态）
-(void)getOnlineState:(NSString *)devMac;

//门铃设备状态单独回调使用
-(int)requestDeviceStateWithDeviceIds:(NSString *)sIds;
@end
