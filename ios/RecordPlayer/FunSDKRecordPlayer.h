//
//  FunSDKRecordPlayer.h
//  Funsdk
//
//  Created by Денис Кожевников on 03.11.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTView.h"
#import "MediaPlaybackControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface FunSDKRecordPlayer : UIView<MediaplayerControlDelegate, MediaPlayBackControlDelegate>
//@interface FunSDKRecordPlayer : UIView <MediaPlayBackControlDelegate>

@property (nonatomic, strong) MediaPlaybackControl *mediaPlayer;
@property (nonatomic, assign) BOOL isInited;

@property (nonatomic, strong) NSString* devId;
@property (nonatomic, assign) NSInteger channelId;
//@property (nonatomic, assign) NSInteger streamType;
//
@property (nonatomic, copy) RCTBubblingEventBlock onStartInit;
@property (nonatomic, copy) RCTBubblingEventBlock onMediaPlayState;
@property (nonatomic, copy) RCTBubblingEventBlock onShowRateAndTime;
@property (nonatomic, copy) RCTBubblingEventBlock onVideoBufferEnd;
@property (nonatomic, copy) RCTBubblingEventBlock onFailed;
@property (nonatomic, copy) RCTBubblingEventBlock onDebugState;
@property (nonatomic, copy) RCTBubblingEventBlock onCapture;
@property (nonatomic, copy) RCTBubblingEventBlock onSearchRecordByFilesResult;
@property (nonatomic, copy) RCTBubblingEventBlock onSearchRecordByTimesResult;
@property (nonatomic, copy) RCTBubblingEventBlock onDownloadProgress;
@property (nonatomic, copy) RCTBubblingEventBlock onDownloadState;

- (void) initRecordPlayer;
- (void) capture:(NSString *)path;
- (void) startRecord:(NSString *)path;
- (void) stopRecord;
- (void) isRecording;
- (void) openVoice;
- (void) closeVoice;
- (void) pausePlay;
- (void) rePlay;
- (void) stopPlay;
- (void) isRecordPlay;
- (void) downloadFile; // TODO:       int position = args.getInt(0);       String path = args.getString(1);


- (void) setPlaySpeed:(int)speed;

- (void) startPlayRecordByTime:(NSDictionary *)start end:(NSDictionary *)end;
- (void) seekToTime:(NSNumber *)addtime nAbsTime:(NSNumber *)nAbsTime;
//- (void) updateStreamTypeMonitor:(NSNumber *)streamType;
//- (void) setVideoFullScreen:(BOOL)isFullScreen;
//- (void) capturePicFromDevAndSave;

@end

NS_ASSUME_NONNULL_END
