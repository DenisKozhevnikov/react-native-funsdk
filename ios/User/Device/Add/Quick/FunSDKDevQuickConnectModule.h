//
//  FunSDKDevQuickConnectModule.h
//  Funsdk
//
//  Created by Денис Кожевников on 08.12.2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

//@interface FunSDKDevQuickConnectModule : NSObject<RCTBridgeModule>
//@interface FunSDKDevQuickConnectModule : FunMsgListener<RCTBridgeModule>
@interface FunSDKDevQuickConnectModule : RCTEventEmitter<RCTBridgeModule>

//- (void)addListener:(NSString *)type;
//- (void)removeListeners:(NSString *)type;

@end

@protocol FunSDKResultDelegate <NSObject>

@required
-(void)OnFunSDKResult:(NSNumber *)pParam;

@end

NS_ASSUME_NONNULL_END

