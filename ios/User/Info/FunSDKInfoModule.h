//
//  FunSDKInfoModule.h
//  Funsdk
//
//  Created by Денис Кожевников on 10.10.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKDevListConnectModule : NSObject<RCTBridgeModule>
@interface FunSDKInfoModule : FunMsgListener<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
