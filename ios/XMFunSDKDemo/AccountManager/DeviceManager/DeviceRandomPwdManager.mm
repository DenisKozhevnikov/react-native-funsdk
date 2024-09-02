//
//  DeviceRandomPwdManager.m
//  XWorld_General
//
//  Created by wujiangbo on 2021/9/8.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "DeviceRandomPwdManager.h"
#import <FunSDK/FunSDK.h>
#import <FunSDK/FunSDK2.h>
#import "DeviceManager.h"
#import "SystemInfoManager.h"

@interface DeviceRandomPwdManager ()

@property (nonatomic, assign) int msgHandle;

@property (nonatomic, strong) NSMutableDictionary *devRandomPwdDataSource;

@property (nonatomic,assign) BOOL needTryAgain;

@property (nonatomic,copy) NSString *devID;

@property (nonatomic,copy) NSString *lastDevID;
@property (nonatomic,copy) NSString *lastUserName;
@property (nonatomic,copy) NSString *lastPassword;
//设备信息管理者
@property (nonatomic,strong) SystemInfoManager *systemInfoManager;
//忽略自动设置随机用户名和密码
@property (nonatomic,assign) BOOL ignoreAutoSetUserNamePassword;

@end

@implementation DeviceRandomPwdManager

-(void)getDeviceRandomPwd:(NSString *)devID autoSetUserNameAndPassword:(BOOL)autoSet Completion:(GetDevPwdResult)completion{
    self.getDevPwdResult = completion;
    self.ignoreAutoSetUserNamePassword = autoSet ? NO : YES;
    self.devID = devID;
    self.needTryAgain = YES;
    Fun_DevConfigJson_NotLoginPtl(self.msgHandle, CSTR(devID), "GetRandomUser", NULL, 1660 ,-1 ,0, 5000, 0);
}

-(void)getDeviceRandomPwd:(NSString *)devID autoSetUserNameAndPassword:(BOOL)autoSet WithTryAgain:(BOOL)tryAgain Completion:(GetDevPwdResult)completion{
    self.getDevPwdResult = completion;
    self.ignoreAutoSetUserNamePassword = autoSet ? NO : YES;
    self.devID = devID;
    self.needTryAgain = tryAgain;
    Fun_DevConfigJson_NotLoginPtl(self.msgHandle, CSTR(devID), "GetRandomUser", NULL, 1660 ,-1 ,0, 5000, 0);
}

-(NSDictionary *)getDeviceRandomPwdFromLocal:(NSString *)devID{
    if ([[self.devRandomPwdDataSource allKeys] containsObject:devID]) {
        return [self.devRandomPwdDataSource objectForKey:devID];
    }else{
        NSDictionary *dic = @{@"userName":@"admin",@"password":@"",@"random":[NSNumber numberWithBool:NO]};
        return dic;
    }
}

-(void)ChangeRandomUserWithDevID:(NSString *)devID newUser:(NSString *)newUser newPassword:(NSString *)newPassword result:(ChangeRandomUserResult)result
{
    self.lastDevID = devID;
    self.lastUserName= newUser;
    self.lastPassword = newPassword;
    
    self.changeRandomUserResult = result;
    self.devID = devID;
    NSMutableDictionary *dic = [[self getDeviceRandomPwdFromLocal:devID] mutableCopy];
    NSString *sRandomUser = [dic objectForKey:@"userName"];
    NSString *sRandomPwd = [dic objectForKey:@"password"];
    NSDictionary* jsonDic1 = @{@"RandomName":sRandomUser,@"RandomPwd":sRandomPwd,@"NewName":newUser,@"NewPwd":newPassword};
    NSError *error;
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    Fun_DevConfigJson_NotLoginPtl(self.msgHandle, [devID UTF8String], "ChangeRandomUser", [pCfgBufString1 UTF8String], 1660, -1, true);
}

#pragma mark - sdk回调
-(void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CONFIG_JSON_NOT_LOGIN:{
            if ([OCSTR(msg->szStr) isEqualToString:@"ChangeRandomUser"]) {
                if (msg->param1 >= 0) {
                    //将修改成功的密码同步到本地
                    [[DeviceManager getInstance] changeDeviceUserNamePasswordLocal:self.lastDevID userName:self.lastUserName password:self.lastPassword];
                    
                    __weak typeof(self) weakSelf = self;
   
                    int result = msg->param1;
                    NSString *jsonStr = OCSTR(msg->pObject);
                    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    
                    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if (dic) {
                        NSString *adminToken = [dic objectForKey:@"AdminToken"];
                        NSString *guestToken = [dic objectForKey:@"GuestToken"];
                        if (weakSelf.changeRandomUserResult) {
                            weakSelf.changeRandomUserResult(result,adminToken,guestToken);
                        }
                    }else{
                        if (weakSelf.changeRandomUserResult) {
                            weakSelf.changeRandomUserResult(result,@"",@"");
                        }
                    }
                }else{
                    if (self.changeRandomUserResult) {
                        self.changeRandomUserResult(msg->param1,@"",@"");
                    }
                }
            }else if ([OCSTR(msg->szStr) isEqualToString:@"GetRandomUser"]){
                //GetRandomUser的回调
                if (msg->param1 >= 0) {
                    Fun_Log((char *)"快速配置流程：获取随机用户名密码成功 \n");
                    
                    //如果没有获取到数据，那就当做普通设备，按照一般流程继续添加
                    if (msg->pObject == NULL) {
                        NSDictionary *dic = @{@"userName":@"admin",@"password":@"",@"random":[NSNumber numberWithBool:NO]};
                        [self saveDevRandomPwdToLocalDataSource:dic];
                        return;
                    }
                    NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                    if ( data == nil ){
                        NSDictionary *dic = @{@"userName":@"admin",@"password":@"",@"random":[NSNumber numberWithBool:NO]};
                        [self saveDevRandomPwdToLocalDataSource:dic];
                        return;
                    }
                    NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    if ( appData == nil || [appData isKindOfClass:[NSNull class]]) {
                        NSDictionary *dic = @{@"userName":@"admin",@"password":@"",@"random":[NSNumber numberWithBool:NO]};
                        [self saveDevRandomPwdToLocalDataSource:dic];
                        return;
                    }

                    NSLog(@"appData = %@",appData);
                    NSDictionary *randomUserDic = [appData valueForKey:@"GetRandomUser"];
                    //是否支持自动修改随机用户名密码
                    BOOL supportAutoChangeRandomAcc = [[randomUserDic objectForKey:@"AutoChangeRandomAcc"] boolValue];
                    NSString *randomUserStr = @"";
                    if (randomUserDic == nil) {
                        NSDictionary *dic = @{@"userName":@"admin",@"password":@"",@"random":[NSNumber numberWithBool:NO]};
                        [self saveDevRandomPwdToLocalDataSource:dic];
                    }else{
                        randomUserStr = [randomUserDic objectForKey:@"Info"];
                        char randomUserData[512] = {0};
                        Fun_DecDevRandomUserInfo([self.devID UTF8String],[randomUserStr UTF8String], randomUserData);
                        NSString *str = [NSString stringWithFormat:@"%s",randomUserData];
                        NSArray *arr = [str componentsSeparatedByString:@" "];
                        if(str.length > 0 && arr.count > 0){
                            NSString *sRandomUser = [[arr objectAtIndex:0] substringFromIndex:3];
                            NSString *sRandomPwd = [[arr objectAtIndex:1] substringFromIndex:3];
                            if (sRandomUser.length > 0 && sRandomPwd.length >0) {
                                NSDictionary *dic = @{@"userName":sRandomUser,@"password":sRandomPwd,@"random":[NSNumber numberWithBool:YES]};
                                [[DeviceManager getInstance] changeDeviceUserNamePasswordLocal:self.devID userName:sRandomUser password:sRandomPwd];
                                NSLog(@"cycy= 获取随机用户名密码成功 %@ %@",sRandomUser,sRandomPwd);
                                //先去登录设备 判断是否是支持token的设备
                                __weak typeof(self) weakSelf = self;
                                Fun_Log((char *)"快速配置流程：获取随机用户名密码成功 去登录设备 判断是否是支持token的设备 \n");
                                [self.systemInfoManager getSystemInfo:self.devID Completion:^(int result) {
                                    if (result < 0){
                                        Fun_Log((char *)"快速配置流程：登录设备失败 \n");
                                        [SVProgressHUD dismiss];
                                    }else{
                                        char szToken[80] = {0};
                                        FUN_DevGetLocalEncToken(weakSelf.devID.UTF8String, szToken);
                                        NSString *adminToken = OCSTR(szToken);
                                        NSLog(@"cycy= 设备登录结果 %i token = %@",result,adminToken);
                                        FUN_DevLogout(0, weakSelf.devID.UTF8String);
                                        [weakSelf.devRandomPwdDataSource setValue:dic forKey:weakSelf.devID];
                                        Fun_Log((char *)"快速配置流程：登录设备成功 \n");
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            if (adminToken.length > 0 && !weakSelf.ignoreAutoSetUserNamePassword) {//如果是支持token的设备 APP自动设置一个随机用户名密码
                                                if (supportAutoChangeRandomAcc) {//支持设置随机用户名密码
                                                    
                                                    //生成随机的设备登录名和密码
                                                    NSString *autoNewUserName = [self randomStringWithLength:8];
                                                    NSString *autoNewPassword = [self randomStringWithLength:16];
                                                    Fun_Log((char *)"快速配置流程：支持设置随机用户名密码开始设置 \n");
                                                    [weakSelf ChangeRandomUserWithDevID:weakSelf.devID newUser:autoNewUserName newPassword:autoNewPassword result:^(int result, NSString *adminTokenBack, NSString *guestToken) {
                                                        if (result >= 0) {
                                                            [[DeviceManager getInstance] changeDeviceUserNamePasswordLocal:weakSelf.devID userName:autoNewUserName password:autoNewPassword];
                                                            Fun_Log((char *)"快速配置流程：设置随机用户名密码成功 \n");
                                                            Fun_DevSetLocalEncToken([weakSelf.devID UTF8String],adminTokenBack.UTF8String);
                                                            
                                                        }else{
                                                            Fun_Log((char *)"快速配置流程：设置随机用户名密码失败 \n");
                                                            Fun_DevSetLocalEncToken([weakSelf.devID UTF8String],adminToken.UTF8String);
                                                            
                                                        }
                                                        
                                                        NSMutableDictionary *dicChange = [dic mutableCopy];
                                                        [dicChange setObject:[NSNumber numberWithBool:YES] forKey:@"SupportToken"];
                                                        [weakSelf saveDevRandomPwdToLocalDataSource:dicChange];
                                                    }];
                                                }else{
                                                    NSMutableDictionary *dicChange = [dic mutableCopy];
                                                    [dicChange setObject:[NSNumber numberWithBool:YES] forKey:@"SupportToken"];
                                                    
                                                    [weakSelf saveDevRandomPwdToLocalDataSource:dicChange];
                                                }
                                            }else{
                                                
                                                [weakSelf saveDevRandomPwdToLocalDataSource:dic];
                                            }
                                        });
                                    }
                                }];
                                return;
                            }
                        }
                        NSDictionary *dic = @{@"userName":@"admin",@"password":@"",@"random":[NSNumber numberWithBool:NO]};
                        [self saveDevRandomPwdToLocalDataSource:dic];
                    }
                }else{
                    if (self.needTryAgain && !(msg->param1 == -11406 || msg->param1 == -400009)) {
                        Fun_Log((char *)"快速配置流程：获取随机用户名密码失败 立刻重试 \n");
                        self.needTryAgain = NO;
                        Fun_DevConfigJson_NotLoginPtl(self.msgHandle, CSTR(self.devID), "GetRandomUser", NULL, 1660 ,-1 ,0, 5000, 0);
                    }else{
                        Fun_Log((char *)"快速配置流程：获取随机用户名密码失败 继续下一步 \n");
                        NSDictionary *dic = @{@"userName":@"admin",@"password":@"",@"random":[NSNumber numberWithBool:NO]};
                        [self saveDevRandomPwdToLocalDataSource:dic];
                    }
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            if ([OCSTR(msg->szStr) isEqualToString:@"ChangeRandomUser"]) {
                if (self.changeRandomUserResult) {
                    //修改成功后重新获取一下随机用户名和密码
                    if(msg->param1 > 0){
                        [self getDeviceRandomPwd:self.devID autoSetUserNameAndPassword:NO Completion:nil];
                    }
                    self.changeRandomUserResult(msg->param1,@"",@"");
                }
            }
        }
            break;
        default:
            break;
    }
}

-(void)saveDevRandomPwdToLocalDataSource:(NSDictionary *)dataSource{
    [self.devRandomPwdDataSource setValue:dataSource forKey:self.devID];
    
    Fun_Log((char *)"快速配置流程：获取随机用户名密码流程结束 回调上级 \n");
    if (self.getDevPwdResult) {
        self.getDevPwdResult(YES);
    }
}

-(void)saveDevRandomPwdToLocalDataSource:(NSDictionary *)dataSource devID:(NSString *)devID{
    self.devID = devID;
    [self.devRandomPwdDataSource setValue:dataSource forKey:self.devID];
}


//MARK: 生成随机码
- (NSString *)randomStringWithLength:(NSInteger)len{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((u_int32_t)[letters length])]];
    }
    
    return randomString;
}



+(instancetype)shareInstance{
    static DeviceRandomPwdManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[DeviceRandomPwdManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.devRandomPwdDataSource = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        self.msgHandle = FUN_RegWnd((__bridge void *)self);
    }
    return self;
}

- (SystemInfoManager *)systemInfoManager{
    if (!_systemInfoManager) {
        _systemInfoManager = [[SystemInfoManager alloc] init];
    }
    
    return _systemInfoManager;
}

@end
