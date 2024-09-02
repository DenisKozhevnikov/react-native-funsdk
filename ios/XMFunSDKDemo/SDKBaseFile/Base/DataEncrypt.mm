//
//  DataEncrypt.m
//  FunSDKDemo
//
//  Created by zhang on 2021/9/1.
//  Copyright © 2021 zhang. All rights reserved.
//

#define ENCRYPTTYPE @"P2PDataEncrypt_zhang"

#import "DataEncrypt.h"
#import "FunSDK/FunSDK.h"

@implementation DataEncrypt

- (void)setP2PDataEncrypt:(BOOL)type {
    if (!type) {
        [[NSUserDefaults standardUserDefaults] setObject:ENCRYPTTYPE forKey:ENCRYPTTYPE];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ENCRYPTTYPE];
    }
    Fun_SetP2PDataEncryptEnable(type);
}

- (void)initP2PDataEncrypt {
    BOOL type = [self getSavedType];
    Fun_SetP2PDataEncryptEnable(type);
}
- (BOOL)getSavedType {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:ENCRYPTTYPE]) {
        return NO;
    }
    return YES;
}
@end
