//
//  FunSDKDevStatusModule.h
//  Pods
//
//  Created by Денис Кожевников on 18.08.2024.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKDevStatusModule : NSObject<RCTBridgeModule>
@interface FunSDKDevStatusModule : FunMsgListener<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
