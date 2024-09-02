//
//  SDKInitializeModel.h
//  MobileVideo
//
//  Created by XM on 2018/4/23.
//  Copyright © 2018年 XM. All rights reserved.
//
/***
 SDK初始化类，这几个文件是调用大部分sdk接口所必须要使用或者继承之后使用的父类
 SDKInitializeModel  初始化FunSDK的类文件，SDK必须初始化才能使用其他功能
 这个功能类中的方法请仔细查看，需要注意的地方有详细注释
 
 //使用定制服务器，需要通过下面的方法初始化   "test.com"：定制的域名或者IP， port：定制的端口号
 //FUN_InitExV2(0, &pa, 0, "", "test.com",port);
 
 *****/
#import <Foundation/Foundation.h>

@interface SDKInitializeModel : NSObject

//SDK初始化
+ (void)SDKInit;
@end
