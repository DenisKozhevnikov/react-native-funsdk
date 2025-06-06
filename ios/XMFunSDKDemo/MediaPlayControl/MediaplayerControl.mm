//
//  MediaplayerControl.m
//  FunSDKDemo
//
//  Created by XM on 2018/10/17.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "MediaplayerControl.h"

@interface MediaplayerControl ()

@end
@implementation MediaplayerControl

/**
 start接口调用后，在OnFunSDKResult回调：
 1、EMSG_START_PLAY  打开视频成功
 2、EMSG_ON_PLAY_BUFFER_BEGIN  开始缓存数据
 3、EMSG_ON_PLAY_BUFFER_END 缓存结束准备刷新界面
 4、EMSG_ON_PLAY_INFO 实时播放信息
 ******/
#pragma mark - 开启视频
-(int)start{
    
    if ( self.status != MediaPlayerStatusStop)  {
        [self stop];
    }
    if(self.status == MediaPlayerStatusStop){
        self.player = FUN_MediaRealPlay(self.msgHandle, [self.devID UTF8String], self.channel, self.stream, (__bridge LP_WND_OBJ)self.renderWnd, 0);
    }
    return self.player;
}
#pragma mark - 停止
-(int)stop{
    self.status = MediaPlayerStatusStop;
    return FUN_MediaStop(self.player, 0);
}


/**
 startYUVBack接口调用后，在OnFunSDKResult回调：
 1、EMSG_START_PLAY  打开视频成功
 2、EMSG_ON_PLAY_BUFFER_BEGIN  开始缓存数据
 3、EMSG_ON_PLAY_BUFFER_END 缓存结束准备刷新界面
4、EMSG_ON_YUV_DATA 不刷新界面，直接回调YUV数据
 ******/
#pragma mark - 开始播放视频，获取YUV数据 （不使用现有的视频播放，需要自己处理YUV数据的调用这个接口，会返回视频YUV数据，需要自己处理然后显示在画面上）
- (int)startYUVBack {
    if ( self.status != MediaPlayerStatusStop)  {
        [self stop];
    }
    if(self.status == MediaPlayerStatusStop){
        self.player = FUN_MediaRealPlay(self.msgHandle, [self.devID UTF8String], self.channel, self.stream, (__bridge LP_WND_OBJ)self.renderWnd, 0);
    }
    FUN_SetIntAttr(self.player, EOA_MEDIA_YUV_USER, self.msgHandle);//返回Yuv数据
    FUN_SetIntAttr(self.player, EOA_SET_MEDIA_VIEW_VISUAL, 0);//自己画画面
    return self.player;
}

#pragma mark - 暂停
-(int)pause{
    int nRet = -1;
    if ( self.status == MediaPlayerStatusPlaying ) {
        nRet = FUN_MediaPause(self.player, 1, 0);
        self.status = MediaPlayerStatusPause;
    }
    return nRet;
}
#pragma mark - 恢复
-(int)resumue{
    if ( self.status != MediaPlayerStatusPause ) {
        return -1;
    }
    self.status = MediaPlayerStatusPlaying;
    return FUN_MediaPause(self.player, 0);
}

#pragma mark - 打开音频，传递音频大小，0-100
-(int)openSound:(int)soundValue{
    return FUN_MediaSetSound(self.player, soundValue, 0);
}
#pragma mark - 关闭音频
-(int)closeSound{
    return FUN_MediaSetSound(self.player, 0, 0);
}

#pragma mark - 抓图
-(int)snapImage:(NSString *)path {
    NSString *dateString = [NSString GetSystemTimeString];
    NSString *file;
    
    if (path) {
        file = path;
    } else {
        file = [NSString getPhotoPath];
    }
    
    NSString *pictureFilePath = [file stringByAppendingFormat:@"/%@.jpg",dateString];
    
    return FUN_MediaSnapImage(self.player, [pictureFilePath UTF8String]);
}

-(int)snapImage {
    NSString *dateString = [NSString GetSystemTimeString];
    NSString *file = [NSString getPhotoPath];
    
    NSString *pictureFilePath = [file stringByAppendingFormat:@"/%@.jpg",dateString];
    return FUN_MediaSnapImage(self.player, [pictureFilePath UTF8String]);
}

#pragma mark 调用设备端截图
- (void)StoreSnap {
    //设备端执行截图操作，并把图片保存，可以使用查询设备端图片方法获取截图
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    char cfg[1024];
    sprintf(cfg,"{\"Name\":\"StoreSnap\",\"StoreSnap\":{\"Channle\":%d}}",channel.channelNumber);
    FUN_DevCmdGeneral(self.msgHandle, CSTR(channel.deviceMac), 2028, "StoreSnap", 4096, 5000, (char *)cfg, (int)strlen(cfg) + 1, -1, 1);
}

#pragma mark - 开始录像
-(int)startRecord{
    NSString *dateString = [NSString GetSystemTimeString];
    NSString *file = [NSString getVideoPath];
    if (self.IsYuv == YES) {
        //鱼眼设备录像
        NSString *movieFilePath = [file stringByAppendingFormat:@"/%@.fvideo",dateString];
        return FUN_MediaStartRecord(self.player, [movieFilePath UTF8String]);
    }else{
        //普通设备录像
        NSString *movieFilePath = [file stringByAppendingFormat:@"/%@.mp4",dateString];
         return FUN_MediaStartRecord(self.player, [movieFilePath UTF8String]);
    }
}
-(int)startRecord:(NSString *)path{
    NSString *dateString = [NSString GetSystemTimeString];
    NSString *file;
    
    if (path) {
        file = path;
    } else {
        file = [NSString getVideoPath];
    }
    
    if (self.IsYuv == YES) {
        //鱼眼设备录像
        NSString *movieFilePath = [file stringByAppendingFormat:@"/%@.fvideo",dateString];
        return FUN_MediaStartRecord(self.player, [movieFilePath UTF8String]);
    }else{
        //普通设备录像
        NSString *movieFilePath = [file stringByAppendingFormat:@"/%@.mp4",dateString];
         return FUN_MediaStartRecord(self.player, [movieFilePath UTF8String]);
    }
}

#pragma mark - 停止录像
-(int)stopRecord{
    return FUN_MediaStopRecord(self.player);
}

#pragma mark - 切换清晰度
-(void)changeStream:(int)stream{
    if (stream == -1) {
        self.stream = !self.stream;
    }else{
        self.stream = stream;
    }
    //切换码流先停止再播放
    [self stop];
    [self start];
}



#pragma mark - 点击云台控制的按钮，开始控制  这个接口没有回调信息
-(void)controZStartlPTAction:(PTZ_ControlType)sender {
    FUN_DevPTZControl(self.msgHandle, SZSTR(self.devID), self.channel, sender, false, 4);
}
#pragma mark - 抬起云台控制的按钮，结束控制   这个接口没有回调信息
-(void)controZStopIPTAction:(PTZ_ControlType)sender {
    FUN_DevPTZControl(self.msgHandle, SZSTR(self.devID), self.channel, sender, true, 4);
}
#pragma mark - 设置播放速度
-(void)setPlaySpeed:(int)speed
{
    FUN_MediaSetPlaySpeed(self.player, speed, 0);
}

- (void)updateState:(int)state {
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:didUpdateState:)]) {
        [self.delegate mediaPlayer:self didUpdateState:state];
    }
}

- (void)showRateAndTime:(NSString *)time rate:(NSString *)rate {
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:didShowRateAndTime:rate:)]) {
        [self.delegate mediaPlayer:self didShowRateAndTime:time rate:rate];
    }
}

- (void)bufferEnd {
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:didBufferEnd:)]) {
        [self.delegate mediaPlayer:self didBufferEnd:true];
    }
}

- (void)failed:(int)msgId errorId:(int)errorId {
    if ([self.delegate respondsToSelector:@selector(mediaPlayer:didFailed:errorId:)]) {
        [self.delegate mediaPlayer:self didFailed:msgId errorId:errorId];
    }
}

#pragma mark FunSDK 结果回调
-(void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    NSLog(@"MediaPlayerControl");
    NSLog(@"sender: %d", msg->sender);
    NSLog(@"id: %d", msg->id);
    NSLog(@"param1: %d", msg->param1);
    NSLog(@"param2: %d", msg->param2);
    NSLog(@"param3: %d", msg->param3);
    NSLog(@"szStr: %s", msg->szStr);
    NSLog(@"pObject: %s", msg->pObject);
    NSLog(@"nDataLen: %d", msg->nDataLen);
    NSLog(@"seq: %d", msg->seq);
    NSLog(@"pMsg: %p", msg->pMsg);
    
    switch ( msg->id ) {
#pragma mark 收到开始直播结果消息
        case EMSG_START_PLAY:{
          if (msg->param1==0) {
              self.status = MediaPlayerStatusBuffering;
              NSLog(@"播放成功～～");
          }else{
              self.status = MediaPlayerStatusStop;
              NSLog(@"播放失败～～");
          }
          
          if (msg->param1 < 0) {
            // Отправляем данные для onFailed
            [self failed:(int)msg->id errorId:(int)msg->param1];
            // Отправляем данные для onMediaPlayState
            [self updateState:4];
          }
          
//          if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:startResult:DSSResult:)] ) {
//              [self.delegate mediaPlayer:self startResult:msg->param1 DSSResult:msg->param3];
//          }
        }
            break;
#pragma mark 收到暂停播放结果消息
        case EMSG_PAUSE_PLAY:{
          
            if (msg->param1==2) {
              // Отправляем данные для onMediaPlayState
              [self updateState:1];
              
                //2为暂停
                self.status = MediaPlayerStatusPause;
            }else if (msg->param1 == 1){
              // Отправляем данные для onMediaPlayState
              [self updateState:0];
              
              
                //1为恢复
                self.status = MediaPlayerStatusPlaying;
            }
//            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:pauseOrResumeResult:)] ) {
//                [self.delegate mediaPlayer:self pauseOrResumeResult:msg->param1];
//            }
        }
            break;
#pragma mark 收到开始缓存数据结果消息
        case EMSG_ON_PLAY_BUFFER_BEGIN:{
          // Отправляем данные для onMediaPlayState
          [self updateState:2];
          
          
            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:buffering:ratioDetail:)] ) {
                [self.delegate mediaPlayer:self buffering:YES ratioDetail:0.8];
            }
        }
            break;
#pragma mark 收到缓冲结束开始有画面结果消息
        case EMSG_ON_PLAY_BUFFER_END:{
          // Отправляем данные для onMediaPlayState
          [self updateState:0];
          // Отправляем данные для onBufferEnd
          [self bufferEnd];
          
          
            if (msg->param1==0) {
                self.status = MediaPlayerStatusPlaying;
            }
            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:buffering:ratioDetail:)] ) {
                int wh[2] = {0};
                int vWidth = 0;int vHeight = 0;
                double ratioDetail = 0;
                FUN_GetAttr(msg->sender, EOA_VIDEO_WIDTH_HEIGHT, (char *)wh);
                if (wh[0] > 0 && wh[1] > 0) {
                    ratioDetail = wh[1]*1.0/wh[0];
                    vWidth = wh[0];
                    vHeight = wh[1];
                }
                //获取宽高
//                [self.delegate mediaPlayer: self width: vWidth htight:vHeight];
                [self.delegate mediaPlayer:self buffering:NO ratioDetail:ratioDetail];
            }
        }
            break;
#pragma mark  媒体通道网络异常断开
        case EMSG_ON_MEDIA_NET_DISCONNECT:{
//            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:startResult:DSSResult:)] ) {
//                [self.delegate mediaPlayer:self startResult:EE_DVR_SUB_CONNECT_ERROR DSSResult:msg->param3];
//            }
        }
            break;
#pragma mark 收到抓图回调结果消息
        case EMSG_SAVE_IMAGE_FILE:{
          if (msg->param1 < 0) {
            // Отправляем данные для onFailed
            [self failed:(int)msg->id errorId:(int)msg->param1];
          } else {
            // Отправляем данные для onMediaPlayState
            [self updateState:19];
          }
//            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:snapImagePath:result:)] ) {
//                [self.delegate mediaPlayer:self snapImagePath:NSSTR(msg->szStr) result:msg->param1];
//            }
        }
            break;
#pragma mark 收到查询直播信息结果消息
        case EMSG_ON_PLAY_INFO:{
//          пример того что приходит
//          sender: 1048589
//          id: 5508
//          // timestamp начало
//          param1: 1731279600
//          // timestamp текущий
//          param2: 1731279601
//          // timestamp конца
//          param3: 1731283200
//          // строка с данными
//          szStr: 2024-11-11 00:00:01;bits=25046;width=960;height=1080
//          pObject: (null)
//          nDataLen: 24005312
//          seq: 0
//          pMsg: 0x302655560
          if((int)msg->param1 == EE_DVR_PASSWORD_NOT_VALID) {
            // Отправляем данные для onMediaPlayState
            [self updateState:4];
            // Отправляем данные для onFailed
            [self failed:(int)msg->id errorId:(int)msg->param1];
          } else {
            const char *info=msg->szStr;
            NSString *str = [NSString stringWithUTF8String:info];
            
            NSArray *components = [str componentsSeparatedByString:@";"];

            if (components.count > 1) {
              NSString *time = components[0];
              
              NSMutableDictionary *params = [NSMutableDictionary dictionary];
              for (NSInteger i = 1; i < components.count; i++) {
                NSArray *paramComponents = [components[i] componentsSeparatedByString:@"="];
                if (paramComponents.count == 2) {
                    NSString *key = paramComponents[0];
                    NSString *value = paramComponents[1];
                    params[key] = value;
                }
              }

              NSString *bits = params[@"bits"];
//              NSString *width = params[@"width"];
//              NSString *height = params[@"height"];
              
              [self showRateAndTime:time rate:bits];
              
//              NSLog(@"Time: %@", time);
//              NSLog(@"Bits: %@", bits);
//              NSLog(@"Width: %@", width);
//              NSLog(@"Height: %@", height);
            }
          }
          
          
//            if (msg->param1 <0) {
//                //缓冲结束之后播放失败
//                if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:startResult:DSSResult:)] ) {
//                    [self.delegate mediaPlayer:self startResult:msg->param1 DSSResult:msg->param3];
//                }
//                break;
//            }
//            const char *time=msg->szStr;
//            NSString *str = [NSString stringWithUTF8String:time];
//            NSString *devtime;
//            if (str.length >18) {
//                devtime = [str substringToIndex:19];
//            }
//            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:info1:info2:)] ) {
//                //播放信息
//                [self.delegate mediaPlayer:self info1:msg->param1 info2:NSSTR(msg->szStr)];
//            }
//            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:DevTime:)] ) {
//                //设备时间
//                [self.delegate mediaPlayer:self DevTime:devtime];
//            }
//            if ([self.delegate respondsToSelector:@selector(mediaPlayer:timeInfo:)]) {
//                //回放时间
//                [self.delegate mediaPlayer:self timeInfo:msg->param2];
//            }
        }
            break;
#pragma mark 收到开始录像结果消息
        case EMSG_START_SAVE_MEDIA_FILE:{
          if (msg->param1 < 0) {
            // Отправляем данные для onFailed
            [self failed:(int)msg->id errorId:(int)msg->param1];
          }
//            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:startRecordResult:path:)] ) {
//                [self.delegate mediaPlayer:self startRecordResult:msg->param1 path:[NSString stringWithUTF8String:msg->szStr]];
//            }
        }
            break;
#pragma mark 收到停止录像结果消息
        case EMSG_STOP_SAVE_MEDIA_FILE:{
          if (msg->param1 < 0) {
            // Отправляем данные для onFailed
            [self failed:(int)msg->id errorId:(int)msg->param1];
          } else {
            // Отправляем данные для onMediaPlayState
            [self updateState:18];
          }
//            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:stopRecordResult:path:)] ) {
//                [self.delegate mediaPlayer:self stopRecordResult:msg->param1 path:[NSString stringWithUTF8String:msg->szStr]];
//            }
        }
            break;
#pragma mark 停止播放
        case EMSG_STOP_PLAY:{
            if ([self.delegate respondsToSelector:@selector(mediaPlayer:stopResult:)]) {
                [self.delegate mediaPlayer:self stopResult:msg->param1];
            }
        }
            break;
#pragma mark 刷新播放
        case EMSG_REFRESH_PLAY:{
//            if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:refreshPlayResult:)]) {
//                [self.delegate mediaPlayer:self refreshPlayResult:msg->param1];
//            }
        }
            break;
#pragma mark -鱼眼相关处理
#pragma mark 用户自定义信息帧回调
        case EMSG_ON_FRAME_USR_DATA:{
            int Hardandsoft = 0;//软解
            int Hardmodel = 0 ;
            
            if (msg->param2 == 3 ) {
                SDK_FishEyeFrameHW fishFrame = {0};
                memcpy(&fishFrame, msg->pObject + 8, sizeof(SDK_FishEyeFrameHW));
                if (fishFrame.secene == SDK_FISHEYE_SECENE_P360_FE) {
                    Hardandsoft = 3;
                    Hardmodel = SDK_FISHEYE_SECENE_P360_FE;
                    
                    FUN_SetIntAttr(self.player, EOA_MEDIA_YUV_USER, self.msgHandle);//返回Yuv数据
                    FUN_SetIntAttr(self.player, EOA_SET_MEDIA_VIEW_VISUAL, 0);//自己画画面
                    self.IsYuv = YES;
                    
                }else if (fishFrame.secene == SDK_FISHEYE_SECENE_RRRR_R) {
                    Hardandsoft = 3;
                    Hardmodel = SDK_FISHEYE_SECENE_RRRR_R;
                    
                    FUN_SetIntAttr(self.player, EOA_MEDIA_YUV_USER, 0);//不返回Yuv数据
                    FUN_SetIntAttr(self.player, EOA_SET_MEDIA_VIEW_VISUAL, 1);//底层画画面
                    self.IsYuv = NO;
                }
            }
            else if((msg->param2 == 4) && \
                    (msg->param1 >= (8 + sizeof(SDK_FishEyeFrameSW)))) {
                SDK_FishEyeFrameSW fishFrame = {0};
                Hardandsoft =4;
                memcpy(&fishFrame, msg->pObject + 8, sizeof(SDK_FishEyeFrameSW));
                
                FUN_SetIntAttr(self.player, EOA_MEDIA_YUV_USER, self.msgHandle);//返回Yuv数据
                FUN_SetIntAttr(self.player, EOA_SET_MEDIA_VIEW_VISUAL, 0);//自己画画面
                self.IsYuv = YES;
                
                // 圆心偏差横坐标  单位:像素点
                short  centerOffsetX = fishFrame.centerOffsetX;
                //圆心偏差纵坐标  单位:像素点
                short centerOffsetY = fishFrame.centerOffsetY;
                //半径  单位:像素点
                short radius = fishFrame.radius;
                //圆心校正时的图像宽度  单位:像素点
                short imageWidth = fishFrame.imageWidth;
                //圆心校正时的图像高度  单位:像素点
                short imageHeight = fishFrame.imageHeight;
                //视角  0:俯视   1:平视
                if (fishFrame.viewAngle == 0) {
                    
                }
                //显示模式   0:360VR
                if (fishFrame.lensType == SDK_FISHEYE_LENS_360VR || fishFrame.lensType == SDK_FISHEYE_LENS_360LVR) {//360vr
                    Hardmodel =0;
                }else{//180Vr
                    Hardmodel = 1;
                    
                }
                if ( self.delegate && [self.delegate respondsToSelector:@selector(centerOffSetX:offSetx:offY:radius:width:height:)] ) {
                    [self.delegate centerOffSetX:self offSetx:centerOffsetX offY:centerOffsetY radius:radius width:imageWidth height:imageHeight];
                }
            }
            else if (msg->param2 == 5)
            {
                //如果是已经保存过信息不支持的设备，则不进行YUV
                NSString *correct;// = [Config getCorrectdev:_devID];
                if ([correct isEqualToString:@"0"]) {

                }else{
                    Hardandsoft = 5;
                    FUN_SetIntAttr(self.player, EOA_MEDIA_YUV_USER, self.msgHandle);//返回Yuv数据
                    FUN_SetIntAttr(self.player, EOA_SET_MEDIA_VIEW_VISUAL, 0);//APP上层自己画画面
                }
            }
            else if (msg->param2 == 8)
            {
                if ([self.delegate respondsToSelector:@selector(mediaPlayer:AnalyzelLength:site:Analyzel:)]) {
                    [self.delegate mediaPlayer:self AnalyzelLength:msg->param1 site:msg->param3 Analyzel:msg->pObject];
                }
                //如果是智能分析报警坐标信息，则调用代理之后直接return
                return;
            }
            else if (msg->param2 == 0x0e){//一路码流支持上下分屏
                Hardandsoft = 4;
                SDK_FishEyeFrameSW *pFishFrameInfo = (SDK_FishEyeFrameSW *)(msg->pObject + 8);

                //双目拼接不进行异常处理 和android统一
//                if (![SDKEnumManager legalSoftCode:pFishFrameInfo->lensType]) {//数据异常不处理
//                    return;
//                }
                
                FUN_SetIntAttr(self.player, EOA_MEDIA_YUV_USER, self.msgHandle);//返回Yuv数据
                FUN_SetIntAttr(self.player, EOA_SET_MEDIA_VIEW_VISUAL, 0);//自己画画面
                self.IsYuv = YES;
                
                // 圆心偏差横坐标  单位:像素点
                short centerOffsetX = pFishFrameInfo->centerOffsetX;
                //圆心偏差纵坐标  单位:像素点
                short centerOffsetY = pFishFrameInfo->centerOffsetY;
                //半径  单位:像素点

                short radius = pFishFrameInfo->radius;
                //圆心校正时的图像宽度  单位:像素点
                short imageWidth = pFishFrameInfo->imageWidth;
                //圆心校正时的图像高度  单位:像素点
                short imageHeight = pFishFrameInfo->imageHeight;
                //视角  0:俯视   1:平视
                if (pFishFrameInfo->viewAngle == 0) {
                    
                }
                //显示模式   0:360VR
                NSLog(@"%d",pFishFrameInfo->lensType);
                Hardmodel = XMVR_TYPE_TWO_LENSES;
                if ( self.delegate && [self.delegate respondsToSelector:@selector(centerOffSetX:offSetx:offY:radius:width:height:)] ) {
                    [self.delegate centerOffSetX:self offSetx:centerOffsetX offY:centerOffsetY radius:radius width:imageWidth height:imageHeight];
                }
            }
            if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:Hardandsoft:Hardmodel:)] ) {
                [self.delegate mediaPlayer:self Hardandsoft:Hardandsoft Hardmodel:Hardmodel];
            }
            ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
            channel.isFish = self.IsYuv;
        }
            break;
#pragma mark YUV数据回调
        case EMSG_ON_YUV_DATA:{
            if (1) { // (需要自己处理YUV数据的，这个逻辑自己写一下，这里默认支持全景鱼眼处理YUV数据)
                // 全景鱼眼处理
                if ( self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:width:height:pYUV:)] ) {
                    [self.delegate mediaPlayer:self width:msg->param2 height:msg->param3 pYUV:(unsigned char *)msg->pObject];
                }
            }else{
            //非全景鱼眼，想要自己处理YUV数据的，使用鱼眼同样的方法取出YUV数据调用 msg->pObject
            }
        }
            break;
        case EMSG_DEV_CMD_EN: {
            if (strcmp(msg->szStr, "StoreSnap") == 0){
                if (msg->param1>=0) {
                    //设备端抓图成功
                }else{
                    //失败
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:storeSnapresult:)]) {
                    [self.delegate mediaPlayer:self storeSnapresult:msg->param1];
                }
            }
        }
            break;
        
        case EMSG_ON_MEDIA_REPLAY:{
          // Отправляем данные для onMediaPlayState
          [self updateState:7];
        }
          break;
        case EMSG_ON_PLAY_END:{
          // Отправляем данные для onMediaPlayState
          [self updateState:4];
        }
          break;
        case EMSG_MEDIA_SETPLAYVIEW:{
          // Отправляем данные для onMediaPlayState
          [self updateState:15];
        }
          break;
        
        default:
            break;
    }
}

@end
