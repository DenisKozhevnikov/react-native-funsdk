//
//  FunSDKDevLanConnectModule.h
//  Funsdk
//
//  Created by Денис Кожевников on 05.06.2025.
//  Copyright © 2025 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKDevLanConnectModule : NSObject<RCTBridgeModule>
@interface FunSDKDevLanConnectModule : FunMsgListener<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
