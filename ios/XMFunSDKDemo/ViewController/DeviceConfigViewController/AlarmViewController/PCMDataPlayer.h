//
//  PCMDataPlayer.h
//  XWorld_General
//
//  Created by Megatron on 2019/3/28.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>

#define QUEUE_BUFFER_SIZE 3//队列缓冲个数

#define MIN_SIZE_PER_FRAME 2048//每帧最小数据长度

@interface PCMDataPlayer :NSObject {
    
        AudioStreamBasicDescription audioDescription;///音频参数
    
        AudioQueueRef audioQueue;//音频播放队列
    
        AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];//音频缓存
    
        BOOL audioQueueUsed[QUEUE_BUFFER_SIZE];
    
        NSLock* sysnLock;
    
}

/*!
 
  *  @brief 重置播放器
 
  */

- (void)reset;

- (void)stop;

- (void)play:(void*)pcmData length:(unsigned int)length;

@end

