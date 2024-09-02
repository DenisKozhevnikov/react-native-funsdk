//
//  FunSDKLoginModule.h
//  Funsdk
//
//  Created by Денис Кожевников on 10.08.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKLoginModule : NSObject<RCTBridgeModule>
@interface FunSDKLoginModule : FunMsgListener<RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
