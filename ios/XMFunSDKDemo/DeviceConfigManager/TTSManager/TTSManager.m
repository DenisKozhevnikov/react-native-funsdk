//
//  TTSManager.m
//  XWorld_General
//
//  Created by Megatron on 2019/12/27.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "TTSManager.h"
#import "NSString+DTPaths.h"

@implementation TTSManager

//MARK: 文字转语音
- (void)transformTextToVoice:(NSString *)content female:(BOOL)ifFemale completion:(TransformToVoiceResult)completed{
    self.transformToVoiceResult = completed;
    
    NSString *voice = ifFemale ? @"female" : @"male";
    
    NSString *urlString = [NSString stringWithFormat:@"https://tts.xmcsrv.net/tts"];
    
    //创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Request
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
        
    // 设置Request的头属性
    mutableRequest.HTTPMethod = @"POST";
        
    NSString * bodyString = [NSString stringWithFormat:@"{\"text\":\"%@\",\"voice\":\"%@\"}",content,voice];
    mutableRequest.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:mutableRequest fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil || error) {
            if (self.transformToVoiceResult) {
                self.transformToVoiceResult(-1,NO);
            }
            return ;
        }
       NSString *filePath = [[NSString documentsPath] stringByAppendingPathComponent:@"transform.wav"];
       BOOL success = [data writeToFile:[[NSString documentsPath] stringByAppendingPathComponent:@"transform.wav"] atomically:YES];
        
        long long fileSize = [self fileSizeAtPath:filePath];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        //设置每次句柄偏移量
        //[fileHandle seekToFileOffset:42*1024];
        //获取每次读入data
        BOOL fileSizeTooLarge = NO;
        if(fileSize >= 84 * 1024){
            if (fileSize > 84 *1024) {
                fileSizeTooLarge = YES;
            }
            NSData *data = [fileHandle readDataOfLength:84*1024];
            [data writeToFile:filePath atomically:YES];
        }
        else{
            //判断能否被16整除
            if (fileSize % 32 != 0) {
                fileSize = fileSize - fileSize % 32;
                NSData *data = [fileHandle readDataOfLength:fileSize];
                [data writeToFile:filePath atomically:YES];
            }
        }
        
        if (success) {
            if (self.transformToVoiceResult) {
                self.transformToVoiceResult(0,fileSizeTooLarge);
            }
        }else{
            if (self.transformToVoiceResult) {
                self.transformToVoiceResult(-1,fileSizeTooLarge);
            }
        }
    }];
    [task resume];
}

-(long long) fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager =[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil]fileSize];
    }
    
    return 0;
}

@end
