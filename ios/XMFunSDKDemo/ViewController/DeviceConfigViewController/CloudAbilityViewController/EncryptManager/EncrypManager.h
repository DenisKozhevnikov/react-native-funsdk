//
//  EncrypManager.h
//  XWorld_General
//
//  Created by Megatron on 2019/10/12.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EncrypManager : NSObject

//MARK: DES加密解密
+ (NSString *)encodeDesWithString:(NSString *)str;
+ (NSString *)decodeDesWithString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
