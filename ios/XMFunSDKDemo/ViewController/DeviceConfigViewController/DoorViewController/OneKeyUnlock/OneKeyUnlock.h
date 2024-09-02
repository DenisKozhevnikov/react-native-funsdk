//
//  OneKeyUnlock.h
//  FunSDKDemo
//
//  Created by plf on 2022/6/23.
//  Copyright © 2022 plf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface OneKeyUnlock : NSObject
+(instancetype)shareInstance;

-(void)oneKeyUnlock;
@end

NS_ASSUME_NONNULL_END
