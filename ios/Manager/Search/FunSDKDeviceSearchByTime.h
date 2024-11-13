//
//  FunSDKDeviceSearchByTime.h
//  Funsdk
//
//  Created by Денис Кожевников on 03.11.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKDeviceSearchByTime : NSObject<RCTBridgeModule>
@interface FunSDKDeviceSearchByTime : FunMsgListener<RCTBridgeModule>

- (void) updateStreamTypeMonitor:(SDK_SearchByTimeResult *)result;

@end

NS_ASSUME_NONNULL_END
