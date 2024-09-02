//
//  GetStorageHeadDataConfig.h
//  XMEye
//
//  Created by zhang on 2019/6/10.
//  Copyright © 2019 Megatron. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetStorageHeadDataConfig : NSObject

@property (nonatomic, copy) NSString *deviceMac;


@property (nonatomic, copy) void (^getHeaderDataBlock)(NSInteger result);

- (void)getStorageHeadDataConfig:(NSString*)offset;

@end

NS_ASSUME_NONNULL_END
