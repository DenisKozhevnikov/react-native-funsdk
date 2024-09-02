//
//  ShareModel.h
//  XWorld
//
//  Created by liuguifang on 16/6/29.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareModel : NSObject

////生成设备关于二维码信息的加密和解密
+(NSString*)encodeDevId:(NSString*)devId userName:(NSString*)username password:(NSString*)pwd type:(int)type;
+(NSArray*)decodeDevInfo:(NSString*)info;


@end
