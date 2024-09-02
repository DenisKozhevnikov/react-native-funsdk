//
//  WifiConfigDataSource.h
//  FunSDKDemo
//
//  Created by zhang on 2019/6/12.
//  Copyright © 2019 zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WifiConfigDataSource : NSObject

@property (nonatomic, copy) NSString *SSID;

@property (nonatomic, copy) NSString *Auth;

@property (nonatomic, copy) NSString *EncrypType;

@property (nonatomic, copy) NSString *NetType;

@property (nonatomic, assign) int RSSI;

@property (nonatomic, assign) int Channel;

@end

NS_ASSUME_NONNULL_END
