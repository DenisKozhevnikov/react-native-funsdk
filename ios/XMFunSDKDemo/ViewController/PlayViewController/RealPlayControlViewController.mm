//
//  RealPlayControlViewController.m
//  Giga Admin
//
//  Created by P on 2019/11/22.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "RealPlayControlViewController.h"
#import "DeviceConfigViewController.h"
#import "PlayBackViewController.h"
#import "MediaplayerControl.h"
#import "PlayView.h"
#import "PlayFunctionView.h"
#import "PlayMenuView.h"
#import "TalkBackControl.h"
#import "FishPlayControl.h"
#import "UILabelOutLined.h"
#import "DeviceManager.h"
#import "DoorBellModel.h"
#import "ControlToolView.h"

#define TotalNumber  32
#define ToolViewHeight 60
@interface RealPlayControlViewController ()<MediaplayerControlDelegate,basePlayFunctionViewDelegate,PlayMenuViewDelegate,ControlToolViewDelegate>
{
    NSMutableArray *playViewArray;  //播放画面数组
    ControlToolView *toolView; // 工具栏
    PlayMenuView *playMenuView;//下方功能栏
    MediaplayerControl  *mediaPlayer;//播放媒体工具，
    NSMutableArray *mediaArray;//媒体播放工具数组，其中的第一个元素就是上面的mediaPlayer
    TalkBackControl *talkControl;//对讲工具
    NSMutableArray *feyeArray;//鱼眼控制数组
    short imageWidth; //语言宽高参数
    short imageHeight;
    short imgradius; //鱼眼半径参数
    UILabelOutLined *timeLab;
    UILabelOutLined *nameLab;
    int hardandsoft;
    int hardmodel;
    double orginalRatio; //视频比例
}
//导航栏左边的返回按钮
@property (nonatomic, strong) UIBarButtonItem *leftBarBtn;

@property (nonatomic,assign) int msgHandle;

@end

@implementation RealPlayControlViewController
{
    int nowModeX;
    int nowModeY;
    
    int maxModeX;
    int maxModeY;
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
    
    //开始播放视频
    [self startRealPlay];
}

#pragma -mark - 创建导航栏
- (void)setNaviStyle {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = TS("TR_Remote_Ctrl");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    self.leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = self.leftBarBtn;
}

-(void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 创建播放背景
- (void)createPlayView {
    if (playViewArray == nil) {
        playViewArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    //单通道播放
    PlayView *pView = [[PlayView alloc] initWithFrame:CGRectMake(0, NavAndStatusHight, ScreenWidth, realPlayViewHeight)];
    NSLog(@"NavAndStatusHight = %f",NavAndStatusHight);
    [self.view addSubview:pView];
    pView.activityView.center = pView.center;
    [playViewArray addObject:pView];
    
}

#pragma mark - 预览对象初始化
- (void)initDataSource {
    if (mediaArray == nil) {
        mediaArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (feyeArray == nil) {
        feyeArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    //选择播放的通道信息
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    mediaPlayer = [[MediaplayerControl alloc] init];
    mediaPlayer.devID = channel.deviceMac;//设备序列号
    mediaPlayer.channel = self.allChannelNum;//当前通道号
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

#pragma mark - 创建工具栏
-(void)createToolView{
    
    if (!toolView) {
        toolView = [[ControlToolView alloc] initWithFrame:CGRectMake(0, NavAndStatusHight+ realPlayViewHeight, ScreenWidth, SCREEN_HEIGHT-(NavAndStatusHight+ realPlayViewHeight))];
        toolView.delgate = self;
        [self.view addSubview:toolView];
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

#pragma mark - 开始预览结果回调
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startResult:(int)result DSSResult:(int)dssResult {
    NSLog(@"远程控制视频打开成功");
    
    if (result >= 0 )
    {
        FUN_DevGetConfig_Json(self.msgHandle, [self.devMac UTF8String], "fVideo.VideoOut", 1024,-1,5000,0);
    }
}

#pragma mark - ControlToolViewDelegate
-(void)controlBtnCancelAction
{
    NSDictionary *dic = dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
          @"OPRemoteCtrl":@{@"P1":@"0x1B",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20006"},};

    NSString *str = [self convertToJsonData:dic];
    char cfg[1024];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, [self.devMac UTF8String], 4000, "OPRemoteCtrl", 4096, 10000,cfg, (int)strlen(cfg) + 1, -1, 0);
}

-(void)controlBtnTouchDownAction:(int)sender
{
    NSDictionary *dic;
    switch (sender) {
        case 0:
            nowModeY-=5;
            
            if (nowModeY<0)
            {
                nowModeY = 0;
            }
            
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20006"},};
            break;
        case 1:
            nowModeY+=5;

            if(nowModeY > maxModeY)
            {
                nowModeY = maxModeY;
            }
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20006"},};
            break;
        case 2:
            nowModeX-=5;
            if (nowModeX<0)
            {
                nowModeX = 0;
            }
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20006"},};
            break;
        case 3:
            nowModeX+=5;

            if (nowModeX>maxModeX)
            {
                nowModeX = maxModeX;
            }
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20006"},};
            break;
        case 4:
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20008"},};
            break;
        case 5:
           dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                   @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x2000b"},};
            break;
        case 6:
          dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                  @"OPRemoteCtrl":@{@"P1":@"0x1B",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20002"}};
            break;
            
        default:
            break;
    }
    NSString *str = [self convertToJsonData:dic];
    char cfg[1024];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, [self.devMac UTF8String], 4000, "OPRemoteCtrl", 4096, 10000,cfg, (int)strlen(cfg) + 1, -1, 0);
}
-(void)controlBtnTouchUpInsideAction:(int)sender
{
    NSDictionary *dic;
    switch (sender) {
        case 0:
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20007"},};
            break;
        case 1:
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20007"},};
            break;
        case 2:
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20007"},};
            break;
        case 3:
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20007"},};
            break;
        case 4:
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20009"},};
            break;
        case 5:
           dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                   @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x2000c"},};
            break;
        case 6:
            dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                    @"OPRemoteCtrl":@{@"P1":@"0x1B",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20003"}};
            break;
            
        default:
            break;
    }

    NSString *str = [self convertToJsonData:dic];
    char cfg[1024];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, [self.devMac UTF8String], 4000, "OPRemoteCtrl", 4096, 10000,cfg, (int)strlen(cfg) + 1, -1, 0);
}

//将十进制转化为十六进制
-(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
         {
             case 10:
                 nLetterValue =@"A";break;
             case 11:
                 nLetterValue =@"B";break;
             case 12:
                 nLetterValue =@"C";break;
             case 13:
                 nLetterValue =@"D";break;
             case 14:
                 nLetterValue =@"E";break;
             case 15:
                 nLetterValue =@"F";break;
             default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];

         }
         str = [nLetterValue stringByAppendingString:str];
         if (tmpid == 0) {
             break;
         }

     }
    
     NSMutableString *str1=[[NSMutableString alloc]initWithString:str];
     if (str1.length !=4)
     {
        for (int i = 0; i<(4-str1.length); i++)
        {
            [str1 insertString:@"0" atIndex:0];
        }
     }
     str = str1;
    
     return str;
}


-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:{
            if (msg->param1 <0) {
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
                
                if([strConfigName containsString:@"fVideo.VideoOut"])
                {
                    maxModeX = [appData[@"fVideo.VideoOut"][@"Mode"][@"Height"] intValue];
                    maxModeY = [appData[@"fVideo.VideoOut"][@"Mode"][@"Width"] intValue];
                    
                    nowModeX = maxModeX/2;
                    nowModeY = maxModeY/2;
                    
                    //获取到宽高后 设置鼠标到最中间
                    if (nowModeX >0 && nowModeY >0)
                    {
                        NSDictionary *dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x000000000B",
                        @"OPRemoteCtrl":@{@"P1":@"0x2",@"P2":[NSString stringWithFormat:@"0x%@%@",[self ToHex:nowModeX],[self ToHex:nowModeY]],@"msg":@"0x20006"}};
                        NSString *str = [self convertToJsonData:dic];
                        char cfg[1024];
                        memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

                        FUN_DevCmdGeneral(self.msgHandle, [self.devMac UTF8String], 4000, "OPRemoteCtrl", 4096, 10000,cfg, (int)strlen(cfg) + 1, -1, 0);
                    }
                }
            }
        }
            break;
        case EMSG_DEV_CMD_EN:{
            NSLog(@"123123123");
        }
            break;
        default:
            break;
    }
}
@end
