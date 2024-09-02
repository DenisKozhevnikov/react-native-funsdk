//
//  PhoneInfoManager.m
//   
//
//  Created by Tony Stark on 2021/10/11.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "PhoneInfoManager.h"
#import <sys/utsname.h>

NSString * const KUserGravity = @"User_Gravity";

@implementation PhoneInfoManager

//MARK: 获取手机类型
+ (NSString *)getPhoneIdentifier{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *strName = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return strName;
}

//MARK: 获取手机屏幕对角线尺寸
+ (double)getMobilePhoneScreenDiagonalSize{
    NSString *realMobileModel = [self getRealMobileModel];
    if ([realMobileModel isEqualToString:@"Unknow"]) {
        return 0;
    }else if ([realMobileModel isEqualToString:@"iPhone 13 Pro Max"]){
        return 6.7;
    }else if ([realMobileModel isEqualToString:@"iPhone 13 Mini"]){
        return 5.4;
    }else if ([realMobileModel isEqualToString:@"iPhone 13"]){
        return 6.1;
    }else if ([realMobileModel isEqualToString:@"iPhone 13 Pro"]){
        return 6.1;
    }else if ([realMobileModel isEqualToString:@"iPhone 12 Pro Max"]){
        return 6.7;
    }else if ([realMobileModel isEqualToString:@"iPhone 12 Pro"]){
        return 6.1;
    }else if ([realMobileModel isEqualToString:@"iPhone 12"]){
        return 6.1;
    }else if ([realMobileModel isEqualToString:@"iPhone 12 mini"]){
        return 5.4;
    }else if ([realMobileModel isEqualToString:@"iPhone SE2"]){
        return 4.7;
    }else if ([realMobileModel isEqualToString:@"iPhone 11 Pro Max"]){
        return 6.5;
    }else if ([realMobileModel isEqualToString:@"iPhone 11 Pro"]){
        return 5.8;
    }else if ([realMobileModel isEqualToString:@"iPhone 11"]){
        return 6.1;
    }else if ([realMobileModel isEqualToString:@"iPhone XS Max"]){
        return 6.5;
    }else if ([realMobileModel isEqualToString:@"iPhone XS"]){
        return 5.8;
    }else if ([realMobileModel isEqualToString:@"iPhone XR"]){
        return 6.7;
    }else if ([realMobileModel isEqualToString:@"iPhone X"]){
        return 5.8;
    }else if ([realMobileModel isEqualToString:@"iPhone 8 Plus"]){
        return 5.5;
    }else if ([realMobileModel isEqualToString:@"iPhone 8"]){
        return 4.7;
    }else if ([realMobileModel isEqualToString:@"iPhone 7 Plus"]){
        return 5.5;
    }else if ([realMobileModel isEqualToString:@"iPhone 7"]){
        return 4.7;
    }else if ([realMobileModel isEqualToString:@"iPhone 6 Plus"]){
        return 5.5;
    }else if ([realMobileModel isEqualToString:@"iPhone 6"]){
        return 4.7;
    }else if ([realMobileModel isEqualToString:@"iPhone 13 Pro"]){
        return 6.7;
    }else if ([realMobileModel isEqualToString:@"iPhone SE"] || [realMobileModel hasPrefix:@"iPhone 5"]){
        return 4.0;
    }
    
    return 0;
}

//MARK: 获取手机真实型号
+ (NSString *)getRealMobileModel{
    NSString *iphoneIdentifier = [self getPhoneIdentifier];
    if ([iphoneIdentifier isEqualToString:@"iPhone3,1"]){
        return @"iPhone 4";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone3,2"]){
        return @"iPhone 4";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone3,3"]){
        return @"iPhone 4";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone4,1"]){
        return @"iPhone 4S";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone5,1"]){
        return @"iPhone 5";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone5,2"]){
        return @"iPhone 5 (GSM+CDMA)";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone5,3"]){
        return @"iPhone 5c (GSM)";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone5,4"]){
        return @"iPhone 5c (GSM+CDMA)";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone6,1"]){
        return @"iPhone 5s (GSM)";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone6,2"]){
        return @"iPhone 5s (GSM+CDMA)";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone7,1"]){
        return @"iPhone 6 Plus";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone7,2"]){
        return @"iPhone 6";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone8,1"]){
        return @"iPhone 6s";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone8,2"]){
        return @"iPhone 6s Plus";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone8,4"]){
        return @"iPhone SE";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone9,1"]){
        return @"iPhone 7";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone9,2"]){
        return @"iPhone 7 Plus";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone9,3"]){
        return @"iPhone 7";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone9,4"]){
        return @"iPhone 7 Plus";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone10,1"]){
        return @"iPhone 8";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone10,4"]){
        return @"iPhone 8";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone10,2"]){
        return @"iPhone 8 Plus";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone10,5"]){
        return @"iPhone 8 Plus";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone10,3"]){
        return @"iPhone X";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone10,6"]){
        return @"iPhone X";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone11,8"]){
        return @"iPhone XR";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone11,2"]){
        return @"iPhone XS";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone11,6"]){
        return @"iPhone XS Max";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone11,4"]){
        return @"iPhone XS Max";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone12,1"]){
        return @"iPhone 11";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone12,3"]){
        return @"iPhone 11 Pro";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone12,5"]){
        return @"iPhone 11 Pro Max";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone12,8"]){
        return @"iPhone SE2";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone13,1"]){
        return @"iPhone 12 mini";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone13,2"]){
        return @"iPhone 12";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone13,3"]){
        return @"iPhone 12 Pro";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone13,4"]){
        return @"iPhone 12 Pro Max";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone14,3"]){
        return @"iPhone 13 Pro Max";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone14,5"]){
        return @"iPhone 13";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone14,4"]){
        return @"iPhone 13 Mini";
    }else if ([iphoneIdentifier isEqualToString:@"iPhone14,2"]){
        return @"iPhone 13 Pro";
    }
    
    return @"Unknow";
}

//MARK: 获取手机物理尺寸
+ (CGSize)getRealResolutionRatioSize{
    NSString *realMobileModel = [self getRealMobileModel];
    if ([realMobileModel isEqualToString:@"Unknow"]) {
        return [[UIScreen mainScreen] currentMode].size;
    }else if ([realMobileModel isEqualToString:@"iPhone 13 Pro Max"]){
        return CGSizeMake(1284, 2778);
    }else if ([realMobileModel isEqualToString:@"iPhone 13 Mini"]){
        return CGSizeMake(1080, 2340);
    }else if ([realMobileModel isEqualToString:@"iPhone 13"]){
        return CGSizeMake(1170, 2532);
    }else if ([realMobileModel isEqualToString:@"iPhone 13 Pro"]){
        return CGSizeMake(1170, 2532);
    }else if ([realMobileModel isEqualToString:@"iPhone 12 Pro Max"]){
        return CGSizeMake(1284, 2778);
    }else if ([realMobileModel isEqualToString:@"iPhone 12 Pro"]){
        return CGSizeMake(1170, 2532);
    }else if ([realMobileModel isEqualToString:@"iPhone 12"]){
        return CGSizeMake(1170, 2532);
    }else if ([realMobileModel isEqualToString:@"iPhone 12 mini"]){
        return CGSizeMake(1080, 2340);
    }else if ([realMobileModel isEqualToString:@"iPhone SE2"]){
        return CGSizeMake(750, 1334);
    }else if ([realMobileModel isEqualToString:@"iPhone 11 Pro Max"]){
        return CGSizeMake(1242, 2688);
    }else if ([realMobileModel isEqualToString:@"iPhone 11 Pro"]){
        return CGSizeMake(1125, 2436);
    }else if ([realMobileModel isEqualToString:@"iPhone 11"]){
        return CGSizeMake(828, 1792);
    }else if ([realMobileModel isEqualToString:@"iPhone XS Max"]){
        return CGSizeMake(1242, 2688);
    }else if ([realMobileModel isEqualToString:@"iPhone XS"]){
        return CGSizeMake(1125, 2436);
    }else if ([realMobileModel isEqualToString:@"iPhone XR"]){
        return CGSizeMake(828, 1792);
    }else if ([realMobileModel isEqualToString:@"iPhone X"]){
        return CGSizeMake(1125, 2436);
    }else if ([realMobileModel hasPrefix:@"iPhone 8"] && [realMobileModel hasSuffix:@"Plus"]){
        return CGSizeMake(1080, 1920);
    }else if ([realMobileModel isEqualToString:@"iPhone 8"]){
        return CGSizeMake(750, 1334);
    }else if ([realMobileModel hasPrefix:@"iPhone 7"] && [realMobileModel hasSuffix:@"Plus"]){
        return CGSizeMake(1080, 1920);
    }else if ([realMobileModel isEqualToString:@"iPhone 7"]){
        return CGSizeMake(750, 1334);
    }else if ([realMobileModel hasPrefix:@"iPhone 6"] && [realMobileModel hasSuffix:@"Plus"]){
        return CGSizeMake(1080, 1920);
    }else if ([realMobileModel isEqualToString:@"iPhone 6"]){
        return CGSizeMake(750, 1334);
    }else if ([realMobileModel isEqualToString:@"iPhone SE"] || [realMobileModel hasPrefix:@"iPhone 5"]){
        return CGSizeMake(640, 1136);
    }
    
    return [[UIScreen mainScreen] currentMode].size;
}

//MARK: 生成随机码
+ (NSString *)randomStringWithLength:(NSInteger)len{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((u_int32_t)[letters length])]];
    }
    
    return randomString;
}

//MARK: 获取手机刘海的高度
+ (CGFloat)heightOfBangs{
    CGFloat safeAreaTopHeight = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        safeAreaTopHeight = window.safeAreaInsets.top;
    }
    
    return safeAreaTopHeight;
}



@end
