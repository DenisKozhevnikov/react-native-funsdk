//
//  FunSDKRegisterModule.m
//  react-native-funsdk
//
//  Created by Денис Кожевников on 18.08.2024.
//

#import "FunSDKRegisterModule.h"
#import "FunSDK/FunSDK.h"
#import "UserAccountModel.h"

@interface FunSDKRegisterModule()<UserAccountModelDelegate>
{
    UserAccountModel *accountModel; // Менеджер аутентификации
}

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *resolvers;

@end

@implementation FunSDKRegisterModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

#pragma - mark Регистрация без почты/телефона
RCT_EXPORT_METHOD(registerByNotBind:(NSDictionary *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *username = params[@"username"];
    NSString *password = params[@"password"];
    
    if (!self.resolvers) {
        self.resolvers = [NSMutableDictionary dictionary];
    }
    
    NSNumber *key = @(EMSG_SYS_REGISER_USER_XM);
    
    // Сохраняем блоки resolve и reject в маппинг
    self.resolvers[key] = @{@"resolve": resolve, @"reject": reject};
    
    if (!accountModel) {
        accountModel = [[UserAccountModel alloc] init];
        accountModel.delegate = self;
    }
    
    [accountModel registerUserName:username password:password code:@"" PhoneOrEmail:@""];
}

-(void)registerUserNameDelegateResult:(long)reslut
{
    
    NSNumber *key = @(EMSG_SYS_REGISER_USER_XM);
    
    NSDictionary *callbacks = self.resolvers[key];
    
    if (callbacks) {
        if (reslut >= 0) {
            RCTPromiseResolveBlock resolve = callbacks[@"resolve"];
            resolve(key);
        } else {
            RCTPromiseRejectBlock reject = callbacks[@"reject"];

            NSString *errorString = [NSString stringWithFormat:@"%d %ld", EMSG_SYS_REGISER_USER_XM, reslut];
            reject(@"login_error", errorString, [NSError errorWithDomain:@"FunSDK" code:reslut userInfo:nil]);
        }
        
        [self.resolvers removeObjectForKey:key];
    }
}


@end
