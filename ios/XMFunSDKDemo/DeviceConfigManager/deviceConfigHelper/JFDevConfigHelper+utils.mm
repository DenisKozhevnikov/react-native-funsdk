//
//  JFDevConfigHelper+utils.m
//  FunSDKDemo
//
//  Created by coderXY on 2023/7/27.
//  Copyright © 2023 coderXY. All rights reserved.
//

#import "JFDevConfigHelper+utils.h"

@implementation JFDevConfigHelper (utils)
// MARK: 数据解析
- (NSDictionary *)jf_jsonHandleWithMsgObj:(const char*)msgObj{
    id resultDic = nil;
    // 1、规避返回数据空
    if(NULL == msgObj) return resultDic;
    NSString *jsonMsgObjStr = OCSTR(msgObj);
    // 2、去除返回数据中的换行符、转义字符
    jsonMsgObjStr = [jsonMsgObjStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonMsgObjStr = [jsonMsgObjStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSData *jsonData = [jsonMsgObjStr dataUsingEncoding:NSUTF8StringEncoding];
    // 3、规避处理后的字符串转义为data异常
    if(!jsonData) return resultDic;
    NSError *error = nil;
    resultDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    // 4、规避返回其他类型数据
    if(resultDic && [resultDic isKindOfClass:[NSDictionary class]]) return resultDic;
    return nil;
}

@end
