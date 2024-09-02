//
//  FunSDKVideoPlayer.h
//  Pods
//
//  Created by Денис Кожевников on 31.08.2024.
//

#import <Foundation/Foundation.h>
#import "React/RCTView.h"
#import "MediaplayerControl.h"
#import "TalkBackControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface FunSDKVideoPlayer : UIView <MediaplayerControlDelegate>

@property (nonatomic, strong) MediaplayerControl *mediaPlayer;
@property (nonatomic, strong) TalkBackControl *talkControl;
@property (nonatomic, assign) BOOL isInited;

@property (nonatomic, strong) NSString* devId;
@property (nonatomic, assign) NSInteger channelId;
@property (nonatomic, assign) NSInteger streamType;

@property (nonatomic, copy) RCTBubblingEventBlock onStartInit;
@property (nonatomic, copy) RCTBubblingEventBlock onMediaPlayState;
@property (nonatomic, copy) RCTBubblingEventBlock onShowRateAndTime;
@property (nonatomic, copy) RCTBubblingEventBlock onVideoBufferEnd;
@property (nonatomic, copy) RCTBubblingEventBlock onGetInfo;
@property (nonatomic, copy) RCTBubblingEventBlock onFailed;
@property (nonatomic, copy) RCTBubblingEventBlock onDebugState;
@property (nonatomic, copy) RCTBubblingEventBlock onCapture;

- (void) startMonitor;
- (void) pauseMonitor;
- (void) replayMonitor;
- (void) stopMonitor;
- (void) destroyMonitor;
- (void) captureImage:(NSString *)path;
- (void) getStreamType;
- (void) startVideoRecord:(NSString *)path;
- (void) stopVideoRecord;
- (void) openVoice;
- (void) closeVoice;
- (void) startSingleIntercomAndSpeak;
- (void) stopSingleIntercomAndSpeak;
- (void) startDoubleIntercom;
- (void) stopDoubleIntercom;
- (void) switchStreamTypeMonitor;
- (void) updateStreamTypeMonitor:(NSNumber *)streamType;
- (void) setVideoFullScreen:(BOOL)isFullScreen;
- (void) capturePicFromDevAndSave;

@end

NS_ASSUME_NONNULL_END
