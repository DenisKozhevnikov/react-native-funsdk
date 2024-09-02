//
//  DoubleEyesManager.h
//  FunSDKDemo
//
//  Created by feimy on 2024/2/22.
//  Copyright © 2024 feimy. All rights reserved.
//

#import "ConfigControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DoubleEyesSetPTZOffsetCallBack)(int result);

@interface DoubleEyesManager : ConfigControllerBase

@property (nonatomic,copy) DoubleEyesSetPTZOffsetCallBack doubleEyesSetPTZOffsetCallBack;

//MARK: 云台快速定位 （点击画面中的某个位置后，镜头转到对应的位置）
- (void)requestSetPTZDeviceID:(NSString *)devID channel:(int)channel xOffset:(int)xOffset yOffset:(int)yOffset zoomScale:(float)scale completed:(DoubleEyesSetPTZOffsetCallBack)completion;

@end

NS_ASSUME_NONNULL_END
