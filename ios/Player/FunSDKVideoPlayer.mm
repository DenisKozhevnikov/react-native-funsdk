//
//  FunSDKVideoPlayer.m
//  react-native-funsdk
//
//  Created by Денис Кожевников on 31.08.2024.
//

#import "React/RCTConvert.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTEventDispatcher.h"
#import "React/UIView+React.h"
#import "FunSDKVideoPlayer.h"
#import "TalkBackControl.h"

#import "MediaplayerControl.h"

@interface FunSDKVideoPlayer()

@end

@implementation FunSDKVideoPlayer
// Без этого не будет работать вывод видео с камеры
+(Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)initializeTalkControl {
    if (!self.talkControl) {
        self.talkControl = [[TalkBackControl alloc] init];
        self.talkControl.deviceMac = self.devId;
        self.talkControl.channel = (int) self.channelId;
        self.talkControl.handle = self.mediaPlayer.msgHandle;
    }
}


- (void) startMonitor {

    if (!self.isInited) {
        self.onStartInit(@{
            @"target": self.reactTag,
            @"status": @"start",
        });
        self.mediaPlayer = [[MediaplayerControl alloc] init];

        self.mediaPlayer.devID = self.devId;
        self.mediaPlayer.channel = (int) self.channelId;
        self.mediaPlayer.stream = (int) self.streamType;
        self.mediaPlayer.renderWnd = self;
        self.mediaPlayer.delegate = self;
        
        [self initializeTalkControl];

        self.isInited = true;
        [self.mediaPlayer start];
    } else {
        [self.mediaPlayer start];
    }
}

- (void) pauseMonitor {
    if(self.mediaPlayer) {
        [self.mediaPlayer pause];
    }
}

- (void) replayMonitor {
    [self.mediaPlayer resumue];
}

- (void) stopMonitor {
    [self.mediaPlayer stop];
}

- (void) destroyMonitor {
    // TODO: ??
}

- (void) captureImage:(NSString *)path {
    if (path) {
        [self.mediaPlayer snapImage:path];
    } else {
        [self.mediaPlayer snapImage];
    }
}

- (void) getStreamType {
    if (self.mediaPlayer) {
        self.onGetInfo(@{
            @"target": self.reactTag,
            @"type": @"streamType",
            @"streamType": @(self.mediaPlayer.stream)
        });
    }
}

- (void) startVideoRecord:(NSString *)path {
    if(path) {
        [self.mediaPlayer startRecord:path];
    } else {
        [self.mediaPlayer startRecord];
    }

}

- (void) stopVideoRecord {
    [self.mediaPlayer stopRecord];
}

- (void) openVoice {
    [self.mediaPlayer openSound:100];
}

- (void) closeVoice {
    [self.mediaPlayer closeSound];
}
//#import "TalkBackControl.h"
- (void) startSingleIntercomAndSpeak {
    [self initializeTalkControl];
    
    self.talkControl.handle = self.mediaPlayer.msgHandle;
    self.talkControl.pitchSemiTonesType = PitchSemiTonesNormal;
    [self.talkControl startTalk];
}

- (void) stopSingleIntercomAndSpeak {
    [self initializeTalkControl];
    
    self.talkControl.handle = self.mediaPlayer.msgHandle;
    [self.talkControl closeTalk];
    
}

- (void) startDoubleIntercom {
    [self initializeTalkControl];
    
    self.talkControl.pitchSemiTonesType = PitchSemiTonesNormal;
    [self.talkControl startDouTalk:YES];
}

- (void) stopDoubleIntercom {
    [self initializeTalkControl];
    
    [self.talkControl stopDouTalk];
}

- (void) switchStreamTypeMonitor {
    if (self.mediaPlayer) {
        self.mediaPlayer.stream = !self.mediaPlayer.stream;
        
        [self.mediaPlayer stop];
        [self.mediaPlayer start];
    }
}

- (void) updateStreamTypeMonitor:(NSNumber *)streamType {
    if (self.mediaPlayer) {
        self.mediaPlayer.stream = [streamType intValue];
        
        [self.mediaPlayer stop];
        [self.mediaPlayer start];
    }
}

- (void) setVideoFullScreen:(BOOL)isFullScreen {
//  TODO: Надо ли?
}

- (void) capturePicFromDevAndSave {
    [self.mediaPlayer StoreSnap];
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startResult:(int)result DSSResult:(int)dssResult {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer buffering:(BOOL)isBuffering ratioDetail:(double)ratioDetail {
    if (self.mediaPlayer) {
        self.onVideoBufferEnd(@{
            @"target": self.reactTag,
            @"isBufferEnd": @(isBuffering)
        });
    }
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer info1:(int)nInfo info2:(NSString*)strInfo {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer pauseOrResumeResult:(int)result {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer stopResult:(int)result {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl *)mediaPlayer timeInfo:(int)timeinfo {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer DevTime:(NSString *)time {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer refreshPlayResult:(int)result {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer width:(int)width htight:(int)height {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startRecordResult:(int)result path:(NSString*)path {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer stopRecordResult:(int)result path:(NSString*)path {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer snapImagePath:(NSString *)path result:(int)result {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer thumbnailImagePath:(NSString *)path result:(int)result {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer storeSnapresult:(int)result {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer Hardandsoft:(int)Hardandsoft Hardmodel:(int)Hardmodel {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer width:(int)width height:(int)height pYUV:(unsigned char *)pYUV {
    // TODO: add
}

-(void)centerOffSetX:(MediaplayerControl*)mediaPlayer  offSetx:(short)OffSetx offY:(short)OffSetY  radius:(short)radius width:(short)width height:(short)height {
    // TODO: add
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer AnalyzelLength:(int)length site:(int)type Analyzel:(char*)area {
    // TODO: add
}

@end
