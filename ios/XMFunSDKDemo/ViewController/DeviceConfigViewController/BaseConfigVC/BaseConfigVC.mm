//
//  BaseConfigVC.m
//  FunSDKDemo
//
//  Created by Megatron on 2019/5/6.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "BaseConfigVC.h"
#import "SystemFunctionConfig.h"
#import <Masonry/Masonry.h>
#import "BaseConfigListCell.h"
#import "ExtralStateCtrlConfig.h"
#import "DevRingCtrlConfig.h"
#import "AudioInputConfig.h"
#import "AudioOutputConfig.h"
#import "VideoRotainConfig.h"

static NSString *const kBaseConfigListCell = @"kBaseConfigListCell";

@interface BaseConfigVC () <UITableViewDelegate,UITableViewDataSource,SystemFunctionConfigDelegate,BaseConfigListCellDelegate,ExtralStateCtrlConfigDelegate,DevRingCtrlConfigDelegate,AudioOutputConfigDelegate,AudioInputConfigDelegate,VideoRotainConfigDelegate>

@property (nonatomic,strong) UITableView *tbFunctionList;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic, strong) SystemFunctionConfig * functionConfig;

@property (nonatomic,assign) BOOL supportVoiceTip;          // 是否支持设备提示音
@property (nonatomic,assign) BOOL supportStatusLed;         // 是否支持状态灯
@property (nonatomic,assign) BOOL supportDevRingControl;    // 是否支持设备响铃控制
@property (nonatomic,assign) BOOL voiceTipEnable;           // 提示音是否开启
@property (nonatomic,assign) BOOL statusLedEnable;          // 状态灯是否开启
@property (nonatomic,assign) BOOL devRingControlEnable;     // 设备响铃是否开启

@property (nonatomic,assign) BOOL ifSupportSetVolume;       // 是否支持音量设置 （支持还要获取对应配置 解析成功才算支持音量输出或者输入）
@property (nonatomic,assign) BOOL ifSupportOutputVolume;    // 是否支持音量输出设置
@property (nonatomic,assign) BOOL ifSupportInputVolume;     // 是否支持音量输入设置
@property (nonatomic,assign) BOOL bSupportDNChangeByImage;  //日夜切换灵敏度

@property (nonatomic,strong) ExtralStateCtrlConfig *extralStateCtrlConfig;  // 设备额外状态设置 （需要根据能力集判断是否支持）设备提示音 设备状态灯等
@property (nonatomic,strong) DevRingCtrlConfig *devRingCtrlConfig;          // 设备警铃设置

@property (nonatomic,strong) AudioInputConfig *audioInputConfig;            // 音量输入
@property (nonatomic,strong) AudioOutputConfig *audioOutputConfig;          // 音量输出
@property (nonatomic,strong) VideoRotainConfig *videoRotainconfig; //摄像机参数配置 (日夜切换灵敏度)
@end

@implementation BaseConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSuvView];
    
    [SVProgressHUD show];
    // 获取能力集
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    [self.functionConfig getSystemFunction:channel.deviceMac];
}

//MARK: - ConfigSubView
- (void)configSuvView{
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
//    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self.view addSubview:self.tbFunctionList];
    
    [self.tbFunctionList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

//MARK: Action
- (void)changeSupport:(NSString *)title{
    for (int i = 0; i < self.dataSource.count; i++) {
        NSMutableDictionary *dic = [[self.dataSource objectAtIndex:i] mutableCopy];
        if ([[dic objectForKey:@"Title"] isEqualToString:title]) {
            [dic setObject:@1 forKey:@"Support"];
            
            [self.dataSource replaceObjectAtIndex:i withObject:dic];
            break;
        }
    }
}

- (void)saveConfig{
    if (self.supportVoiceTip) {
        [self.extralStateCtrlConfig setVoiceTipEnable:self.voiceTipEnable ? 1 : 0];
    }
    
    if (self.supportStatusLed) {
        [self.extralStateCtrlConfig setIsOn:self.statusLedEnable ? 1 : 0];
    }
    
    if (self.supportStatusLed || self.supportVoiceTip) {
        [SVProgressHUD show];
        [self.extralStateCtrlConfig mySetConfig];
    }
}

//MARK: - Delegate
//MARK: UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.row];
    int support = [[dic objectForKey:@"Support"] intValue];
    if (support == 1) {
        return 60;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BaseConfigListCell *cell = (BaseConfigListCell *)[tableView dequeueReusableCellWithIdentifier:kBaseConfigListCell];
    cell.delegate = self;
    cell.row = (int)indexPath.row;
    cell.section = (int)indexPath.section;
    cell.hidden = NO;
    
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"Title"];
    int support = [[dic objectForKey:@"Support"] intValue];
    if (support != 1) {
        cell.hidden = YES;
        return cell;
    }
    
    cell.lbTitle.text = title;
    if ([title isEqualToString:TS("Beep")]) {
        [cell changeStyle:BaseConfigListCellStyleSwitch];
        cell.mySwitch.on = self.voiceTipEnable;
    }else if ([title isEqualToString:TS("Status_Light")]){
        [cell changeStyle:BaseConfigListCellStyleSwitch];
        cell.mySwitch.on = self.statusLedEnable;
    }else if ([title isEqualToString:TS("Door_Ring")]){
        [cell changeStyle:BaseConfigListCellStyleSwitch];
        cell.mySwitch.on = self.devRingControlEnable;
    }else if ([title isEqualToString:TS("Input_Volume")]){
        [cell changeStyle:BaseConfigListCellStyleSlider];
        [cell.slider setValue:([self.audioInputConfig getVolume]/100.0)];
    }else if ([title isEqualToString:TS("Output_Volume")]){
        [cell changeStyle:BaseConfigListCellStyleSlider];
        [cell.slider setValue:([self.audioOutputConfig getVolume]/100.0)];
    }
    else if ([title isEqualToString:TS("TR_Device_Image_Sensibility")]){
        [cell changeStyle:BaseConfigListCellStyleSlider];
        [cell.slider setValue:([self.videoRotainconfig getDncThr]/100.0)];
    }
    
    return cell;
}

//MARK: BaseConfigListCellDelegate
- (void)switchValueChanged:(BOOL)enable row:(int)row section:(int)section{
    NSDictionary *dic = [self.dataSource objectAtIndex:row];
    NSString *title = [dic objectForKey:@"Title"];
    
    if ([title isEqualToString:TS("Beep")]) {
        self.voiceTipEnable = enable;
        [self.extralStateCtrlConfig setVoiceTipEnable:enable ? 1 : 0];
        [SVProgressHUD show];
        [self.extralStateCtrlConfig mySetConfig];
    }else if ([title isEqualToString:TS("Status_Light")]){
        self.statusLedEnable = enable;
        [self.extralStateCtrlConfig setIsOn:enable ? 1 : 0];
        [SVProgressHUD show];
        [self.extralStateCtrlConfig mySetConfig];
    }else if ([title isEqualToString:TS("Door_Ring")]){
        self.devRingControlEnable = enable;
        [self.devRingCtrlConfig setEnable:enable];
        [SVProgressHUD show];
        [self.devRingCtrlConfig mySetConfig];
    }
}

- (void)sliderValueChanged:(float)value row:(int)row section:(int)section{
    NSDictionary *dic = [self.dataSource objectAtIndex:row];
    NSString *title = [dic objectForKey:@"Title"];
    
    if ([title isEqualToString:TS("Input_Volume")]) {
        [self.audioInputConfig setVolume:(int)(value*100)];
    }else if ([title isEqualToString:TS("Output_Volume")]){
        [self.audioOutputConfig setVolume:(int)(value*100)];
    }else if ([title isEqualToString:TS("TR_Device_Image_Sensibility")]){
        [self.videoRotainconfig setDncThr:(int)(value*100)];
    }
}

- (void)sliderValueStopChangeRow:(int)row section:(int)section{
    NSDictionary *dic = [self.dataSource objectAtIndex:row];
    NSString *title = [dic objectForKey:@"Title"];
    
    if ([title isEqualToString:TS("Input_Volume")]) {
        [SVProgressHUD show];
        [self.audioInputConfig setConfig];
    }else if ([title isEqualToString:TS("Output_Volume")]){
        [SVProgressHUD show];
        [self.audioOutputConfig setConfig];
    }else if ([title isEqualToString:TS("TR_Device_Image_Sensibility")]){
        [SVProgressHUD show];
        [self.videoRotainconfig setRotainConfig];
    }
}

//MARK: ExtralStateCtrlConfigDelegate
- (void)getExtralStateCtrlConfigResult:(NSInteger)result{
    if (result >= 0) {
        self.statusLedEnable = [self.extralStateCtrlConfig getIsOn];
        self.voiceTipEnable = [self.extralStateCtrlConfig getVoiceTipEnable];
        
        [self.tbFunctionList reloadData];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

- (void)setExtralStateCtrlConfigResult:(NSInteger)result{
    if (result >= 0) {
        [SVProgressHUD showSuccessWithStatus:TS("config_Save_Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK: DevRingCtrlConfigDelegate
- (void)getDevRingCtrlConfigResult:(NSInteger)result{
    if (result >= 0) {
        self.devRingControlEnable = [self.devRingCtrlConfig getEnable];
        
        [self.tbFunctionList reloadData];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

- (void)setDevRingCtrlConfigResult:(NSInteger)result{
    if (result >= 0) {
        [SVProgressHUD showSuccessWithStatus:TS("config_Save_Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK: 音频输入配置回调
- (void)getAudioInputConfigResult:(int)result{
    if (result >= 0) {
        self.ifSupportInputVolume = [self.audioInputConfig checkSupportConfig];
        if (self.ifSupportInputVolume) {
            [self changeSupport:TS("Input_Volume")];
            
            [self.tbFunctionList reloadData];
        }
    }else{
        
    }
    
    [self.audioOutputConfig getConfig];
}

- (void)setAudioInputConfigResult:(int)result{
    if (result >= 0) {
        [SVProgressHUD showSuccessWithStatus:TS("config_Save_Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK: 音频输出配置回调
- (void)getAudioOutputConfigResult:(int)result{
    if (result >= 0) {
        self.ifSupportOutputVolume = [self.audioOutputConfig checkSupportConfig];
        if (self.ifSupportOutputVolume) {
            [self changeSupport:TS("Output_Volume")];
            
            [self.tbFunctionList reloadData];
        }
    }else{
        
    }
}

- (void)setAudioOutputConfigResult:(int)result{
    if (result >= 0) {
        [SVProgressHUD showSuccessWithStatus:TS("config_Save_Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark - 获取摄像机参数配置
- (void)getVideoRotainConfig {
    [SVProgressHUD showWithStatus:TS("")];
    //调用获取摄像机图像翻转等参数的接口
    [self.videoRotainconfig getRotainConfig];
}

#pragma mark 获取摄像机参数代理回调
- (void)getVideoRotainConfigResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [self.tbFunctionList reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

-(void)setVideoRotainConfigResult:(NSInteger)result{
    if (result >0) {
        //成功，刷新界面数据
        [SVProgressHUD showSuccessWithStatus:TS("config_Save_Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK: SystemFunctionConfigDelegate
- (void)SystemFunctionConfigGetResult:(NSInteger)result{
    if (result >= 0) {
        [SVProgressHUD dismiss];
        
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if (object.sysFunction.SupportCloseVoiceTip == YES) {
            self.supportVoiceTip = YES;
            [self changeSupport:TS("Beep")];
        }
        
        if (object.sysFunction.SupportStatusLed == YES) {
            self.supportStatusLed = YES;
            [self changeSupport:TS("Status_Light")];
        }
        
        if (object.sysFunction.SupportDevRingControl) {
            self.supportDevRingControl = YES;
            [self changeSupport:TS("Door_Ring")];
        }
        
        if (object.sysFunction.ifSupportSetVolume) {
            self.ifSupportSetVolume = YES;
            
            [self.audioInputConfig getConfig];
        }
        
        if (object.sysFunction.isupportDNChangeByImage) {
            self.bSupportDNChangeByImage = YES;
            [self changeSupport:TS("TR_Device_Image_Sensibility")];
            [self.videoRotainconfig getRotainConfig];
        }
        
        [self.tbFunctionList reloadData];
        
        if (!self.supportStatusLed || self.supportVoiceTip) {
            [self.extralStateCtrlConfig myGetConfig];
        }

        if (self.supportDevRingControl) {
            [self.devRingCtrlConfig myGetConfig];
        }
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

//MARK: - LazyLoad
- (VideoRotainConfig *)videoRotainconfig{
    if (!_videoRotainconfig) {
        _videoRotainconfig = [[VideoRotainConfig alloc] init];
        _videoRotainconfig.delegate = self;
    }
    
    return _videoRotainconfig;
}

- (SystemFunctionConfig *)functionConfig{
    if (!_functionConfig) {
        _functionConfig = [[SystemFunctionConfig alloc] init];
        _functionConfig.delegate = self;
    }
    
    return _functionConfig;
}

- (UITableView *)tbFunctionList{
    if (!_tbFunctionList) {
        _tbFunctionList = [[UITableView alloc] init];
        _tbFunctionList.delegate = self;
        _tbFunctionList.dataSource = self;
        
        [_tbFunctionList registerClass:[BaseConfigListCell class] forCellReuseIdentifier:kBaseConfigListCell];
    }
    
    return _tbFunctionList;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [@[@{@"Title":TS("Status_Light"),@"DetailInfo":TS(""),@"Support":@0},\
                         @{@"Title":TS("Beep"),@"DetailInfo":TS(""),@"Support":@0},\
                         @{@"Title":TS("Door_Ring"),@"DetailInfo":TS(""),@"Support":@0},\
                         @{@"Title":TS("Input_Volume"),@"DetailInfo":TS(""),@"Support":@0},\
                         @{@"Title":TS("Output_Volume"),@"DetailInfo":TS(""),@"Support":@0},\
                         @{@"Title":TS("TR_Device_Image_Sensibility"),@"DetailInfo":TS(""),@"Support":@0}] mutableCopy];
    }
    
    return _dataSource;
}

- (ExtralStateCtrlConfig *)extralStateCtrlConfig{
    if (!_extralStateCtrlConfig) {
        _extralStateCtrlConfig = [[ExtralStateCtrlConfig alloc] init];
        _extralStateCtrlConfig.delegate = self;
    }
    
    return _extralStateCtrlConfig;
}

- (DevRingCtrlConfig *)devRingCtrlConfig{
    if (!_devRingCtrlConfig) {
        _devRingCtrlConfig = [[DevRingCtrlConfig alloc] init];
        _devRingCtrlConfig.delegate = self;
    }
    
    return _devRingCtrlConfig;
}

- (AudioInputConfig *)audioInputConfig{
    if (!_audioInputConfig) {
        _audioInputConfig = [[AudioInputConfig alloc] init];
        _audioInputConfig.delegate = self;
        
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        _audioInputConfig.devID = channel.deviceMac;
    }
    
    return _audioInputConfig;
}

- (AudioOutputConfig *)audioOutputConfig{
    if (!_audioOutputConfig) {
        _audioOutputConfig = [[AudioOutputConfig alloc] init];
        _audioOutputConfig.delegate = self;
        
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        _audioOutputConfig.devID = channel.deviceMac;
    }
    
    return _audioOutputConfig;
}

@end
