//
//  FunSDKDevConfigModule.h
//  Funsdk
//
//  Created by Денис Кожевников on 15.01.2025.
//  Copyright © 2025 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKDevConfigModule : NSObject<RCTBridgeModule>
@interface FunSDKDevConfigModule : FunMsgListener<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
