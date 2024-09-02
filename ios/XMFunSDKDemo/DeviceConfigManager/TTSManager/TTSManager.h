//
//  TTSManager.h
//  XWorld_General
//
//  Created by Megatron on 2019/12/27.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TransformToVoiceResult)(int result,BOOL fileSizeTooLarge);

@interface TTSManager : NSObject

@property (nonatomic,copy) TransformToVoiceResult transformToVoiceResult;

//MARK: 文字转语音
- (void)transformTextToVoice:(NSString *)content female:(BOOL)ifFemale completion:(TransformToVoiceResult)completed;

@end

