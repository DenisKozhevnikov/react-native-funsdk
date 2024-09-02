//
//  SensorDeviceModel.h
//  FunSDKDemo
//
//  Created by Megatron on 2019/3/29.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorDeviceModel : NSObject

@property (nonatomic,strong) NSMutableDictionary *dicListInfo;
@property (nonatomic,assign) BOOL ifOnline;
@property (nonatomic,strong) NSMutableDictionary *dicStatusInfo;

@end

NS_ASSUME_NONNULL_END
