//
//  FunSDKRecordPlayer.m
//  Funsdk
//
//  Created by Денис Кожевников on 03.11.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import "React/RCTConvert.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTEventDispatcher.h"
#import "React/UIView+React.h"
#import "FunSDKRecordPlayer.h"

#import "MediaPlaybackControl.h"

@interface FunSDKRecordPlayer()

@end

@implementation FunSDKRecordPlayer

+(Class)layerClass{
    return [CAEAGLLayer class];
}

- (void) initRecordPlayer {
  self.onStartInit(@{
      @"target": self.reactTag,
      @"status": @"start",
  });
  
  self.mediaPlayer = [[MediaPlaybackControl alloc] init];
  self.mediaPlayer.devID = self.devId;
  self.mediaPlayer.channel = (int) self.channelId;
//  self.mediaPlayer.stream = (int) self.streamType;
  self.mediaPlayer.stream = 1;
  self.mediaPlayer.renderWnd = self;
  self.mediaPlayer.delegate = self;
  self.mediaPlayer.playbackDelegate = self;
  
  self.isInited = true;
  
  self.onStartInit(@{
      @"target": self.reactTag,
      @"status": @"initialized"
  });
}

- (void) startPlayRecord {
  // TODO: ??
}

- (void) capture:(NSString *)path {
  if (path) {
    [self.mediaPlayer snapImage:path];
  } else {
    [self.mediaPlayer snapImage];
  }
}

- (void) startRecord:(NSString *)path {
  if(path) {
    [self.mediaPlayer startRecord:path];
  } else {
    [self.mediaPlayer startRecord];
  }
}

- (void) stopRecord {
  [self.mediaPlayer stopRecord];
}

- (void) isRecording {
  // TODO: ??
}

- (void) openVoice {
  [self.mediaPlayer openSound:100];
}

- (void) closeVoice {
  [self.mediaPlayer closeSound];
}

- (void) pausePlay {
  if(self.mediaPlayer) {
      [self.mediaPlayer pause];
  }
}

- (void) rePlay {
  [self.mediaPlayer resumue];
}

- (void) stopPlay {
  [self.mediaPlayer stop];
}

- (void) isRecordPlay {
  // TODO: ??
}

- (void) downloadFile {
  // TODO: ??
}

// speed 0 == x1, speed 1 == x2, speed 2 == x4
- (void) setPlaySpeed:(int)speed {
  [self.mediaPlayer setPlaySpeed:speed];
}

// cloud?
- (void) startPlayCloudRecordByTime:(NSDictionary *)start end:(NSDictionary *)end {
  [self.mediaPlayer startPlayCloudVideo2:start endDate:end];
}

- (void) startPlayRecordByTime:(NSDictionary *)start end:(NSDictionary *)end {
  [self.mediaPlayer startPlayBack2:start endDate:end];
}

- (void)seekToTime:(NSInteger)addtime {
  [self.mediaPlayer seekToTime:addtime];
}

- (void)refresh {
  [self.mediaPlayer refresh];
}

- (void)mediaPlayer:(MediaplayerControl*)mediaPlayer didUpdateState:(int)state {
  self.onMediaPlayState(@{
    @"target": self.reactTag,
    @"state": @(state),
  });
}

-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer didShowRateAndTime:(NSString *)time rate:(NSString *)rate {
  self.onShowRateAndTime(@{
    @"target": self.reactTag,
    @"time": time,
    @"rate": rate,
  });
}

- (void)mediaPlayer:(MediaplayerControl *)mediaPlayer didBufferEnd:(BOOL)bufferEnded {
  self.onVideoBufferEnd(@{
    @"target": self.reactTag,
    @"isBufferEnd": @(bufferEnded)
  });
}

-(void)mediaPlayer:(MediaplayerControl *)mediaPlayer didFailed:(int)msgId errorId:(int)errorId {
  self.onFailed(@{
    @"target": self.reactTag,
    @"msgId": @(msgId),
    @"errorId": @(errorId)
  });
}

@end
