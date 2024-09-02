//
//  FunSDKVideoView.m
//  react-native-funsdk
//
//  Created by Денис Кожевников on 31.08.2024.
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "FunSDKVideoPlayerManager.h"
#import <React/RCTLog.h>

#import "FunSDKVideoPlayer.h"

#import "MediaplayerControl.h"

@implementation FunSDKVideoPlayerManager

RCT_EXPORT_MODULE(RCTMonitor)

//@synthesize bridge = _bridge;

- (UIView *)view
{
    return [[FunSDKVideoPlayer alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(onStartInit, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onMediaPlayState, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onShowRateAndTime, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onVideoBufferEnd, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onGetInfo, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFailed, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDebugState, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCapture, RCTDirectEventBlock);

RCT_EXPORT_VIEW_PROPERTY(devId, NSString);
RCT_EXPORT_VIEW_PROPERTY(channelId, NSInteger);
RCT_EXPORT_VIEW_PROPERTY(streamType, NSInteger);

- (void)performActionOnFunSDKVideoPlayerWithTag:(nonnull NSNumber *)reactTag
                                           action:(void (^)(FunSDKVideoPlayer *view))action {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        FunSDKVideoPlayer *view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[FunSDKVideoPlayer class]]) {
            RCTLogError(@"Cannot find FunSDKVideoPlayer with tag #%@", reactTag);
            return;
        }
        // Выполнение переданного действия
        if (action) {
            action(view);
        }
    }];
}

RCT_EXPORT_METHOD(startMonitor:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view startMonitor];
    }];
}

RCT_EXPORT_METHOD(pauseMonitor:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view pauseMonitor];
    }];
}

RCT_EXPORT_METHOD(replayMonitor:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view replayMonitor];
    }];
}

RCT_EXPORT_METHOD(stopMonitor:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view stopMonitor];
    }];
}

RCT_EXPORT_METHOD(destroyMonitor:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view destroyMonitor];
    }];
}

RCT_EXPORT_METHOD(captureImage:(nonnull NSNumber *)reactTag path:(nonnull NSString *)path) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view captureImage:path];
    }];
}

RCT_EXPORT_METHOD(getStreamType:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view getStreamType];
    }];
}

RCT_EXPORT_METHOD(startVideoRecord:(nonnull NSNumber *)reactTag path:(nonnull NSString *)path) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view startVideoRecord:path];
    }];
}

RCT_EXPORT_METHOD(stopVideoRecord:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view stopVideoRecord];
    }];
}

RCT_EXPORT_METHOD(openVoice:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view openVoice];
    }];
}

RCT_EXPORT_METHOD(closeVoice:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view closeVoice];
    }];
}

RCT_EXPORT_METHOD(startSingleIntercomAndSpeak:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view startSingleIntercomAndSpeak];
    }];
}
RCT_EXPORT_METHOD(stopSingleIntercomAndSpeak:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view stopSingleIntercomAndSpeak];
    }];
}
RCT_EXPORT_METHOD(startDoubleIntercom:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view startDoubleIntercom];
    }];
}
RCT_EXPORT_METHOD(stopDoubleIntercom:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view stopDoubleIntercom];
    }];
}

RCT_EXPORT_METHOD(switchStreamTypeMonitor:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view switchStreamTypeMonitor];
    }];
}

RCT_EXPORT_METHOD(updateStreamTypeMonitor:(nonnull NSNumber *)reactTag streamType:(nonnull NSNumber *)streamType) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view updateStreamTypeMonitor:streamType];
    }];
}

RCT_EXPORT_METHOD(setVideoFullScreen:(nonnull NSNumber *)reactTag isFullScreen:(nonnull BOOL*)isFullScreen) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view setVideoFullScreen:isFullScreen];
    }];
}

RCT_EXPORT_METHOD(capturePicFromDevAndSave:(nonnull NSNumber *)reactTag) {
    [self performActionOnFunSDKVideoPlayerWithTag:reactTag action:^(FunSDKVideoPlayer *view) {
        [view capturePicFromDevAndSave];
    }];
}

@end
