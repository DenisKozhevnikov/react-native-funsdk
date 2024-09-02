//
//  PlayViewController.m
//  FunSDKDemo
//
//  Created by XM on 2018/5/23.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "PlayViewController.h"
#import "DeviceConfigViewController.h"
#import "PlayBackViewController.h"
#import "MediaplayerControl.h"
#import "PlayView.h"
#import "PlayFunctionView.h"
#import "PlayMenuView.h"
#import "TalkView.h"
#import "PTZView.h"
#import "TalkBackControl.h"
#import "FishPlayControl.h"
#import "UILabelOutLined.h"
#import "DeviceManager.h"
#import "DoorBellModel.h"

#import "RealPlayControlViewController.h"
#import "DeviceAbilityManager.h"
#import "SVProgressHUD.h"
#import "UIView+Layout.h"

//双目相关
#import "DoubleEyesManager.h"
#import <Masonry/Masonry.h>
#import <FunSDK/VRSoft.h>
#import "VRGLViewController.h"
#import "XMDeviceOrientationManager.h"

#define PlayViewNumberFour [[DeviceControl getInstance] getSelectChannelArray].count == 4 ? YES : NO
#define NSNumber_Four 4

@interface PlayViewController () <MediaplayerControlDelegate,PlayViewDelegate,basePlayFunctionViewDelegate,PlayMenuViewDelegate,TalKViewDelegate,PTZViewDelegate,XMUIAlertVCDelegate,VRGLViewControllerDelegate>
{
    NSMutableArray *playViewArray;  //播放画面数组
    PlayFunctionView *toolView; // 工具栏
    PlayMenuView *playMenuView;//下方功能栏
    TalkView *talkView;//对讲功能界面
    PTZView *ptzView; //云台控制界面
    MediaplayerControl  *mediaPlayer;//播放媒体工具，
    NSMutableArray *mediaArray;//媒体播放工具数组，其中的第一个元素就是上面的mediaPlayer
    TalkBackControl *talkControl;//对讲工具
    NSMutableArray *feyeArray;//鱼眼控制数组
    int Hardandsofts;//鱼眼解码模式 4:软解 3:硬解
    int Hardmodels;//鱼眼画面模式
    int shapeType; //吸顶模式还是壁挂模式
    BOOL isFeyeYuv;//是否是鱼眼预览
    short centerOffsetX; //鱼眼偏移量参数
    short centerOffsetY;
    short imageWidth; //语言宽高参数
    short imageHeight;
    short imgradius; //鱼眼半径参数
    UILabelOutLined *timeLab;
    UILabelOutLined *nameLab;
    int hardandsoft;
    int hardmodel;
    double orginalRatio; //视频比例
    
}

//导航栏右边的设置按钮
@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;
//导航栏左边的返回按钮
@property (nonatomic, strong) UIBarButtonItem *leftBarBtn;

@property (nonatomic,assign) int msgHandle;

@property (nonatomic, assign) NSInteger focusWindowIndex;//焦点窗体

@property (nonatomic,strong) DeviceAbilityManager *deviceAbilityManager;

@property (nonatomic, strong)DoubleEyesManager *doubleEyesManager;
@property (nonatomic, strong)VRGLViewController *vrglVC;
//是否需要配置软解环境
@property (nonatomic,assign) BOOL needConfigSoftEAGLContext;
@property (nonatomic, assign) BOOL bFull; //全屏


@end

@implementation PlayViewController
{
    float doorBellRatioDetail; //门铃设备的视频比例
    BOOL fullRatio; //切换比例显示和满屏显示  YES:满屏 NO：比例显示
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgHandle = FUN_RegWnd((__bridge void*)self);
    
    //创建导航栏;
    [self setNaviStyle];
    
    //创建预览界面
    [self createPlayView];
    
    //获取要播放的设备信息
    [self initDataSource];
    
    //创建工具栏界面
    [self createToolView];
    
    //创建下方功能栏
    [self createPlayMenuView];
    
    //开始播放视频
    [self startRealPlay];
    
    //获取wifi强度和是否支持多目枪球云台定位
    [self getConfig];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartPlayAllDeviceType) name:@"ReStartPlay" object:nil];
}
// 兼容门铃的重新播放 从未激活状态进入时 需要判断设备类型 选择是否需要唤醒操作
-(void)restartPlayAllDeviceType
{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    // 如果是门铃预览 进入界面时 都唤醒一遍
    if (device.nType == XM_DEV_DOORBELL || device.nType == CZ_DOORBELL || device.nType == XM_DEV_CAT || device.nType == XM_DEV_LOW_POWER) {
        [SVProgressHUD showWithStatus:TS("device_sleep_wake_uping")];
        
        FUN_DevWakeUp(self.msgHandle, CSTR(channel.deviceMac), 0);
    }
    
}
#pragma mark - 获取wifi强度和是否支持多目枪球云台定位
-(void)getConfig{
    __weak typeof(self) wSelf = self;
  
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannelArray][self.focusWindowIndex];
    self.deviceAbilityManager.devID = channel.deviceMac;
    //获取设备能力集
    [self.deviceAbilityManager getSystemFunctionConfig:^(int result) {
        if (result>=0&&wSelf.deviceAbilityManager.supportNetWiFiSignalLevel) {
            //获取设备Wi-Fi信号强弱
            ChannelObject *channel = [[DeviceControl getInstance] getSelectChannelArray][self.focusWindowIndex];
            FUN_DevCmdGeneral(self.msgHandle, CSTR(channel.deviceMac), 1020, "WifiRouteInfo", 0, 5000, NULL, 0, -1, (int)self.focusWindowIndex);
        }
        //是否支持多目枪球云台定位
        if (result >= 0 && wSelf.deviceAbilityManager.iSupportGunBallTwoSensorPtzLocate) {
            DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: channel.deviceMac];
            dev.sysFunction.iSupportGunBallTwoSensorPtzLocate = wSelf.deviceAbilityManager.iSupportGunBallTwoSensorPtzLocate;
        }
    }];
}


- (DeviceAbilityManager *)deviceAbilityManager{
    if (!_deviceAbilityManager) {
        _deviceAbilityManager = [[DeviceAbilityManager alloc] init];
    }
    return _deviceAbilityManager;
}

- (DoubleEyesManager *)doubleEyesManager{
    if (!_doubleEyesManager) {
        _doubleEyesManager = [[DoubleEyesManager alloc] init];
    }
    return _doubleEyesManager;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - 全屏处理
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
     [self layoutWithDeviceOrientation:toInterfaceOrientation];
}

-(void)layoutWithDeviceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || \
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if (@available(iOS 16.0, *)){
            [UIView animateWithDuration:0.3 animations:^{
                PlayView *pview = [playViewArray objectAtIndex:mediaPlayer.index];
                pview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                if(dev.iSceneType == XMVR_TYPE_TWO_LENSES){
                    self.vrglVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                    [pview mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(SCREEN_HEIGHT);
                        make.width.mas_equalTo(SCREEN_WIDTH);
                        make.center.mas_equalTo(self);
                    }];
                }
                else if (orginalRatio > 0) {
                    if(SCREEN_WIDTH * orginalRatio > SCREEN_HEIGHT-20){
                        pview.frame = CGRectMake(0, 0, (SCREEN_HEIGHT-20) / orginalRatio, (SCREEN_HEIGHT-20));
                    }else{
                        pview.frame = pview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * orginalRatio);
                    }
                    pview.center = CGPointMake(SCREEN_WIDTH / 2, (SCREEN_HEIGHT-20) / 2);
                }
                //鱼眼设备
                GLKViewController *glkVC1= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                if (glkVC1 != nil) {
                    [glkVC1.view removeFromSuperview];
            
                    [[feyeArray objectAtIndex:mediaPlayer.index] createFeye:hardandsoft frameSize:pview.frame];
                    GLKViewController *glkVC= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                    [self addChildViewController:glkVC];
                    [pview addSubview:glkVC.view];
                    [[feyeArray objectAtIndex:mediaPlayer.index] refreshSoftModel:(int)hardandsoft model:hardmodel];
                }
               
            } completion:nil];
        }
        else {
            [UIView animateWithDuration:0.3 animations:^{
                PlayView *pview = [playViewArray objectAtIndex:mediaPlayer.index];
                pview.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
                if(dev.iSceneType == XMVR_TYPE_TWO_LENSES){
                    self.vrglVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                    [pview mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(SCREEN_HEIGHT);
                        make.width.mas_equalTo(SCREEN_WIDTH);
                        make.center.mas_equalTo(self);
                    }];
                }
                else if (orginalRatio > 0) {
                    if(SCREEN_HEIGHT * orginalRatio > SCREEN_WIDTH){
                        pview.frame = CGRectMake(0, 0, SCREEN_WIDTH / orginalRatio, SCREEN_WIDTH);
                    }else{
                        pview.frame = pview.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_HEIGHT * orginalRatio);
                    }
                    pview.center = CGPointMake(SCREEN_HEIGHT / 2, SCREEN_WIDTH / 2);
                }
                //鱼眼设备
                GLKViewController *glkVC1= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                if (glkVC1 != nil) {
                    [glkVC1.view removeFromSuperview];
            
                    [[feyeArray objectAtIndex:mediaPlayer.index] createFeye:hardandsoft frameSize:pview.frame];
                    GLKViewController *glkVC= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                    [self addChildViewController:glkVC];
                    [pview addSubview:glkVC.view];
                    [[feyeArray objectAtIndex:mediaPlayer.index] refreshSoftModel:(int)hardandsoft model:hardmodel];
                }
               
            } completion:nil];
        }
        toolView.hidden = YES;
        self.navigationController.navigationBar.hidden = YES;
        self.bFull = YES;
    }else{

        if (@available(iOS 16.0, *)){
            
            [UIView animateWithDuration:0.3 animations:^{
                PlayView *pview = [playViewArray objectAtIndex:mediaPlayer.index];
                pview.frame = CGRectMake(0,NavHeight, SCREEN_WIDTH, SCREEN_WIDTH *0.8);
                if(dev.iSceneType == XMVR_TYPE_TWO_LENSES){
                    //重新设置双目镜头显示方式
                    [self.vrglVC setTwoLensesDrawMode: FitScreen];
                    pview.frame = CGRectMake(0,NavHeight, SCREEN_WIDTH, SCREEN_WIDTH * orginalRatio);
                    self.vrglVC.view.frame = CGRectMake(0,0, SCREEN_WIDTH,  SCREEN_WIDTH * orginalRatio);
                    //移除约束
                    [pview mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(self.view.mas_width);
                        make.height.mas_equalTo(self.view.mas_width).multipliedBy(1.125);
                        make.top.mas_equalTo(NavHeight);
                        make.left.mas_equalTo(self);
                          
                    }];
                    NSLog(@"----%f", NavHeight);
                }
                //鱼眼设备
                GLKViewController *glkVC1= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                if (glkVC1 != nil) {
                    [glkVC1.view removeFromSuperview];
                    
                    [[feyeArray objectAtIndex:mediaPlayer.index] createFeye:hardandsoft frameSize:pview.frame];
                    GLKViewController *glkVC= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                    [self addChildViewController:glkVC];
                    [pview addSubview:glkVC.view];
                    [[feyeArray objectAtIndex:mediaPlayer.index] refreshSoftModel:(int)hardandsoft model:hardmodel];
                }

            } completion:nil];
            
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                PlayView *pview = [playViewArray objectAtIndex:mediaPlayer.index];
                pview.frame = CGRectMake(0,20 + (ScreenWidth < 400 ? 32 : 44), SCREEN_HEIGHT, SCREEN_HEIGHT *0.8);
                if(dev.iSceneType == XMVR_TYPE_TWO_LENSES){
                    pview.frame = CGRectMake(0,20 + (ScreenWidth < 400 ? 32 : 44), SCREEN_WIDTH, SCREEN_WIDTH * orginalRatio);
                    self.vrglVC.view.frame = CGRectMake(0,0, SCREEN_WIDTH,  SCREEN_WIDTH * orginalRatio);
                    //移除约束
                    [pview mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_equalTo(self.view.mas_width);
                        make.height.mas_equalTo(self.view.mas_width).multipliedBy(1.125);
                        make.top.mas_equalTo(NavHeight);
                        make.left.mas_equalTo(self);
                          
                    }];
                }
                //鱼眼设备
                GLKViewController *glkVC1= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                if (glkVC1 != nil) {
                    [glkVC1.view removeFromSuperview];
                    
                    [[feyeArray objectAtIndex:mediaPlayer.index] createFeye:hardandsoft frameSize:pview.frame];
                    GLKViewController *glkVC= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
                    [self addChildViewController:glkVC];
                    [pview addSubview:glkVC.view];
                    [[feyeArray objectAtIndex:mediaPlayer.index] refreshSoftModel:(int)hardandsoft model:hardmodel];
                }

            } completion:nil];
        }
       
        toolView.hidden = NO;
        self.navigationController.navigationBar.hidden = NO;
        self.bFull = NO;
    }
}

#pragma mark - 开始播放视频
- (void)startRealPlay {
    for (int i =0; i< playViewArray.count; i++) {
        PlayView *pView = [playViewArray objectAtIndex:i];
        [pView playViewBufferIng];
        MediaplayerControl *mediaPlayer = [mediaArray objectAtIndex:i];
        [mediaPlayer start];
    }
}
#pragma mark 切换码流
-(void)changeStreamType {
    //如果正在录像、对讲、播放音频，需要先停止这几项操作
    [self stopRecord];
    [self closeSound];
    [self stopTalk];
    //先停止预览
     [mediaPlayer stop];
    //切换主辅码流
    if (mediaPlayer.stream == 0) {
        mediaPlayer.stream = 1;
    }else if (mediaPlayer.stream == 1) {
        mediaPlayer.stream = 0;
    }
    //重新播放预览
    [mediaPlayer start];
    //刷新主辅码流显示
    [playMenuView setStreamType:mediaPlayer.stream];
}
#pragma mark - 工具栏点击 - 暂停、音频、抓图、录像
- (void)basePlayFunctionViewBtnClickWithBtn:(int)tag {
    if ((CONTROL_TYPE)tag == CONTROL_FULLREALPLAY_PAUSE) {
        //点击暂停按钮，暂停预览
        if (mediaPlayer.status == MediaPlayerStatusPlaying) {
            [mediaPlayer pause];
        }else if (mediaPlayer.status == MediaPlayerStatusPause) {
             [mediaPlayer resumue];
        }
    }if ((CONTROL_TYPE)tag == CONTROL_REALPLAY_VOICE) {
        //点击音频按钮，打开音频
        if (mediaPlayer.voice == MediaVoiceTypeNone) {
            //音频没有回调，所以直接在这里刷新界面
            [self openSound];
        }else if (mediaPlayer.voice == MediaVoiceTypeVoice){
            [self closeSound];
        }
    }if ((CONTROL_TYPE)tag == CONTROL_REALPLAY_TALK) {
        //点击对讲按钮,打开对讲
        [self presentTalkView];
    }if ((CONTROL_TYPE)tag == CONTROL_REALPLAY_SNAP) {
        //开始抓图
        [mediaPlayer snapImage];
    }if ((CONTROL_TYPE)tag == CONTROL_REALPLAY_VIDEO) {
        //开始和停止录像
        if (mediaPlayer.record == MediaRecordTypeNone) {
            [mediaPlayer startRecord];
        }else if (mediaPlayer.record == MediaRecordTypeRecording){
            [mediaPlayer stopRecord];
        }
    }
}
#pragma mark 停止录像
- (void)stopRecord {
    if (mediaPlayer.record == MediaRecordTypeNone) {
        [mediaPlayer stopRecord];
    }
}
#pragma mark 停止播放音频
- (void)closeSound {
    if (mediaPlayer.voice == MediaVoiceTypeVoice){
        [mediaPlayer closeSound];
        mediaPlayer.voice = MediaVoiceTypeNone;
        [toolView refreshFunctionView:CONTROL_REALPLAY_VOICE result:NO];
    }
}
#pragma mark 开始播放音频
- (void)openSound {
    if (mediaPlayer.voice == MediaVoiceTypeNone){
        [mediaPlayer openSound:100];
        mediaPlayer.voice = MediaVoiceTypeVoice;
        [toolView refreshFunctionView:CONTROL_REALPLAY_VOICE result:YES];
    }
}

#pragma mark - 开始预览结果回调
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startResult:(int)result DSSResult:(int)dssResult {
    if (result < 0) {
        if (result == EE_DVR_PASSWORD_NOT_VALID || result == -11318 || result == EE_DVR_LOGIN_USER_NOEXIST) //密码错误，弹出密码修改框
        {
            [SVProgressHUD dismiss];
            ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
            DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
            
            
            int tag = result;
            int errorResult = dssResult;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                int tagDeal = errorResult  == EE_DVR_PASSWORD_NOT_VALID?tag + 1000:tag;
                
                //弹出密码输入框
                [UIView showUserOrPasswordErrorTips:errorResult delegate:self presentedVC:self tag:tagDeal devID:mediaPlayer.devID changePwd:NO];
            });
            
            return;
        }
        [MessageUI ShowErrorInt:result];
    }else {
        if (dssResult == XM_NET_TYPE_DSS) { //DSS 打开视频成功
            
        }else if (dssResult == XM_NET_TYPE_RPS){//RPS打开预览成功
             
         }
        PlayView *pview = [playViewArray objectAtIndex:mediaPlayer.index];
        [pview playViewBufferIng];
        
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        if (devObject.nType == XM_DEV_DOORBELL || devObject.nType == XM_DEV_CAT || devObject.nType == CZ_DOORBELL || devObject.nType == XM_DEV_INTELLIGENT_LOCK || devObject.nType == XM_DEV_DOORBELL_A || devObject.nType == XM_DEV_DOORLOCK_V2) {
            // 开始开启设备信息主动上报
            [[DoorBellModel shareInstance] beginUploadData:channel.deviceMac];
            // 设备信息上报回调
            [DoorBellModel shareInstance].DevUploadDataCallBack = ^(NSDictionary *state, NSString *devMac) {
                // state 个字段表示的意思
                //                    DevStorageStatus 表示存储状态： -2：设备存储未知 -1：存储设备被拔出 0：没有存储设备 1：有存储设备 2：存储设备插入
                //                    electable 表示充电状态：0：未充电 1：正在充电 2：电充满 3：未知（表示各数据不准确）
                //                    freecapacity = 0;
                //                    percent = "-1";
                
                NSLog(@"DoorBellModel %@",state);
            };
        }
    }
}

#pragma mark - 视频缓冲中
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer buffering:(BOOL)isBuffering ratioDetail:(double)ratioDetail{
        PlayView *pview = [playViewArray objectAtIndex:mediaPlayer.index];
    if (isBuffering == YES) {//开始缓冲
        [pview playViewBufferIng];
        
    }else{//缓冲完成
        // 预览开始时抓张设备缩略图 当背景
        DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
        doorBellRatioDetail = ratioDetail;
        
        orginalRatio = ratioDetail;
        NSString* thumbnailPathName = [NSString devThumbnailFile:mediaPlayer.devID andChannle:0];
        FUN_MediaGetThumbnail(mediaPlayer.player, thumbnailPathName.UTF8String,1);
        [pview playViewBufferEnd];
        //判断设备长宽以及 是否是一路码流上下分屏
        if(dev.imageWidth != 0 && dev.imageHeight != 0 && dev.iSceneType == XMVR_TYPE_TWO_LENSES){
            [self mediaId: mediaPlayer.devID codecType: dev.iCodecType scene: dev.iSceneType];
        }
        
    }
}

#pragma mark 收到暂停播放结果消息
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer pauseOrResumeResult:(int)result {
    if (result == 2) { //暂停预览
        mediaPlayer.status = MediaPlayerStatusPause;
        [toolView refreshFunctionView:CONTROL_FULLREALPLAY_PAUSE result:YES];
    }else if (result == 1){ //恢复预览
        mediaPlayer.status = MediaPlayerStatusPlaying;
         [toolView refreshFunctionView:CONTROL_FULLREALPLAY_PAUSE result:NO];
    }
}
#pragma mark - 录像开始结果
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startRecordResult:(int)result path:(NSString*)path {
     if (result == EE_OK) { //开始录像成功
         mediaPlayer.record = MediaRecordTypeRecording;
         [toolView refreshFunctionView:CONTROL_REALPLAY_VIDEO result:YES];
     }else{
         [MessageUI ShowErrorInt:result];
         [toolView refreshFunctionView:CONTROL_REALPLAY_VIDEO result:NO];
     }
}
#pragma mark - 录像结束结果
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer stopRecordResult:(int)result path:(NSString*)path {
    if (result == EE_OK) { //结束录像成功
        [SVProgressHUD showSuccessWithStatus:TS("Success") duration:2.0];
    }else{
        [MessageUI ShowErrorInt:result];
    }
     [toolView refreshFunctionView:CONTROL_REALPLAY_VIDEO result:NO];
    mediaPlayer.record = MediaRecordTypeNone;
}

#pragma mark 抓图结果
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer snapImagePath:(NSString *)path result:(int)result {
    if (result == EE_OK) { //抓图成功
        [SVProgressHUD showSuccessWithStatus:TS("Success") duration:2.0];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

#pragma mark 设备抓图结果
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer storeSnapresult:(int)result {
    if (result >=0 ) { //抓图成功
        [SVProgressHUD showSuccessWithStatus:TS("Success") duration:2.0];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}
#pragma mark 收到视频宽高比信息
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer width:(int)width htight:(int)height {
    NSLog(@"width = %d; height = %d",width, height);
    DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
    dev.imageWidth = width;
    dev.imageHeight = height;
}
#pragma mark -鱼眼视频预览相关处理 （非鱼眼设备可以不用考虑下列几个方法）
UIPinchGestureRecognizer *twoFingerPinch;//硬解码捏合手势
#pragma mark 用户自定义信息帧回调，通过这个判断是什么模式在预览
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer Hardandsoft:(int)Hardandsoft Hardmodel:(int)Hardmodel {
    //一路码流双目
    if(Hardmodel == XMVR_TYPE_TWO_LENSES){
       // 取消隐藏
        playMenuView.btnFull.hidden = NO;
        DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
        //存储 设备的软硬解码以及场景
        dev.iCodecType = Hardandsoft;
        dev.iSceneType = Hardmodel;
        //播放界面布局
        PlayView *pview = [playViewArray objectAtIndex:mediaPlayer.index];
        pview.frame = CGRectMake(0,0, SCREEN_WIDTH,  SCREEN_WIDTH * 1.125);
        self.vrglVC.view.frame = CGRectMake(0,0, SCREEN_WIDTH,  SCREEN_WIDTH * 1.125);
        [pview addSubview: self.vrglVC.view ];
        // 在mediavc 中也存储软硬解码方式以及场景
        self.vrglVC.iCodecType = Hardandsoft;
        self.vrglVC.iSceneType = Hardmodel;
        self.vrglVC.hwRatio = 1.125;
        [pview mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.view.mas_width);
            make.height.mas_equalTo(self.view.mas_width).multipliedBy(1.125);
            make.top.mas_equalTo(NavHeight);
            make.left.mas_equalTo(self);
        }];
        //codec配置
        [self mediaId:mediaPlayer.devID codecType:Hardandsoft scene:Hardmodel];
        //预览界面工具栏等重新布局
        [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(NavAndStatusHight + realPlayViewHeight * 1.125 + 100);
            make.centerX.mas_equalTo(self);
            make.height.mas_equalTo(ToolViewHeight);
            make.width.mas_equalTo(ScreenWidth);
        }];
        float height = (ScreenHeight - NavHeight - realPlayViewHeight - ToolViewHeight);
        [playMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(NavAndStatusHight + realPlayViewHeight * 1.125 + 140);
            make.centerX.mas_equalTo(self);
            make.height.mas_equalTo(height);
            make.width.mas_equalTo(ScreenWidth);
        }];
    }
   else if (Hardandsoft == 3 || Hardandsoft == 4 || Hardandsoft == 5) {
        //创建鱼眼预览界面
        [self mediaPlayer:mediaPlayer createFeye:Hardandsoft Hardmodel:Hardmodel];
    }
}
#pragma mark YUV数据回调
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer width:(int)width height:(int)height pYUV:(unsigned char *)pYUV {
    DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
    if(dev.iSceneType == XMVR_TYPE_TWO_LENSES){
        [self.vrglVC PushData:width height:height YUVData:pYUV];
    }
    else [[feyeArray objectAtIndex:mediaPlayer.index]  PushData:width height:height YUVData:pYUV];
}
#pragma mark - 设备时间（鱼眼）
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer DevTime:(NSString *)time {
        [[feyeArray objectAtIndex:mediaPlayer.index] setTimeLabelText:time];
}
#pragma mark 鱼眼软解坐标参数
-(void)centerOffSetX:(MediaplayerControl*)mediaPlayer  offSetx:(short)OffSetx offY:(short)OffSetY  radius:(short)radius width:(short)width height:(short)height {
    DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
    //潘偏移量
    dev.centerOffsetX = OffSetx;
    dev.centerOffsetY = OffSetY;
    //半径
    dev.imgradius = radius;
    if(width > 0){
        dev.imageWidth = width;
    }
    if(height > 0){
        dev.imageHeight = height;
    }
    [[feyeArray objectAtIndex:mediaPlayer.index] centerOffSetX:OffSetx offY:OffSetY radius:radius width:width height:height];
}
#pragma mark 鱼眼画面智能分析报警自动旋转画面
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer AnalyzelLength:(int)length site:(int)type Analyzel:(char*)area {
    
}

#pragma mark 鱼眼codec配置
-(void)mediaId:(NSString *)devID codecType:(int)codec scene:(int)scene{
    
    DeviceObject *devInfo = [[DeviceControl getInstance] GetDeviceObjectBySN: devID];
    
        if(codec == 4 && scene == XMVR_TYPE_TWO_LENSES) {
        //如果收到信息帧，那么则需要配置EAGLContext
            if(self.needConfigSoftEAGLContext){
                //防止频繁初始化
                self.needConfigSoftEAGLContext = NO;
                //初始化
                [self.vrglVC configSoftEAGLContext];
            }
            //如果是SDK处理双目画中画
            [self.vrglVC setVRType:XMVR_TYPE_TWO_LENSES_IN_ONE];
        }
        
        if (devInfo.imageWidth != 0 && devInfo.imageHeight != 0) {
            int height = scene == XMVR_TYPE_TWO_LENSES?devInfo.imageHeight * 0.5 : devInfo.imageHeight;
            int offsetX = scene == XMVR_TYPE_TWO_LENSES?devInfo.imageWidth * 0.5 : devInfo.centerOffsetX;
            int offsetY = scene == XMVR_TYPE_TWO_LENSES?devInfo.imageHeight * 0.5 : devInfo.centerOffsetY;
            int iImgradius = scene == XMVR_TYPE_TWO_LENSES?devInfo.imageWidth * 0.5 : devInfo.imgradius;
            NSLog(@"%d %d", devInfo.imageWidth, devInfo.imageHeight);
            //设置镜头偏移参数
            [self.vrglVC setVRFecParams:offsetX yCenter:offsetY radius:iImgradius Width:devInfo.imageWidth Height:height];
        }
        
        if(scene == XMVR_TYPE_TWO_LENSES){
            //获取当前双目模式
            XMTwoLensesScreen model = [self.vrglVC getVRSoftTwoLensesScreen];
            if(model == XMTWOLENSESSCREEN_END){
                //设置双目镜头显示方式
                [self.vrglVC setTwoLensesDrawMode:FitScreen];
            }
            //全屏模式下的镜头切换
            if(self.bFull && model != XMTWOLENSESSCREEN_END && model != TwoLensesScreenDouble){
                [self.vrglVC setVRSoftTwoLensesScreen:model];
            }
        }
      
}

#pragma mark - 预览对象初始化
- (void)initDataSource {
    if (mediaArray == nil) {
        mediaArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (feyeArray == nil) {
        feyeArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (PlayViewNumberFour) {
        //4画面播放
        for (int i =0; i< NSNumber_Four; i++) {
            //选择播放的通道信息
            ChannelObject *channel = [[[DeviceControl getInstance] getSelectChannelArray] objectAtIndex:i];
            if (mediaPlayer == nil) { //第一个默认通道控制工具
                mediaPlayer = [[MediaplayerControl alloc] init];
                mediaPlayer.devID = channel.deviceMac;//设备序列号
                mediaPlayer.channel = channel.channelNumber;//当前通道号
                mediaPlayer.stream = 1;//辅码流
                mediaPlayer.renderWnd = [playViewArray objectAtIndex:i];
                mediaPlayer.delegate = self;
                mediaPlayer.index = i;
                [mediaArray addObject:mediaPlayer];
                //初始化对讲工具，这个可以放在对讲开始前初始化
                talkControl = [[TalkBackControl alloc] init];
                talkControl.deviceMac = mediaPlayer.devID;
                talkControl.channel = mediaPlayer.channel;
            }else{ //4通道播放的后面3个通道控制k工具初始化
                MediaplayerControl *Player = [[MediaplayerControl alloc] init];
                Player.devID = channel.deviceMac;//设备序列号
                Player.channel = channel.channelNumber;//当前通道号
                Player.stream = 1;//辅码流
                Player.renderWnd = [playViewArray objectAtIndex:i];
                Player.delegate = self;
                Player.index = i;
                [mediaArray addObject:Player];
            }
            //鱼眼工具，非全景设备用不到这个
            FishPlayControl *feyeControl = [[FishPlayControl alloc] init];
            [feyeArray addObject:feyeControl];
        }
    }else{ //单通道播放初始化
        //选择播放的通道信息
        ChannelObject *channel = [[[DeviceControl getInstance] getSelectChannelArray] firstObject];
        mediaPlayer = [[MediaplayerControl alloc] init];
        mediaPlayer.devID = channel.deviceMac;//设备序列号
        mediaPlayer.channel = channel.channelNumber;//当前通道号
        mediaPlayer.stream = 1;//辅码流
        mediaPlayer.renderWnd = [playViewArray objectAtIndex:0];
        mediaPlayer.delegate = self;
        [mediaArray addObject:mediaPlayer];
        //初始化对讲工具，这个可以放在对讲开始前初始化
        talkControl = [[TalkBackControl alloc] init];
        talkControl.deviceMac = mediaPlayer.devID;
        talkControl.channel = mediaPlayer.channel;
        //鱼眼工具，非全景设备用不到这个
        FishPlayControl *feyeControl = [[FishPlayControl alloc] init];
        [feyeArray addObject:feyeControl];
    }
    self.needConfigSoftEAGLContext = YES;
}

#pragma mark - 界面初始化
- (void)createPlayView {
    if (playViewArray == nil) {
        playViewArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (PlayViewNumberFour) {
        //4通道播放
        for (int i =0; i< NSNumber_Four; i++) {
            float width = ScreenWidth/2.0;
            float height = realPlayViewHeight/2.0;
            float x = i%2 * width;
            float y = NavAndStatusHight;
            if (i > 1) {
                y = NavAndStatusHight + height;
            }
            PlayView *pView = [[PlayView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            pView.playViewDelegate = self;
            [self.view addSubview:pView];
            [pView refreshView:i];
            [playViewArray addObject:pView];
        }
    }else{
        //单通道播放
        PlayView *pView = [[PlayView alloc] initWithFrame:CGRectMake(0, NavAndStatusHight, ScreenWidth, realPlayViewHeight)];
        pView.playViewDelegate = self;
        NSLog(@"NavAndStatusHight = %f",realPlayViewHeight);
        [self.view addSubview:pView];
        pView.activityView.center = pView.center;
        [playViewArray addObject:pView];
    }
    [self setSelectPlayView];
}

-(void)PlayViewSelected:(int)tag {
    if ([[DeviceControl getInstance] getSelectChannelArray].count > tag) {
        self.focusWindowIndex = tag;
        [[DeviceControl getInstance] setSelectChannelIndex:tag];
        if (mediaArray.count > tag) {
            mediaPlayer = mediaArray[tag];
        }
        [self setSelectPlayView];
    }
}

- (void)setSelectPlayView {
    if (PlayViewNumberFour) {
        ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
        for (int i =0; i< playViewArray.count; i++) {
            PlayView *pView = [playViewArray objectAtIndex:i];
            BOOL select =  i == channel.channelNumber ? YES : NO;
            [pView setFrameColor:select];
        }
    }else{
        PlayView *pView = [playViewArray firstObject];
        [pView setFrameColor:YES];
    }
}

- (void)setNaviStyle {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = TS("Real_Time_Video");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    self.rightBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Local_Settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushToDeviceConfigViewController)];
    self.navigationItem.rightBarButtonItem = self.rightBarBtn;
    self.rightBarBtn.width = 15;
    
    self.leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = self.leftBarBtn;
}

#pragma mark - 创建工具栏
-(void)createToolView{
    if (!toolView) {
        toolView = [[PlayFunctionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ToolViewHeight)];
        toolView.Devicedelegate = self;
    }
    toolView.hidden = NO;
    toolView.playMode = REALPLAY_MODE;
    toolView.screenVertical = YES;
    [toolView showPlayFunctionView];
    toolView.frame = CGRectMake(0, NavAndStatusHight+ realPlayViewHeight, ScreenWidth, ToolViewHeight);
    [self.view addSubview:toolView];
    [toolView setPlayMode:REALPLAY_MODE];
}

-(void)createPlayMenuView {
    if (!playMenuView) {
        playMenuView = [[PlayMenuView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ToolViewHeight)];
        playMenuView.delegate = self;
    }
    float height = (ScreenHeight - NavHeight - realPlayViewHeight - ToolViewHeight);
    playMenuView.frame = CGRectMake(0, NavAndStatusHight+ realPlayViewHeight +ToolViewHeight + 50, ScreenWidth, height);
    [self.view addSubview:playMenuView];
}
#pragma mark 初始化鱼眼播放界面
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer createFeye:(int)Hardandsoft Hardmodel:(int)Hardmodel{
    PlayView *pView = [playViewArray objectAtIndex:mediaPlayer.index];
    [[feyeArray objectAtIndex:mediaPlayer.index] createFeye:Hardandsoft frameSize:pView.frame];
    GLKViewController *glkVC= [[feyeArray objectAtIndex:mediaPlayer.index] getFeyeViewController];
    [self addChildViewController:glkVC];
    [pView addSubview:glkVC.view];
    hardandsoft = Hardandsoft;
    hardmodel = Hardmodel;
    [[feyeArray objectAtIndex:mediaPlayer.index] refreshSoftModel:(int)Hardandsoft model:Hardmodel];
}


#pragma mark - 跳转到设备配置界面
- (void)pushToDeviceConfigViewController {
    [mediaPlayer stop];
    DeviceConfigViewController *devConfigVC = [[DeviceConfigViewController alloc] init];
    [self.navigationController pushViewController:devConfigVC animated:YES];
}

#pragma mark - 显示云台控制器
-(void)showPTZControl{
    if (ptzView == nil) {
        ptzView = [[PTZView alloc] initWithFrame:CGRectMake(0, ScreenHeight-150, ScreenWidth, 150)];
        ptzView.PTZdelegate = self;
        ptzView.speedDelegate = self;
    }
    [self.view addSubview:ptzView];
}
#pragma mark  显示对讲画面
-(void)presentTalkView{
    if (talkView == nil) {
        talkView = [[TalkView alloc]init];
        talkView.frame = CGRectMake(0, ScreenHeight - 150 , ScreenWidth, 180);
        talkView.delegate = self;
        [self.view addSubview:talkView];
        [talkView showTheView];
        [toolView refreshFunctionView:CONTROL_REALPLAY_TALK result:YES];
    }else{
        [talkView cannelTheView];
        [self closeTalkView];
    }
}
#pragma mark - 云台控制按钮的代理  云台控制方法没有回调
//方向控制点击
-(void)controlPTZBtnTouchDownAction:(int)sender{
    [mediaPlayer controZStartlPTAction:(PTZ_ControlType)sender];
}
//方向控制抬起
-(void)controlPTZBtnTouchUpInsideAction:(int)sender{
    [mediaPlayer controZStopIPTAction:(PTZ_ControlType)sender];
}
//点击控制的按钮(变倍，变焦，光圈)
-(void)controladdSpeedTouchDownAction:(int)sender{
    [mediaPlayer controZStartlPTAction:(PTZ_ControlType)sender];
}
//抬起控制的按钮(变倍，变焦，光圈)
-(void)controladdSpeedTouchUpInsideAction:(int)sender{
   [mediaPlayer controZStopIPTAction:(PTZ_ControlType)sender];
}

#pragma - mark - 语音对讲按钮代理 (对讲和双向对讲同时只能打开一个)
- (void)openTalk {
   talkControl.handle = mediaPlayer.msgHandle;
//    talkControl.pitchSemiTonesType = talkView.talkSoundType;
    [talkControl startTalk];
    [toolView refreshFunctionView:CONTROL_REALPLAY_VOICE result:NO];
}
- (void)closeTalk {
    talkControl.handle = mediaPlayer.msgHandle;
    [talkControl pauseTalk];
    [toolView refreshFunctionView:CONTROL_REALPLAY_VOICE result:YES];
}
#pragma - mark 开始双向对讲  (单向对讲和双向对讲同时只能打开一个) (双向对讲最好做一下手机端的回音消除工作     demo中并没有做这个)
- (void)startDouTalk {
//    talkControl.pitchSemiTonesType = talkView.talkSoundType;
    [talkControl startDouTalk:YES];
    [toolView refreshFunctionView:CONTROL_REALPLAY_VOICE result:YES];
}
//结束双向对讲
- (void)stopDouTalk {
    [talkControl stopDouTalk];
    [toolView refreshFunctionView:CONTROL_REALPLAY_VOICE result:NO];
}

#pragma mark  停止对讲
- (void)stopTalk {
    //停止对讲
    [talkControl closeTalk];
    if (talkView) {
        [talkView cannelTheView];
    }
}
#pragma mark 隐藏对讲画面
-(void)closeTalkView {
    //停止对讲
    talkControl.handle = mediaPlayer.msgHandle;
    [talkControl closeTalk];
    [toolView refreshFunctionView:CONTROL_REALPLAY_TALK result:NO];
    [toolView refreshFunctionView:CONTROL_REALPLAY_VOICE result:NO];
    talkView = nil;
}
#pragma mark - 跳转到视频回放界面
-(void)presentPlayBackViewController {
    
    [talkControl closeTalk]; //停止对讲
    [mediaPlayer closeSound]; //停止音频
    [mediaPlayer stop];
    
    PlayBackViewController *playBack = [[PlayBackViewController alloc] init];
    [self.navigationController pushViewController:playBack animated:YES];
}

#pragma mark - 打开预览，获取视频YUV数据进行处理
- (void)playYUVBtnClick {
    //第一个通道返回YUV数据
    [[playViewArray objectAtIndex:0] playViewBufferIng];
    //开始获取YUV数据回调
    [[mediaArray objectAtIndex:0] startYUVBack];
}

#pragma mark - 跳转到控制view
-(void)changeToControlVC
{
    //现获取配置看下支不支持
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevGetConfig_Json(self.msgHandle, [channel.deviceMac UTF8String], "SystemFunction", 1024,-1,5000,0);
    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeNone];
}
#pragma mark - 调用设备抓图
- (void)storeSnapEvent {
    [SVProgressHUD show];
    [mediaPlayer StoreSnap];
}

#pragma mark - 调用走廊模式
- (void)corridorModelEvent {
    PlayView *pView = [playViewArray objectAtIndex:0];
    CGPoint point = pView.center;
    
    if (fullRatio) {
        [pView setFrame:CGRectMake(0, NavAndStatusHight, ScreenWidth, realPlayViewHeight)];
        [pView setCenter:point];
        fullRatio = NO;
    }
    else
    {
        if (doorBellRatioDetail>1) {
            [pView setFrame:CGRectMake(0, NavAndStatusHight, ScreenWidth*1/doorBellRatioDetail, realPlayViewHeight)];
            [pView setCenter:point];
            fullRatio = YES;
        }
        else
        {
            [pView setFrame:CGRectMake(0, NavAndStatusHight, ScreenWidth, realPlayViewHeight*doorBellRatioDetail)];
            [pView setCenter:point];
            fullRatio = YES;
        }
    }
    
    
    
}


#pragma mark - 返回设备列表界面
- (void)popViewController {
    // 停止设备主动上报
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    [[DoorBellModel shareInstance] beginStopUploadData:devObject.deviceMac];
    [talkControl closeTalk]; //停止对讲
    [mediaPlayer closeSound]; //停止音频
    [mediaPlayer stop];
    [[DeviceControl getInstance] cleanSelectChannel];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)xmAlertVCClickIndex:(int)index tag:(int)tag content:(NSString *)content msg:(NSString *)msg name:(NSString *)name{
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    
    if (index == 0) {
        //取消输入密码，返回设备列表
        [self popViewController];
    }else if (index == 1){
        if (content.length > 64) {
            content = [content substringToIndex:64];
        }
        
        devObject.loginName = name;
        
        //修改设备名称和设备密码
        [[DeviceManager getInstance] changeDevicePsw:devObject.deviceMac loginName:devObject.loginName password:content];
        //重新播放预览
        [mediaPlayer start];
    }
}

//MARK: 一路码流上下分屏设备指哪看哪功能
- (void)vrglViewController:(CGPoint)point firstPoint:(CGPoint)firstPoint{
    // 播放状态才能使用该功能
    if(mediaPlayer.status != MediaPlayerStatusPlaying) return;
    //判断下 如果触摸开始到离开 位置移动操作5就不算点击
    if (abs((int)(firstPoint.x - point.x)) < 5 && abs((int)(firstPoint.y - point.y)) < 5) {
        NSString *devID = mediaPlayer.devID;
        DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN:devID];
        if (dev.sysFunction.iSupportGunBallTwoSensorPtzLocate == 1 && dev.iSceneType == XMVR_TYPE_TWO_LENSES){
            CGRect rect;
            BOOL needSetPTZ = NO;
            //用于判断用户点击的是哪一分屏
            if (self.bFull){
                if (point.x < self.vrglVC.view.frame.size.width * 0.5 && [self.vrglVC getVRSoftTwoLensesScreen] == TwoLensesScreenDouble){
                    float remain = self.vrglVC.view.frame.size.height - SCREEN_WIDTH * 0.5 * 9 /16.0;
                    float legalY1 = remain * 0.5;
                    float legalY2 = remain * 0.5 + SCREEN_WIDTH * 0.5 * 9 /16.0;
                    if (point.y >= legalY1 && point.y <= legalY2){
                        rect = CGRectMake(0, 0, SCREEN_WIDTH * 0.5, SCREEN_WIDTH * 0.5 * 9 /16.0);
                        point.y = point.y - legalY1;
                        needSetPTZ = YES;
                    }
                }
            }
           else if (point.y < self.vrglVC.view.frame.size.height * 0.5){
                    rect = self.vrglVC.view.bounds;
                    rect = CGRectMake(0, 0, rect.size.width, rect.size.height * 0.5);
                    needSetPTZ = YES;
            }
            
            if (needSetPTZ){
                CGPoint center = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);
                int x = point.x - center.x;
                int y = point.y - center.y;
                x = x / (rect.size.width * 0.5) * 4096;
                y = y / (rect.size.height * 0.5) * 4096;
                float scale = 1;//画中画默认就是1倍
                //Y轴坐标系反转 和设备端统一为左手正螺旋坐标系
                y = -y;
                //分享设备 不支持的 不滑动
                if (dev.ret && !dev.sysFunction.SupportPTZTour) {
                }else{
                    [self.doubleEyesManager requestSetPTZDeviceID:devID channel:-1 xOffset:x yOffset:y zoomScale:scale - 1 completed:^(int result) {
                        
                    }];
                }
            }
        }
    }
}

//MARK: - 全屏按钮
- (void)fullScreenEvent{
    // 根据设备方向重新布局
    [XMDeviceOrientationManager deviceOrientationPortraitAndUpsideDownSwitching];
    self.bFull = YES;
}

//MARK: - 双目全屏双击显示单画面
- (void)vrglViewControllerDoubleClicked:(CGPoint)point{
    DeviceObject *devInfo = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
    if(devInfo.iSceneType == XMVR_TYPE_TWO_LENSES ){//如果是上下分屏的设备 全屏且1分屏时支持切换模式
        if(self.bFull){
            if(self.vrglVC.view.transform.a != 1){
                self.vrglVC.view.transform = CGAffineTransformIdentity;
            }
            //双镜头
            if([self.vrglVC getVRSoftTwoLensesScreen] == TwoLensesScreenDouble){
                if(point.x <= SCREEN_WIDTH * 0.5){
                    //显示左边镜头
                    [self.vrglVC setVRSoftTwoLensesScreen:TwoLensesScreenLeft];
                }else{
                    //右边
                    [self.vrglVC setVRSoftTwoLensesScreen:TwoLensesScreenRight];
                }
            }else if([self.vrglVC getVRSoftTwoLensesScreen] == TwoLensesScreenLeft ||
                     [self.vrglVC getVRSoftTwoLensesScreen] == TwoLensesScreenRight){
                //回到双镜头
                [self.vrglVC setVRSoftTwoLensesScreen:TwoLensesScreenDouble];
            }
        }
        return;
    }
}


-(void)OnFunSDKResult:(NSNumber *) pParam{
NSInteger nAddr = [pParam integerValue];
MsgContent *msg = (MsgContent *)nAddr;

switch (msg->id) {
    case EMSG_DEV_WAKE_UP:
    {
        [SVProgressHUD dismiss];
        if (msg->param1 >= 0) {
            if (msg->seq == 0 || msg->seq == 1) {
                [self startRealPlay];
            }
        }
        else
        {
            if (msg->seq == 0) {
                ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
                FUN_DevWakeUp(self.msgHandle, CSTR(channel.deviceMac), 1);
            }
            else if (msg->seq == 1)
            {
                //如果两次都失败了就直接播放
                [self startRealPlay];
            }
        }
    }
        break;
        case EMSG_DEV_GET_CONFIG_JSON:{
            if (msg->param1 <0) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%i",(int)msg->param1]];
            }
            else
            {
                [SVProgressHUD dismiss];
                if (msg->pObject == nil) {
                    return;
                }
                SDK_CameraParam *pParam = (SDK_CameraParam *)msg->pObject;
                
                NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data == nil )
                    break;
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ( appData == nil) {
                    break;
                }
                NSString* strConfigName = appData[@"Name"];
                
                
                if([strConfigName containsString:@"SystemFunction"])
                {
                    NSLog(@"OtherFunction");
                    
                    BOOL remoteCtrl = [appData[@"SystemFunction"][@"OtherFunction"][@"SupportSysRemoteCtrl"] boolValue];
                    
                    //支持远程控制
                    if (remoteCtrl)
                    {
                        ChannelObject *channel =  [[DeviceControl getInstance] getSelectChannel];
                        
                        RealPlayControlViewController *vc = [[RealPlayControlViewController alloc]init];
                        vc.devMac = channel.deviceMac;
                        vc.allChannelNum = (int)[[DeviceControl getInstance] getSelectChannelIndex];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:TS("TR_Not_Support_Function") duration:1.5];
                    }
                }
                
            }
        }
            break;
    case EMSG_DEV_CMD_EN:
    {
        if ([OCSTR(msg->szStr) isEqualToString:@"WifiRouteInfo"]) {
            ChannelObject *channel = [[DeviceControl getInstance] getSelectChannelArray][self.focusWindowIndex];
            
            DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
         
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    return;
                }
                NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                
                NSError *error;
                NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                if (!retDic) {
                    return;
                }
                
                NSDictionary *dicInfo = [retDic objectForKey:@"WifiRouteInfo"];
                if ((([[dicInfo objectForKey:@"WlanStatus"] boolValue] && [dicInfo objectForKey:@"WlanStatus"]) && (![[dicInfo objectForKey:@"Eth0Status"] boolValue] && [dicInfo objectForKey:@"Eth0Status"])) || ![dicInfo objectForKey:@"WlanStatus"]){
                    PlayView *pView = [playViewArray objectAtIndex:self.focusWindowIndex];
                    [pView bringSubviewToFront:pView.wifiStatus];
                    pView.wifiStatus.hidden = NO;
                    NSInteger wifiStatus = [retDic[@"WifiRouteInfo"][@"SignalLevel"] integerValue];
                    if (wifiStatus >= 80) {
                        pView.wifiStatus.image = [UIImage imageNamed:@"network_4"];
                    }else if (wifiStatus >= 60) {
                        pView.wifiStatus.image = [UIImage imageNamed:@"network_3"];
                    }else if (wifiStatus >= 40) {
                        pView.wifiStatus.image = [UIImage imageNamed:@"network_2"];
                    }else if (wifiStatus >= 5) {
                        pView.wifiStatus.image = [UIImage imageNamed:@"network_1"];
                    }else if (wifiStatus >= 0) {
                        pView.wifiStatus.image = [UIImage imageNamed:@"none"];
                    }
                }
            }
            return;
        }
    }
        break;
        
        default:
                    break;
    }
}



-(VRGLViewController *)vrglVC{
    if (!_vrglVC) {
        _vrglVC = [[VRGLViewController alloc] init];
        _vrglVC.vrglViewControllerDelegateDelegate = self;
    }
    return _vrglVC;
}
@end

