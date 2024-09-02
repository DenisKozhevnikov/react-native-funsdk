//
//  DeviceShareManager.m
//  FunSDKDemo
//
//  Created by yefei on 2022/10/21.
//  Copyright © 2022 yefei. All rights reserved.
//

#import "DeviceShareManager.h"
#import "ShareModel.h"
#import <CommonCrypto/CommonDigest.h>
#import <FunSDK/FunSDK2.h>

@interface DeviceShareManager ()

@property (nonatomic,assign) long long requestCount;

@property (nonatomic,copy) NSString * uName;

@property (nonatomic,copy) NSString * uPassword;

@end

@implementation DeviceShareManager



- (instancetype)init{
    self = [super init];
    if (self) {
        self.requestCount = 0;
    }
    
    return self;
}

//MARK: - 分享设备
- (void)shareDevice:(NSString *)devID toUser:(NSString *)userID permission:(NSString *)permissions comletion:(void(^)(int result))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr;
  
    requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdshareadd/v1/%@/%@.rs",timeMillis,encryptStr];
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
        
    char szPassword[80] = {0};
    FUN_DevGetLocalPwd(CSTR(dev.deviceMac), szPassword);
    char szUser[128] = {0};
    FUN_DevGetLocalUserName(dev.deviceMac.UTF8String, szUser);
    if (OCSTR(szUser).length > 0) {
        dev.loginName = OCSTR(szUser);
    }
    NSString *info = [ShareModel encodeDevId:devID userName:dev.loginName password:OCSTR(szPassword) type:dev.nType];
    if (!info) {
        info = @"";
    }
    NSString *devInfo = [self convertToJsonData:@{@"devInfo":info}];
  
    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&shareUuid=%@&acceptId=%@&powers=%@&permissions=%@",self.uName,self.uPassword,dev.deviceMac,[self xmURLEncodedString:userID],[self xmURLEncodedString:devInfo],[self xmURLEncodedString:permissions]];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                if (completion) {
                    completion(1);
                }
            }else{
                if (completion) {
                    completion(-1);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}

//MARK: - 搜索可以分享的用户
- (void)searchUser:(NSString *)userName completion:(DeviceShareSearchUserCallBack)callBack{
    self.deviceShareSearchUserCallBack = callBack;
    
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/usersearch/v1/%@/%@.rs",timeMillis,encryptStr];
    
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体
    
    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&search=%@",self.uName,self.uPassword,[self xmURLEncodedString:userName]];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (self.deviceShareSearchUserCallBack) {
                    self.deviceShareSearchUserCallBack(-1, [NSArray array]);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (self.deviceShareSearchUserCallBack) {
                    self.deviceShareSearchUserCallBack(-1, [NSArray array]);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                //获取成功
                NSArray *array = [dict objectForKey:@"data"];
                //回调给上层最终结果
                if (self.deviceShareSearchUserCallBack) {
                    self.deviceShareSearchUserCallBack(-1, array);
                }
            }else{
                if (self.deviceShareSearchUserCallBack) {
                    self.deviceShareSearchUserCallBack(-1, [NSArray array]);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}

//MARK: - 修改分享权限
- (void)changeSharedPermission:(NSString *)permission sharedUserID:(NSString *)sharedID completion:(void(^)(int result))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdsharesetpermission/v1/%@/%@.rs",timeMillis,encryptStr];
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&shareId=%@&permissions=%@",self.uName,self.uPassword,sharedID,[self xmURLEncodedString:permission]];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                if (completion) {
                    completion(1);
                }
            }else{
                if (completion) {
                    completion(-1);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}



//MARK: - 取消分享
- (void)cancelShareDeviceID:(NSString *)shareDeviceID completion:(void(^)(int result))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdsharedel/v1/%@/%@.rs",timeMillis,encryptStr];

    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体

    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&devId=%@",self.uName,self.uPassword,shareDeviceID];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                if (completion) {
                    completion(1);
                }
            }else{
                if (completion) {
                    completion(-1);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}

//MARK: - 请求我分享的设备 分享给了哪些账号 ID传空字符串 就是返回所有的分享的账号信息
- (void)requestSharedDevice:(NSString *)devID sharedInfo:(void(^)(int result,NSArray *sharedList))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdsharemylist/v1/%@/%@.rs",timeMillis,encryptStr];
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    
    //5.设置请求体

    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&shareUuid=%@",self.uName,self.uPassword,devID];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1,nil);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1,nil);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                NSArray *array = [dict objectForKey:@"data"];
                if (completion) {
                    completion(1,array);
                }
            }else{
                if (completion) {
                    completion(-1,nil);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}

//MARK: - 请求分享给我的设备列表
- (void)requestDeviceSharedToMe:(void(^)(int result,NSArray *sharedToMeList))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdsharelist/v1/%@/%@.rs",timeMillis,encryptStr];
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体
    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@",self.uName,self.uPassword];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1,nil);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1,nil);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                NSArray *array = [dict objectForKey:@"data"];
                if ([array isKindOfClass:[NSArray class]]) {
                    if (completion) {
                        completion(1,array);
                    }
                }else{
                    if (completion) {
                        completion(-1,nil);
                    }
                }
            }else{
                if (completion) {
                    completion(-1,nil);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}

//MARK: - 接受分享
- (void)acceptShareDeviceID:(NSString *)devID completion:(void(^)(int result))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdshareaccept/v1/%@/%@.rs",timeMillis,encryptStr];
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体
    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&devId=%@",self.uName,self.uPassword,devID];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                if (completion) {
                    completion(1);
                }
            }else{
                if (completion) {
                    completion(-1);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}

//MARK: - 拒绝分享
- (void)denyShareDeviceID:(NSString *)devID completion:(void(^)(int result))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdsharerefuse/v1/%@/%@.rs",timeMillis,encryptStr];
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体

    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&devId=%@",self.uName,self.uPassword,devID];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1);
                }
                return;
            }
            NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
            if ([result isEqualToString:@"success"]) {
                if (completion) {
                    completion(1);
                }
            }else{
                if (completion) {
                    completion(-1);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}


//MARK: - 主动添加来自分享的设备 通过二维码扫描等方式
- (void)addSharedDevice:(NSString *)devID shareAccountID:(NSString *)shareAccountID permission:(NSString *)permissions completion:(void(^)(int result))completion{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //2.根据会话对象创建task
    NSString *timeMillis = [self getRequestTimeMillis];
    NSString *encryptStr = [self getMD5EncryptSignatureTimeMills:timeMillis];
    NSString *requestStr = [NSString stringWithFormat:@"https://rs.xmeye.net/mdshareadd2/v1/%@/%@.rs",timeMillis,encryptStr];
    NSURL *url = [NSURL URLWithString:requestStr];
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体
    NSString * bodyString = [NSString stringWithFormat:@"uname=%@&upass=%@&shareUuid=%@&acceptId=%@&powers=&permissions=%@",self.uName,self.uPassword,devID,shareAccountID,permissions];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithUTF8String:APPUUID] forHTTPHeaderField:@"uuid"];
    [request setValue:[NSString stringWithUTF8String:APPKEY] forHTTPHeaderField:@"appKey"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //8.解析数据
            if (data == nil) {
                if (completion) {
                    completion(-1);
                }
                return ;
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *transformData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:transformData options:kNilOptions error:nil];
            if (dict == nil) {
                if (completion) {
                    completion(-1);
                }
                return;
            }
            
            if ([dict isKindOfClass:[NSDictionary class]]) {
                NSString *result = [[dict objectForKey:@"msg"] lowercaseString];
                int code = [[dict objectForKey:@"code"] intValue];
                if ([result isEqualToString:@"success"]) {
                    if (completion) {
                        completion(1);
                    }
                }else{
                    int error = -1;
                    if (code == 4101) {//不能添加自己分享的设备
                        error = -4101;
                    }else if (code == 4124){//分享的设备已经备分享者取消或者删除
                        error = -4124;
                    }
                    
                    if (completion) {
                        completion(error);
                    }
                }
            }else{
                if (completion) {
                    completion(-1);
                }
            }
        });
    }];
    
    //7.执行任务
    [dataTask resume];
}




//MARK:获取请求时间戳标记
- (NSString *)getRequestTimeMillis{
    return [[self getRequestCountStr] stringByAppendingString:[self getCurTimeStr]];
}

//MARK:获取请求次数字符串 防止并发
- (NSString *)getRequestCountStr{
    self.requestCount++;
    if (self.requestCount < 10) {
        return [NSString stringWithFormat:@"000000%lli",self.requestCount];
    }else if (self.requestCount < 100) {
        return [NSString stringWithFormat:@"00000%lli",self.requestCount];
    }else if (self.requestCount < 1000) {
        return [NSString stringWithFormat:@"0000%lli",self.requestCount];
    }else if (self.requestCount < 10000) {
        return [NSString stringWithFormat:@"000%lli",self.requestCount];
    }else if (self.requestCount < 100000) {
        return [NSString stringWithFormat:@"00%lli",self.requestCount];
    }else if (self.requestCount < 1000000) {
        return [NSString stringWithFormat:@"0%lli",self.requestCount];
    }else if (self.requestCount < 10000000) {
        return [NSString stringWithFormat:@"%lli",self.requestCount];
    }else{
        self.requestCount = 1;
        return [NSString stringWithFormat:@"000000%lli",self.requestCount];
    }
}


- (NSString *)getCurTimeStr{
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    
    long long millis = interval * 1000;
    return [NSString stringWithFormat:@"%lli",millis];
}

- (NSString *)getMD5EncryptSignatureTimeMills:(NSString *)timeMillis{
    NSString *content = [NSString stringWithFormat:@"%@%@%@%@",[NSString stringWithUTF8String:APPUUID],[NSString stringWithUTF8String:APPKEY],[NSString stringWithUTF8String:APPSECRET],timeMillis];

    //移位
    int moveCard = MOVECARD;
    NSData *dataChange = [content dataUsingEncoding:NSUTF8StringEncoding];
    Byte *changeByte = (Byte *)[dataChange bytes];
    Byte temp;
    for (int i = 0; i < [dataChange length]; i++) {
        temp = ((i % moveCard) > (([dataChange length] - i) % moveCard)) ? changeByte[i] : changeByte[[dataChange length] - (i + 1)];
        changeByte[i] = changeByte[[dataChange length] - (i + 1)];
        changeByte[[dataChange length] - (i + 1)] = temp;
    }
    
    //合并
    NSData *dataMerge = [content dataUsingEncoding:NSUTF8StringEncoding];
    Byte *mergeByte = (Byte *)[dataMerge bytes];
    int encryptLength = (int)[dataMerge length];
    int encryptLength2 = encryptLength * 2;
    Byte *mergeTemp = (Byte *)malloc(encryptLength2);
    
    for (int i = 0; i < [dataMerge length]; i++) {
        mergeTemp[i] = mergeByte[i];
        mergeTemp[encryptLength2 - 1 - i] = changeByte[i];
    }
    
    //byte数组 md5加密
    NSData *strdata = [[NSData alloc] initWithBytes:mergeTemp length:encryptLength2];
    NSString *valueStr = [[NSString alloc] initWithData:strdata encoding:NSUTF8StringEncoding];
    
    const char *value = [valueStr UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    free(mergeTemp);
    return outputString;
}

-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

//MARK:URL编码
- (NSString *)xmURLEncodedString:(NSString *)urlString {
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodeString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    
    return encodeString;
}

- (NSString *)uName{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"DemoUser"];;;
}

- (NSString *)uPassword{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"DemoPassword"];
}
@end
