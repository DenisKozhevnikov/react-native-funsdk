//
//  UserAccountModel.m
//  MobileVideo
//
//  Created by XM on 2018/4/23.
//  Copyright © 2018年 XM. All rights reserved.
//
#import "FunSDK/FunSDK.h"

#import "UserAccountModel.h"
#import "DeviceManager.h"
#import "AlarmManager.h"
#import "DeviceRandomPwdManager.h"

@implementation UserAccountModel
- (id)init {
    self = [super init];
    if (self) {
        //逻辑思路：确认每次登录账号之前，已经退出上次的登录初始化操作即可
        [self loginOut];
    }
    return self;
}
#pragma mark 用户名登陆
- (void)loginWithName:(NSString *)userName andPassword:(NSString *)psw {
    //初始化将要链接的服务器信息（，只是IP信息赋值，没有回调）
    FUN_SysInit("arsp.xmeye.net;arsp1.xmeye.net;arsp2.xmeye.net", 15010);
    //初始化底层库Net网络相关（没有回调）
    FUN_InitNetSDK();
    
    //账号登陆接口（有回调） self.msgHandle(model句柄，区分是哪一个model)
    FUN_SysGetDevList(self.msgHandle, SZSTR(userName) , SZSTR(psw),0);
    
    //暂存登陆模式
    [[LoginShowControl getInstance] setLoginType:loginTypeCloud];
    //云登陆需要暂存登陆账号密码
    [[LoginShowControl getInstance] setLoginUserName:userName password:psw];
    
    [self initLogServer];
}

- (void)loginWithTypeLocal {
    //初始化底层库Net网络相关（没有回调）
    FUN_InitNetSDK();
    
    FUN_SysInit([[NSString GetDocumentPathWith:@"LocalDB.db"] UTF8String]);
    //Fun_SysAddDevByFile(self.msgHandle, [[NSString GetCachesPathWith:@"LocalDB.db"] UTF8String],0);
    FUN_SysGetDevList(self.msgHandle,"" ,"",0);
    //设置登陆模式
    [[LoginShowControl getInstance] setLoginType:loginTypeLocal];
    
    [self initLogServer];
}

//这个方法是为了保存APP运行日志文件，可以注释
- (void)initLogServer{
    NSString *serverIP;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    serverIP=[userDefault objectForKey:@"LOG_SERVER_IP"];
    if (serverIP == nil || [serverIP length] <= 0) {
        serverIP = @"123.59.14.61";
        [userDefault setObject:serverIP forKey:@"LOG_SERVER_IP"];
    }
    
    NSString *serverPort;
    serverPort=[userDefault objectForKey:@"LOG_SERVER_PORT"];
    if (serverPort == nil || [serverPort length] <= 0) {
        serverPort=@"9911";
        [userDefault setObject:serverPort forKey:@"LOG_SERVER_PORT"];
    }
    
    NSString *nType;
    nType=[userDefault objectForKey:@"LOG_SERVER_TYPE"];
    if (nType == nil || [nType length]<= 0) {
        nType=@"3";
        [userDefault setObject:nType forKey:@"LOG_SERVER_TYPE"];
    }
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray lastObject];
    path = [path stringByAppendingPathComponent:@"log.txt"];
    const char *logFile = [path UTF8String];
    FunMsgListener *listener = [[FunMsgListener alloc]init];
    Fun_LogInit(listener.msgHandle, [serverIP UTF8String], [serverPort intValue], logFile, [nType intValue]);
    
}

- (void)loginWithTypeAP {
    FUN_InitNetSDK();
    FUN_SysInitAsAPModel([[NSString GetDocumentPathWith:@"SSID"] UTF8String]);
    
    // 判断直连设备的类型
    NSString *sn;
    NSString *sid = [NSString getCurrent_SSID];
    if ([sid hasPrefix:@"socket"]) {
        sn = @"172.16.10.1:9001";
    }else{
        sn = @"192.168.10.1:34567";
    }
    
    SDBDeviceInfo devInfo = {0};
    NSData* gb2312data = [NSString AutoCopyUTF8Str:[NSString getCurrent_SSID]];
    [gb2312data getBytes:devInfo.Devname length:sizeof(devInfo.Devname)];
    STRNCPY(devInfo.loginName, SZSTR(@"admin"));
    STRNCPY(devInfo.loginPsw, SZSTR(@""));
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //判断是否为随机用户名密码设备
        __weak typeof(self) weakSelf = self;
        [[DeviceRandomPwdManager shareInstance] getDeviceRandomPwd:sn autoSetUserNameAndPassword:YES Completion:^(BOOL completion) {
            [SVProgressHUD dismiss];
            NSMutableDictionary * dic = [[[DeviceRandomPwdManager shareInstance] getDeviceRandomPwdFromLocal:sn] mutableCopy];
            NSString *sRandomUser = [dic objectForKey:@"username"];
            NSString *sRandomPwd = [dic objectForKey:@"password"];
            BOOL random = [[dic objectForKey:@"random"] boolValue];
            if (random == YES)
            {
                [weakSelf apConnectWithUserName:sRandomUser passWord:sRandomPwd];
            }else{
                [weakSelf apConnectWithUserName:@"" passWord:@""];
            }
        }];
    });
    
    
    
//    SDBDeviceInfo devInfo = {0};
//    NSData* gb2312data = [NSString AutoCopyUTF8Str:[NSString getCurrent_SSID]];
//    [gb2312data getBytes:devInfo.Devname length:sizeof(devInfo.Devname)];
//    STRNCPY(devInfo.loginName, SZSTR(@"admin"));
//    STRNCPY(devInfo.loginPsw, SZSTR(@""));
//    // 判断直连设备的类型
//    NSString *sid = [NSString getCurrent_SSID];
//    if ([sid hasPrefix:@"socket"]) {
//        devInfo.nType = 1;
//        devInfo.nPort = 9001;
//        strcpy(devInfo.Devmac, "172.16.10.1:9001");
//    }
//    else{
//        devInfo.nType = 0;
//        devInfo.nPort = 34567;
//        strcpy(devInfo.Devmac, "192.168.10.1:34567");
//    }
//    FUN_SysAdd_Device(self.msgHandle, &devInfo);
//
//    FUN_SysGetDevList(self.msgHandle, "", "",0);
//
//    //设置登陆模式
//    [[LoginShowControl getInstance] setLoginType:loginTypeAP];
}

-(void)apConnectWithUserName:(NSString *)userName passWord:(NSString *)passWord{
    NSString *sn = @"192.168.10.1";
    int devType = 0;
    
    SDBDeviceInfo devInfo = {0};
    NSData* gb2312data = [NSString AutoCopyUTF8Str:[NSString getCurrent_SSID]];
    [gb2312data getBytes:devInfo.Devname length:sizeof(devInfo.Devname)];
    STRNCPY(devInfo.loginName, SZSTR(@"admin"));
    STRNCPY(devInfo.loginPsw, SZSTR(@""));
    
    // 判断直连设备的类型
    NSString *sid = [NSString getCurrent_SSID];
    if ([sid hasPrefix:@"socket"]) {
        devInfo.nType = devType;
        devInfo.nPort = 9001;
        strcpy(devInfo.Devmac, "172.16.10.1:9001");
    }
    else{
        devInfo.nType = devType;
        devInfo.nPort = 34567;
        strcpy(devInfo.Devmac, "192.168.10.1:34567");
    }
    
    if (userName.length == 0 && passWord.length == 0) {
        STRNCPY(devInfo.loginName, SZSTR(@"admin"));
        STRNCPY(devInfo.loginPsw, SZSTR(@""));
        //不是随即用户名密码设备,本地密码置空
        FUN_DevSetLocalPwd(devInfo.Devmac, "admin", "");
    }else{
        STRNCPY(devInfo.loginName, SZSTR(userName));
        STRNCPY(devInfo.loginPsw, SZSTR(passWord));
        
        FUN_DevSetLocalPwd(devInfo.Devmac, [userName UTF8String], [passWord UTF8String]);
    }

    FUN_SysAdd_Device(self.msgHandle, &devInfo);
    FUN_SysGetDevList(self.msgHandle, "", "",0);
    
    //设置登陆模式
    [[LoginShowControl getInstance] setLoginType:loginTypeAP];
}

#pragma mark 登出  login out
- (void)loginOut {
    // clean up SDK
    FUN_UnInitNetSDK();
}

#pragma mark 通过邮箱或者手机号获取验证码
- (void)getCodeWithPhoneOrEmailNumber:(NSString *)phoneEmail {
    if ([phoneEmail containsString:@"@"]) {
        //获取邮箱验证码
        FUN_SysSendEmailCode(self.msgHandle, [phoneEmail UTF8String], 0);
    }else{
        //获取手机验证码
        FUN_SysSendPhoneMsg(self.msgHandle, [@"" UTF8String], [phoneEmail UTF8String], 0);
    }
}
#pragma mark 通过邮箱或者手机号注册，直接注册的话，code和手机号邮箱设置为空""
- (void)registerUserName:(NSString *)username password:(NSString *)psw code:(NSString *)code PhoneOrEmail:(NSString *)phoneEmail {
    FUN_SysRegUserToXM(self.msgHandle, [username UTF8String], [psw UTF8String], [code UTF8String], [phoneEmail  UTF8String], 0);
}
#pragma mark 忘记密码 获取验证码
-(int)fogetPwdWithPhoneNum:(NSString *)phoneNum{
    if ([phoneNum containsString:@"@"]) {
        //该邮箱是否已经注册
      return FUN_SysSendCodeForEmail(self.msgHandle, [phoneNum UTF8String], 0);
    }else{
        //该手机号是否已经注册
        return FUN_SysForgetPwdXM(self.msgHandle, [phoneNum UTF8String], 0);
    }

}

#pragma mark 修改用户密码
- (void)changePassword:(NSString *)userName oldPassword:(NSString *)oldPsw newPsw:(NSString *)newPsw {
    FUN_SysPsw_Change(self.msgHandle, [userName UTF8String], [oldPsw UTF8String], [newPsw UTF8String]);
}

#pragma mark 检查验证码的合法性,找回密码之前需要验证
- (void)checkCode:(NSString *)phoneEmail code:(NSString *)code {
    if ([phoneEmail containsString:@"@"]) {
        //邮箱验证码合法性
        FUN_SysCheckCodeForEmail(self.msgHandle, [phoneEmail UTF8String], [code UTF8String],  0);
    }else{
        //手机验证码合法性
        FUN_CheckResetCodeXM(self.msgHandle, [phoneEmail UTF8String], [code UTF8String],  0);
    }
}
#pragma mark 找回用户登录密码
- (void)resetPassword:(NSString *)phoneEmail newPassword:(NSString *)psw {
    if ([phoneEmail containsString:@"@"]) {
        //通过邮箱进行重置
        FUN_SysChangePwdByEmail(self.msgHandle, [phoneEmail UTF8String], [psw UTF8String],  0);
    }else{
        //通过手机进行重置
        FUN_ResetPwdXM(self.msgHandle, [phoneEmail UTF8String], [psw UTF8String],  0);
    }
}

#pragma mark 请求账户信息（是否绑定手机号或者邮箱）
- (void)requestAccountInfo
{
    FUN_SysGetUerInfo(self.msgHandle, "", "", 0);
}

#pragma mark 获取验证码 (绑定手机号或者邮箱需要)
- (void)getBindingPhoneEmailCode:(NSString *)username password:(NSString *)psw PhoneOrEmail:(NSString *)phoneEmail
{
    if ([phoneEmail containsString:@"@"]) {
        //通过邮箱获取验证码
        FUN_SysSendBindingEmailCode(self.msgHandle, [phoneEmail UTF8String], [username UTF8String], [psw UTF8String], 0);
    }
    else{
        //通过手机获取验证码
        FUN_SysSendBindingPhoneCode(self.msgHandle,[phoneEmail UTF8String], [username UTF8String], [psw UTF8String], 0);
    }
}

#pragma mark 绑定手机或者邮箱
- (void)bindPhoneEmail:(NSString *)username password:(NSString *)psw PhoneOrEmail:(NSString *)phoneEmail code:(NSString *)code
{
    if ([phoneEmail containsString:@"@"]) {
        //绑定邮箱
        FUN_SysBindingEmail(self.msgHandle, [username UTF8String], [psw UTF8String], [phoneEmail UTF8String], [code UTF8String], 0);
    }
    else{
        //绑定手机
        FUN_SysBindingPhone(self.msgHandle , [username UTF8String],  [psw UTF8String], [phoneEmail UTF8String], [code UTF8String], 0);
    }
}

#pragma mark 删除账号 code：验证码
- (void)deleteAccount:(NSString*)code {
    FUN_SysCancellationAccount(self.msgHandle, [code UTF8String], 0);
}


#pragma mark - 网络请求回调接口 有回调信息的所有FUN接口都会回调进这个方法
- (void)OnFunSDKResult:(NSNumber *) pParam {
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    NSLog(@"sender: %d", msg->sender);
    NSLog(@"id: %d", msg->id);
    NSLog(@"param1: %d", msg->param1);
    NSLog(@"param2: %d", msg->param2);
    NSLog(@"param3: %d", msg->param3);
    NSLog(@"szStr: %s", msg->szStr);
    NSLog(@"pObject: %s", msg->pObject);
    NSLog(@"nDataLen: %d", msg->nDataLen);
    NSLog(@"seq: %d", msg->seq);
    NSLog(@"pMsg: %p", msg->pMsg);
    
    
    switch (msg->id) {
#pragma mark  账号登陆结果回调信息
        case EMSG_SYS_GET_DEV_INFO_BY_USER:{
            if (msg->param1 < 0){
                //用户名登录失败，根据错误信息msg->param1判断错误类型
                if (msg->param1 == EE_PASSWORD_NOT_VALID)
                {
                    //密码错误示例
                }
            }else{
                // 初始化报警服务器
                [[AlarmManager getInstance] initServer:[[[LoginShowControl getInstance] getPushToken] UTF8String]];
                
                
                //用户名登录成功，返回用户名下的设备列表信息，保存到APP缓存和本地存储中
                [[DeviceManager getInstance]  resiveDevicelist:[NSMessage SendMessag:nil obj:msg->pObject p1:msg->param1 p2:0]];
                //获取用户名下的别人分享给自己的设备
                [[DeviceManager getInstance] getShareToMeList];
                
/*
 *
 *如果需要别人分享给这个账号的设备一起回调给APP，则在 EMSG_SYS_GET_DEV_INFO_BY_USER 回调结果为成功时(msg->param1 > 0) 可以改为执行下面的方法，方法执行完毕之后，devData中的数据就是设备列表Json数据，包括”mine“本账号设备列表和”share“字段别人分享给自己的设备列表
 回调json参数APP需要用到的参数说明：
 account 设备所属账号 （其他账户分享给自己的设备才有）
 uuid 设备序列号
 type 设备类型
 nickname 设备名称
 username 设备登录名
 password 设备密码
 port 端口号
 */
                char devJson[750*500];
                FUN_GetFunStrAttr(EFUN_ATTR_GET_USER_ACCOUNT_DATA_INFO, devJson, 750*500);
                NSLog(@"包含当前账号的设备列表和其他用户分享给自己的设备列表json数据 = %s",devJson);
                
                
                
                
            }
            //用户登录回调
            if ([self.delegate respondsToSelector:@selector(loginWithNameDelegate:)]) {
                [self.delegate loginWithNameDelegate:msg->param1];
            }
        }
            break;
        case EMSG_SYS_ADD_DEV_BY_FILE:{
            //本地登录
            FUN_SysGetDevList(self.msgHandle, "", "");
        }
#pragma mark 收到通过邮箱注册账户结果消息
        case EMSG_SYS_REGISTE_BY_EMAIL:
#pragma mark 收到通过手机注册账户结果消息
        case EMSG_SYS_REGISER_USER_XM:
#pragma mark 收到直接注册账户结果消息
        case EMSG_SYS_NO_VALIDATED_REGISTER_EXTEND:
        {
            if (msg->param1 >=0) {
                //注册成功
            }else{
                //注册失败，错误信息msg->param1
            }
            //用户注册回调
            if ([self.delegate respondsToSelector:@selector(registerUserNameDelegateResult:)]) {
                [self.delegate registerUserNameDelegateResult:msg->param1];
            }
        }
            break;
            
#pragma mark 获取验证码结果
        case EMSG_SYS_SEND_EMAIL_CODE:
        case EMSG_SYS_GET_PHONE_CHECK_CODE:{
            if (msg->param1 >= 0) {
                //获取验证码成功，手机或者邮箱将会收到验证码
            }else{
                //获取验证码失败，可以选择是否跳过验证码直接进行注册
                if(msg->param1 !=EE_AS_PHONE_CODE2&&msg->param1!=EE_AS_SEND_EMAIL_CODE3){
                    //手机号或者邮箱已经被注册
                }
            }
            //获取验证码回调
            if ([self.delegate respondsToSelector:@selector(getCodeDelegateResult:)]) {
                [self.delegate getCodeDelegateResult:msg->param1];
            }
        }
            break;
#pragma mark 忘记密码 收到验证码（邮箱\手机）
        case EMSG_SYS_SEND_EMAIL_FOR_CODE:
        case EMSG_SYS_FORGET_PWD_XM:
        {
            if (msg->param1 >= 0) {
                //获取验证码成功，手机或者邮箱将会收到验证码
            }else{
                //获取验证码失败
            }
            //获取验证码回调
            if ([self.delegate respondsToSelector:@selector(forgetPwdGetCodeDelegateResult:userName:)]) {
                [self.delegate forgetPwdGetCodeDelegateResult:msg->param1 userName:[NSString stringWithUTF8String:msg->szStr]];
            }
        }
            break;
#pragma mark 手机号和邮箱验证码校验回调
        case EMSG_SYS_CHECK_CODE_FOR_EMAIL:
        case EMSG_SYS_REST_PWD_CHECK_XM:
        {
            [SVProgressHUD dismiss];
            if (msg->param1 < 0) {
                //验证码校验失败
            }else{
                //验证码校验成功
            }
            //验证码校验合法性回调
            if ([self.delegate respondsToSelector:@selector(checkCodeDelegateResult:)]) {
                [self.delegate checkCodeDelegateResult:msg->param1];
            }
        }
            break;
            
#pragma mark 通过邮箱和手机号找回密码回调
        case  EMSG_SYS_PSW_CHANGE_BY_EMAIL:
        case  EMSG_SYS_RESET_PWD_XM:
        {
            if (msg->param1 < 0) {
                //修改密码失败
            }else{
                //回调成功，找回密码成功，已经修改为新的密码
            }
            //找回密码重置密码回调
            if ([self.delegate respondsToSelector:@selector(resetPasswordDelegateResult:)]) {
                [self.delegate resetPasswordDelegateResult:msg->param1];
            }
        }
            break;
            
#pragma mark 修改密码结果
        case EMSG_SYS_PSW_CHANGE:
        {
            [SVProgressHUD dismiss];
            if (msg->param1 < 0){
                //修改密码失败
            }else{
                //修改密码成功
            }
            //修改密码回调
            if ([self.delegate respondsToSelector:@selector(changePasswordDelegateResult:)]) {
                [self.delegate changePasswordDelegateResult:msg->param1];
            }
        }
            break;
#pragma mark 请求账户信息（是否绑定手机号或者邮箱）
        case EMSG_SYS_GET_USER_INFO:
        {
            [SVProgressHUD dismiss];
            NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
            if(msg->param1 >= 0)
            {
                char *result = (char *)msg->szStr;
                // 将c的jason字符串转化为NSData
                NSData *resultData = [NSData dataWithBytes:result length:strlen(result)];
                
                // 将NSData转化为字典
                NSError *error;
                userInfoDic = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
            
            }
            
            if ([self.delegate respondsToSelector:@selector(getUserInfo:result:)]) {
                [self.delegate getUserInfo:userInfoDic result:msg->param1];
            }
        }
            break;
#pragma mark 获取验证码回调（绑定邮箱/手机）
        case EMSG_SYS_SEND_BINDING_EMAIL_CODE:
        case EMSG_SYS_SEND_BINDING_PHONE_CODE:
        {
            [SVProgressHUD dismiss];
            if (msg->param1 < 0){
                //获取验证码失败
            }else{
                //获取验证码成功
            }
            //获取验证码回调
            if ([self.delegate respondsToSelector:@selector(getCodeForBindPhoneEmailResult:)]) {
                [self.delegate getCodeForBindPhoneEmailResult:msg->param1];
            }
        }
            break;
#pragma mark 绑定邮箱/手机回调
        case EMSG_SYS_BINDING_EMAIL:
        case EMSG_SYS_BINDING_PHONE:
        {
            [SVProgressHUD dismiss];
            if (msg->param1 < 0){
                //绑定邮箱/手机失败
            }else{
                //绑定邮箱/手机成功
            }
            //修改密码回调
            if ([self.delegate respondsToSelector:@selector(bindPhoneEmailResult:)]) {
                [self.delegate bindPhoneEmailResult:msg->param1];
            }
        }
            break;
#pragma mark Delete Account  删除账号
        case EMSG_SYS_CANCELLATION_USER_XM:
        {
            if (msg->param1 < 0) {
                if (msg->param1 == -604302 && (OCSTR(msg->szStr).length > 0)) {
                    [SVProgressHUD dismiss];
                    //需要验证码才能删除，msg->szStr中有回调信息
                    if ([self.delegate respondsToSelector:@selector(deleteAccountResult:)]) {
                        [self.delegate deleteAccountResult:0];
                    }
                }
                else if (msg->param1 == -604302)
                {
                    [SVProgressHUD showErrorWithStatus:TS("Account cannot be deleted")];
                }
                else if (msg->param1 == -604402)
                {
                    [SVProgressHUD showErrorWithStatus:TS("Get code too many times")];
                }
                else
                {
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }else
            {
                [SVProgressHUD showSuccessWithStatus:TS("Delete account success")];
            }
        }
            break;
        default:
            break;
    }
}

@end
