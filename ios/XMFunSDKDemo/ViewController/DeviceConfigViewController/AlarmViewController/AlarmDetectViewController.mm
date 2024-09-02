//
//  AlarmDetectViewController.m
//  FunSDKDemo
//
//  Created by Levi on 2018/5/21.
//  Copyright © 2018年 Levi. All rights reserved.
//

#import "AlarmLevelViewController.h"
#import "AlarmConfigTableViewCell.h"
#import "AlarmDetectViewController.h"
#import "AlarmManager.h"
#import "AlarmDetectConfig.h"   //移动侦测
#import <FunSDK/Fun_MC.h>
#import "SystemFunctionConfig.h"
#import "AlarmVoiceChoseVC.h"

@interface AlarmDetectViewController ()<UITableViewDelegate,UITableViewDataSource,AlarmDetectConfigDelegate,AlarmManagerDelegate,SystemFunctionConfigDelegate>

//灵敏度Lab
@property (nonatomic, strong) UILabel *alarmSensitivityLab;
//报警间隔
@property (nonatomic, strong) UILabel *alarmPushIntervalLab;
//报警间隔
@property (nonatomic, strong) UISlider *alarmPushIntervalSlider;

@property (nonatomic, strong) UITableView *alarmTableView;

//表视图数据源
@property (nonatomic, strong) NSMutableDictionary *dateSourceDic;

@property (nonatomic, strong) AlarmDetectConfig *alarmDetectConfig;
@property (nonatomic,strong) AlarmManager *alarmManager;

@property (nonatomic,assign) BOOL messageAvoidance;  // 消息免打扰是否开启

@property (nonatomic, strong) SystemFunctionConfig * functionConfig;

@property (nonatomic,assign) BOOL supportAlarmVoiceTipsType;  // 是否支持报警声选择
@property (nonatomic, assign) int selectedVoiceType;    // 选中的报警音类型（和数据源中VoiceEnum对应）
@property (nonatomic, assign) int selectedVoiceTypeIndex;//报警音类型列表中的位置
@property (nonatomic, strong) NSMutableArray *arrayList; //报警音类型列表

@end

@implementation AlarmDetectViewController{
    BOOL test;
}

- (SystemFunctionConfig *)functionConfig{
    if (!_functionConfig) {
        _functionConfig = [[SystemFunctionConfig alloc] init];
        _functionConfig.delegate = self;
    }
    
    return _functionConfig;
}

- (UILabel *)alarmSensitivityLab {
    if (!_alarmSensitivityLab) {
        _alarmSensitivityLab = [UILabel new];
        _alarmSensitivityLab.textAlignment = NSTextAlignmentRight;
    }
    return _alarmSensitivityLab;
}

- (UILabel *)alarmPushIntervalLab {
    if (!_alarmPushIntervalLab) {
        _alarmPushIntervalLab = [UILabel new];
        _alarmPushIntervalLab.textAlignment = NSTextAlignmentRight;
    }
    return _alarmPushIntervalLab;
}
- (UISlider *)alarmPushIntervalSlider {
    if (!_alarmPushIntervalSlider) {
        _alarmPushIntervalSlider = [[UISlider alloc] init];
        _alarmPushIntervalSlider.minimumValue = 30;
        _alarmPushIntervalSlider.maximumValue = 1800;
        [_alarmPushIntervalSlider addTarget:self action:@selector(pushIntervalChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _alarmPushIntervalSlider;
}

- (UITableView *)alarmTableView {
    if (!_alarmTableView) {
        _alarmTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        _alarmTableView.delegate = self;
        _alarmTableView.dataSource = self;
        _alarmTableView.tableFooterView = [UIView new];
        [_alarmTableView registerClass:[AlarmConfigTableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _alarmTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏样式
    [self setNaviStyle];
    
    [self configSubView];
    
    //向SDK请求报警数据
    [self getDataSource];
    
    // 获取能力集（是否支持警戒提示音选择）
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    [self.functionConfig getSystemFunction:channel.deviceMac];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    int link = MC_GetLinkState(CSTR(channel.deviceMac));
    self.messageAvoidance = link == 1 ? YES : NO;
    
    [AlarmManager getInstance].delegate = self;
}

-(void)getDataSource{
    self.dateSourceDic = [@{
                            @"0":@[@"Alarm_interval"],
                            @"1":@[@"Video_loss_alarm",@"Message_avoidance"],
                            @"2":@[@"Alarm_function",@"Alarm_video",@"Alarm_picture",@"Send_to_phone",@"Alarm_Sensitivity"],
                            @"3":@[@"Alarm_function2",@"Alarm_video2",@"Alarm_picture2",@"Send_to_phone2"],
                            @"4":@[@"Custom_example"],
                            }
                          mutableCopy];
    //获取报警配置
    [SVProgressHUD showWithStatus:TS("")];
    if (_alarmDetectConfig == nil) {
        _alarmDetectConfig = [[AlarmDetectConfig alloc] init];
        _alarmDetectConfig.delegate = self;
    }
    [_alarmDetectConfig getDeviceAlarmDetectConfig];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("alarm_config");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:TS("ad_save") style:UIBarButtonItemStyleDone target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)configSubView {
    [self.view addSubview:self.alarmTableView];
}

#pragma mark -- UITableViewDelegate/DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.supportAlarmVoiceTipsType) {
        return 6;
    }
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        return 2;
    }else if(section == 2){
        return 5;
    }else if(section == 3){
        return 4;
    }else if(section == 4){
        return 1;
    }else if(section == 5){
        return 1;
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2 || section == 3){
        return 50;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    headView.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:0.7];
    UILabel *headLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth, 50)];
    if (section == 0 || section == 1 || section == 4 || section == 5) {
        return nil;
    }else if (section == 2){
        headLab.text = TS("Motion_detection");
    }else if (section == 3){
        headLab.text = TS("Video_block");
    }
    
    [headView addSubview:headLab];
    return headView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *dataSourceArray = [self.dateSourceDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
    cell.textLabel.text = TS([[dataSourceArray objectAtIndex:indexPath.row] UTF8String]);
    cell.mySwitch.hidden = YES;
    cell.mySwitch.tag = -1;
    [cell.mySwitch removeFromSuperview];
    [cell.mySwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
    
    //alarm interval
    if ([cell.textLabel.text isEqualToString:TS("Alarm_interval")]) { //1 alarm interval、报警间隔
        
        cell.mySwitch.hidden = YES;
        
        self.alarmPushIntervalLab.frame = CGRectMake(ScreenWidth - 80, 7, 60, 30);
        [cell.contentView addSubview:self.alarmPushIntervalLab];
        self.alarmPushIntervalSlider.frame = CGRectMake(100, 7, ScreenWidth-180, 30);
        [cell.contentView addSubview:self.alarmPushIntervalSlider];
        
        self.alarmPushIntervalLab.text = [NSString stringWithFormat:@"%d%@",[self.alarmDetectConfig getPushInterval],TS("s")] ;
        self.alarmPushIntervalSlider.value = [self.alarmDetectConfig getPushInterval];
        self.alarmPushIntervalSlider.hidden = NO;
        self.alarmPushIntervalLab.hidden = NO;
    }
    
    //Video loss
    if ([cell.textLabel.text isEqualToString:TS("Video_loss_alarm")]) { //2 Video loss 视频丢失
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 200;
        [cell.mySwitch setOn:[self.alarmDetectConfig getLossEnable]];
    }
    if ([cell.textLabel.text isEqualToString:TS("Message_avoidance")]) { //2 消息免打扰
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 201;
        [cell.mySwitch setOn:self.messageAvoidance];
    }
    
    //MOTION DETECT
    if ([cell.textLabel.text isEqualToString:TS("Alarm_function")]) { //3 MOTION DETECT alarm on 移动侦测报警开关
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 300;
        [cell.mySwitch setOn:[self.alarmDetectConfig getMotionEnable]];
        NSLog(@"移动侦测开关 = %@,",[NSNumber numberWithBool:[self.alarmDetectConfig getMotionEnable]] );
    }
    if ([cell.textLabel.text isEqualToString:TS("Alarm_video")]) { //3 alarm video switch 报警录像开关
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 301;
        [cell.mySwitch setOn:[self.alarmDetectConfig getMotionRecordEnable]];
    }
    if ([cell.textLabel.text isEqualToString:TS("Alarm_picture")]) { //3 报警抓图开关
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 302;
        [cell.mySwitch setOn:[self.alarmDetectConfig getMotionSnapEnable]];
    }
    if ([cell.textLabel.text isEqualToString:TS("Send_to_phone")]) { //3 alarm message send to app switch 报警消息开关
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 303;
        [cell.mySwitch setOn:[self.alarmDetectConfig getMotionMessageEnable]];
    }
    if ([cell.textLabel.text isEqualToString:TS("Alarm_Sensitivity")]) { //3 灵敏度
        self.alarmSensitivityLab.frame = CGRectMake(ScreenWidth - 100, 7, 80, 30);
        [cell.contentView addSubview:self.alarmSensitivityLab];
        cell.mySwitch.hidden = YES;
        int bum = [_alarmDetectConfig getMotionlevel];
        if (bum == 1 || bum == 2) {
            self.alarmSensitivityLab.text = TS("Alarm_Lower");
        }else if (bum == 3 || bum == 4){
            self.alarmSensitivityLab.text = TS("Alarm_Middle");
        }else if (bum == 5 || bum == 6){
            self.alarmSensitivityLab.text = TS("Alarm_Anvanced");
        }
    }
    
    //Video blocked （BlindDetect）
    if ([cell.textLabel.text isEqualToString:TS("Alarm_function2")]) { //4 alarm on switch 视频遮挡开关
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 400;
        [cell.mySwitch setOn:[self.alarmDetectConfig getBlindEnable]];
    }
    if ([cell.textLabel.text isEqualToString:TS("Alarm_video2")]) { //4 视频遮挡录像
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 401;
        [cell.mySwitch setOn:[self.alarmDetectConfig getBlindRecordEnable]];
    }
    if ([cell.textLabel.text isEqualToString:TS("Alarm_picture2")]) { //4 抓图
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 402;
        [cell.mySwitch setOn:[self.alarmDetectConfig getBlindSnapEnable]];
    }
    if ([cell.textLabel.text isEqualToString:TS("Send_to_phone2")]) { //4 推送消息到手机
        cell.mySwitch.hidden = NO;
        [cell addSubview:cell.mySwitch];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mySwitch.tag = 403;
        [cell.mySwitch setOn:[self.alarmDetectConfig getBlindMessageEnable]];
    }
    NSLog(@"%@开关 = %d,",cell.textLabel.text, cell.mySwitch.isOn);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==2 && indexPath.row == 4) {
        AlarmLevelViewController *viewController = [AlarmLevelViewController new];
        __weak typeof(self) weakSelf = self;
        viewController.alarmLevelBlock = ^(NSString *iLevel) {
            weakSelf.alarmSensitivityLab.text = iLevel;
        };
        [self.navigationController pushViewController:viewController animated:NO];
    }else if (indexPath.section == 4) {
        //自定义设置移动侦测报警周日到周五白天打开，保存后生效,不设置时段的话，设备默认全天报警
        [self.alarmDetectConfig setExampleDetectionConfig];
        [SVProgressHUD showSuccessWithStatus:TS("设置成功，保存后生效") duration:1.0];
    }else if (indexPath.section == 5) {
        AlarmVoiceChoseVC *vc = [[AlarmVoiceChoseVC alloc] init];
        vc.arrayDataSource = [self.arrayList mutableCopy];
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        vc.devID = channel.deviceMac;
        vc.selectedVoiceTypeIndex = self.selectedVoiceTypeIndex;
        __weak typeof(self) weakSelf = self;
        vc.AlarmVoiceChoseVoiceTypeAction = ^(int voiceType) {
            weakSelf.selectedVoiceType = voiceType;
            [weakSelf.alarmDetectConfig setSelectVoiceTipNum:voiceType];
            [weakSelf getSelectedInfo];
        };
        
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }
    return;
}

- (void)getSelectedInfo{
    for (int i = 0; i < self.arrayList.count; i ++) {
        if ([[[self.arrayList objectAtIndex:i] objectForKey:@"VoiceEnum"] intValue] == self.selectedVoiceType) {
            self.selectedVoiceTypeIndex = i;
            break;
        }
    }
}

#pragma mark :获取能力级回调 SystemFunctionConfigDelegate
- (void)SystemFunctionConfigGetResult:(NSInteger)result{
    if (result >= 0) {
        [SVProgressHUD dismiss];
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        //如果支持报警声类型则刷新列表
        if (object.sysFunction.supportAlarmVoiceTipsType == YES) {
            self.supportAlarmVoiceTipsType = object.sysFunction.supportAlarmVoiceTipsType;
            [self.dateSourceDic setObject:@[@"TR_Alarm_Voice"] forKey:@"5"];
            //设置语言 获取报警声列表之前需要先设置一下语言
            [self.alarmDetectConfig setBrowserLanguage];
            [self.alarmTableView reloadData];
        }
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark -- 获取报警配置代理回调
- (void)getAlarmDetectConfigResult:(NSInteger)result{
    if (result  >0) {
        [SVProgressHUD dismiss];
        [self.alarmTableView reloadData];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark -- 获取报警声列表代理回调
- (void)getVoiceTipTypeResult:(NSInteger)result{
    if (result  >0) {
        [SVProgressHUD dismiss];
        self.arrayList = [[self.alarmDetectConfig getVoiceTip] mutableCopy];
        self.selectedVoiceType = [self.alarmDetectConfig getSelectVoiceTipNum];
        for (int i = 0; i < self.arrayList.count; i ++) {
            if ([[[self.arrayList objectAtIndex:i] objectForKey:@"VoiceEnum"] intValue] == self.selectedVoiceType) {
                self.selectedVoiceTypeIndex = i;
                break;
            }
        }
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

- (void)switchValueChange:(UISwitch*)alarmSwitch{
    if (alarmSwitch.tag == 200) {
        [_alarmDetectConfig setLossEnable:alarmSwitch.on];
    }
    if (alarmSwitch.tag == 201) {
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        if (alarmSwitch.on) {
            [[AlarmManager getInstance] UnlinkAlarm:channel.deviceMac];
        }else{
            [[AlarmManager getInstance] LinkAlarm:channel.deviceMac DeviceName:@""];
        }
    }
    if (alarmSwitch.tag == 300) {
        [_alarmDetectConfig setMotionEnable: alarmSwitch.on];
        
    }
    if (alarmSwitch.tag == 301) {
        [_alarmDetectConfig setMotionRecordEnable: alarmSwitch.on];
        
    }
    if (alarmSwitch.tag == 302) {
        [_alarmDetectConfig setMotionSnapEnable: alarmSwitch.on];
        
    }
    if (alarmSwitch.tag == 303) {
        [_alarmDetectConfig setMotionMessageEnable: alarmSwitch.on];
    }
    
    if (alarmSwitch.tag == 400) {
        [_alarmDetectConfig setBlindEnable: alarmSwitch.on];
    }
    if (alarmSwitch.tag == 401) {
        [_alarmDetectConfig setBlindRecordEnable: alarmSwitch.on];
    }
    if (alarmSwitch.tag == 402) {
        [_alarmDetectConfig setBlindSnapEnable: alarmSwitch.on];
    }
    if (alarmSwitch.tag == 403) {
        [_alarmDetectConfig setBlindMessageEnable: alarmSwitch.on];
    }
    
}

#pragma mark -- 保存报警配置
-(void)saveConfig{
//灵敏度保存
    if ([self.alarmSensitivityLab.text isEqualToString:TS("Alarm_Lower")]) {
        [_alarmDetectConfig setMotionlevel: 1];
    }else if ([self.alarmSensitivityLab.text isEqualToString:TS("Alarm_Middle")]){
        [_alarmDetectConfig setMotionlevel: 3];
    }else if ([self.alarmSensitivityLab.text isEqualToString:TS("Alarm_Anvanced")]){
        [_alarmDetectConfig setMotionlevel: 5];
    }
    //发送保存配置命令
    [_alarmDetectConfig setDeviceAlarmDetectConfig];
    
    [SVProgressHUD showWithStatus:TS("")];
    
    
}

//保存配置结果回调
-(void)setAlarmDetectConfigResult:(NSInteger)result{
    if (result>0) {
        [SVProgressHUD showSuccessWithStatus:TS("Success")];
    }else{
         [MessageUI ShowErrorInt:(int)result];
    }
}
- (void)pushIntervalChange:(UISlider*)slider{
    [self.alarmDetectConfig setAlarmPushInterval:slider.value];
    self.alarmPushIntervalLab.text = [NSString stringWithFormat:@"%d%@",(int)slider.value,TS("s")];
}
#pragma mark  获取设备报警间隔代理回调
- (void)getAlarmPushIntervalResult:(NSInteger)result {
    if (result>0) {
        [SVProgressHUD dismiss];
        [self.alarmTableView reloadData];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark  保存设备报警间隔代理回调
- (void)setAlarmPushIntervalResult:(NSInteger)result {
    if (result>0) {
        [SVProgressHUD showSuccessWithStatus:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK:
- (void)LinkAlarmDelegate:(NSString *)deviceMac Result:(NSInteger)result{
    if (result >= 0) {
        
    }else{
        [MessageUI ShowErrorInt:(int)result];
        [self.alarmTableView reloadData];
    }
}

- (void)UnlinkAlarmAlarmDelegate:(NSString *)deviceMac Result:(NSInteger)result{
    if (result >= 0) {
        
    }else{
        [MessageUI ShowErrorInt:(int)result];
        [self.alarmTableView reloadData];
    }
}

@end
