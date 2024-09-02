
//
//  DoorBellModel.m
//  XWorld_General
//
//  Created by SaturdayNight on 12/10/2017.
//  Copyright © 2017 xiongmaitech. All rights reserved.
//                  

#import "DoorBellModel.h"
#import <FunSDK/FunSDK.h>
//#import "AppDelegate.h"

static int const MaxWaitTime = 15;

@interface DoorBellModel ()
{
    
}

@end

@implementation DoorBellModel

+(DoorBellModel *)shareInstance
{
    static DoorBellModel *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[DoorBellModel alloc] init];
        model.dicDevMacSleepWait = [NSMutableDictionary dictionaryWithCapacity:0];
        model.dicDevMacWorking = [NSMutableDictionary dictionaryWithCapacity:0];
        model.dicDevMacSleepCountingAdd = [NSMutableDictionary dictionaryWithCapacity:0];
        model.dicDoorBellBatteryInfo = [NSMutableDictionary dictionaryWithCapacity:0];
        model.dicUploadingDevice = [NSMutableDictionary dictionaryWithCapacity:0];
        model.dicDevConfig = [NSMutableDictionary dictionaryWithCapacity:0];
        model.dicNoLongerPromptDevMac = [NSMutableDictionary dictionaryWithCapacity:0];
        model.dicDevMacSleepDeviceListWakeUp = [NSMutableDictionary dictionaryWithCapacity:0];
        [model updateDeviceBatteryRecord];
        model.msgHandle = FUN_RegWnd((__bridge void *)model);
        model.ifCounting = NO;
    });
    
    return model;
}

#pragma mark 开始倒计时
-(void)beginCountDown
{
    NSLog(@"DoorBellModel 设备休眠开始倒计时1");
    // 清除多画面切换处理数据
    [self cancelCountDownChange];
    [self removeAllDeviceChange];

    // 开始设备睡眠倒计时
    if (self.ifCounting) {
        // 如果上次计时正在进行中 判断是否是同一个设备 不是同一个 直接sleep上次的设备 如果是同一个 重新开始计时
        // 理论上正在等待休眠的设备只有一个 每次只操作一个门铃

        NSLog(@"DoorBellModel 开始倒计时遇到正在倒计时");
        // 是否需要马上休眠
        BOOL ifNeedSleepNow = YES;
        NSArray *allKeysDicSleepWait = self.dicDevMacSleepWait.allKeys;
        if (allKeysDicSleepWait && allKeysDicSleepWait.count > 0) {
            NSString *strMac = allKeysDicSleepWait[0];
            if ([self.dicDevMacSleepCountingAdd objectForKey:strMac]) {
                // 是同一个设备 重新开始倒计时
                ifNeedSleepNow = NO;
            }
        }

        if (ifNeedSleepNow) {
            NSArray *allKeys = [self.dicDevMacSleepWait.allKeys mutableCopy];

//            AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
            for (int i = 0; i < allKeys.count; i ++) {
                FUN_DevLogout(self.msgHandle, [allKeys[i] UTF8String]);

//                [delegate removeSleepDevice:allKeys[i]];

                if (self.DoorBellEFunStateChangeSleep) {
                    self.DoorBellEFunStateChangeSleep(allKeys[i],10);
                }
            }

            [self.dicDevMacSleepWait removeAllObjects];

            self.curCount = 0;
            self.dicDevMacSleepWait = [self.dicDevMacSleepCountingAdd mutableCopy];
            [self.dicDevMacSleepCountingAdd removeAllObjects];
        }
        else
        {
            self.curCount = 0;
        }

        return;
    }

    if (!self.myTimer) {
        self.curCount = 0;
        self.ifCounting = YES;
        // 将等待
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(curCountCalcute) userInfo:nil repeats:YES];

        NSLog(@"DoorBellModel 开始倒计时2");
    }
}

-(void)curCountCalcute
{
    self.curCount ++;
    
    NSLog(@"DoorBellModel %li",self.curCount);
    // 如果超过最大时间 就睡眠设备
    if (self.curCount >= MaxWaitTime) {
        
        NSLog(@"DoorBellModel 设备休眠命令发送");
        [self sendingSleepCmd];
        [self cancelCountDown];
    }
}

#pragma mark 取消倒计时
-(void)cancelCountDown
{
    NSLog(@"DoorBellModel 取消倒计时");
    if (self.myTimer) {
        [self.myTimer invalidate];
        self.myTimer = nil;
        self.ifCounting = NO;
    }
    
    [self.dicDevMacSleepWait removeAllObjects];
}

#pragma mark 发送睡眠命令
-(void)sendingSleepCmd
{
    NSArray *allKeys = self.dicDevMacSleepWait.allKeys;
    for (int i = 0; i < allKeys.count; i ++) {
//        AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
        // 没有工作中的设备才可以发送休眠
        if (![self.dicDevMacWorking.allKeys containsObject:allKeys[i]]) {
            FUN_DevLogout(self.msgHandle, [allKeys[i] UTF8String]);
//            [delegate removeSleepDevice:allKeys[i]];
            // 回调到对应地方进行处理
            if (self.DoorBellEFunStateChangeSleep) {
                self.DoorBellEFunStateChangeSleep(allKeys[i],10);
            }
        }
    }

    [self.dicDevMacSleepWait removeAllObjects];
}

//MARK:加入休眠计划（直接进入预览或者设置界面时需要调用）
-(void)addDormantPlanDevice:(NSString *)devMac
{
    NSLog(@"DoorBellModel 将设备加入休眠计划");
    //在AppDelegate中保存了一份所有之后需要休眠的设备 所以在这里添加休眠计划设备时，要统一加上
//    AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
//    if (delegate.arrayNeedSleepDevice) {
//        tempArray = [delegate.arrayNeedSleepDevice mutableCopy];
//    }

    BOOL ifExist = NO;
    for (NSString *mac in tempArray) {
        if ([mac isEqualToString:devMac]) {
            ifExist = YES;
            break;
        }
    }

    if (!ifExist) {
        [tempArray addObject:devMac];
    }

//    delegate.arrayNeedSleepDevice = [tempArray mutableCopy];

    //添加休眠计划的设备 如果正在快速配置休眠倒计时中 去除该设备
    [self.dicDevConfig removeObjectForKey:devMac];

    if (self.ifCounting) { // 如果加入休眠计划的设备正在倒计时休眠中 那么取消倒计时 因为同一时间只会有一个设备在休眠倒计时中（低功耗设备只有单个窗口）
        if (self.dicDevMacSleepCountingAdd.allKeys.count > 0 && [[self.dicDevMacSleepCountingAdd objectForKey:self.dicDevMacSleepCountingAdd.allKeys.firstObject] isEqualToString:devMac]) {
            [self.dicDevMacSleepCountingAdd removeObjectForKey:devMac];
            [self cancelCountDown];

            NSLog(@"DoorBellModel 添加休眠设备1");
        }
        else
        {
            [self.dicDevMacSleepCountingAdd setObject:devMac forKey:devMac];

            if ([self.dicDevMacSleepWait objectForKey:devMac]) {

                NSLog(@"DoorBellModel 添加休眠设备 取消");
                [self cancelCountDown];
            }
        }

        [self.dicDevMacSleepWait setObject:devMac forKey:devMac];
        [self.dicDevMacWorking setObject:devMac forKey:devMac];
    }
    else
    {
        [self.dicDevMacSleepWait setObject:devMac forKey:devMac];
        [self.dicDevMacWorking setObject:devMac forKey:devMac];

        NSLog(@"DoorBellModel 添加休眠设备3");
    }
}

#pragma mark 移除正在运行的设备
-(void)removeSleepDeviceWorking:(NSString *)devMac
{
    if (devMac.length > 10) {
        [self.dicDevMacWorking removeObjectForKey:devMac];
    }
}

#pragma mark 移除所有正在运行的设备
-(void)removeAllWorkingDevice
{
    [self.dicDevMacWorking removeAllObjects];
}

#pragma mark - 切换屏幕设备睡眠处理
-(void)beginCountDownChange
{
    if (self.ifChangeCounting) {
        self.countChange = 0;
    }
    else
    {
        if (!self.myTimerChange) {
            self.countChange = 0;
            self.ifChangeCounting = YES;
            // 将等待
            self.myTimerChange = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitTimeCount) userInfo:nil repeats:YES];
        }
    }
}

-(void)waitTimeCount
{
//    self.countChange ++;
//
//    // 如果超过最大时间 就睡眠设备
//    if (self.countChange >= MaxWaitTime) {
//        NSArray *allKeys = [self.dicDevMacSleepWait.allKeys mutableCopy];
//
//        AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
//        for (int i = 0; i < allKeys.count; i ++) {
//            FUN_DevLogout(self.msgHandle, [allKeys[i] UTF8String]);
//
//            [delegate removeSleepDevice:allKeys[i]];
//        }
//
//        [self.dicDevMacSleepChange removeAllObjects];
//
//        [self cancelCountDownChange];
//    }
}

-(void)cancelCountDownChange
{
    if (self.myTimerChange) {
        [self.myTimerChange invalidate];
        self.myTimerChange = nil;
        self.ifChangeCounting = NO;
    }
}

-(void)addSleepDeviceChange:(NSString *)devMac
{
    [self.dicDevMacSleepChange setObject:devMac forKey:devMac];
}

-(void)removeAllDeviceChange
{
    [self.dicDevMacSleepChange removeAllObjects];
}

#pragma mark - 处理快速配置成功后 设备休眠
-(void)beginCountDownConfig
{
    if (self.ifChangeCounting) {
        self.countConfig = 0;
    }
    else
    {
        if (!self.myTimerConfig) {
            self.countConfig = 0;
            self.ifConfigCounting = YES;
            // 将等待
            self.myTimerConfig = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(configWaitTimeCount) userInfo:nil repeats:YES];
        }
    }
}

-(void)configWaitTimeCount
{
//    self.countConfig ++;
//
//    // 如果超过最大时间 就睡眠设备
//    if (self.countConfig >= MaxWaitTime) {
//        NSArray *allKeys = [self.dicDevConfig.allKeys mutableCopy];
//
//        AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
//        for (int i = 0; i < allKeys.count; i ++) {
//            FUN_DevLogout(self.msgHandle, [allKeys[i] UTF8String]);
//            [delegate removeSleepDevice:allKeys[i]];
//        }
//
//        [self.dicDevConfig removeAllObjects];
//
//        [self cancelCountDownConfig];
//    }
}

-(void)cancelCountDownConfig
{
    if (self.myTimerConfig) {
        [self.myTimerConfig invalidate];
        self.myTimerConfig = nil;
        self.ifConfigCounting = NO;
    }
}

-(void)addSleepDeviceConfig:(NSString *)devMac
{
    [self.dicDevConfig setObject:devMac forKey:devMac];
}

-(void)removeAllDeviceConfig
{
    [self.dicDevConfig removeAllObjects];
}

#pragma mark 设备列表点击唤醒 设备休眠
-(void)beginCountDownDeviceListWakeUp
{
    if (self.myTimerDeviceListWakeUp) {  // 如果正在休眠倒计时
        
    }
    else
    {
        // 开启计时器
        if (!self.myTimerDeviceListWakeUp) {
            self.countDeviceListWakeUp = 0;
            
            self.myTimerDeviceListWakeUp = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitTimeCountDeviceListWakeUp) userInfo:nil repeats:YES];
        }
    }
}

-(void)waitTimeCountDeviceListWakeUp
{
    // 取出所有设备 判断是否到达指定时间
    NSArray *keys = self.dicDevMacSleepDeviceListWakeUp.allKeys;

    BOOL ifTimerNeedCancel = YES;   // 计时器是否需要取消

//    AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);

    for (int i = 0; i < keys.count; i ++) {
        NSMutableDictionary *dicChange = [[self.dicDevMacSleepDeviceListWakeUp objectForKey:keys[i]] mutableCopy];

        if (dicChange) {
            NSInteger count = [[dicChange objectForKey:@"COUNT"] integerValue];
            // 如果超过最长时间 那么就发送休眠命令
            if ([self.dicDevMacWorking.allKeys containsObject:keys[i]]) { // 如果设备正在工作 取消列表的倒计时
                [dicChange setObject:[NSNumber numberWithInteger:(MaxWaitTime + 1)] forKey:keys[i]];
                [self.dicDevMacSleepDeviceListWakeUp setObject:dicChange forKey:keys[i]];
            }
            else if (count + 1 == MaxWaitTime) {
                FUN_DevLogout(self.msgHandle, [keys[i] UTF8String]);


//                [delegate removeSleepDevice:keys[i]];

                [dicChange setObject:[NSNumber numberWithInteger:(count + 1)] forKey:@"COUNT"];
                [self.dicDevMacSleepDeviceListWakeUp setObject:dicChange forKey:keys[i]];

                if (self.DoorBellEFunStateChangeSleep) {
                    self.DoorBellEFunStateChangeSleep(keys[i],10);
                }
            }
            else if (count + 1 > MaxWaitTime)
            {

            }
            else if (count + 1 < MaxWaitTime)
            {
                ifTimerNeedCancel = NO;

                [dicChange setObject:[NSNumber numberWithInteger:(count + 1)] forKey:@"COUNT"];
                [self.dicDevMacSleepDeviceListWakeUp setObject:dicChange forKey:keys[i]];
            }
        }
    }

    if (ifTimerNeedCancel) {
        [self cancelCountDownDeviceListWakeUp];
    }
}

-(void)cancelCountDownDeviceListWakeUp
{
    if (self.myTimerDeviceListWakeUp) {
        [self.myTimerDeviceListWakeUp invalidate];
        self.myTimerDeviceListWakeUp = nil;
        [self removeAllDeviceDeviceListWakeUp];
    }
}

-(void)addSleepDeviceDeviceListWakeUp:(NSString *)devMac
{
    NSDictionary *dicAdd = @{@"COUNT":@0,@"SN":devMac};
    
    [self.dicDevMacSleepDeviceListWakeUp setObject:dicAdd forKey:devMac];
}

-(void)removeAllDeviceDeviceListWakeUp
{
    [self.dicDevMacSleepDeviceListWakeUp removeAllObjects];
}

#pragma mark - 记录设备电量
-(void)updateDeviceBatteryRecord
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingString:@"/DoorBellBatteryInfo.plist"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!dic) {
        self.dicDoorBellBatteryInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    else
    {
        self.dicDoorBellBatteryInfo = [dic mutableCopy];
    }
}

-(void)setDevice:(NSString *)devID batteryNum:(int)battery
{
    [self.dicDoorBellBatteryInfo setObject:[NSNumber numberWithInt:battery] forKey:devID];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingString:@"/DoorBellBatteryInfo.plist"];
    
    [self.dicDoorBellBatteryInfo writeToFile:path atomically:YES];
}

static const int kGetBatterySeqOnce = 209;          // 单次获取电量标识

#pragma mark - 主动请求电量
-(void)requestBatteryState:(NSString *)devMac needWakeUp:(BOOL)needWakeUp
{
    self.requestBatteryStateDevMac = devMac;
    
    // FUN_DevGetConfig_Json(self.msgHandle, [devMac UTF8String], "Dev.ElectCapacity", 1024,-1,5000,0);
    // 通过主动上报的方式去获取电量状态 直接获取会不准确
    // 
    if (needWakeUp) {
        FUN_DevWakeUp(self.msgHandle, [devMac UTF8String], 0);
        return;
    }
    
    FUN_DevStartUploadData(self.msgHandle, [devMac UTF8String], 5, kGetBatterySeqOnce);
}

#pragma mark 屏蔽电量低提示（下次app启动后恢复）
-(void)addNoLongerPromptDevice:(NSString *)devMac
{
    [self.dicNoLongerPromptDevMac setObject:devMac forKey:devMac];
}

#pragma mark - 设备准备主动上报
-(void)beginUploadData:(NSString *)devMac
{
    // 判断设备是否已经在主动上报
    NSArray *arrayKeys = self.dicUploadingDevice.allKeys;
    NSString *usedDevMacs = @"";            // 正在上报的设备序列号
    for (int i = 0; i < arrayKeys.count; i ++) {
        NSString *strKeyNum = arrayKeys[i];
        NSString *strValueDevMac = [self.dicUploadingDevice objectForKey:strKeyNum];
        
        usedDevMacs = [usedDevMacs stringByAppendingPathComponent:strValueDevMac];
    }
    
    // 如果设备已经在主动上报了 就不需要再次请求
    if ([usedDevMacs containsString:devMac]) {
        return;
    }
    
    // 判断是否是主动请求上报设备 如果是 删除之前的主动请求
    if ([devMac isEqualToString:self.requestBatteryStateDevMac]) {
        self.requestBatteryStateDevMac = @"";
    }
    
    // 如果没有在主动上报 就开始上报 同时添加序列号到正在上报字典中
    [self.dicUploadingDevice setObject:devMac forKey:devMac];
    
    FUN_DevStartUploadData(self.msgHandle, [devMac UTF8String], 5, 0);
}

-(void)beginStopUploadData:(NSString *)devMac
{
    // 准备停止设备的主动上报 并从正在上报字典中移除
    // 判断设备是否已经在主动上报
    if (self.dicUploadingDevice) {
        [self.dicUploadingDevice removeObjectForKey:devMac];
    }
            
    FUN_DevStopUploadData(self.msgHandle, [devMac UTF8String], 5, 0);
}

-(void)stopAllDeviceUpload
{
    NSArray *arrayKeys = self.dicUploadingDevice.allKeys;
    for (int i = 0; i < arrayKeys.count; i ++) {
        NSString *strKey = arrayKeys[i];
        
        FUN_DevStopUploadData(self.msgHandle, [strKey UTF8String], 5, 0);
    }
    
    [self.dicUploadingDevice removeAllObjects];
}

-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (strcmp("Dev.ElectCapacity", msg->szStr) == 0)
            {
                if (msg->param1 >= 0) {
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    
                    NSError *error;
                    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                    if (!retDic) {
                        return;
                    }
                    
                        NSDictionary *dicE = [retDic objectForKey:@"Dev.ElectCapacity"];
                        // 电池电量
                        int percentage = [[dicE objectForKey:@"percent"] intValue];
                        /* 具体百分比规则：
                    switch (percentage) {
                        case 0:
                            result = 0;
                            break;
                        case 1:
                            result = 0.1;
                            break;
                        case 2:
                            result = 0.2;
                            break;
                        case 3:
                            result = 0.4;
                            break;
                        case 4:
                            result = 0.6;
                            break;
                        case 5:
                            result = 0.8;
                            break;
                        case 6:
                            result = 1;
                            break;
                        case 7:
                            result = 1;
                            break;
                        default:
                            break;
                    }
                         result表示百分比*/
                    
                        [[DoorBellModel shareInstance] setDevice:self.requestBatteryStateDevMac batteryNum:percentage];
                        [[DoorBellModel shareInstance] updateDeviceBatteryRecord];
                    
                        // 电量低提示
                    if (percentage != 99 && percentage <= 2 && [[dicE objectForKey:@"electable"] intValue] != 1) {
                        if (self.DoorBellLowBatteryTip) {
                            // 判断是否屏蔽提示
                            if (![self.dicNoLongerPromptDevMac objectForKey:self.requestBatteryStateDevMac]) {
                                self.DoorBellLowBatteryTip(self.requestBatteryStateDevMac);
                            }   
                        }
                    }
                }
                else
                {
                    
                }
            }
        }
            break;
            case EMSG_DEV_WAKE_UP:
        {
            if (msg->param1 < 0)
            {
                
            }
            else
            {
                [self requestBatteryState:self.requestBatteryStateDevMac needWakeUp:NO];
            }
        }
            break;
        case EMSG_DEV_START_UPLOAD_DATA:
        {
            
        }
            break;
            case EMSG_DEV_ON_UPLOAD_DATA:
        {
            if (msg->param1 > 0) {
                NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                
                NSError *error;
                 NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                if (!retDic) {
                    return;
                }
                
                NSDictionary *dicState = [retDic objectForKey:@"Dev.ElectCapacity"];
                
//                    DevStorageStatus 表示存储状态： -2：设备存储未知 -1：存储设备被拔出 0：没有存储设备 1：有存储设备 2：存储设备插入
//                    electable 表示充电状态：0：未充电 1：正在充电 2：电充满 3：未知（表示各数据不准确）
//                    freecapacity = 0;
//                    percent = "-1";

                if ([[NSString stringWithUTF8String:msg->szStr] isEqualToString:self.requestBatteryStateDevMac]) {
                    if ([[dicState objectForKey:@"electable"] intValue] != 3) {
                        int percentage = [[dicState objectForKey:@"percent"] intValue];
                        
                        if (percentage <= 2 && [[dicState objectForKey:@"electable"] intValue] != 1) {
                            if (self.DoorBellLowBatteryTip) {
                                // 判断是否屏蔽提示
                                if (![self.dicNoLongerPromptDevMac objectForKey:self.requestBatteryStateDevMac]) {
                                    self.DoorBellLowBatteryTip(self.requestBatteryStateDevMac);
                                }
                                
                            }
                        }
                        
                        [[DoorBellModel shareInstance] setDevice:self.requestBatteryStateDevMac batteryNum:percentage];
                        [[DoorBellModel shareInstance] updateDeviceBatteryRecord];
                        
                        FUN_DevStopUploadData(self.msgHandle, [self.requestBatteryStateDevMac UTF8String], 5, 0);
                    }
                    
                }
                else
                {
                if (self.DevUploadDataCallBack) {
                    NSString *strMac = [NSString stringWithUTF8String:(msg->szStr)];
                    if (strMac) {
                        self.DevUploadDataCallBack(dicState,strMac);
                    }
                }
                }
            }
            else{
                NSLog(@"");
            }
        }
            break;
        case EMSG_SYS_GET_DEV_STATE:{
            DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:NSSTR(msg->szStr)];
            if (devObject) {
                devObject.state = msg->param1;
                if (devObject.state <= 0) {
                    NSLog(@"devMac:%@ devState:%d",devObject.deviceMac,devObject.state);
                }
                //设备状态在线的话，去获取下设备系统信息，鱼眼灯泡的亮度，鱼眼支持切换的模式/灯泡亮度调节能力
                if(msg->param1 > 0 ){
                    // 如果是门铃，不做任何处理，要保持休眠状态。
                    // 智能门锁也有深度休眠状态
                    if ([devObject getDeviceTypeLowPowerConsumption]) {
                        devObject.eFunDevStateNotCode = FUN_GetDevState(CSTR(devObject.deviceMac), EFunDevStateType_IDR);
                    }
            }
                
                if (self.DoorBellRequestDeviceStateCallBack) {
                    self.DoorBellRequestDeviceStateCallBack(devObject.deviceMac);
                }
            
            }
        }
            break;
            default:
            break;
    }
}

#pragma mark - 门铃请求在线状态 （收到报警消息刷新状态后15s内 无操作 需要再次请求状态）
-(void)getOnlineState:(NSString *)devMac
{
//    if (![self.dicDevMacWorking objectForKey:devMac]) {
//        [[AccountModel sharedAccountModel] requestDeviceStateWithDeviceIds:devMac];
//    }
}

//门铃设备状态单独回调使用
#pragma mark 获取设备状态
-(int)requestDeviceStateWithDeviceIds:(NSString *)sIds {
    if ([sIds length] >0) {
        FUN_SysGetDevState(self.msgHandle, CSTR(sIds), self.reqSeqNum++);
    }
    
    return 0;
}

@end

