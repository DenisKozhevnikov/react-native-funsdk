//
//  FunSDKVideoPlayerManager.m
//  Funsdk
//
//  Created by Денис Кожевников on 03.11.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "FunSDKRecordPlayerManager.h"
#import <React/RCTLog.h>

#import "FunSDKRecordPlayer.h"

#import "MediaPlaybackControl.h"

@implementation FunSDKRecordPlayerManager
{
  H264_DVR_FINDINFO Info;
}

RCT_EXPORT_MODULE(RCTDevRecordMonitor)

- (UIView *)view
{
    return [[FunSDKRecordPlayer alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(onStartInit, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onMediaPlayState, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onShowRateAndTime, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoBufferEnd, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFailed, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDebugState, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCapture, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSearchRecordByFilesResult, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onSearchRecordByTimesResult, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDownloadProgress, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDownloadState, RCTDirectEventBlock);

RCT_EXPORT_VIEW_PROPERTY(devId, NSString);
RCT_EXPORT_VIEW_PROPERTY(channelId, NSInteger);
//RCT_EXPORT_VIEW_PROPERTY(streamType, NSInteger);

- (void)performActionOnFunSDKVideoPlayerWithTag:(nonnull NSNumber *)reactTag
                                           action:(void (^)(FunSDKRecordPlayer *view))action {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
      FunSDKRecordPlayer *view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[FunSDKRecordPlayer class]]) {
            RCTLogError(@"Cannot find FunSDKVideoPlayer with tag #%@", reactTag);
            return;
        }
        // Выполнение переданного действия
        if (action) {
            action(view);
        }
    }];
}

RCT_EXPORT_METHOD(init:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view initRecordPlayer];
    }];
}

RCT_EXPORT_METHOD(startPlayRecord:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
//        [view startPlayRecord];
    }];
}

RCT_EXPORT_METHOD(capture:(nonnull NSNumber *)reactTag path:(nonnull NSString *)path) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view capture:path];
    }];
}

RCT_EXPORT_METHOD(startRecord:(nonnull NSNumber *)reactTag path:(nonnull NSString *)path) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view startRecord:path];
    }];
}


RCT_EXPORT_METHOD(stopRecord:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view stopRecord];
    }];
}

RCT_EXPORT_METHOD(isRecording:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view isRecording];
    }];
}

RCT_EXPORT_METHOD(openVoice:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view openVoice];
    }];
}

RCT_EXPORT_METHOD(closeVoice:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view closeVoice];
    }];
}

RCT_EXPORT_METHOD(pausePlay:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view pausePlay];
    }];
}

RCT_EXPORT_METHOD(rePlay:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view rePlay];
    }];
}

RCT_EXPORT_METHOD(stopPlay:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view stopPlay];
    }];
}

RCT_EXPORT_METHOD(isRecordPlay:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view isRecordPlay];
    }];
}

RCT_EXPORT_METHOD(downloadFile:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view downloadFile];
    }];
}

RCT_EXPORT_METHOD(setPlaySpeed:(nonnull NSNumber *)reactTag playSpeed:(nonnull NSNumber *)playSpeed) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
      [view setPlaySpeed:[playSpeed intValue]];
    }];
}

RCT_EXPORT_METHOD(startPlayRecordByTime:(nonnull NSNumber *)reactTag start:(nonnull NSDictionary *)start end:(nonnull NSDictionary *)end) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKRecordPlayer *view) {
        [view startPlayRecordByTime:start end:end];
    }];
}

@end
