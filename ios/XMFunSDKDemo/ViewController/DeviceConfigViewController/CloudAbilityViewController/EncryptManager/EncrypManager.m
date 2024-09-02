//
//  EncrypManager.m
//  XWorld_General
//
//  Created by Megatron on 2019/10/12.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "EncrypManager.h"
#import <CommonCrypto/CommonCryptor.h>

static NSString *const kInitVector = @"3301MEGATRON";
static NSString *const DESKey = @"XMDES201910111012";

@implementation EncrypManager

+ (NSString *)encodeDesWithString:(NSString *)str{

    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];

    size_t plainTextBufferSize = [data length];

    const void *vplainText = (const void *)[data bytes];



    CCCryptorStatus ccStatus;

    uint8_t *bufferPtr = NULL;

    size_t bufferPtrSize = 0;

    size_t movedBytes = 0;



    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);

    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));

    memset((void *)bufferPtr, 0x0, bufferPtrSize);



    const void *vkey = (const void *) [DESKey UTF8String];

    const void *vinitVec = (const void *) [kInitVector UTF8String];



    ccStatus = CCCrypt(kCCEncrypt,

                      kCCAlgorithmDES,

                      kCCOptionPKCS7Padding,

                      vkey,

                      kCCKeySizeDES,

                      vinitVec,

                      vplainText,

                      plainTextBufferSize,

                      (void *)bufferPtr,

                      bufferPtrSize,

                      &movedBytes);

    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];

    NSString *result = [myData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    return result;

}

+ (NSString *)decodeDesWithString:(NSString *)str{

        NSData *encryptData = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];

        size_t plainTextBufferSize = [encryptData length];

        const void *vplainText = [encryptData bytes];



        CCCryptorStatus ccStatus;

        uint8_t *bufferPtr = NULL;

        size_t bufferPtrSize = 0;

        size_t movedBytes = 0;



        bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);

        bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));

        memset((void *)bufferPtr, 0x0, bufferPtrSize);



        const void *vkey = (const void *) [DESKey UTF8String];

        const void *vinitVec = (const void *) [kInitVector UTF8String];



        ccStatus = CCCrypt(kCCDecrypt,

                          kCCAlgorithmDES,

                          kCCOptionPKCS7Padding,

                          vkey,

                          kCCKeySizeDES,

                          vinitVec,

                          vplainText,

                          plainTextBufferSize,

                          (void *)bufferPtr,

                          bufferPtrSize,

                          &movedBytes);

        NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr

                                                                        length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];

        return result;

}

@end
