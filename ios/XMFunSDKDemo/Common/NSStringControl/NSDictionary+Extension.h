//
//  NSDictionary+Extension.h
//   
//
//  Created by Megatron on 2022/9/30.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Extension)

+ (NSDictionary *__nullable)dictionaryFromData:(char *)data;

@end

NS_ASSUME_NONNULL_END
