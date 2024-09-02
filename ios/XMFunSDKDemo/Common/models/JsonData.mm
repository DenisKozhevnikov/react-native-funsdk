//
//  JsonData.m
//  XMEye
//
//  Created by 杨翔 on 2019/3/26.
//  Copyright © 2019 Megatron. All rights reserved.
//

#import "JsonData.h"
#import "FunSDK/FunSDK.h"
#import "FunSDK/netsdk.h"
#include <iostream>
#include <vector>

@implementation JsonData

+(NSData *)parseMsgObject:(char *)data{
    NSString *jsonString = [JsonData isJsonData:data];
    NSData *transformData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return transformData;
}

+(NSString *)isJsonData:(char *)data{
    if (IsJsonData(data)) {
        char *pObjectType = strrchr(data, '}');
        
        if(pObjectType){
            *(++pObjectType)= '\0';
            return [[NSString alloc]initWithUTF8String:data];
        }
    }
    return nil;
}

bool IsJsonData(std::string strData)
{
    if (strData[0] != '{')
        return false;
    
    int num = 1;
    for (int i=1; i<strData.length(); ++i)
    {
        if (strData[i] == '{')
        {
            ++num;
        }
        else if (strData[i] == '}')
        {
            --num;
        }
        
        if (num == 0)
        {
            return true;
        }
    }
    
    return false;
}



@end
