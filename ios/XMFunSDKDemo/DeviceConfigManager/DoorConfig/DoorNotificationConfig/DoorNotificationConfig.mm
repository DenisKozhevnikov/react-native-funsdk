//
//  DoorNotificationConfig.m
//  FunSDKDemo
//
//  Created by XM on 2019/4/17.
//  Copyright © 2019年 XM. All rights reserved.
//

#import "DoorNotificationConfig.h"
#import "Consumer_DoorLockAuthManage.h"

@interface DoorNotificationConfig ()
{
    JObjArray<Consumer_DoorLockAuthManage> config;      //消息推送管理
}
@end

@implementation DoorNotificationConfig
- (BOOL)checkConfig {
    if (config.Size() == 0) {
        return NO;
    }
    return YES;
}
#pragma mark - 获取消息推送管理信息
- (void)getDoorNotificationConfig {
    //获取通道
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    config.SetName(JK_Consumer_DoorLockAuthManage);
    [self AddConfig:[CfgParam initWithName:channel.deviceMac andConfig:&config andChannel:-1 andCfgType:CFG_GET_SET]];
    
    [self GetConfig];
}
#pragma mark 设置消息推送管理信息
- (void)setDoorNotificationConfig {
    [self SetConfig];
}


#pragma mark - 获取配置回调
-(void)OnGetConfig:(CfgParam *)param{
    [super OnGetConfig:param];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:config.Name()]]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(DoorNotificationConfigGetResult:)]) {
            [self.delegate DoorNotificationConfigGetResult:param.errorCode];
        }
    }
}
#pragma mark  保存配置回调
-(void)OnSetConfig:(CfgParam *)param{
    if ([param.name isEqualToString:NSSTR(config.Name())]) {
        if ([self.delegate respondsToSelector:@selector(DoorNotificationConfigSetResult:)]) {
            [self.delegate DoorNotificationConfigSetResult:param.errorCode];
        }
    }
}

#pragma mark - 获取密码数量
- (int)checkPasswordAdmin {//管理员密码
    return config[0].mPassWdManger.Admin.Size();
}
- (int)checkPasswordGeneral {//普通成员密码
    return config[0].mPassWdManger.General.Size();
}
- (int)checkPasswordGuest { //宾客
    return config[0].mPassWdManger.Guest.Size();
}
- (int)checkPasswordTemporary { //临时
    return config[0].mPassWdManger.Temporary.Size();
}
- (int)checkPasswordForce { //强制
    return config[0].mPassWdManger.Force.Size();
}

#pragma mark - 获取管理员密码信息
- (NSMutableArray*)getPasswordAdmin {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    //1、先判断是否有密码数据，如果有，有几个
    for (int i =0; i< [self checkPasswordAdmin]; i++) {
        //读取名称和消息推送开关
        NSString *name = NSSTR(config[0].mPassWdManger.Admin[i].NickName.Value());
        NSNumber *enable = [NSNumber numberWithBool:config[0].mPassWdManger.Admin[i].MessagePushEnable.Value()];
        //存入字典
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",enable,@"enable", nil];
        //添加进管理员数组
        [array addObject:dic];
    }
    return array;
}
//普通用户密码信息
- (NSMutableArray*)getPasswordGeneral {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i =0; i< [self checkPasswordGeneral]; i++) {
        NSString *name = NSSTR(config[0].mPassWdManger.General[i].NickName.Value());
        NSNumber *enable = [NSNumber numberWithBool:config[0].mPassWdManger.General[i].MessagePushEnable.Value()];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",enable,@"enable", nil];
        [array addObject:dic];
    }
    return array;
}
//宾客密码信息
- (NSMutableArray*)getPasswordGuest {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i =0; i< [self checkPasswordGuest]; i++) {
        NSString *name = NSSTR(config[0].mPassWdManger.Guest[i].NickName.Value());
        NSNumber *enable = [NSNumber numberWithBool:config[0].mPassWdManger.Guest[i].MessagePushEnable.Value()];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",enable,@"enable", nil];
        [array addObject:dic];
    }
    return array;
}
//临时密码信息
- (NSMutableArray*)getPasswordTemporary {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i =0; i< [self checkPasswordTemporary]; i++) {
        NSString *name = NSSTR(config[0].mPassWdManger.Temporary[i].NickName.Value());
        NSNumber *enable = [NSNumber numberWithBool:config[0].mPassWdManger.Temporary[i].MessagePushEnable.Value()];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",enable,@"enable", nil];
        [array addObject:dic];
    }
    return array;
}
//强拆密码信息
- (NSMutableArray*)getPasswordForce {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i =0; i< [self checkPasswordForce]; i++) {
        NSString *name = NSSTR(config[0].mPassWdManger.Force[i].NickName.Value());
        NSNumber *enable = [NSNumber numberWithBool:config[0].mPassWdManger.Force[i].MessagePushEnable.Value()];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",enable,@"enable", nil];
        [array addObject:dic];
    }
    return array;
}

#pragma mark - 设置密码消息推送信息
- (void)setPasswordAdmin:(NSMutableArray*)array {
    //先判断获取到的数据中有几条管理员密码信息
    for (int i =0; i< [self checkPasswordAdmin]; i++) {
        //如果数组元素数量大于当前处理值
        if (array.count >i) {
            NSMutableDictionary *dic = [array objectAtIndex:i];
            //设置消息推送开关
            config[0].mPassWdManger.Admin[i].MessagePushEnable = [[dic objectForKey:@"enable"] boolValue];
        }
    }
}
- (void)setPasswordGeneral:(NSMutableArray*)array {
    for (int i =0; i< [self checkPasswordGeneral]; i++) {
        if (array.count >i) {
            NSMutableDictionary *dic = [array objectAtIndex:i];
            config[0].mPassWdManger.General[i].MessagePushEnable = [[dic objectForKey:@"enable"] boolValue];
        }
    }
}
- (void)setPasswordGuest:(NSMutableArray*)array {
    for (int i =0; i< [self checkPasswordGuest]; i++) {
        if (array.count >i) {
            NSMutableDictionary *dic = [array objectAtIndex:i];
            config[0].mPassWdManger.Guest[i].MessagePushEnable = [[dic objectForKey:@"enable"] boolValue];
        }
    }
}
- (void)setPasswordTemporary:(NSMutableArray*)array {
    for (int i =0; i< [self checkPasswordTemporary]; i++) {
        if (array.count >i) {
            NSMutableDictionary *dic = [array objectAtIndex:i];
            config[0].mPassWdManger.Temporary[i].MessagePushEnable = [[dic objectForKey:@"enable"] boolValue];
        }
    }
}
- (void)setPasswordForce:(NSMutableArray*)array {
    for (int i =0; i< [self checkPasswordForce]; i++) {
        if (array.count >i) {
            NSMutableDictionary *dic = [array objectAtIndex:i];
            config[0].mPassWdManger.Force[i].MessagePushEnable = [[dic objectForKey:@"enable"] boolValue];
        }
    }
}
@end
