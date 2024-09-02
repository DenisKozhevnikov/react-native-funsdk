//
//  VoiceBroadcastingManager.h
//  FunSDKDemo
//
//  Created by plf on 2023/6/3.
//  Copyright © 2023 plf. All rights reserved.
//

#import "FunMsgListener.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^GetAllAudioClockListCallBack)(NSDictionary *dic);

@interface VoiceBroadcastingManager : FunMsgListener

@property (nonatomic,copy) NSString *devID;

@property (nonatomic,assign) int channelNum;

@property (nonatomic,copy) GetAllAudioClockListCallBack getAllAudioClockListCallBack;
-(void)getAllAudioClockList:(GetAllAudioClockListCallBack)callBack;

@end

NS_ASSUME_NONNULL_END
