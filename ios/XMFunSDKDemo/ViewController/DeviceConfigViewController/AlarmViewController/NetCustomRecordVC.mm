//
//  NetCustomRecordVC.m
//  XWorld_General
//
//  Created by Megatron on 2019/12/27.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "NetCustomRecordVC.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"
#import "TTSManager.h"
#import <AVFoundation/AVFoundation.h>
#import "Record.h"
#import "NSString+DTPaths.h"
#import "FunSDK/FunSDK.h"
#import "PCMDataPlayer.h"

typedef enum CustomRecordingStatus
{
    CustomRecordingStatusNone,
    CustomRecordingStatusRecord,
    CustomRecordingStatusFinish
}CustomRecordingStatus;

@interface NetCustomRecordVC () <UITextFieldDelegate,AVAudioPlayerDelegate>

@property (nonatomic,assign) int msgHandle;
//文件上传句柄
@property (nonatomic,assign) int fileUploadHandle;
//总共需要上传的文件个数
@property (nonatomic,assign) int fileTotalNum;
//当前需要传的文件序号
@property (nonatomic,assign) int curNeedUploadFileIndex;
@property (nonatomic,strong) NSFileHandle *fileHandle;
// 单个文件的大小
@property (nonatomic,assign) int singleSize;
// 文件总大小
@property (nonatomic,assign) long long fileSize;

//选择文字转语音还是录音
@property (nonatomic,strong) UISegmentedControl *segmentCtrl;
//是否需要显示文字转语音
@property (nonatomic,assign) BOOL needTTS;
//文字转语音界面
@property (nonatomic,strong) UIView *ttsView;
//文字输入框
@property (nonatomic,strong) UITextField *tfContent;
//男女声选择按钮
@property (nonatomic,strong) UIButton *btnMale;
@property (nonatomic,strong) UIButton *btnFemale;
//文字转语音管理者
@property (nonatomic,strong) TTSManager *ttsManager;
//文字转语音是否成功
@property (nonatomic,assign) BOOL ttsSuccess;

//录音界面
@property (nonatomic,strong) UIView *recordView;
//录音按钮
@property (nonatomic,strong) UIButton *btnRecord;
//录音时间
@property (nonatomic,strong) UILabel *lbTime;
//录音提示
@property (nonatomic,strong) UILabel *lbRecordTip;
//是否有录音
@property (nonatomic,assign) BOOL recordBefore;
//当前录音状态
@property (nonatomic,assign) CustomRecordingStatus recordStatus;
//录音的总时间
@property (nonatomic,assign) int recordTotalTime;
//录音播放时间计时器
@property (nonatomic,strong) NSTimer *recordPlayTimer;
//录音播放当前时间
@property (nonatomic,assign) int recordPlayCurTime;
//是否正在播放
@property (nonatomic,assign) BOOL ifPlayingRecord;

//音频处理
@property(nonatomic,strong) AVAudioSession *session;
//录音文件路径
@property(nonatomic,copy) NSString *tmpFile;
@property(nonatomic,strong) NSURL *tmpUrl;
//录音时间
@property (nonatomic,assign) int sec;
//录音计时器
@property (nonatomic,strong) NSTimer *timer;
//录音器
@property(nonatomic,strong) AVAudioRecorder *recorder;
//录音播放器
@property(nonatomic,strong) AVAudioPlayer *player;

//试听按钮
@property (nonatomic,strong) UIButton *btnListen;
//上传按钮
@property (nonatomic,strong) UIButton *btnUpload;

//存储临时文字内容
@property (nonatomic,copy) NSString *lastLegalContent;

@end

@implementation NetCustomRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.msgHandle = FUN_RegWnd((__bridge void*)self);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNav];
    
    //判断APP语言 中文情况下才显示文字转语音
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"zh-Hans"]) {
        self.needTTS = YES;
    }
    
    if (self.needTTS) {
        [self.view addSubview:self.ttsView];
        [self.view addSubview:self.recordView];
        [self.view addSubview:self.btnListen];
        [self.view addSubview:self.btnUpload];
        [self.view addSubview:self.segmentCtrl];
        
        self.segmentCtrl.selectedSegmentIndex = 0;
        self.recordView.hidden = YES;
        
        [self.btnListen mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).multipliedBy(0.9);
            make.bottom.equalTo(self.btnUpload.mas_top).mas_offset(-20);
            make.centerX.equalTo(self.view);
            make.height.equalTo(@40);
        }];
        
        [self.btnUpload mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).multipliedBy(0.9);
            make.bottom.equalTo(self.view.mas_bottom).mas_offset(-30);
            make.centerX.equalTo(self.view);
            make.height.equalTo(@40);
        }];
        
        [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.top.equalTo(self.view);
        }];
        
        [self.ttsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.top.equalTo(self.view);
        }];
        
        [self.segmentCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).mas_offset(30 + 64);
        }];
    }else{
        [self.view addSubview:self.recordView];
        [self.view addSubview:self.btnListen];
        [self.view addSubview:self.btnUpload];
        
       [self.btnListen mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).multipliedBy(0.9);
            make.bottom.equalTo(self.btnUpload.mas_top).mas_offset(-20);
            make.centerX.equalTo(self.view);
            make.height.equalTo(@40);
        }];
        
        [self.btnUpload mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).multipliedBy(0.9);
            make.bottom.equalTo(self.view.mas_bottom).mas_offset(-30);
            make.centerX.equalTo(self.view);
            make.height.equalTo(@40);
        }];
        
        [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.top.equalTo(self.view);
        }];
        
        [self.segmentCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).mas_offset(30);
        }];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

//MARK: ConfigNav
- (void)configNav{
    self.navigationItem.title = TS("TR_Bell_Customize");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

}

//MARK: - EventAction
- (void)backAction{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.recordPlayTimer) {
        [self.recordPlayTimer invalidate];
        self.timer = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: 选择转换方式点击事件
- (void)segmentValueChanged:(UISegmentedControl *)segment{
    if (self.segmentCtrl.selectedSegmentIndex == 0) {
        self.ttsView.hidden = NO;
        self.recordView.hidden = YES;
        
        if (self.ttsSuccess) {
            [self makeEnable:YES button:self.btnListen];
            [self makeEnable:YES button:self.btnUpload];
            
            
        }else{
            [self makeEnable:NO button:self.btnListen];
            [self makeEnable:NO button:self.btnUpload];
        }
    }else{
        self.ttsView.hidden = YES;
        self.recordView.hidden = NO;
        
        if (self.recordBefore) {
            [self makeEnable:YES button:self.btnListen];
            [self makeEnable:YES button:self.btnUpload];
        }else{
            [self makeEnable:NO button:self.btnListen];
            [self makeEnable:NO button:self.btnUpload];
        }
    }
}

//MARK: 男女选择
- (void)btnMaleClicked{
    self.btnMale.selected = YES;
    self.btnFemale.selected = NO;
}

- (void)btnFemaleClicked{
    self.btnFemale.selected = YES;
    self.btnMale.selected = NO;
}

//MARK:文字转语音
- (void)btnTransformClicked{
    if (self.ttsSuccess) {
        [self makeEnable:YES button:self.btnListen];
        [self makeEnable:YES button:self.btnUpload];
        
        
    }else{
        [self makeEnable:NO button:self.btnListen];
        [self makeEnable:NO button:self.btnUpload];
    }
    
    if (self.tfContent.text.length == 0) {
        [self.tfContent becomeFirstResponder];
        return;
    }
    
//    //判断是否是中文
//    if (![self isValidated:[self.tfContent.text stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
//        [SVProgressHUD setMinimumDismissTimeInterval:2];
//        [SVProgressHUD showErrorWithStatus:TS(@"TR_Please_Enter_Right_Alarm_Tips")];
//        return;
//    }
    
    [self.tfContent resignFirstResponder];
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    [self.ttsManager transformTextToVoice:self.tfContent.text female:self.btnFemale.selected completion:^(int result,BOOL fileSizeTooLarge) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result >= 0) {
                if (fileSizeTooLarge) {
                    [SVProgressHUD showErrorWithStatus:TS("TR_File_Size_Exceed_Max_Size")];
                }else{
                    [SVProgressHUD dismiss];
                }
                
                weakSelf.ttsSuccess = YES;
                if (weakSelf.segmentCtrl.selectedSegmentIndex == 0) {
                    [weakSelf makeEnable:YES button:weakSelf.btnListen];
                    [weakSelf makeEnable:YES button:weakSelf.btnUpload];
                }
            }else{
                
                weakSelf.ttsSuccess = NO;
                [SVProgressHUD showErrorWithStatus:TS("TR_Operator_Failed")];
            }
        });
    }];
}

//MARK:录音按钮点击
- (void)btnRecordClicked:(UIButton *)sender{
    if (self.ifPlayingRecord) {
        return;
    }
    
    if (self.recordBefore) {
        [self makeEnable:YES button:self.btnListen];
        [self makeEnable:YES button:self.btnUpload];
    }else{
        [self makeEnable:NO button:self.btnListen];
        [self makeEnable:NO button:self.btnUpload];
    }
    
    if (self.recordStatus == CustomRecordingStatusNone || self.recordStatus == CustomRecordingStatusFinish) {
        [self startRecord];
        self.recordStatus = CustomRecordingStatusRecord;
        [self.btnRecord setImage:[UIImage imageNamed:@"ic_voice_stop.png"] forState:UIControlStateNormal];
    }
    else {
        [self stopRecord];
        self.recordStatus = CustomRecordingStatusFinish;
        [self.btnRecord setImage:[UIImage imageNamed:@"ic_voice.png"] forState:UIControlStateNormal];
    }
    
}

-(void)startRecord{
    self.session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    //判断后台有没有播放
    if (self.session == nil) {
        NSLog(@"Error creating sessing:%@", [sessionError description]);
        [SVProgressHUD showErrorWithStatus:TS("operator_failed")];
        return;
    } else {
        [self.session setActive:YES error:nil];
    }
    
    self.lbTime.text = @"00:00";
    self.lbRecordTip.text = TS("TR_Press_To_End_Record");
        //设置录音音质
        NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];//采样率
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];//声音通道
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];//音频质量
        [recordSetting setValue:[NSNumber numberWithFloat:128000] forKey:AVEncoderBitRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        
        //创建临时文件来存放录音文件
        self.tmpFile = [NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]];
        self.tmpUrl = [NSURL fileURLWithPath:self.tmpFile];
        
        //创建一个计时器来为录音计时，同时时间置0
        self.sec = 0.0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                      
                                                      target:self selector:@selector(timerRecording) userInfo:nil repeats:YES];
        
        //开始录音,将所获取到得录音存到文件里，录音放进相应url里
        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.tmpUrl settings:recordSetting error:nil];
        //准备记录录音
        [self.recorder prepareToRecord];
        //启动或者恢复记录的录音文件
        [self.recorder record];
}

-(void)timerRecording
{
    self.sec = self.sec + 1;
    if (self.sec > 3) {
        [self stopRecord];
        self.recordStatus = CustomRecordingStatusFinish;
        [self.btnRecord setImage:[UIImage imageNamed:@"ic_voice.png"] forState:UIControlStateNormal];
        
        [self.timer invalidate];
        self.timer = nil;
        self.sec = 0;
        self.lbTime.text = @"00:03";
        self.recordTotalTime = 3;
    
        return;
    }
    
    self.lbTime.text = [NSString stringWithFormat:@"00:0%d",(int)self.sec];
    
}

-(NSString *)getRecordingPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directoryStr = [path stringByAppendingString:@"/customAlarmVoice"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:directoryStr]) {
        
    }else{
        [manager createDirectoryAtPath:directoryStr withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return directoryStr;
}

-(void)stopRecord{
    [self.recorder stop];

    self.recordBefore = YES;
    
    if (self.needTTS) {
        if (self.segmentCtrl.selectedSegmentIndex == 1) {
            [self makeEnable:YES button:self.btnListen];
            [self makeEnable:YES button:self.btnUpload];
        }
    }else{
        [self makeEnable:YES button:self.btnListen];
        [self makeEnable:YES button:self.btnUpload];
    }
    
    //计时器停止
    [self.timer invalidate];
    self.timer = nil;
    self.recorder = nil;
    
    int s = (int)self.sec;
    self.recordTotalTime = s;
    self.lbTime.text = [NSString stringWithFormat:@"00:0%i",s];
    self.lbRecordTip.text = TS("TR_Press_To_Record");
    self.sec = 0;
    NSError *sessionError;
    
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]];
    long long fileSize = [self fileSizeAtPath:filePath];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    //设置每次句柄偏移量
    //[fileHandle seekToFileOffset:42*1024];
    //获取每次读入data
    if(fileSize >= 84 * 1024){
        NSData *data = [fileHandle readDataOfLength:84*1024];
        [data writeToFile:filePath atomically:YES];
    }
    else{
        //判断能否被16整除
        if (fileSize % 32 != 0) {
            fileSize = fileSize - fileSize % 32;
            NSData *data = [fileHandle readDataOfLength:fileSize];
            [data writeToFile:filePath atomically:YES];
        }
    }
}

-(long long) fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager =[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil]fileSize];
    }
    
    return 0;
}

-(void)playRecord:(NSString *)path{
    NSError *playError;
    
    NSURL *playUrl = [NSURL URLWithString:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:playUrl error:&playError];
    self.player.delegate = self;
    [self.player setVolume:1];
    
    [self.player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.ifPlayingRecord = NO;
}

//MARK:点击试听按钮
- (void)btnListenClicked{
    if (self.ifPlayingRecord) {
        return;
    }
    if (self.needTTS) {
        if (self.segmentCtrl.selectedSegmentIndex == 1) {
            self.ifPlayingRecord = YES;
            [self playRecord:[NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]]];
            self.recordPlayCurTime = 0;
            self.lbTime.text = [NSString stringWithFormat:@"00:0%i",self.recordPlayCurTime];
            self.lbRecordTip.text = @"";
            if (!self.recordPlayTimer) {
                self.recordPlayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordPlaying) userInfo:nil repeats:YES];
            }
        }else{
            self.ifPlayingRecord = YES;
            [self playRecord:[[NSString documentsPath] stringByAppendingPathComponent:@"transform.wav"]];
        }
    }else{
        self.ifPlayingRecord = YES;
        [self playRecord:[NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]]];
        self.recordPlayCurTime = 0;
        self.lbTime.text = [NSString stringWithFormat:@"00:0%i",self.recordPlayCurTime];
        self.lbRecordTip.text = @"";
        if (!self.recordPlayTimer) {
            self.recordPlayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordPlaying) userInfo:nil repeats:YES];
        }
    }
}

- (void)recordPlaying{
    self.recordPlayCurTime++;
    if (self.recordPlayCurTime >= self.player.duration) {
        self.lbTime.text = [NSString stringWithFormat:@"00:0%i",self.recordTotalTime];
        [self.recordPlayTimer invalidate];
        self.recordPlayTimer = nil;
        self.ifPlayingRecord = NO;
        self.lbRecordTip.text = TS("TR_Press_To_Record");
    }else{
        self.lbTime.text = [NSString stringWithFormat:@"00:0%i",self.recordPlayCurTime];
    }
}

//MARK:上传按钮点击
- (void)btnUploadClicked{
    NSString *filePath = @"";
    if (self.needTTS) {
        if (self.segmentCtrl.selectedSegmentIndex == 1) {
            filePath = [NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]];
        }else{
            filePath = [[NSString documentsPath] stringByAppendingPathComponent:@"transform.wav"];
        }
    }else{
        filePath = [NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]];
    }
    
    long long fileSize = [self fileSizeAtPath:filePath];
    NSMutableDictionary *dic = [@{@"OPFile":@{@"FileType" : @1,@"Channel":@[@0],@"FilePurpose":@0,@"FileSize":[NSNumber numberWithLongLong:fileSize/2],@"FileName":@"customAlarmVoice.pcm",@"Parameter":@{@"BitRate":@128,@"SampleRate":@8000,@"SampleBit":@8,@"EncodeType":@"G711_ALAW"}}} mutableCopy];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    FUN_DevStartFileTransfer(self.msgHandle, [self.devID UTF8String], [strValues UTF8String], 15000);
}

- (void)dismissKeyBoard{
    [self.tfContent resignFirstResponder];
}

//MARK: - Delegate
//MARK: UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

- (BOOL)isValidated:(NSString *)str
{
    if (str.length == 0) {
        return YES;
    }
    NSString *match = @"(^[\u4e00-\u9fa50-9%!@#&*(),.<>?/。，？、！%：:；;“”‘’]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];

    return [predicate evaluateWithObject:str];
}

//MARK: OnFunResult
-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    if (msg->id == EMSG_DEV_START_FILE_TRANSFER){
        if (msg->param1 < 0) {
            
        }else{
            NSString *filePath = @"";
            if (self.needTTS) {
                if (self.segmentCtrl.selectedSegmentIndex == 1) {
                    filePath = [NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]];
                }else{
                    filePath = [[NSString documentsPath] stringByAppendingPathComponent:@"transform.wav"];
                }
            }else{
                filePath = [NSString stringWithFormat:@"%@/customAlarmVoice.caf",[self getRecordingPath]];
            }
            
            self.fileSize = [self fileSizeAtPath:filePath];
           
            self.singleSize = 32 * 1024;
            self.curNeedUploadFileIndex = 0;
            int x = (self.fileSize/self.singleSize);
            int y = (self.fileSize % self.singleSize) > 0 ? 1 : 0;
            self.fileTotalNum = x + y;
            
            self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
            //设置每次句柄偏移量
            [self.fileHandle seekToFileOffset:self.singleSize *(self.curNeedUploadFileIndex)];
            NSData *dataUpdata = nil;
            if (self.fileTotalNum == 1) {
                if (self.fileSize % self.singleSize != 0) {
                    dataUpdata = [self.fileHandle readDataOfLength:self.fileSize];
                }else{
                    dataUpdata = [self.fileHandle readDataOfLength:self.singleSize];
                }
            }else{
                dataUpdata = [self.fileHandle readDataOfLength:self.singleSize];
            }
            char *value = (char *)[dataUpdata bytes];
            
            if (self.fileTotalNum == 1) {
                self.fileUploadHandle = FUN_DevFileDataTransfer(self.msgHandle, [self.devID UTF8String], value, (int)[dataUpdata length], 1,60000,self.curNeedUploadFileIndex);
            }else{
                self.fileUploadHandle = FUN_DevFileDataTransfer(self.msgHandle, [self.devID UTF8String], value, (int)[dataUpdata length], 0,60000,self.curNeedUploadFileIndex);
            }
        }
    }else if (msg->id == EMSG_DEV_FILE_DATA_TRANSFER){
        if (msg->param1 < 0) {

        }else{
            self.curNeedUploadFileIndex = msg->seq + 1;
            
            if (self.curNeedUploadFileIndex == self.fileTotalNum) {
                FUN_DevStopFileTransfer(self.fileUploadHandle);
                
                NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data == nil )
                    return;
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ( appData == nil) {
                    return;
                }
                if ([appData.allKeys containsObject:@"OPFile"]) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Failed")];
                }else{

                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }else{
                NSData *dataUpdata = nil;
                
                [self.fileHandle seekToFileOffset:self.curNeedUploadFileIndex * self.singleSize];
                
                if (self.fileTotalNum == self.curNeedUploadFileIndex + 1) {
                    if (self.fileSize % self.singleSize != 0) {
                        dataUpdata = [self.fileHandle readDataOfLength:int(self.fileSize - (self.fileTotalNum - 1) * self.singleSize)];
                    }else{
                        dataUpdata = [self.fileHandle readDataOfLength:self.singleSize];
                    }
                }else{
                    dataUpdata = [self.fileHandle readDataOfLength:self.singleSize];
                }
                
                char *value = (char *)[dataUpdata bytes];
                
                if (self.fileTotalNum == self.curNeedUploadFileIndex + 1) {
                    self.fileUploadHandle = FUN_DevFileDataTransfer(self.msgHandle, [self.devID UTF8String], value, (int)[dataUpdata length], 1,60000,self.curNeedUploadFileIndex);
                }else{
                    self.fileUploadHandle = FUN_DevFileDataTransfer(self.msgHandle, [self.devID UTF8String], value, (int)[dataUpdata length], 0,60000,self.curNeedUploadFileIndex);
                }
            }
        }
    }
}

//MARK: - LazyLoad
- (UIView *)ttsView{
    if (!_ttsView) {
        _ttsView = [[UIView alloc] init];
        
        self.tfContent = [[UITextField alloc] init];
        self.tfContent.borderStyle = UITextBorderStyleNone;
        self.tfContent.placeholder = TS("TR_Enter_Text_To_Be_Converted");
        self.tfContent.textAlignment = NSTextAlignmentCenter;
        self.tfContent.delegate = self;
        
        [_ttsView addSubview:self.tfContent];
        
        [self.tfContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_ttsView).multipliedBy(0.9);
            make.centerX.equalTo(_ttsView);
            make.height.equalTo(@40);
            make.centerY.equalTo(_ttsView).mas_offset(-100);
        }];
        
        UIView *underLine = [[UIView alloc] init];
        underLine.backgroundColor = [UIColor lightGrayColor];
        
        [_ttsView addSubview:underLine];
        
        [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tfContent);
            make.right.equalTo(self.tfContent);
            make.height.equalTo(@0.5);
            make.top.mas_equalTo(self.tfContent.mas_bottom);
        }];
        
        self.btnFemale = [[UIButton alloc] init];;
        [self.btnFemale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnFemale setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [self.btnFemale setTitle:TS("TR_Sex_Female") forState:UIControlStateNormal];
        [self.btnFemale setTitle:TS("TR_Sex_Female") forState:UIControlStateSelected];
        [self.btnFemale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnFemale setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [self.btnFemale addTarget:self action:@selector(btnFemaleClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_ttsView addSubview:self.btnFemale];
        
        [self.btnFemale mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_ttsView.mas_centerX);
            make.height.equalTo(@40);
            make.width.equalTo(@80);
            make.top.equalTo(self.tfContent.mas_bottom).mas_offset(10);
        }];
        
        self.btnMale = [[UIButton alloc] init];
        [self.btnMale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnMale setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [self.btnMale setTitle:TS("TR_Sex_Male") forState:UIControlStateNormal];
        [self.btnMale setTitle:TS("TR_Sex_Male") forState:UIControlStateSelected];
        [self.btnMale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnMale setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        self.btnMale.selected = YES;
        [self.btnMale addTarget:self action:@selector(btnMaleClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_ttsView addSubview:self.btnMale];
        
        [self.btnMale mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_ttsView.mas_centerX).mas_offset(-10);
            make.height.equalTo(@40);
            make.width.equalTo(@80);
            make.top.equalTo(self.tfContent.mas_bottom).mas_offset(10);
        }];
        
        UIButton *btnTransform = [UIButton buttonWithType:UIButtonTypeSystem];
        btnTransform.layer.cornerRadius = 3;
        btnTransform.layer.masksToBounds = YES;
        btnTransform.layer.borderColor = [UIColor blackColor].CGColor;
        btnTransform.layer.borderWidth = 1;
        [btnTransform setTitle:TS("TR_Transformation") forState:UIControlStateNormal];
        [btnTransform setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnTransform addTarget:self action:@selector(btnTransformClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_ttsView addSubview:btnTransform];
        
        [btnTransform mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@40);
            make.width.equalTo(_ttsView).multipliedBy(0.9);
            make.centerX.equalTo(_ttsView);
            make.top.equalTo(self.btnFemale.mas_bottom).mas_offset(10);
        }];
        
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
        
        [_ttsView addSubview:bottomLine];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_ttsView);
            make.right.equalTo(_ttsView);
            make.bottom.equalTo(_ttsView);
            make.height.equalTo(@1);
        }];
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
        [_ttsView addGestureRecognizer:tapView];
    }
    
    return _ttsView;
}

- (TTSManager *)ttsManager{
    if (!_ttsManager) {
        _ttsManager = [[TTSManager alloc] init];
    }
    
    return _ttsManager;
}

- (UIView *)recordView{
    if (!_recordView) {
        _recordView = [[UIView alloc] init];
        
        self.btnRecord = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnRecord setBackgroundImage:[UIImage imageNamed:@"ic_voice.png"] forState:UIControlStateNormal];
        [self.btnRecord addTarget:self action:@selector(btnRecordClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_recordView addSubview:self.btnRecord];
        
        [self.btnRecord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_recordView);
            make.width.equalTo(@70);
            make.height.equalTo(@70);
        }];
        
        self.lbTime = [[UILabel alloc] init];
        self.lbTime.textAlignment = NSTextAlignmentCenter;
        self.lbTime.text = TS("00:00");
        self.lbTime.font = [UIFont systemFontOfSize:18];
        
        [_recordView addSubview:self.lbTime];
        
        [self.lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_recordView);
            make.width.equalTo(@200);
            make.height.equalTo(@35);
            make.top.equalTo(self.btnRecord.mas_bottom);
        }];
        
        self.lbRecordTip = [[UILabel alloc] init];
        self.lbRecordTip.textAlignment = NSTextAlignmentCenter;
        self.lbRecordTip.text = TS("TR_Press_To_Record");
        self.lbRecordTip.font = [UIFont systemFontOfSize:15];
        
        [_recordView addSubview:self.lbRecordTip];
        
        [self.lbRecordTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_recordView);
            make.width.equalTo(@200);
            make.height.equalTo(@30);
            make.top.equalTo(self.lbTime.mas_bottom);
        }];
        
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
        
        [_recordView addSubview:bottomLine];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_recordView);
            make.right.equalTo(_recordView);
            make.bottom.equalTo(_recordView);
            make.height.equalTo(@1);
        }];
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
        [_recordView addGestureRecognizer:tapView];
    }
    
    return _recordView;
}

- (UIButton *)btnListen{
    if (!_btnListen) {
        _btnListen = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnListen.layer.cornerRadius = 3;
        _btnListen.layer.masksToBounds = YES;
        _btnListen.layer.borderColor = [UIColor blackColor].CGColor;
        _btnListen.layer.borderWidth = 1;
        [_btnListen setTitle:TS("TR_Audition") forState:UIControlStateNormal];
        [_btnListen addTarget:self action:@selector(btnListenClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnListen setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self makeEnable:NO button:_btnListen];
    }
    
    return _btnListen;
}

- (UIButton *)btnUpload{
    if (!_btnUpload) {
        _btnUpload = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnUpload.layer.cornerRadius = 3;
        _btnUpload.layer.masksToBounds = YES;
        _btnUpload.layer.borderColor = [UIColor blackColor].CGColor;
        _btnUpload.layer.borderWidth = 1;
        [_btnUpload setTitle:TS("TR_Upload_Prompt_Voice") forState:UIControlStateNormal];
        [_btnUpload addTarget:self action:@selector(btnUploadClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnUpload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self makeEnable:NO button:_btnUpload];
    }
    
    return _btnUpload;
}

- (void)makeEnable:(BOOL)enable button:(UIButton *)btn{
    btn.enabled = enable;
    if (!enable) {
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else{
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (UISegmentedControl *)segmentCtrl{
    if (!_segmentCtrl) {
        _segmentCtrl = [[UISegmentedControl alloc] initWithItems:@[TS("TR_Text_To_Voice"),TS("TR_Record_Prompt")]];
        [_segmentCtrl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_segmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
        _segmentCtrl.selectedSegmentIndex = -1;
    }
    
    return _segmentCtrl;
}

@end
