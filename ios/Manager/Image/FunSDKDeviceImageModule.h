//
//  FunSDKDeviceImageModule.h
//  Pods
//
//  Created by Денис Кожевников on 11.11.2024.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKDeviceImageModule : NSObject<RCTBridgeModule>
@interface FunSDKDeviceImageModule : FunMsgListener<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
