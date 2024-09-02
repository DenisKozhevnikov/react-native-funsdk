//
//  FlipManager.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/8/17.
//  Copyright © 2020 wujiangbo. All rights reserved.
//

#import "FlipManager.h"
#import <FunSDK/FunSDK.h>

@interface FlipManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,strong) NSMutableDictionary *dicRotateInfo;  // 90度旋转配置

@end

@implementation FlipManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

//MARK:获取翻转配置
-(void)getFlipInfo{
    FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "Camera.ParamEx", 1024);
}

//MARK:设置翻转配置
-(void)setFlip{
    int mode = [[self.dicRotateInfo objectForKey:@"CorridorMode"] intValue];
    if (mode + 1 >= 4) {
        mode = 0;
    }else{
        mode++;
    }
    
    [self.dicRotateInfo setObject:[NSNumber numberWithInt:mode] forKey:@"CorridorMode"];
    
    NSDictionary* jsonDic = @{@"Name":@"Camera.ParamEx",@"Camera.ParamEx":@[self.dicRotateInfo]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, CSTR(self.devID), "Camera.ParamEx", [pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1));
    
    [SVProgressHUD show];
}

//MARK: - FunSDKCallBack
-(void)OnFunSDKResult:(NSNumber *)pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (msg->param1>=0 && [OCSTR(msg->szStr) isEqualToString:@"Camera.ParamEx"]){
                if (msg->pObject == NULL) {
                   return;
                }
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
              
                if (jsonDic) {
                   NSArray *array = [jsonDic objectForKey:@"Camera.ParamEx"];
                   if (array.count >= 1) {
                       self.dicRotateInfo = [[array objectAtIndex:0] mutableCopy];
                   }
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            if ([OCSTR(msg->szStr) isEqualToString:@"Camera.ParamEx"]){
                [SVProgressHUD dismiss];
                if (msg->param1 >= 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Success")];
                }else{
                    [SVProgressHUD showErrorWithStatus:TS("Error")];

                }
            }
        }
            break;
        default:
            break;
    }
}

@end
