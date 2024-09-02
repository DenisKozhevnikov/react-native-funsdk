//
//  JsonData.h
//  XMEye
//
//  Created by 杨翔 on 2019/3/26.
//  Copyright © 2019 Megatron. All rights reserved.
//

/**
 判断是不是json数据
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface JsonData : NSObject

//+(NSString *)isJsonData:(char *)data;

+(NSData *)parseMsgObject:(char *)data;

@end

