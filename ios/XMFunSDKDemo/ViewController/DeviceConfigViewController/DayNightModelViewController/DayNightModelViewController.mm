//
//  DayNightModelViewController.m
//  XMEye Pro
//
//  Created by 杨翔 on 2021/1/21.
//  Copyright © 2021 Megatron. All rights reserved.
//

#import "DayNightModelViewController.h"
#import <FunSDK/FunSDK.h>
#import "DeviceObject.h"
#import <Masonry/Masonry.h>
#import "TransferModel.h"
#import "SystemInfoManager.h"

@interface DayNightModelViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) int msgHandle;

@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) NSMutableDictionary *cameraParamDic;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) TransferModel *tranModel;                 //ip地址的表达方式转换
@property (nonatomic, strong) SystemInfoManager *systemInfoManager;

@property (nonatomic, copy) NSString * currentDayNightName;

//通用双光灯能力
@property (nonatomic,assign) BOOL iSupportChannelCameraAbility;

@end

@implementation DayNightModelViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}

- (void)dealloc{
    if (self.msgHandle > 0) {
        FUN_UnRegWnd(self.msgHandle);
        self.msgHandle = -1;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgHandle = FUN_RegWnd((__bridge void*)self);
    self.navigationItem.title = TS("setting");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
//    self.navigationItem.title = TS("TR_DayNightMode");
//    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//    [btnLeft setBackgroundColor:[UIColor clearColor]];
//    [btnLeft setBackgroundImage:[[UIImage imageNamed:@"back_2019"] imageWithRenderingMode:UIImageRenderingModeAutomatic] forState:UIControlStateNormal];
//    [btnLeft addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
//    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.cameraParamDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:self.devID];
    
    // 设备配置获取、设置
    if (devObject.channelArray.count > 1 &&
        devObject.deviceType != DEVICE_TYPE_DVR) {
        devObject.deviceType = DEVICE_TYPE_DVR; // 普通DVR设备
    }else if(devObject.channelArray.count == 1 &&
             devObject.deviceType != DEVICE_TYPE_IPC){
        devObject.deviceType = DEVICE_TYPE_IPC; // IPC设备
    }
    
    [self getWhiteLightConfig];
    
    if (devObject.deviceType == DEVICE_TYPE_IPC) {
        [self getDataSource];
        FUN_DevGetConfig_Json(self.msgHandle, SZSTR(self.devID), "Camera.Param", 0, self.channelNum);
    }else{
        self.iSupportChannelCameraAbility = NO;
        [self getChannelCameraAbility];
    }
}
#pragma mark -- 获取一下灯光配置
-(void)getWhiteLightConfig{
    DeviceObject *deviceObject = [[DeviceControl getInstance] GetDeviceObjectBySN:self.devID];
    
    if (deviceObject.channelArray.count>1){
        FUN_DevCmdGeneral(self.msgHandle, [deviceObject.deviceMac UTF8String], 1362, "ChannelSystemFunction", 4096, 5000,NULL,0,-1,0);
        
        /**
         带有模拟通道的DVR不用请求透传。。
         不请求不代表没有而是模拟通道没有调试过这些透传相关功能，所以暂时直接屏蔽
         大概逻辑是透传的通道传的通道号是数字通道的。
         eg:DVR一共8个通道  4个模拟通道，4个数字通道，
         bypass@SystemFunction.[0]代表的是数字通道的第一个通达也就是通达5的能力级
         */
        __weak typeof(self) weakSelf = self;
        [self.systemInfoManager getSystemInfo:deviceObject.deviceMac Completion:^(int result) {
            if (result >= 0) {
                if (![self.systemInfoManager videoInChannel]) {
                    [weakSelf getByPassSystemFunction:deviceObject];
                }
            }
        }];
        
    }else{
        FUN_DevGetConfig_Json(self.msgHandle, [deviceObject.deviceMac UTF8String], "SystemFunction",0,-1,5000,0);
        FUN_DevCmdGeneral(self.msgHandle, [deviceObject.deviceMac UTF8String], 1360, "Camera", 0, 5000, NULL, 0, -1, 0);
    }
}

-(void)getByPassSystemFunction:(DeviceObject *)deviceObject{
    for (int i = 0; i<deviceObject.channelArray.count; i++) {
        ChannelObject *channel = [deviceObject.channelArray objectAtIndex:i];
        int seq = 200 + channel.channelNumber;
        NSString *cfgName = [NSString stringWithFormat:@"bypass@SystemFunction.[%i]",channel.channelNumber];
        FUN_DevCmdGeneral(self.msgHandle, [deviceObject.deviceMac UTF8String], 1362, cfgName.UTF8String, 4096, 20000, NULL, 0, -1, seq);
    }
}

-(void)getChannelCameraAbility{
    char szTime[128] = {0};
    sprintf(szTime, "{\"Name\":\"ChannelCameraAbility.[%d]\",\"SessionID\":\"0x00000004\"}", (int)self.channelNum);
    
    FUN_DevGetConfigJson(self.msgHandle, SZSTR(self.devID), "ChannelCameraAbility", self.channelNum,1362, 0, szTime, 0, 5000);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

-(void)getDataSource{
    self.dataSourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:self.devID];
    ChannelObject *channelObject;
    for (ChannelObject *chObject in devObject.channelArray) {
        if (chObject.channelNumber == self.channelNum) {
            channelObject = chObject;
            break;
        }
    }
    
    if (devObject.deviceType == DEVICE_TYPE_IPC) {
        self.dataSourceArray = [@[@"TR_StarLightInfrared",@"TR_Full_Color",@"TR_Black_and_White"] mutableCopy]; //IPC默认有
        if (channelObject.iSupportIntellDoubleLight == 1){
            [self.dataSourceArray addObject:@"TR_Smart_Alarm"];
        }

        if (channelObject.iSupportSoftPhotosensitive == 1){
            [self.dataSourceArray addObject:@"Full_Color_Vision"];
            [self.dataSourceArray addObject:@"General_Night_Vision"];
        }
    }else{
        if (channelObject.iSupportDoubleLightBulb != 1 && self.iSupportChannelCameraAbility != YES && channelObject.iSSupportSoftPhotoSensitiveMask != 1) {
            self.dataSourceArray = [@[@"TR_StarLightInfrared",@"TR_Full_Color",@"TR_Black_and_White"] mutableCopy];
        }else if(channelObject.iSupportDoubleLightBulb != 1 && self.iSupportChannelCameraAbility != YES){
            self.dataSourceArray = [@[@"TR_StarLightInfrared",@"TR_Full_Color",@"TR_Black_and_White",@"Full_Color_Vision",@"General_Night_Vision"] mutableCopy];
        }else if(channelObject.iSSupportSoftPhotoSensitiveMask != 1){
            self.dataSourceArray = [@[@"TR_StarLightInfrared",@"TR_Full_Color",@"TR_Black_and_White",@"TR_Smart_Alarm"] mutableCopy];
        }else{
            self.dataSourceArray = [@[@"TR_StarLightInfrared",@"TR_Full_Color",@"TR_Black_and_White",@"TR_Smart_Alarm",@"Full_Color_Vision",@"General_Night_Vision"] mutableCopy];
        }
    }
    
    [self.tableView reloadData];
}

//MARK: - FUNSDK
#pragma mark - 回调
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:{
            if (msg->param1 <0) {
                if (msg->param1 == -400009 ||msg->param1 == -11406){
                    if ([[NSString stringWithFormat:@"%s",msg->szStr]isEqual:@"ChannelCameraAbility"]){
                        self.iSupportChannelCameraAbility = NO;
                        [self getDataSource];
                        FUN_DevGetConfig_Json(self.msgHandle, SZSTR(self.devID), "Camera.Param", 0, self.channelNum);
                        return;
                    }
                }
                
                [SVProgressHUD showErrorWithStatus:TS("Error") duration:1.5];
                [self backAction];
            }else if (strcmp(msg->szStr, "SystemFunction") == 0){
                if (msg->pObject == NULL) {
                    [SVProgressHUD dismissWithError:TS("Get_cfg_failed") afterDelay:1.0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self backAction];
                    });
                    return;
                }
                NSDictionary *appData = nil;
                NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data != nil ){
                    appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                }

                NSError *error;
                NSMutableDictionary *infoDic = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if (infoDic == nil) {
                    return;
                }
                NSDictionary *systemFunctionDic = [infoDic objectForKey:@"SystemFunction"];
                if (systemFunctionDic == nil) {
                    return;
                }
                DeviceObject *deviceObject = [[DeviceControl getInstance] GetDeviceObjectBySN:self.devID];
                if (deviceObject.deviceType != DEVICE_TYPE_IPC) {
//    #pragma mark -- 获取是否支持NVR通道是否支持人形检测
//                    NSDictionary *alarmDic = [systemFunctionDic objectForKey:@"AlarmFunction"];
//                    if (alarmDic == nil) {
//                        return;
//                    }
//
//                    int humanDectionNVRNew = [[alarmDic objectForKey:@"HumanDectionNVRNew"] intValue];
//                    if(humanDectionNVRNew == 1){
//                        FUN_DevGetConfig_Json(SELF, [self.devID UTF8String], "NetUse.DigitalHumanAbility", 0, self.channelNum, 5000,0);
//                    }else{
//                        [SVProgressHUD dismiss];
//                    }
                }else{
                    ChannelObject *channelObject = [deviceObject.channelArray firstObject];
                    channelObject.iSupportSoftPhotosensitive = [systemFunctionDic[@"OtherFunction"][@"SupportSoftPhotosensitive"] boolValue]?1:0;
                    [SVProgressHUD dismiss];
//                    FUN_DevCmdGeneral(SELF, [self.devID UTF8String], 1360, "Camera", 0, 5000, NULL, 0, -1, 0);
                }
            }else {
                if (msg->pObject == NULL) {
                    [SVProgressHUD dismissWithError:TS("Get_cfg_failed")];
                    return;
                }
                
                NSString *originalString = NSSTR(msg->pObject);
                NSMutableString *mstring = [NSMutableString stringWithString:originalString];
                NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
                NSRange range = [originalString rangeOfCharacterFromSet:controlChars];
                while (range.location != NSNotFound){ // 包含
                    [mstring deleteCharactersInRange:range]; // 删除
                    range = [mstring rangeOfCharacterFromSet:controlChars]; // 遍历
                }
                NSData *data = [[[NSString alloc] initWithUTF8String:mstring.UTF8String] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data == nil ){
                    [SVProgressHUD dismissWithError:TS("Get_cfg_failed")];
                    return;
                }
                NSError *error;
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if ( appData == nil || [appData isKindOfClass:[NSNull class]]) {
                    [SVProgressHUD dismissWithError:TS("Get_cfg_failed")];
                    return;
                }
                NSString* strConfigName = appData[@"Name"];
                if ([strConfigName containsString:@"Camera.Param"]){
                    [SVProgressHUD dismiss];
                    self.cameraParamDic = [appData mutableCopy];
                    if ([[appData objectForKey:strConfigName] isKindOfClass:[NSNull class]]) {
                        [SVProgressHUD showErrorWithStatus:TS("Get_cfg_failed") duration:1.5];
                        [self backAction];
                        return;
                    }
                    NSString *dayNightString = [NSString stringWithFormat:@"%@",[[appData objectForKey:strConfigName] objectForKey:@"DayNightColor"]];
                    int dayNightValue = [[dayNightString substringFromIndex:dayNightString.length-1] intValue];
                    self.currentDayNightName = [self getDayNightNameWithModel:dayNightValue];
                    [self.tableView reloadData];
                }else if ([strConfigName containsString:@"ChannelCameraAbility"]){
                    NSDictionary *dic = [appData objectForKey:strConfigName];
                    if ([dic isKindOfClass:[NSNull class]]) {
                        self.iSupportChannelCameraAbility = NO;
                    }else{
                        if ([[dic allKeys] containsObject:@"SupportIntellDoubleLight"]) {
                            self.iSupportChannelCameraAbility = [[dic objectForKey:@"SupportIntellDoubleLight"] boolValue];
                        }
                    }

                    
                    [self getDataSource];
                    FUN_DevGetConfig_Json(self.msgHandle, SZSTR(self.devID), "Camera.Param", 0, self.channelNum);
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            if (msg->param1 < 0) {
                [SVProgressHUD dismissWithError:TS("Save_Failed")];
            }else {
                if (strcmp(msg->szStr, "Camera.Param") == 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success") duration:1.0];
                    [self backAction];
                }
            }
        }
            break;
        case EMSG_DEV_CMD_EN:{
            [self funsdkSetWhiteLightConfig:msg];
        }
            break;
        default:
            break;
    }
}
#pragma mark -- 灯光配置下发
-(void)funsdkSetWhiteLightConfig:(MsgContent *)msg{
    //编码配置
    NSString *paramName = msg->szStr?[NSString stringWithUTF8String:msg->szStr]:nil;
    if (msg->param1 < 0) {
        //透传不需要隐藏。。会把其他提示语隐藏掉
        if (![paramName containsString:@"bypass@SystemFunction"]) {
            [SVProgressHUD dismiss];
        }
        
        if (![paramName isEqualToString:@"ChannelSystemFunction"] &&
            ![paramName isEqualToString:@"Camera"] &&
            ![paramName containsString:@"bypass@SystemFunction"]) {
            [SVProgressHUD showErrorWithStatus:TS("Error") duration:1.5];
        }
        return;
    }else{
        if ([paramName isEqualToString:@"ChannelSystemFunction"]){
            NSString *pObject = msg->pObject?[NSString stringWithUTF8String:msg->pObject]:nil;
            NSData *data = [pObject dataUsingEncoding:NSUTF8StringEncoding];
            if ( data == nil ){
                return;
            }
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ( appData == nil){
                return;
            }
            NSString* strConfigName = [appData valueForKey:@"Name"];
            NSDictionary* systemParams = [appData valueForKey:strConfigName];
            if (systemParams == nil || [systemParams isKindOfClass:[NSNull class]]) {
                return;
            }
            
            DeviceObject *deviceObject = [[DeviceControl getInstance] GetDeviceObjectBySN:self.devID];
            
            for (int i = 0; i<deviceObject.channelArray.count; i++)
            {
                ChannelObject *channelObject = [deviceObject.channelArray objectAtIndex:i];
                // 内部已作保护处理
                if ([(NSArray *)(systemParams[@"SupportCameraWhiteLight"]) count]>0)
                {
                    channelObject.iSupportCameraWhiteLight = [[systemParams[@"SupportCameraWhiteLight"] objectAtIndex:i] boolValue] ? 1: 0;
//                            channelObject.iSupportCameraWhiteLight = [systemParams[@"SupportCameraWhiteLight"][i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportSoftPhotosensitive"]) count]>0)
                {
                    channelObject.iSupportSoftPhotosensitive = [[systemParams[@"SupportSoftPhotosensitive"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportDoubleLightBulb"]) count]>0)
                {
                    channelObject.iSupportDoubleLightBulb = [[systemParams[@"SupportDoubleLightBulb"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportMusicLightBulb"]) count]>0)
                {
                    channelObject.iSupportMusicLightBulb = [[systemParams[@"SupportMusicLightBulb"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportDoubleLightBoxCamera"]) count]>0)
                {
                    channelObject.iSupportDoubleLightBoxCamera = [[systemParams[@"SupportDoubleLightBoxCamera"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportSetDetectTrackWatchPoint"]) count]>0)
                {
                    channelObject.iSupportSetDetectTrackWatchPoint = [[systemParams[@"SupportSetDetectTrackWatchPoint"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportDetectTrack"]) count]>0)
                {
                    channelObject.iSupportDetectTrack = [[systemParams[@"SupportDetectTrack"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportBoxCameraBulb"]) count]>0)
                {
                    channelObject.iSupportBoxCameraBulb = [[systemParams[@"SupportBoxCameraBulb"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"PEAInHumanPed"]) count]>0)
                {
                    channelObject.iPEAInHumanPed = [[systemParams[@"PEAInHumanPed"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportAlarmVoiceTipsType"]) count]>0)
                {
                    channelObject.isupportAlarmVoiceTipsType = [[systemParams[@"SupportAlarmVoiceTipsType"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SupportPeaInHumanPed"]) count]>0)
                {
                    channelObject.HumanDectionDVR = [[systemParams[@"SupportPeaInHumanPed"] objectAtIndex:i] boolValue]?1:0;
                }
                if ([(NSArray *)(systemParams[@"SoftPhotoSensitiveMask"]) count]>0)
                {
                    channelObject.iSSupportSoftPhotoSensitiveMask = [[systemParams[@"SoftPhotoSensitiveMask"] objectAtIndex:i] boolValue]?1:0;
                }
                
                if ([(NSArray *)(systemParams[@"LowPowerCameraSupportPir"]) count]>0) {
                    channelObject.lowPowerCameraSupportPir = [[systemParams[@"LowPowerCameraSupportPir"] objectAtIndex:i] boolValue];
                }
            }
            //刷新一下
            [self getDataSource];
        }else if ([paramName containsString:@"bypass@SystemFunction"]){
            if (msg->pObject == NULL) {
                return;
            }
            NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
            
            if ( data == nil ){
                return;
            }
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ( appData == nil){
                return;
            }
            NSString* strConfigName = [appData valueForKey:@"Name"];
            NSDictionary* systemParams = appData[strConfigName];
            
            if (systemParams == nil|| [systemParams isKindOfClass:[NSNull class]]) return;
            
            
            DeviceObject *deviceObject = [[DeviceControl getInstance] GetDeviceObjectBySN:self.devID];
            
            int index = msg->seq - 200;
            if (index >= deviceObject.channelArray.count || index < 0) return;
            
            ChannelObject *channel = [deviceObject.channelArray objectAtIndex:index];
            channel.iSupportScaleTwoLensNotCode = 0;
            if ([[systemParams allKeys] containsObject:@"OtherFunction"]) {
                NSDictionary *dataSourceDic = systemParams[@"OtherFunction"];
                channel.iSupportScaleTwoLensNotCode = [(NSNumber *)dataSourceDic[@"SupportScaleTwoLens"] boolValue] == YES?1:0;
            }
            
            //刷新一下
            [self getDataSource];
        }else if ([paramName isEqualToString:@"Camera"]){
            if (msg->pObject == NULL) {
                return;
            }
            NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
            
            if ( data == nil ){
                return;
            }
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ( appData == nil){
                return;
            }
            NSString* strConfigName = [appData valueForKey:@"Name"];
            NSDictionary* systemParams = [appData valueForKey:strConfigName];
            if (systemParams == nil|| [systemParams isKindOfClass:[NSNull class]]) {
                return;
            }
            
            DeviceObject *deviceObject = [[DeviceControl getInstance] GetDeviceObjectBySN:self.devID];
            ChannelObject *channelObject = [deviceObject.channelArray objectAtIndex:0];
            
            channelObject.iSupportIntellDoubleLight = [systemParams[@"SupportIntellDoubleLight"] boolValue]?1:0;
            
            
            //刷新一下
            [self getDataSource];
            return;
        }
    }
}

#pragma mark -- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = TS([[self.dataSourceArray objectAtIndex:indexPath.row] UTF8String]);
    
    if ([cell.textLabel.text isEqualToString:self.currentDayNightName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *dataSource = [self.dataSourceArray objectAtIndex:indexPath.row];
    int dayNightMode = [self getDayNightModeWithName:dataSource];
    NSString *hexString = @"0x";
    NSMutableArray *arr = [self.tranModel reTransfer:[NSString stringWithFormat:@"%d",dayNightMode]];
    for (int i =0; i<arr.count; i++) {
        hexString = [hexString stringByAppendingString:arr[i]];
    }
    
    NSString *cameraParam = [self.cameraParamDic objectForKey:@"Name"];
    NSMutableDictionary *cameraParamDic = [[self.cameraParamDic objectForKey:cameraParam] mutableCopy];
    if ([[cameraParamDic allKeys] containsObject:@"DayNightColor"]) {
        [cameraParamDic setObject:hexString forKey:@"DayNightColor"];
        [self.cameraParamDic setObject:cameraParamDic forKey:cameraParam];
        
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.cameraParamDic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        FUN_DevSetConfig_Json(self.msgHandle, SZSTR(self.devID), "Camera.Param", [strValues UTF8String],[strValues length]+1, self.channelNum);
        [SVProgressHUD showWithStatus:TS("Saving2") maskType:SVProgressHUDMaskTypeBlack];
    }
}

-(int)getDayNightModeWithName:(NSString *)dayNightName{
    if ([dayNightName isEqualToString:@"TR_StarLightInfrared"]) {
        return 0;
    }else if ([dayNightName isEqualToString:@"TR_Full_Color"]) {
        return 1;
    }else if ([dayNightName isEqualToString:@"TR_Black_and_White"]) {
        return 2;
    }else if ([dayNightName isEqualToString:@"TR_Smart_Alarm"]) {
        return 3;
    }else if ([dayNightName isEqualToString:@"Full_Color_Vision"]) {
        return 4;
    }else if ([dayNightName isEqualToString:@"General_Night_Vision"]) {
        return 5;
    }else if ([dayNightName isEqualToString:@"TR_License_Plate_Mode"]) {
        return 6;
    }else{
        return 7;
    }
}

-(NSString *)getDayNightNameWithModel:(int)dayNightMode{
    if (dayNightMode == 0) {
        return TS("TR_StarLightInfrared");
    }else if (dayNightMode == 1) {
        return TS("TR_Full_Color");
    }else if (dayNightMode == 2) {
        return TS("TR_Black_and_White");
    }else if (dayNightMode == 3) {
        return TS("TR_Smart_Alarm");
    }else if (dayNightMode == 4) {
        return TS("Full_Color_Vision");
    }else if (dayNightMode == 5) {
        return TS("General_Night_Vision");
    }else if (dayNightMode == 6) {
        return TS("TR_License_Plate_Mode");
    }else{
        return TS("所有循环");
    }
}




-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

-(TransferModel *)tranModel{
    if (!_tranModel) {
        _tranModel = [[TransferModel alloc] init];
    }
    return _tranModel;
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(SystemInfoManager *)systemInfoManager{
    if (!_systemInfoManager) {
        _systemInfoManager = [[SystemInfoManager alloc] init];
    }
    return _systemInfoManager;
}
@end
