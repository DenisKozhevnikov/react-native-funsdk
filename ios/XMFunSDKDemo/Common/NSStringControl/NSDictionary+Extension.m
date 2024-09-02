//
//  NSDictionary+Extension.m
//   
//
//  Created by Megatron on 2022/9/30.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

+ (NSDictionary *__nullable)dictionaryFromData:(char *)data{
    if (data == NULL) {
        return nil;
    }
    
    NSData *jsonData = [NSData dataWithBytes:data length:strlen(data)];
    NSError *error;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        return nil;
    }
    
    return jsonDic;
}

@end
