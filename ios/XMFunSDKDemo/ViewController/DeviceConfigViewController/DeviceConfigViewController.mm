//
//  DeviceConfigViewController.m
//  FunSDKDemo
//
//  Created by Levi on 2018/5/17.
//  Copyright © 2018年 Levi. All rights reserved.
//

#import "EncodeViewController.h" //编码配置
#import "AlarmDetectViewController.h" //报警配置
#import "RecordViewController.h" //录像配置
#import "ParamViewController.h" //图像配置
#import "TimeSynViewController.h" //时间同步
#import "VideoFileViewController.h" //设备录像查询
#import "PictureFileViewController.h"//设备图片查询
#import "PasswordViewController.h" //密码修改
#import "StorageViewController.h" //存储空间
#import "CruiseViewController.h"
#import "AboutDeviceViewController.h" //关于设备信息
#import "UpgradeDeviceViewController.h" //设备升级
#import "DeviceconfigTableViewCell.h"
#import "DeviceConfigViewController.h"
#import "SystemInfoConfig.h"
#import "DeviceManager.h"
#import "CloudAbilityViewController.h"
#import "AlarmMessageViewController.h"  //推送消息
#import "EncodingFormatViewController.h"  //编码格式设置
#import "AnalyzerViewController.h"  //智能分析
#import "SystemFunctionConfig.h"
#import "WaterMarkViewController.h"       //水印设置
#import "BuzzerViewController.h"            //蜂鸣功能
#import "ShutDownTimeViewController.h" //设备休眠时间
#import "ElectricityViewController.h" //设备电量
#import "HumanDetectionViewController.h"  //DVR人形检测
#import "IPCHumanDetectionViewController.h"  //IPC人形检测
#import "AlarmPICViewController.h"   //徘徊检测
#import "NetworkViewController.h"
#import "SensorlistVCViewController.h"
#import "DoorViewController.h"
#import "BaseConfigVC.h"
#import "HumanDetectionForIPCViewController.h"
#import "FishEyeBulbViewController.h"
#import "LightBulbViewController.h"
#import "AutoCruiseVC.h"
#import "OneKeyToCoverVC.h"
#import "DoorBellCfgVC.h"
#import "ChangeChannelTitleViewController.h"

#import "GetStorageHeadDataConfig.h" //调试设备存储内存时使用，正常情况下用不到
#import <MessageUI/MessageUI.h>

#import "ShareDeviceGatherVC.h"
#import "DayNightModelViewController.h"//日夜模式
#import "VoiceBroadcastingViewController.h"
#import "MQTTViewController.h"

#import "DeviceRandomPwdManager.h"

@interface DeviceConfigViewController ()<UITableViewDelegate,UITableViewDataSource,SystemInfoConfigDelegate,SystemFunctionConfigDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *devConfigTableView;

@property (nonatomic, strong) NSMutableArray *configTitleArray;

@property (nonatomic, strong) SystemInfoConfig * config;

@property (nonatomic, strong) SystemFunctionConfig * functionConfig;

@property (nonatomic, strong) GetStorageHeadDataConfig * storageTestConfig;

@end

@implementation DeviceConfigViewController

- (UITableView *)devConfigTableView {
    if (!_devConfigTableView) {
        _devConfigTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        _devConfigTableView.delegate = self;
        _devConfigTableView.dataSource = self;
        _devConfigTableView.rowHeight = 60;
        [_devConfigTableView registerClass:[DeviceconfigTableViewCell class] forCellReuseIdentifier:@"cell"];
        _devConfigTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    }
    return _devConfigTableView;
}



#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏样式
    [self setNaviStyle];
    
    //初始化数据
    [self initDataSource];
    
    //配置子视图
    [self configSubView];
    
     //获取各个设备配置前，如果设备(门铃门锁等等)是在休眠状态，需要先进行唤醒
    [self checkDeviceSleepType];
    
    //获取设备能力级SystemFunction
    [self getSystemFunction];
    
    //获取设备信息systeminfo
    [self getSysteminfo];
}

//获取设备能力级SystemFunction
- (void)getSystemFunction{
    if (!_functionConfig) {
        _functionConfig = [[SystemFunctionConfig alloc] init];
        _functionConfig.delegate = self;
    }
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    [_functionConfig getSystemFunction:channel.deviceMac];
}
//编码配置需要知道设备的模拟通道数量，所以在编码配置前需要获取一下
- (void)getSysteminfo {
    if (_config == nil) {
        _config = [[SystemInfoConfig alloc] init];
        _config.delegate = self;
    }
    [SVProgressHUD show];
     [_config getSystemInfo];
}

//MARK: 获取SystemFunction回调
- (void)SystemFunctionConfigGetResult:(NSInteger)result{

}

//休眠中的设备需要先唤醒才能去获取其他配置
- (void)checkDeviceSleepType {
    ChannelObject *object = [[DeviceControl getInstance] getSelectChannel];
    [[DeviceManager getInstance] deviceWeakUp:object.deviceMac];
}
#pragma mark  获取设备systeminfo回调
- (void)SystemInfoConfigGetResult:(NSInteger)result {
    if (result >0) {
        //获取成功
        [SVProgressHUD dismiss];
    }else{
        //获取失败
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark -- UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.configTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceconfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DeviceconfigTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *detailInfo = [self.configTitleArray[indexPath.row] objectForKey:@"detailInfo"];
    if (detailInfo && detailInfo.length > 0) {
        cell.Labeltext.frame = CGRectMake(64, 9, ScreenWidth - 64, 22);
        cell.detailLabel.hidden = NO;
        cell.Labeltext.text = [self.configTitleArray[indexPath.row] objectForKey:@"title"];
        cell.detailLabel.text = detailInfo;
    }else{
        cell.Labeltext.frame = CGRectMake(64, 18, ScreenWidth - 64, 22);
        cell.detailLabel.hidden = YES;
        cell.Labeltext.text = [self.configTitleArray[indexPath.row] objectForKey:@"title"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleStr = [self.configTitleArray[indexPath.row] objectForKey:@"title"];
    if ([titleStr isEqualToString:TS("alarm_config")]) {
        AlarmDetectViewController *alarmDetectVC = [[AlarmDetectViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:alarmDetectVC animated:NO];
    }else if ([titleStr isEqualToString:TS("分享设备")]){ //分享设置
        
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        ShareDeviceGatherVC * vc = [ShareDeviceGatherVC new];
        vc.devId = channel.deviceMac;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([titleStr isEqualToString:TS("Encode_config")]){ //编码配置
        EncodeViewController *encodeVC = [[EncodeViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:encodeVC animated:NO];
    }else if ([titleStr isEqualToString:TS("Record_config")]){ //录像配置
        RecordViewController *encodeVC = [[RecordViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:encodeVC animated:NO];
    }else if ([titleStr isEqualToString:TS("picture_vonfig")]){ //图像配置
        ParamViewController *encodeVC = [[ParamViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:encodeVC animated:NO];
    }else if ([titleStr isEqualToString:TS("time_syn")]){ //时间同步
        TimeSynViewController *timeVC = [[TimeSynViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:timeVC animated:NO];
    }else if ([titleStr isEqualToString:TS("record_file")]){ //设备录像
        VideoFileViewController *videoVC = [[VideoFileViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:videoVC animated:NO];
    }else if ([titleStr isEqualToString:TS("picture_file")]){  //设备图片
        PictureFileViewController *pictureVC = [[PictureFileViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:pictureVC animated:NO];
    }else if ([titleStr isEqualToString:TS("password_change")]){ //修改密码
        PasswordViewController *passwordVC = [[PasswordViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:passwordVC animated:NO];
        
    }else if ([titleStr isEqualToString:TS("device_storage")]){ //设备存储
        StorageViewController *storageVC = [[StorageViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:storageVC animated:NO];
    }else if ([titleStr isEqualToString:TS("preset_tour")]){ //巡航 (巡航功能另外需要设备支持云台功能才可以，这个设备出厂时已经确定，一般都支持，部分客户定制设备可能会根据客户要求去掉能力级，默认支持或者不支持，根据支持情况可以无需判断能力级）
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if(object.sysFunction.SupportPTZTour == NO){
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        CruiseViewController *cruiseVC = [[CruiseViewController alloc]init];
        [self.navigationController pushViewController:cruiseVC animated:NO];
    }else if([titleStr isEqualToString:TS("Timed_Cruise")]){
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if(object.sysFunction.SupportTimingPtzTour == NO){
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        
        AutoCruiseVC *cruiseVC = [[AutoCruiseVC alloc]init];
        [self.navigationController pushViewController:cruiseVC animated:YES];
        
    }else if ([titleStr isEqualToString:TS("About_Device")]){ //关于设备
        AboutDeviceViewController *deviceVC = [[AboutDeviceViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:deviceVC animated:NO];
    }else if ([titleStr isEqualToString:TS("Equipment_Update")]){ //设备升级
        UpgradeDeviceViewController *upgradeVC = [[UpgradeDeviceViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:upgradeVC animated:NO];
    }else if ([titleStr isEqualToString:TS("Alarm_message_push")]){ //推送消息
        AlarmMessageViewController *alarmMessageVC = [[AlarmMessageViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:alarmMessageVC animated:NO];
        
    }else if ([titleStr isEqualToString:TS("AnalyzeConfig")]){ //智能分析
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if(object.sysFunction.NewVideoAnalyze == NO){
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        AnalyzerViewController *analyzeVC = [[AnalyzerViewController alloc] init];
        [self.navigationController pushViewController:analyzeVC animated:NO];
    }else if ([titleStr isEqualToString:TS("Encoding_format")]){ //视频格式
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if(object.sysFunction.SupportSmartH264 == NO){
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        EncodingFormatViewController *formatVC = [[EncodingFormatViewController alloc] init];
        [self.navigationController pushViewController:formatVC animated:NO];
    }else if([titleStr isEqualToString:TS("Watermark_setting")]){ //水印
        WaterMarkViewController *waterMarkVC = [[WaterMarkViewController alloc] init];
        [self.navigationController pushViewController:waterMarkVC animated:NO];
    }else if([titleStr isEqualToString:TS("Cloud_storage")]){ //云服务
        CloudAbilityViewController *cloudVC = [[CloudAbilityViewController alloc] init];
        [self.navigationController pushViewController:cloudVC animated:NO];
    }else if([titleStr isEqualToString:TS("Buzzer_setting")]){
        BuzzerViewController *BuzzerVC = [[BuzzerViewController alloc] init];
        [self.navigationController pushViewController:BuzzerVC animated:NO];
    }else if([titleStr isEqualToString:TS("设置休眠")]){
        /****
         * 获取和设置设备休眠时间 （目前只有部分设备支持休眠，例如门铃、门锁、猫眼、喂食器等等）
         *休眠时间单位为秒S，
         ***/
        ShutDownTimeViewController *timeVC = [[ShutDownTimeViewController alloc] init];
        [self.navigationController pushViewController:timeVC animated:NO];
    }else if([titleStr isEqualToString:TS("IDR_BATTERY")]){
        /****
         * 设备电量，一般只有带电池设备支持
         ***/
        ElectricityViewController *electVC = [[ElectricityViewController alloc] init];
        [self.navigationController pushViewController:electVC animated:NO];
    }else if([titleStr isEqualToString:TS("appEventHumanDetectAlarm")]){ //人行检测 DVR
        HumanDetectionViewController *humandetectVC = [[HumanDetectionViewController alloc] init];
        [self.navigationController pushViewController:humandetectVC animated:NO];
    }else if([titleStr isEqualToString:TS("HumanDetectAlarm_IPC")]){ //人行检测 IPC，简易版本
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if(object.sysFunction.PEAInHumanPed == NO && [[DeviceControl getInstance] getSelectChannelArray].count <=1){
            //单品设备并且不支持人形检测时，提示设备不支持
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        IPCHumanDetectionViewController *IPCHumandetectVC = [[IPCHumanDetectionViewController alloc] init];
        [self.navigationController pushViewController:IPCHumandetectVC animated:NO];
    }else if([titleStr isEqualToString:TS("Intelligent_Vigilance")]){
        //智能警戒 完全体版本的IPC人形检测，根据需求判断使用简易版的还是完全版本的
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if (devObject.sysFunction.PEAInHumanPed == NO) {
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        
        HumanDetectionForIPCViewController *controller = [[HumanDetectionForIPCViewController alloc]init];
        controller.devID = channel.deviceMac;
        controller.channelNum = 0;
        [self.navigationController pushViewController:controller animated:YES];
    }else if([titleStr isEqualToString:TS("AlarmPIR")]){
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if(object.sysFunction.SupportPirAlarm == NO){
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        AlarmPICViewController *alarmPIC = [[AlarmPICViewController alloc] init];
        [self.navigationController pushViewController:alarmPIC animated:NO];
    }else if ([titleStr isEqualToString:TS("Sensor_Config")]){
        SensorlistVCViewController *vc = [[SensorlistVCViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([titleStr isEqualToString:TS("DEV_DOORLOCK")]){
        DoorViewController *vc = [[DoorViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([titleStr isEqualToString:TS("Network_setting")]){
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if(object.sysFunction.WifiModeSwitch == NO){
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        NetworkViewController *vc = [[NetworkViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([titleStr isEqualToString:TS("Base_Config")]){
        BaseConfigVC *vc = [[BaseConfigVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([titleStr isEqualToString:TS("One_Key_To_Cover")]){
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if (devObject.sysFunction.SupportOneKeyMaskVideo == NO) {
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        
        OneKeyToCoverVC *vc = [[OneKeyToCoverVC alloc] init];
        vc.devId = channel.deviceMac;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([titleStr isEqualToString:TS("DoorBell_Cfg")]){
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DoorBellCfgVC *vc = [[DoorBellCfgVC alloc] init];
        vc.devID = channel.deviceMac;
        
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([titleStr isEqualToString:TS("LightBulb_Cfg")]){
        //灯泡配置
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if (devObject.sysFunction.iSupportCameraWhiteLight == NO) {
            [SVProgressHUD showErrorWithStatus:TS("EE_MNETSDK_NOTSUPPORT")];
            return;
        }
        LightBulbViewController *vc = [[LightBulbViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([titleStr isEqualToString:TS("FishBulb_Cfg")]){
        //鱼眼灯泡配置
        
    }else if ([titleStr isEqualToString:TS("SD卡录像数据调试")]){ //
        //调试存储异常的接口，正常APP不要增加这个功能
        [self startStorageTest];
    }
    else if ([titleStr isEqualToString:TS("TR_Channel_Name")]){ //修改通道名称
        ChangeChannelTitleViewController *vc = [[ChangeChannelTitleViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([titleStr isEqualToString:TS("TR_DayNightMode")]){ //日夜模式
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DayNightModelViewController *vc = [[DayNightModelViewController alloc] init];
        vc.devID = channel.deviceMac;
        vc.channelNum = channel.channelNumber;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([titleStr isEqualToString:TS("TR_Voice_Broadcasting")]){ //语音播报功能
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        VoiceBroadcastingViewController *vc = [[VoiceBroadcastingViewController alloc]init];
        vc.devID = channel.deviceMac;
        vc.channelNum = channel.channelNumber;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([titleStr isEqualToString:TS("MQTT")]){ //MQTT demonstrate
        MQTTViewController *vc = [[MQTTViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        return;
    }
    
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("setting");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
}

- (void)configSubView {
    [self.view addSubview:self.devConfigTableView];
    [[NSNotificationCenter defaultCenter] postNotificationName:MasterAccount object:@"123"];
}

- (void)initDataSource {
    self.configTitleArray =[@[//@{@"title":TS("SD卡录像数据调试"),@"detailInfo":@"调试存储异常的接口，正常APP不要增加这个功能"},
        @{@"title":TS("Base_Config"),@"detailInfo":@""},
        @{@"title":TS("TR_Channel_Name"),@"detailInfo":@""},
        @{@"title":TS("分享设备"),@"detailInfo":@"分享我的设备，分享出去的设备，别人分享给我的设备"},
        @{@"title":TS("Encode_config"),@"detailInfo":@"在这里,你可以配置分辨率,帧数,音频,视频"},
        @{@"title":TS("alarm_config"),@"detailInfo":@"设备支持各种报警触发和联动,您可以在这里进行配置"},
        @{@"title":TS("Record_config"),@"detailInfo":@"设备主辅码流录像配置"},
        @{@"title":TS("picture_vonfig"),@"detailInfo":@"设备视频画面图像反转"},
        @{@"title":TS("time_syn"),@"detailInfo":@"在这里可以显示和同步设备时间"},
        @{@"title":TS("device_storage"),@"detailInfo":@"该选项允许您查看和管理设备的存储空间"},
        @{@"title":TS("password_change"),@"detailInfo":@"您可以更改设备的访问密码"},
        @{@"title":TS("record_file"),@"detailInfo":@"设备端保存的录像，必须有存储空间的设备才有录像"},
        @{@"title":TS("picture_file"),@"detailInfo":@"设备端保存的报警抓图等等，必须有存储空间的设备才有图片"},
        @{@"title":TS("preset_tour"),@"detailInfo":@"设置设备一键巡航，需要判断能力级"},
        @{@"title":TS("Timed_Cruise"),@"detailInfo":@"设置设备定时巡航，需要判断能力级"},
        @{@"title":TS("Alarm_message_push"),@"detailInfo":@"设备报警消息"},
        @{@"title":TS("About_Device"),@"detailInfo":@"设备信息和恢复出厂设置"},
        @{@"title":TS("Equipment_Update"),@"detailInfo":@"检查设备固件版本，升级设备"},
        @{@"title":TS("AnalyzeConfig"),@"detailInfo":@""},
        @{@"title":TS("Cloud_storage"),@"detailInfo":@""},
        @{@"title":TS("Encoding_format"),@"detailInfo":@""},
        @{@"title":TS("Watermark_setting"),@"detailInfo":@""},
        @{@"title":TS("Buzzer_setting"),@"detailInfo":@""},
        @{@"title":TS("设置休眠"),@"detailInfo":@""},
        @{@"title":TS("IDR_BATTERY"),@"detailInfo":@""},
        @{@"title":TS("appEventHumanDetectAlarm"),@"detailInfo":@"DVR设备人形检测报警"},
        @{@"title":TS("HumanDetectAlarm_IPC"),@"detailInfo":@"IPC和NVR设备人形检测报警"},
        @{@"title":TS("AlarmPIR"),@"detailInfo":@"检测到有人物徘徊时，触发报警"},
        @{@"title":TS("DoorBell_Cfg"),@"detailInfo":@""},
        @{@"title":TS("LightBulb_Cfg"),@"detailInfo":@""},
        @{@"title":TS("FishBulb_Cfg"),@"detailInfo":@""},
        @{@"title":TS("DEV_DOORLOCK"),@"detailInfo":@""},
        @{@"title":TS("Network_setting"),@"detailInfo":@""},
        @{@"title":@"GB配置",@"detailInfo":@""},
        @{@"title":@"Json和DevCmd调试",@"detailInfo":@""},
        @{@"title":@"鱼眼信息",@"detailInfo":@""},
        @{@"title":TS("Sensor_Config"),@"detailInfo":@""},
        @{@"title":TS("One_Key_To_Cover"),@"detailInfo":@""},
        @{@"title":TS("TR_DayNightMode"),@"detailInfo":@""},
        @{@"title":TS("TR_Voice_Broadcasting"),@"detailInfo":@""},
        @{@"title":TS("MQTT"),@"detailInfo":@""},
    ] mutableCopy];
}


- (void)startStorageTest {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TS("SD卡录像数据调试") message:TS("存储异常调试接口，仅供出现存储异常时的调试使用") preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = TS("请输入想要设置的偏移值");
        NSString *offset = [[NSUserDefaults standardUserDefaults] objectForKey:@"offset"];
        if (offset != nil) {
            textField.text = offset;
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *offset = alert.textFields.firstObject;
        //调试存储异常的接口，获取设备存储头文件，需要设备支持才能使用，仅供调试使用
        [self storageBugTest:offset.text];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//调试存储接口，获取设备存储头文件，需要设备支持
- (void)storageBugTest:(NSString*)offset {
    ChannelObject *object = [[DeviceControl getInstance] getSelectChannel];
    self.storageTestConfig = [[GetStorageHeadDataConfig alloc] init];
    self.storageTestConfig.deviceMac = object.deviceMac;
    __weak DeviceConfigViewController *instance = self;
    self.storageTestConfig.getHeaderDataBlock = ^(NSInteger result){
        if (result >= 0) {
            if (![MFMailComposeViewController canSendMail]) {
                UIAlertView *wAlertView = [[UIAlertView alloc]initWithTitle:TS("cannot_send_email")
                                                                    message:TS("please_check_email_setting")
                                                                   delegate:nil
                                                          cancelButtonTitle:TS("Confirm")
                                                          otherButtonTitles:nil];
                [wAlertView show];
                return;
            }
            MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
            mailPicker.mailComposeDelegate = instance;

            //设置主题
            [mailPicker setSubject: @"storage for iOS"];
            
            // 添加收件人
            NSArray *toRecipients = [NSArray arrayWithObject: @"cs@xiongmaitech.com"];
            [mailPicker setToRecipients: toRecipients];
            
            [mailPicker setMessageBody:@"获取数据成功" isHTML:NO];
            
            ChannelObject *object = [[DeviceControl getInstance] getSelectChannel];
            NSData *fileData = [NSData dataWithContentsOfFile:[NSString tempZipPath:object.deviceMac]];
            if (fileData) {
                [mailPicker addAttachmentData: fileData mimeType: @"" fileName: [NSString stringWithFormat:@"%@.zip",object.deviceMac]];
            }
            [instance presentViewController:mailPicker animated:YES completion:nil];
            
        }else{
            [MessageUI ShowErrorInt:(int)result];
        }
    };
    [[NSUserDefaults standardUserDefaults] setObject:offset forKey:@"offset"];
    [self.storageTestConfig getStorageHeadDataConfig:offset];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = TS("edit_email");
            break;
        case MFMailComposeResultSaved:
            msg = TS("save_email");
            break;
        case MFMailComposeResultSent:
            msg = TS("send_email");
            break;
        case MFMailComposeResultFailed:
            msg = TS("save_or_send_email_failed");
            break;
        default:
            msg = @"";
            break;
    }
    [SVProgressHUD showSuccessWithStatus:msg duration:1.0];
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end

