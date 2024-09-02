//
//  ObjectCoder.h
//  XMEye
//
//  Created by XM on 2018/4/6.
//  Copyright © 2018年 Megatron. All rights reserved.
//
//支持对象序列化的父类，用来保存设备对象到本地

#import <Foundation/Foundation.h>

@interface ObjectCoder : NSObject  <NSCoding,NSCopying,NSMutableCopying>
@end
